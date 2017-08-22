/*SQL(postgreSQL) query used to analyze customer funnel by cohort (users signed in at same month) with user log data.
the "event" table that stored user log data is created from data source http://downloads.dataiku.com/tutorials/v2.0/TUTORIAL_CHURN/events.csv.gz*,
"product" table is created using data source http://downloads.dataiku.com/tutorials/v2.0/TUTORIAL_CHURN/products.csv.gz*/

--user sign in date 
CREATE VIEW user_first_date AS 
SELECT user_id,CAST(ts AS DATE) sign_up_date
FROM (SELECT user_id,
	     ts,
	     ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ts) record_num
      FROM event)sub
WHERE record_num = 1;

--tag user_id with cohort in event table 
CREATE VIEW event_cohort AS
SELECT e.*, 
       CONCAT(DATE_PART('year', u.sign_up_date),'-',DATE_PART('month', u.sign_up_date)) cohort
 FROM event e
 JOIN user_first_date u ON u.user_id = e.user_id;

--total new users per cohort
CREATE VIEW cohort_users AS
SELECT CONCAT(DATE_PART('year', sign_up_date), '-',  DATE_PART('month', sign_up_date)) cohort,
       COUNT(user_id) total_users
 FROM user_first_date
GROUP BY DATE_PART('year', sign_up_date), DATE_PART('month', sign_up_date);
 

/*activation*/
-- MAU by cohort
COPY (
SELECT c.cohort,
       CONCAT(DATE_PART('year', ts), '-',  DATE_PART('month', ts)) year_month,
       COUNT(DISTINCT user_id) active_user,
       CAST(CAST(COUNT(DISTINCT user_id) AS float)/CAST(c.total_users AS float) AS DECIMAL(4,2)) active_pct,
       COUNT(*)/COUNT(DISTINCT user_id) per_user_event       
  FROM event_cohort ec
  JOIN cohort_users c ON ec.cohort = c.cohort 
GROUP BY c.cohort, c.total_users, DATE_PART('year', ts), DATE_PART('month', ts)
ORDER BY c.cohort, DATE_PART('year', ts), DATE_PART('month', ts))
TO 'E:/Data Science Study/User behavior/cohort_analysis_active.csv' DELIMITER ',' CSV HEADER;


/*conversion and retention*/
-- rank by user conversion over time
CREATE VIEW orders AS 
SELECT e.*,
       ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY ts) as order_rank
FROM event_cohort 
WHERE type = 'buy_order';


-- user first order and second order after signing up 
-- revenue per cohort per month
CREATE VIEW conversion_bymonth AS
SELECT o.cohort,
       DATE_PART('year', ts) order_year, 
       DATE_PART('month', ts) order_month,
       CONCAT(DATE_PART('year', ts), '-',  DATE_PART('month', ts)) year_month,
       SUM(CASE WHEN order_rank = 1 THEN 1 ELSE 0 END) first_order_users,
       SUM(CASE WHEN order_rank = 2 THEN 1 ELSE 0 END) second_order_users,
       SUM(p.price) revenue       
 FROM orders o
 JOIN products p ON o.product_id = p.product_id
GROUP BY o.cohort, order_year, order_month
ORDER BY o.cohort, order_year, order_month;

-- cumulative conversion rate, retention rate, ARPU
COPY (
SELECT c1.cohort,
       year_month,
       CAST(SUM(first_order_users) OVER (PARTITION BY c1.cohort ORDER BY order_year, order_month)/c2.total_users AS DECIMAL(4,2)) conversion_rate,
       CAST(SUM(second_order_users) OVER (PARTITION BY c1.cohort ORDER BY order_year, order_month)/SUM(first_order_users) OVER (PARTITION BY c1.cohort ORDER BY order_year, order_month) AS DECIMAL(4,2)) retention_rate,
       CAST(SUM(revenue) OVER (PARTITION BY c1.cohort ORDER BY order_year, order_month)/c2.total_users AS INT) ARPU  
 FROM conversion_bymonth c1
 JOIN cohort_users c2 ON c1.cohort = c2.cohort
 ORDER BY c1.cohort, order_year, order_month)
TO 'E:/Data Science Study/User behavior/cohort_analysis_conversion.csv' DELIMITER ',' CSV HEADER;

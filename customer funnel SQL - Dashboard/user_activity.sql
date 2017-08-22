/* SQL(PostgreSQL) query to analyze user activity with user log data.
The "event" table which stored user log data is created with data sources: 
https://www.dataiku.com/learn/guide/tutorials/churn-prediction.html */


/*Acquisition & Activation*/
/*Define user groups as below, calculate the total number of users in each group daily
  - Persistent: active in today and yesterday
  - New: active today, no event record in history
  - Returned: active today, inactive yesterday
  - Churned: inactive today, active yesterday */

/*Method 1: full outer join*/
--find unique user - active date pairs
CREATE VIEW ua_date AS
SELECT DISTINCT user_id, CAST(ts AS DATE) the_date
FROM event;

--outer join current day’s user activity with the last day’s user activity
CREATE VIEW ty_join AS
SELECT ud1.user_id as user_id, ud1.the_date as today, ud2.the_date as yesterday
FROM ua_date ud1
FULL OUTER JOIN ua_date ud2 
           ON  ud1.the_date - ud2.the_date = 1
           AND ud1.user_id = ud2.user_id;

SELECT * FROM ty_join LIMIT 100;

--count number of persistent, returned + new, churned users by date
--this method requires extra steps to separate between returned users and new users, returned_new is the total number of both groups
CREATE VIEW ps_returned_new AS
SELECT today,
       SUM(CASE WHEN (today IS NOT NULL) AND (yesterday IS NOT NULL) THEN 1 ELSE NULL END) persistent,
       SUM(CASE WHEN (today IS NOT NULL) AND (yesterday IS NULL) THEN 1 ELSE NULL END) returned_new
   FROM ty_join
GROUP BY today;

--count churned users by date
CREATE VIEW churn AS
SELECT yesterday + 1 adj_today,
       SUM(CASE WHEN (today IS NULL) AND (yesterday IS NOT NULL) THEN 1 ELSE NULL END) churned
   FROM ty_join
GROUP BY yesterday;

--combined report
SELECT today, persistent, returned_new, churned
  FROM ps_returned_new t1
  JOIN churn t2
   ON t1.today = t2.adj_today
 WHERE today IS NOT NULL
 ORDER BY today 


/*Method 2: LEAD() LAG()*/

--find the last and next active dates of each user-date pairs
CREATE VIEW ua_lead_lag AS
SELECT user_id,
       the_date,
       LAG(the_date, 1) OVER (PARTITION BY user_id ORDER BY the_date) last_active,
       LEAD(the_date, 1) OVER (PARTITION BY user_id ORDER BY the_date) next_active
FROM ua_date;

SELECT * FROM ua_lead_lag LIMIT 10;

--count persistent, returned users, new users by date 

CREATE VIEW ps_returned_new AS
SELECT the_date,
       SUM(CASE WHEN the_date - last_active = 1 THEN 1 ELSE NULL END) persistent,
       SUM(CASE WHEN the_date - last_active > 1 THEN 1 ELSE NULL END) returned,
       SUM(CASE WHEN last_active IS NULL THEN 1 ELSE NULL END) new
   FROM ua_lead_lag
GROUP BY the_date;

--count churned users. current dates(the_date) are active. churn dates are one day after the current dates
CREATE VIEW churn2 AS
SELECT the_date + 1 adj_date, 
       SUM(CASE WHEN (next_active - the_date > 1 OR next_active IS NULL) THEN 1 ELSE NULL END) churned
   FROM ua_lead_lag
GROUP BY adj_date;

SELECT * FROM churn2 LIMIT 10;

--combined report 
CREATE VIEW funnel_report AS
SELECT the_date, persistent, new, returned, churned
  FROM ps_returned_new t1
  JOIN churn2 t2
   ON t1.the_date = t2.adj_date
 WHERE the_date IS NOT NULL
 ORDER BY the_date;

--copy result to csv file for later use
COPY (SELECT the_date, persistent, new, returned, churned
  FROM DAU_returned_new t1
  JOIN churn2 t2
   ON t1.the_date = t2.adj_date
 WHERE the_date IS NOT NULL
 ORDER BY the_date) 
 TO 'your path/funnel_report.csv' DELIMITER ',' CSV HEADER;

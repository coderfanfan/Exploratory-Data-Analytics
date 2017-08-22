This file contains codes developed to build below interactive dashboard to track customer funnel.
>https://yurongfan.shinyapps.io/dashboard

>the original data source: 
* Event: a log of what happened on your website: what page users see, what product they like or purchase
* (http://downloads.dataiku.com/tutorials/v2.0/TUTORIAL_CHURN/events.csv.gz)
* Products: a look-up table containing a product id, and information about its category and price. 
* (http://downloads.dataiku.com/tutorials/v2.0/TUTORIAL_CHURN/products.csv.gz)

>included files:
  * dashboard.rmd: R flexdashboard + shiny code
  * user_activity.sql: sql query used to analyze original log data 
  * cohort_analysis.sql: sql query used to analyze original log data 

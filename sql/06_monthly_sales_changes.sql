-- 월별 매출 변화 분석
-- 외부 요인 데이터가 없어 증가 원인은 단정할 수 없음
USE CoffeeShopAnalytics;
GO

-- 월별 매출, 거래량, 전월 대비 증감률
;WITH Monthly AS (
 SELECT DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS month_start,
        COUNT(DISTINCT transaction_date) AS observed_days,
        COUNT(*) AS records,
        SUM(CAST(transaction_qty AS DECIMAL(18,2)) * CAST(unit_price AS DECIMAL(18,2))) AS revenue
 FROM dbo.CoffeeTransactions
 GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1)
), Metrics AS (
 SELECT month_start, observed_days, records, revenue,
        CAST(records * 1.0 / NULLIF(observed_days,0) AS DECIMAL(18,3)) AS records_per_day,
        CAST(revenue / NULLIF(observed_days,0) AS DECIMAL(18,4)) AS revenue_per_day,
        CAST(revenue / NULLIF(records,0) AS DECIMAL(18,4)) AS revenue_per_record
 FROM Monthly
)
SELECT month_start, observed_days, records,
       CAST(revenue AS DECIMAL(18,2)) AS revenue,
       CAST(records_per_day AS DECIMAL(18,2)) AS records_per_day,
       CAST(revenue_per_day AS DECIMAL(18,2)) AS revenue_per_day,
       CAST(revenue_per_record AS DECIMAL(18,2)) AS revenue_per_record,
       CAST(100.0*(revenue / NULLIF(LAG(revenue) OVER(ORDER BY month_start),0)-1) AS DECIMAL(9,2)) AS mom_revenue_pct,
       CAST(100.0*(revenue_per_day / NULLIF(LAG(revenue_per_day) OVER(ORDER BY month_start),0)-1) AS DECIMAL(9,2)) AS mom_daily_revenue_pct,
       CAST(100.0*(records_per_day / NULLIF(LAG(records_per_day) OVER(ORDER BY month_start),0)-1) AS DECIMAL(9,2)) AS mom_daily_records_pct
FROM Metrics
ORDER BY month_start;
GO

-- 매장별 3월·5월 매출 증가분
;WITH StoreMonthly AS (
 SELECT DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS month_start,
        store_location,
        COUNT(*) AS records,
        SUM(CAST(transaction_qty AS DECIMAL(18,2))*CAST(unit_price AS DECIMAL(18,2))) AS revenue
 FROM dbo.CoffeeTransactions
 GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1), store_location
), Compare AS (
 SELECT month_start,store_location,records,revenue,
        LAG(records) OVER (PARTITION BY store_location ORDER BY month_start) AS prior_records,
        LAG(revenue) OVER (PARTITION BY store_location ORDER BY month_start) AS prior_revenue
 FROM StoreMonthly
)
SELECT month_start,store_location,records,records-prior_records AS record_change,
       CAST(revenue AS DECIMAL(18,2)) AS revenue,
       CAST(revenue-prior_revenue AS DECIMAL(18,2)) AS revenue_change
FROM Compare
WHERE month_start IN ('20230301','20230501')
ORDER BY month_start,revenue_change DESC;
GO

-- 카테고리별 3월·5월 매출 증가분
;WITH CategoryMonthly AS (
 SELECT DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS month_start,
        product_category,
        SUM(CAST(transaction_qty AS DECIMAL(18,2))*CAST(unit_price AS DECIMAL(18,2))) AS revenue
 FROM dbo.CoffeeTransactions
 GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1), product_category
), Compare AS (
 SELECT month_start, product_category, revenue,
        LAG(revenue) OVER (PARTITION BY product_category ORDER BY month_start) AS prior_revenue
 FROM CategoryMonthly
)
SELECT month_start,product_category,
       CAST(revenue AS DECIMAL(18,2)) AS revenue,
       CAST(revenue-prior_revenue AS DECIMAL(18,2)) AS revenue_change
FROM Compare
WHERE month_start IN ('20230301','20230501')
ORDER BY month_start,revenue_change DESC;
GO

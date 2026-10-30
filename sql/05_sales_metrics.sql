-- 추가 매출 지표
-- 매출 = 수량 × 단가 (할인·환불 미반영)
USE CoffeeShopAnalytics;
GO

-- 월별 매출, 일평균 매출
;WITH Monthly AS (
    SELECT
        DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS sales_month,
        COUNT(DISTINCT transaction_date) AS observed_days,
        COUNT(*) AS transaction_records,
        SUM(CAST(transaction_qty AS DECIMAL(18,2)) * CAST(unit_price AS DECIMAL(18,2))) AS revenue
    FROM dbo.CoffeeTransactions
    GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1)
)
SELECT
    sales_month,
    observed_days,
    transaction_records,
    CAST(revenue AS DECIMAL(18,2)) AS revenue,
    CAST(revenue / NULLIF(observed_days, 0) AS DECIMAL(18,2)) AS revenue_per_observed_day,
    CAST(revenue / NULLIF(transaction_records, 0) AS DECIMAL(18,2)) AS revenue_per_record,
    CAST(100.0 * (revenue - LAG(revenue) OVER (ORDER BY sales_month)) /
         NULLIF(LAG(revenue) OVER (ORDER BY sales_month), 0) AS DECIMAL(9,2)) AS mom_growth_pct
FROM Monthly
ORDER BY sales_month;
GO

-- 매장별 기록당 매출 및 판매 수량
SELECT
    store_location,
    COUNT(*) AS transaction_records,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty AS DECIMAL(18,2)) * unit_price) AS DECIMAL(18,2)) AS revenue,
    CAST(SUM(CAST(transaction_qty AS DECIMAL(18,2)) * unit_price) /
         NULLIF(COUNT(*), 0) AS DECIMAL(18,2)) AS revenue_per_record,
    CAST(1.0 * SUM(transaction_qty) / NULLIF(COUNT(*), 0) AS DECIMAL(18,3)) AS units_per_record
FROM dbo.CoffeeTransactions
GROUP BY store_location
ORDER BY revenue DESC;
GO

-- 시간대별 매출 비중
;WITH StoreHour AS (
    SELECT store_location, DATEPART(HOUR, transaction_time) AS sales_hour,
           COUNT(*) AS transaction_records,
           SUM(CAST(transaction_qty AS DECIMAL(18,2)) * unit_price) AS revenue
    FROM dbo.CoffeeTransactions
    GROUP BY store_location, DATEPART(HOUR, transaction_time)
)
SELECT
    store_location, sales_hour, transaction_records,
    CAST(revenue AS DECIMAL(18,2)) AS revenue,
    CAST(100.0 * revenue / NULLIF(SUM(revenue) OVER (PARTITION BY store_location),0)
         AS DECIMAL(9,2)) AS within_store_revenue_pct,
    DENSE_RANK() OVER (PARTITION BY store_location ORDER BY revenue DESC) AS store_hour_rank
FROM StoreHour
ORDER BY store_location, sales_hour;
GO

-- 카테고리별 매출 비중
;WITH CategorySales AS (
    SELECT product_category,
           SUM(CAST(transaction_qty AS DECIMAL(18,2)) * unit_price) AS revenue
    FROM dbo.CoffeeTransactions
    GROUP BY product_category
)
SELECT product_category,
       CAST(revenue AS DECIMAL(18,2)) AS revenue,
       CAST(100.0 * revenue / NULLIF(SUM(revenue) OVER (),0) AS DECIMAL(9,2)) AS revenue_share_pct
FROM CategorySales
ORDER BY revenue DESC;
GO

-- 매출 및 판매 패턴 분석
-- 주문 묶음 ID, 고객 ID, 원가 정보는 없음
USE CoffeeShopAnalytics;
GO
-- 전체 지표
SELECT
    COUNT(*) AS transaction_count,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue,
    CAST(AVG(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(10,2)) AS revenue_per_transaction_record
FROM dbo.CoffeeTransactions;

-- 매장별 매출
SELECT
    store_location,
    COUNT(*) AS transaction_count,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue,
    CAST(AVG(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(10,2)) AS revenue_per_transaction_record
FROM dbo.CoffeeTransactions
GROUP BY store_location
ORDER BY revenue DESC;

-- 매장별 시간대 매출
SELECT
    store_location,
    DATEPART(HOUR, transaction_time) AS sales_hour,
    COUNT(*) AS transaction_count,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
FROM dbo.CoffeeTransactions
GROUP BY store_location, DATEPART(HOUR, transaction_time)
ORDER BY store_location, sales_hour;

-- 월별 매출 및 전월 대비 증감률
;WITH Monthly AS (
    SELECT DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1) AS sales_month,
           CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
    FROM dbo.CoffeeTransactions
    GROUP BY DATEFROMPARTS(YEAR(transaction_date), MONTH(transaction_date), 1)
), Comparison AS (
    SELECT sales_month, revenue,
           LAG(revenue) OVER (ORDER BY sales_month) AS prev_month_revenue
    FROM Monthly
)
SELECT sales_month, revenue, prev_month_revenue,
       CAST(100.0 * (revenue - prev_month_revenue) / NULLIF(prev_month_revenue, 0) AS DECIMAL(10,2)) AS mom_growth_pct
FROM Comparison
ORDER BY sales_month;

-- 카테고리별 매출
SELECT
    product_category,
    COUNT(*) AS transaction_count,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
FROM dbo.CoffeeTransactions
GROUP BY product_category
ORDER BY revenue DESC;

-- 매장별 매출 상위 상품 5개
;WITH ProductRevenue AS (
    SELECT store_location, product_detail,
           CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
    FROM dbo.CoffeeTransactions
    GROUP BY store_location, product_detail
), Ranked AS (
    SELECT store_location, product_detail, revenue,
           ROW_NUMBER() OVER (PARTITION BY store_location ORDER BY revenue DESC, product_detail) AS revenue_rank
    FROM ProductRevenue
)
SELECT store_location, revenue_rank, product_detail, revenue
FROM Ranked
WHERE revenue_rank <= 5
ORDER BY store_location, revenue_rank;

-- 일별 매출
SELECT
    transaction_date,
    COUNT(*) AS transaction_count,
    SUM(transaction_qty) AS units_sold,
    CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
FROM dbo.CoffeeTransactions
GROUP BY transaction_date
ORDER BY transaction_date;
GO

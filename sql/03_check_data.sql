-- 데이터 품질 확인
USE CoffeeShopAnalytics;
GO
-- 거래 건수 및 기간
SELECT COUNT(*) AS row_count,
       COUNT(DISTINCT transaction_id) AS unique_transaction_ids,
       MIN(transaction_date) AS first_date,
       MAX(transaction_date) AS last_date
FROM dbo.CoffeeTransactions;
-- 기준: 149,116건 / 2023-01-01 ~ 2023-06-30

-- 수량, 단가, 매장명 검증
SELECT
    SUM(CASE WHEN transaction_qty <= 0 THEN 1 ELSE 0 END) AS invalid_qty_rows,
    SUM(CASE WHEN unit_price <= 0 THEN 1 ELSE 0 END) AS invalid_price_rows,
    SUM(CASE WHEN store_location IS NULL OR LTRIM(RTRIM(store_location)) = ''
             THEN 1 ELSE 0 END) AS missing_store_rows
FROM dbo.CoffeeTransactions;
-- 이상값 0건 확인

-- 매장 ID와 매장명 매핑 확인
SELECT store_id, COUNT(DISTINCT store_location) AS location_count,
       MIN(store_location) AS store_name
FROM dbo.CoffeeTransactions
GROUP BY store_id
ORDER BY store_id;

-- 총매출 검증
SELECT COUNT(*) AS transaction_rows,
       SUM(transaction_qty) AS items_sold,
       CAST(SUM(CAST(transaction_qty * unit_price AS DECIMAL(18,2))) AS DECIMAL(18,2)) AS revenue
FROM dbo.CoffeeTransactions;
-- 기준: $698,812.33
GO

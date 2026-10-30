-- DB 및 거래 테이블 생성
IF DB_ID(N'CoffeeShopAnalytics') IS NULL
    CREATE DATABASE CoffeeShopAnalytics;
GO
USE CoffeeShopAnalytics;
GO

IF OBJECT_ID(N'dbo.CoffeeTransactions', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.CoffeeTransactions (
        transaction_id   INT           NOT NULL PRIMARY KEY,
        transaction_date DATE          NOT NULL,
        transaction_time TIME(0)       NOT NULL,
        transaction_qty  INT           NOT NULL,
        store_id         INT           NOT NULL,
        store_location   NVARCHAR(80)  NOT NULL,
        product_id       INT           NOT NULL,
        unit_price       DECIMAL(10,2) NOT NULL,
        product_category NVARCHAR(100) NOT NULL,
        product_type     NVARCHAR(100) NOT NULL,
        product_detail   NVARCHAR(200) NOT NULL,
        CONSTRAINT CK_CoffeeTransactions_Qty CHECK (transaction_qty > 0),
        CONSTRAINT CK_CoffeeTransactions_Price CHECK (unit_price > 0)
    );
END;
GO

SELECT DB_NAME() AS current_database,
       OBJECT_ID(N'dbo.CoffeeTransactions', N'U') AS table_object_id;
GO

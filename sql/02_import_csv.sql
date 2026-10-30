-- CSV 경로를 로컬 환경에 맞게 수정
-- SQL Server 서비스 계정에 파일 읽기 권한 필요
-- 중복 적재 시 기본키 오류 발생
USE CoffeeShopAnalytics;
GO
DECLARE @CsvPath NVARCHAR(4000) = N'C:\coffee-shop-analysis\coffee_shop_sales_clean.csv';
DECLARE @Cmd NVARCHAR(MAX) =
    N'BULK INSERT dbo.CoffeeTransactions FROM ' + QUOTENAME(@CsvPath, '''') +
    N' WITH (FORMAT = ''CSV'', FIRSTROW = 2, FIELDQUOTE = ''"'', ' +
    N'CODEPAGE = ''65001'', ROWTERMINATOR = ''0x0a'', TABLOCK);';
EXEC sys.sp_executesql @Cmd;
GO
SELECT COUNT(*) AS imported_rows FROM dbo.CoffeeTransactions;
GO

CREATE DATABASE PropertySales;
USE PropertySales;

CREATE TABLE NeighborhoodSales (
    Borough VARCHAR(50),
    Neighborhood VARCHAR(50),
    HomeType VARCHAR(50),
    NumSales INT,
    LowestPrice DECIMAL(10, 2),
    AvgPrice DECIMAL(10, 2),
    HighestPrice DECIMAL(10, 2),
    SaleYear INT
);
-- Descriptive Analysis
-- 1. Overall distribution of sales data
SELECT
    COUNT(*) AS TotalRecords,
    MIN(NumSales) AS MinNumSales,
    AVG(NumSales) AS AvgNumSales,
    MAX(NumSales) AS MaxNumSales,
    MIN(LowestPrice) AS MinLowestPrice,
    AVG(AvgPrice) AS AvgAvgPrice,
    MAX(HighestPrice) AS MaxHighestPrice
FROM NeighborhoodSales;

-- 2. Borough with highest and lowest number of sales
SELECT Borough, SUM(NumSales) AS TotalSales
FROM NeighborhoodSales
GROUP BY Borough
ORDER BY TotalSales DESC
LIMIT 1;

SELECT Borough, SUM(NumSales) AS TotalSales
FROM NeighborhoodSales
GROUP BY Borough
ORDER BY TotalSales ASC
LIMIT 1;

-- 3. Neighborhood with highest and lowest number of sales
SELECT Borough, Neighborhood, NumSales
FROM NeighborhoodSales
ORDER BY NumSales DESC
LIMIT 1;

SELECT Borough, Neighborhood, NumSales
FROM NeighborhoodSales
ORDER BY NumSales ASC
LIMIT 1;

-- 4. Average sale price for each type of home
SELECT HomeType, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY HomeType;

-- Trends Analysis
-- 5. Change in number of sales and average sale prices over the years
SELECT SaleYear, SUM(NumSales) AS TotalSales, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY SaleYear;

-- 6. Trend in lowest and highest sale prices over the years
SELECT SaleYear, MIN(LowestPrice) AS MinLowestPrice, MAX(HighestPrice) AS MaxHighestPrice
FROM NeighborhoodSales
GROUP BY SaleYear;

-- Comparative Analysis
-- 7. Average sale prices by borough
SELECT Borough, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY Borough;

-- 8. Highest average sale price neighborhoods within each borough
SELECT n.Borough, n.Neighborhood, n.AvgPrice AS AvgAvgPrice
FROM NeighborhoodSales n
INNER JOIN (
    SELECT Borough, MAX(AvgPrice) AS MaxAvgPrice
    FROM NeighborhoodSales
    GROUP BY Borough
) max_prices ON n.Borough = max_prices.Borough AND n.AvgPrice = max_prices.MaxAvgPrice;



-- 9. Variation in number of sales by property type
SELECT HomeType, AVG(NumSales) AS AvgNumSales
FROM NeighborhoodSales
GROUP BY HomeType;

-- Neighborhood Insights
-- 10. Neighborhoods with consistently higher average sale prices over the years
SELECT Borough, Neighborhood, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY Borough, Neighborhood
HAVING AVG(AvgPrice) > (
    SELECT AVG(AvgPrice)
    FROM NeighborhoodSales
);

-- 11. Neighborhoods with significant fluctuations in sales
SELECT Borough, Neighborhood, MAX(NumSales) - MIN(NumSales) AS SalesFluctuation
FROM NeighborhoodSales
GROUP BY Borough, Neighborhood
ORDER BY SalesFluctuation DESC
LIMIT 1;

-- 12. Neighborhoods that have shown rapid growth in terms of both sales volume and average sale price
SELECT Borough, Neighborhood, AvgAvgPrice, AvgNumSales
FROM (
    SELECT
        Borough,
        Neighborhood,
        AVG(AvgPrice) AS AvgAvgPrice,
        AVG(NumSales) AS AvgNumSales
    FROM NeighborhoodSales
    GROUP BY Borough, Neighborhood
) AS Subquery
WHERE AvgAvgPrice > (
    SELECT AVG(AvgPrice)
    FROM (
        SELECT Borough, Neighborhood, AVG(AvgPrice) AS AvgPrice
        FROM NeighborhoodSales
        GROUP BY Borough, Neighborhood
    ) AS SubQueryAlias
) AND AvgNumSales > (
    SELECT AVG(NumSales)
    FROM (
        SELECT Borough, Neighborhood, AVG(NumSales) AS NumSales
        FROM NeighborhoodSales
        GROUP BY Borough, Neighborhood
    ) AS SubQueryAlias2
);


-- Property Type Analysis
-- 13. Difference in the distribution of sale prices among different types of homes
SELECT HomeType, AVG(AvgPrice) AS AvgAvgPrice, STDDEV(AvgPrice) AS StdDevAvgPrice
FROM NeighborhoodSales
GROUP BY HomeType;

-- 14. Property type with the highest average sale price
SELECT HomeType, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY HomeType
ORDER BY AvgAvgPrice DESC
LIMIT 1;

-- 15. Trends in the number of sales for each type of home
SELECT HomeType, SaleYear, SUM(NumSales) AS TotalSales
FROM NeighborhoodSales
GROUP BY HomeType, SaleYear;

-- Yearly Analysis
-- 16. Highest and lowest sale prices recorded for each year
SELECT SaleYear, MAX(HighestPrice) AS MaxHighestPrice, MIN(LowestPrice) AS MinLowestPrice
FROM NeighborhoodSales
GROUP BY SaleYear;

-- 17. Change in average sale price from year to year
SELECT SaleYear, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY SaleYear;

-- Price Range Insights
-- 18. Neighborhoods with significantly higher lowest sale prices
SELECT Borough, Neighborhood, AVG(LowestPrice) AS AvgLowestPrice
FROM NeighborhoodSales
GROUP BY Borough, Neighborhood
HAVING AVG(LowestPrice) > (
    SELECT AVG(LowestPrice)
    FROM NeighborhoodSales
);

-- 19. Neighborhoods with wider range between lowest and highest sale prices
SELECT Borough, Neighborhood, MAX(HighestPrice) - MIN(LowestPrice) AS PriceRange
FROM NeighborhoodSales
GROUP BY Borough, Neighborhood
ORDER BY PriceRange DESC
LIMIT 1;

-- Investment Opportunities
-- 20. Neighborhoods with consistent growth in average sale prices and high sales volume
SELECT Borough, Neighborhood, AvgAvgPrice, AvgNumSales
FROM (
    SELECT 
        Borough, 
        Neighborhood, 
        AVG(AvgPrice) AS AvgAvgPrice, 
        AVG(NumSales) AS AvgNumSales,
        (SELECT AVG(AvgPrice) FROM NeighborhoodSales) AS OverallAvgPrice,
        (SELECT AVG(NumSales) FROM NeighborhoodSales) AS OverallAvgNumSales
    FROM NeighborhoodSales
    GROUP BY Borough, Neighborhood
) Subquery
WHERE AvgAvgPrice > OverallAvgPrice AND AvgNumSales > OverallAvgNumSales;


-- 21. Neighborhoods with low average sale price but trending upward
SELECT Borough, Neighborhood, AVG(AvgPrice) AS AvgAvgPrice
FROM NeighborhoodSales
GROUP BY Borough, Neighborhood;


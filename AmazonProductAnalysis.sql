CREATE DATABASE AmazonProduct;

USE AmazonProduct;

CREATE TABLE amazon_products (
    Uniq_Id VARCHAR(255) PRIMARY KEY,
    Crawl_Timestamp TIMESTAMP,
    Pageurl VARCHAR(255),
    Website VARCHAR(255),
    Title VARCHAR(255),
    Num_Of_Reviews INT,
    Average_Rating DECIMAL(3, 2),
    Number_Of_Ratings INT,
    Model_Num VARCHAR(255),
    Sku VARCHAR(255),
    Upc VARCHAR(255),
    Manufacturer VARCHAR(255),
    Model_Name VARCHAR(255),
    Price DECIMAL(10, 2),
    Monthly_Price DECIMAL(10, 2),
    Stock INT,
    Carrier VARCHAR(255),
    Color_Category VARCHAR(255),
    Internal_Memory VARCHAR(255),
    Screen_Size DECIMAL(4, 2),
    Specifications TEXT,
    Five_Star INT,
    Four_Star INT,
    Three_Star INT,
    Two_Star INT,
    One_Star INT,
    Broken_Link INT,
    Discontinued INT
);

USE AmazonProduct;

SET SQL_SAFE_UPDATES=0;


-- Remove leading and trailing spaces from string columns
UPDATE amazon_products
SET Title = TRIM(Title),
    Model_Num = TRIM(Model_Num),
    Sku = TRIM(Sku),
    Upc = TRIM(Upc),
    Manufacturer = TRIM(Manufacturer),
    Model_Name = TRIM(Model_Name),
    Carrier = TRIM(Carrier),
    Color_Category = TRIM(Color_Category),
    Internal_Memory = TRIM(Internal_Memory);

-- Convert NULL values in Number_Of_Ratings to 0
UPDATE amazon_products
SET Number_Of_Ratings = 0
WHERE Number_Of_Ratings IS NULL;

-- Convert NULL values in Price and Monthly_Price to 0.00
UPDATE amazon_products
SET Price = 0.00,
    Monthly_Price = 0.00
WHERE Price IS NULL OR Monthly_Price IS NULL;

-- Convert NULL values in Stock to 0
UPDATE amazon_products
SET Stock = 0
WHERE Stock IS NULL;

-- Convert NULL values in Screen_Size to 0.00
UPDATE amazon_products
SET Screen_Size = 0.00
WHERE Screen_Size IS NULL;

SET SQL_SAFE_UPDATES=1;

-- Top Manufacturers with High Ratings and High Sales
SELECT 
    Manufacturer,
    AVG(Average_Rating) AS Avg_Rating,
    SUM(Number_Of_Ratings) AS Total_Ratings,
    COUNT(*) AS Num_Products
FROM amazon_products
GROUP BY Manufacturer
HAVING AVG(Average_Rating) >= 4.0 AND SUM(Number_Of_Ratings) >= 1000
ORDER BY Total_Ratings DESC;

-- Product Popularity by Color Category and Screen Size
SELECT 
    Color_Category,
    Screen_Size,
    AVG(Number_Of_Ratings) AS Avg_Ratings,
    SUM(Number_Of_Ratings) AS Total_Ratings
FROM amazon_products
GROUP BY Color_Category, Screen_Size
HAVING Total_Ratings >= 10000
ORDER BY Avg_Ratings DESC;

-- Cross-category Analysis: Products with High Ratings and Low Price
SELECT 
    Color_Category,
    Internal_Memory,
    AVG(Average_Rating) AS Avg_Rating,
    AVG(Price) AS Avg_Price,
    SUM(Number_Of_Ratings) AS Total_Ratings
FROM amazon_products
GROUP BY Color_Category, Internal_Memory
HAVING AVG(Average_Rating) >= 4.5 AND AVG(Price) <= 200
ORDER BY Total_Ratings DESC;

-- Subquery to Find Top Reviewed Products by Color Category
SELECT 
    Color_Category,
    Title,
    Num_Of_Reviews,
    Average_Rating
FROM amazon_products
WHERE (Color_Category, Num_Of_Reviews) IN (
    SELECT Color_Category, MAX(Num_Of_Reviews) AS Max_Reviews
    FROM amazon_products
    GROUP BY Color_Category
)
ORDER BY Color_Category;

-- Sales by Color Category and Month
SELECT 
    Color_Category,
    SUBSTRING(Crawl_Timestamp, 1, 7) AS Month,
    SUM(Number_Of_Ratings) AS Total_Ratings,
    SUM(Price) AS Total_Sales
FROM amazon_products
GROUP BY Color_Category, Month
ORDER BY Month, Total_Ratings DESC;

-- Product Variants with Monthly Price Comparison
SELECT 
    Title,
    Model_Num,
    MAX(Monthly_Price) AS Max_Monthly_Price,
    MIN(Monthly_Price) AS Min_Monthly_Price
FROM amazon_products
GROUP BY Title, Model_Num
HAVING COUNT(DISTINCT Color_Category) >= 3
ORDER BY Max_Monthly_Price DESC;

CREATE TABLE manufacturer_info (
    Manufacturer VARCHAR(255) PRIMARY KEY,
    Website VARCHAR(255)
);

SELECT 
    p.Title,
    p.Manufacturer,
    m.Website AS Manufacturer_Website
FROM AmazonProduct.amazon_products AS p
INNER JOIN AmazonProduct.manufacturer_info AS m
ON p.Manufacturer = m.Manufacturer;


-- Subquery to Find Average Rating of Top Manufacturer's Products
SELECT 
    p.Manufacturer,
    AVG(p.Average_Rating) AS Avg_Rating_Top_Manufacturer
FROM AmazonProduct.amazon_products p
INNER JOIN (
    SELECT Manufacturer, SUM(Number_Of_Ratings) AS TotalRatings
    FROM AmazonProduct.amazon_products
    GROUP BY Manufacturer
    ORDER BY TotalRatings DESC
    LIMIT 1
) top_manufacturer
ON p.Manufacturer = top_manufacturer.Manufacturer
GROUP BY p.Manufacturer;


-- Subquery to Find Color Categories with High Rating Variance
SELECT 
    Color_Category,
    AVG(Average_Rating) AS Avg_Rating,
    VARIANCE(Average_Rating) AS Rating_Variance
FROM amazon_products
GROUP BY Color_Category
HAVING COUNT(DISTINCT Model_Num) >= 5
ORDER BY Rating_Variance DESC;

-- Subquery to Find Correlation Between Number of Reviews and Ratings
SELECT 
    AVG(Average_Rating) AS Avg_Rating,
    AVG(Num_Of_Reviews) AS Avg_Num_Reviews,
    (
        SUM((Average_Rating - Avg_Avg_Rating) * (Num_Of_Reviews - Avg_Avg_Num_Reviews)) /
        (SQRT(SUM(POW(Average_Rating - Avg_Avg_Rating, 2)) * SUM(POW(Num_Of_Reviews - Avg_Avg_Num_Reviews, 2))))
    ) AS Correlation
FROM (
    SELECT 
        AVG(Average_Rating) AS Avg_Avg_Rating,
        AVG(Num_Of_Reviews) AS Avg_Avg_Num_Reviews
    FROM amazon_products
) AS avg_values, amazon_products;



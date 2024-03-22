rename table customer_acquisition_data to clv;
rename table rfm_data to transactions;

select * from transactions;

-- customer life time value 

-- Total Revenue Per Customer
select CustomerID,sum(TransactionAmount ) AS Total_revenue
from transactions group by CustomerID;

-- Purchase Frequency
select CustomerID,count(*) as Purchase_Frequency
from transactions group by CustomerID;

-- Average Purcchase Value 
select CustomerID,avg(TransactionAmount) as Average_purchase
from transactions group by CustomerID;


-- Customer Lifetime value

SELECT 
    CustomerID,
    AVG(TransactionAmount) AS AvgPurchaseValue,
    COUNT(*) AS PurchaseFrequency,
    AVG(TransactionAmount) * COUNT(*) AS CLV
FROM 
    Transactions
GROUP BY 
    CustomerID;
    
    
WITH CLVCalculation AS (
    SELECT 
        CustomerID,
        AVG(TransactionAmount) * COUNT(*) AS CLV
    FROM 
        Transactions
    GROUP BY 
        CustomerID
)
-- customer segement groups
SELECT 
    CustomerID,
    CLV,
    CASE
        WHEN CLV >= 1000 THEN 'High Value'
        WHEN CLV BETWEEN 500 AND 999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CLVSegment
FROM 
    CLVCalculation;
   
   
   -- RFM Analysis(Recency,Frequency,Monetory)
   
   -- how recently a customer has made a purchase (Recency)
   SELECT CustomerID, MAX(PurchaseDate) AS LastPurchaseDate,
       DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
FROM transactions
GROUP BY CustomerID;


-- how often they make purchases (Frequency),
SELECT CustomerID, COUNT(*) AS Frequency
FROM transactions
GROUP BY CustomerID;

-- how much money they spend (Monetary value)
SELECT CustomerID, SUM(TransactionAmount) AS Monetary
FROM transactions
GROUP BY CustomerID; 


-- join RFM metrics
SELECT R.CustomerID, R.Recency, F.Frequency, M.Monetary
FROM (SELECT CustomerID, DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
      FROM transactions
      GROUP BY CustomerID) R
JOIN (SELECT CustomerID, COUNT(*) AS Frequency
      FROM transactions
      GROUP BY CustomerID) F ON R.CustomerID = F.CustomerID
JOIN (SELECT CustomerID, SUM(TransactionAmount) AS Monetary
      FROM transactions
      GROUP BY CustomerID) M ON R.CustomerID = M.CustomerID;
      

-- With RFM Scores , classified customers into segments
SELECT 
    R.CustomerID,
    CASE
        WHEN R.Recency <= 30 THEN 'High'
        WHEN R.Recency BETWEEN 31 AND 60 THEN 'Medium'
        ELSE 'Low'
    END AS RecencyScore,
    CASE
        WHEN F.Frequency >= 10 THEN 'High'
        WHEN F.Frequency BETWEEN 5 AND 9 THEN 'Medium'
        ELSE 'Low'
    END AS FrequencyScore,
    CASE
        WHEN M.Monetary >= 500 THEN 'High'
        WHEN M.Monetary BETWEEN 200 AND 499 THEN 'Medium'
        ELSE 'Low'
    END AS MonetaryScore
FROM 
    (SELECT 
         CustomerID, 
         DATEDIFF(CURRENT_DATE, MAX(PurchaseDate)) AS Recency
     FROM 
         transactions
     GROUP BY 
         CustomerID) R
JOIN 
    (SELECT 
         CustomerID, 
         COUNT(*) AS Frequency
     FROM 
         transactions
     GROUP BY 
         CustomerID) F ON R.CustomerID = F.CustomerID
JOIN 
    (SELECT 
         CustomerID, 
         SUM(TransactionAmount) AS Monetary
     FROM 
         transactions
     GROUP BY 
         CustomerID) M ON R.CustomerID = M.CustomerID;
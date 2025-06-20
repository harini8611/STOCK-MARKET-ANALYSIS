--  Fixing the column
ALTER TABLE bajaj CHANGE `ï»¿Date` `Date` TEXT;


--  Add new column to store proper DATE format 
ALTER TABLE bajaj ADD COLUMN ParsedDate DATE;

-- 1. Turn off Safe Updates
SET SQL_SAFE_UPDATES = 0;

-- 2. Perform the update
UPDATE bajaj
SET ParsedDate = STR_TO_DATE(`Date`, '%d-%b-%y')
WHERE `Date` IS NOT NULL;

-- 3. Turn Safe Updates back on (optional but recommended)
SET SQL_SAFE_UPDATES = 1;


--  Spread b/w high & low (fluctuation of amount in a day)
SELECT 
  ParsedDate AS `Date`, 
  (`High Price` - `Low Price`) AS `Spread High-Low`
FROM bajaj;

--  Spread b/w open & close (indicates whether price went up/down in a day)
SELECT 
  ParsedDate AS `Date`, 
  (`Close Price` - `Open Price`) AS `Spread Close-Open`
FROM bajaj;

--  Top 10 days of spread b/w high and low(volatility)
SELECT 
  ParsedDate AS `Date`, 
  (`High Price` - `Low Price`) AS `Volatility`
FROM bajaj
ORDER BY `Volatility` DESC
LIMIT 10;

--  AVG DELIVERY % BY MONTH
SELECT 
  MONTH(ParsedDate) AS `Month`, 
  AVG(`% Deli. Qty to Traded Qty`) AS `Avg Delivery %`
FROM bajaj
GROUP BY MONTH(ParsedDate);

--  DAILY TURNOVER PER SHARE
SELECT 
  ParsedDate AS `Date`,
  `Total Turnover (Rs.)`,
  `No.of Shares`,
  (`Total Turnover (Rs.)` / `No.of Shares`) AS `Avg Price Per Share`
FROM bajaj
WHERE `No.of Shares` > 0;

-- MONTHLY TURNOVER
SELECT 
  YEAR(ParsedDate) AS `Year`, 
  MONTH(ParsedDate) AS `Month`, 
  SUM(`Total Turnover (Rs.)`) AS `Monthly Turnover`
FROM bajaj
GROUP BY YEAR(ParsedDate), MONTH(ParsedDate)
ORDER BY `Year`, `Month`;

--  YEARLY TURNOVER
SELECT 
  YEAR(ParsedDate) AS `Year`, 
  SUM(`Total Turnover (Rs.)`) AS `Yearly Turnover`
FROM bajaj
GROUP BY YEAR(ParsedDate)
ORDER BY `Year`;

--  MAX AND MIN MONTHLY TURNOVER
SELECT 
  MAX(`Monthly Turnover`) AS `Max Monthly Turnover`, 
  MIN(`Monthly Turnover`) AS `Min Monthly Turnover`
FROM (
  SELECT 
    YEAR(ParsedDate) AS `Year`, 
    MONTH(ParsedDate) AS `Month`, 
    SUM(`Total Turnover (Rs.)`) AS `Monthly Turnover`
  FROM bajaj
  GROUP BY YEAR(ParsedDate), MONTH(ParsedDate)
) AS monthly_data;

--  MAX AND MIN YEARLY TURNOVER
SELECT 
  MAX(`Yearly Turnover`) AS `Max Yearly Turnover`, 
  MIN(`Yearly Turnover`) AS `Min Yearly Turnover`
FROM (
  SELECT 
    YEAR(ParsedDate) AS `Year`, 
    SUM(`Total Turnover (Rs.)`) AS `Yearly Turnover`
  FROM bajaj
  GROUP BY YEAR(ParsedDate)
) AS yearly_data;

--  TOP 10 TURNOVER DAYS
SELECT 
  ParsedDate AS `Date`, 
  `Total Turnover (Rs.)`
FROM bajaj
ORDER BY `Total Turnover (Rs.)` DESC
LIMIT 10;

--  MONTHLY VOLATALITY
SELECT 
  YEAR(ParsedDate) AS `Year`,
  MONTH(ParsedDate) AS `Month`,
  AVG(`High Price` - `Low Price`) AS `Avg Monthly Volatility`
FROM bajaj
GROUP BY YEAR(ParsedDate), MONTH(ParsedDate)
ORDER BY `Year`, `Month`;

--  TOP 10 DAYS BY DELIVERY %
SELECT 
  ParsedDate AS `Date`,
  `% Deli. Qty to Traded Qty`
FROM bajaj
ORDER BY `% Deli. Qty to Traded Qty` DESC
LIMIT 10;

--  MONTHLY AVG CLOSE PRICE
SELECT 
  YEAR(ParsedDate) AS `Year`,
  MONTH(ParsedDate) AS `Month`,
  AVG(`Close Price`) AS `Avg Close Price`
FROM bajaj
GROUP BY YEAR(ParsedDate), MONTH(ParsedDate)
ORDER BY `Year`, `Month`;

--  PRICE MOVEMENT SUMMARY
SELECT 
  COUNT(*) AS `Total Days`,
  SUM(CASE WHEN `Close Price` > `Open Price` THEN 1 ELSE 0 END) AS `Up Days`,
  SUM(CASE WHEN `Close Price` < `Open Price` THEN 1 ELSE 0 END) AS `Down Days`,
  SUM(CASE WHEN `Close Price` = `Open Price` THEN 1 ELSE 0 END) AS `No Change Days`
FROM bajaj;

-- YEARLY AVG DAILY RANGE (Volatility)
SELECT 
  YEAR(ParsedDate) AS `Year`,
  AVG(`High Price` - `Low Price`) AS `Avg Daily Range`
FROM bajaj
GROUP BY YEAR(ParsedDate)
ORDER BY `Year`;

-- TOP 10 DAYS BY NO OF TRADES
SELECT 
  ParsedDate AS `Date`,
  `No. of Trades`
FROM bajaj
ORDER BY `No. of Trades` DESC
LIMIT 10;

-- QUARTERLY TURNOVER
SELECT 
  YEAR(ParsedDate) AS `Year`,
  QUARTER(ParsedDate) AS `Quarter`,
  SUM(`Total Turnover (Rs.)`) AS `Quarterly Turnover`
FROM bajaj
GROUP BY YEAR(ParsedDate), QUARTER(ParsedDate)
ORDER BY `Year`, `Quarter`;

-- COMPARE TURN OVER ON UP AND DOWN DAYS
SELECT 
  CASE 
    WHEN `Close Price` > `Open Price` THEN 'Up Day'
    WHEN `Close Price` < `Open Price` THEN 'Down Day'
    ELSE 'No Change'
  END AS `Day Type`,
  AVG(`Total Turnover (Rs.)`) AS `Avg Turnover`
FROM bajaj
GROUP BY `Day Type`;

-- Step 1: Calculate monthly turnover
WITH MonthlyTurnover AS (
  SELECT 
    YEAR(ParsedDate) AS Year,
    MONTH(ParsedDate) AS Month,
    SUM(`Total Turnover (Rs.)`) AS MonthlyTurnover
  FROM bajaj
  GROUP BY YEAR(ParsedDate), MONTH(ParsedDate)
)

-- Step 2: Get the max and min turnover months
SELECT *
FROM MonthlyTurnover
WHERE MonthlyTurnover = (
    SELECT MAX(MonthlyTurnover) FROM MonthlyTurnover
)
   OR MonthlyTurnover = (
    SELECT MIN(MonthlyTurnover) FROM MonthlyTurnover
);








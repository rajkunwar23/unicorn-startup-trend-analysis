SELECT * FROM unicorn_companies;
SELECT * FROM investors;
SELECT * FROM company_investments;

-- Company-Level
-- How are unicorns distributed by industry and Which industries dominate valuation share?
CREATE VIEW vw_industry_summary AS 
SELECT industry,
COUNT(company_id) AS unicorn_count,
ROUND(AVG(valuation),2) AS avg_valuation
FROM unicorn_companies
GROUP BY industry;
-- ORDER BY avg_valuation DESC;

-- How does valuation vary by country?
SELECT country,ROUND(AVG(valuation),2) AS avg_valuation
FROM unicorn_companies
GROUP BY country
ORDER BY avg_valuation DESC;

-- Investor-Level
-- Who are the most active investors?
CREATE VIEW vw_investor_exposure AS 
SELECT i.investor_name,COUNT(DISTINCT ci.company_id) AS active_cnt
FROM company_investments ci JOIN investors i
ON ci.investor_id=i.investor_id
GROUP BY i.investor_name;
-- ORDER BY active_cnt DESC
-- LIMIT 10;

-- Investment-Level
-- Which industries attract the most investor interest?
SELECT uc.industry,COUNT(ci.investor_id) AS investor_cnt 
FROM company_investments ci JOIN unicorn_companies uc
ON ci.company_id=uc.company_id
GROUP BY uc.industry
ORDER BY investor_cnt DESC
LIMIT 10;

-- run this command in SQL Shell psql -- \COPY (SELECT * FROM vw_investor_exposure) TO 'C:\Users\rajku\Downloads\vw_investor_exposure.csv' DELIMITER ',' CSV HEADER;



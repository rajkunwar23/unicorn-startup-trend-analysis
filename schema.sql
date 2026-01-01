-- 1. Create schema
CREATE TABLE unicorn_companies (
    company_id SERIAL PRIMARY KEY,
    company VARCHAR(255),
    valuation NUMERIC(15,2),
    year_Joined INT,
    industry VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255),
    continent VARCHAR(100),
    Year_Founded INT,
    funding NUMERIC(15,2),
    investors TEXT
);

SELECT * from unicorn_companies;

-- Run this comand in SQL Shell after connecting to the correct db -\copy unicorn_companies(company,valuation,year_joined,industry,city,country,continent,year_founded,funding,investors) FROM 'C:/Users/rajku/Downloads/Unicorn_Companies.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE investors (
    investor_id SERIAL PRIMARY KEY,
    investor_name VARCHAR(255)
);

INSERT INTO investors (investor_name)
SELECT DISTINCT
    TRIM(investor)
FROM unicorn_companies,
     LATERAL unnest(string_to_array(investors, ',')) AS investor
WHERE investors IS NOT NULL
  AND TRIM(investor) <> '';

SELECT * FROM investors;

CREATE TABLE company_investments (
    investment_id SERIAL PRIMARY KEY,
    company_id INT REFERENCES unicorn_companies(company_id),
    investor_id INT REFERENCES investors(investor_id)
);

INSERT INTO company_investments (company_id, investor_id)
SELECT DISTINCT
    uc.company_id,
    i.investor_id
FROM unicorn_companies uc
JOIN LATERAL unnest(string_to_array(uc.investors, ',')) AS inv(investor_name)
    ON TRUE
JOIN investors i
    ON TRIM(inv.investor_name) = i.investor_name
WHERE uc.investors IS NOT NULL
  AND TRIM(inv.investor_name) <> '';

SELECT * FROM company_investments;

CREATE TABLE industry_yearly_metrics (
    industry VARCHAR(255),
    year INT,
    unicorn_count INT,
    avg_valuation NUMERIC(15,2),
    total_funding NUMERIC(15,2),
    PRIMARY KEY (industry, year)
);

CREATE TABLE new_unicorn_companies (
    company_id SERIAL PRIMARY KEY,
    company VARCHAR(255),
    valuation NUMERIC,
    year_Joined INT,
    industry VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255),
    continent VARCHAR(100),
    Year_Founded INT,
    funding NUMERIC,
    investors TEXT,
	GDP NUMERIC
);

SELECT * FROM new_unicorn_companies

-- CREATE TABLE emerging_unicorn_candidates (
--     company VARCHAR(255),
--     industry VARCHAR(255),
--     country VARCHAR(255),
--     total_funding NUMERIC(15,2),
--     funding_velocity NUMERIC(10,2),
--     top_investor_count INT,
--     candidate_score NUMERIC(6,2),
--     is_potential_unicorn BOOLEAN
-- );


CREATE TABLE dim_date (
    date_key SERIAL PRIMARY KEY,
    year_joined INT NOT NULL,
    year_founded INT
)
INSERT INTO dim_date (year_joined,year_founded)
SELECT DISTINCT year_joined,year_founded
FROM unicorn_companies;


CREATE TABLE dim_industry (
    industry_key SERIAL PRIMARY KEY,
    industry_name TEXT UNIQUE NOT NULL
);

INSERT INTO dim_industry (industry_name)
SELECT DISTINCT
    TRIM(industry)
FROM unicorn_companies
WHERE industry IS NOT NULL;


CREATE TABLE dim_geography (
    geography_key SERIAL PRIMARY KEY,
    continent TEXT,
    country TEXT NOT NULL,
    city TEXT NOT NULL,
    UNIQUE (country, city)
);
INSERT INTO dim_geography (continent, country, city)
SELECT DISTINCT
    continent,
    country,
    city
FROM unicorn_companies
WHERE country IS NOT NULL
  AND city IS NOT NULL;

  
CREATE TABLE dim_company (
    company_id INT UNIQUE,
    company_name TEXT NOT NULL
);
INSERT INTO dim_company (company_id, company_name)
SELECT DISTINCT
    company_id,
    company
FROM unicorn_companies;

-- 1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Můj seznám s daty

SELECT 
DISTINCT industry_branch_code 
FROM czechia_payroll cp;

-- mám NULL hodnoty u 344 záznamů 

SELECT *
FROM czechia_payroll cp 
WHERE industry_branch_code IS NULL
ORDER BY payroll_year, payroll_quarter;

-- mám NULL hodnoty u 3096 záznamů (mám průměrné tisíc osob zaměstnaných v každém roce a čtvrtletí)

SELECT *
FROM czechia_payroll cp 
WHERE value IS NULL;

-- 316  množství zaměstnaných osob
-- 5958 hrubá mzda na zaměstnance

SELECT 
  DISTINCT value_type_code
FROM czechia_payroll cp;

-- 200 Kč
-- 80403 tisíc osob

SELECT 
  DISTINCT unit_code 
FROM czechia_payroll cp;

-- 100 fyzický
-- 200 přepočtený

SELECT 
  DISTINCT calculation_code 
FROM czechia_payroll;


SELECT 
  DISTINCT payroll_year 
FROM czechia_payroll cp 
ORDER BY payroll_year ASC;

-- Zjištění rozsahu let

SELECT
  industry_branch_code,
  MIN(payroll_year),
  payroll_quarter
FROM czechia_payroll cp 
GROUP BY industry_branch_code;

 
SELECT
  industry_branch_code,
  MAX(payroll_year),
  payroll_quarter
FROM czechia_payroll cp 
GROUP BY industry_branch_code;

-- Meziroční růst:

WITH Growing AS (
SELECT *
  /*cp.value,
    cp.payroll_year,
	cp.payroll_quarter,
	cp.industry_branch_code*/
FROM czechia_payroll cp
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 100 AND cp.payroll_quarter = 4 AND cp.industry_branch_code IS NOT NULL 
ORDER BY cp.industry_branch_code, cp.payroll_year
)
SELECT
	value,
	payroll_year,
	industry_branch_code,
	cpib.name,
    LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year) AS previous_year_value,
	(value - LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year)) / LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year) * 100 AS year_over_year_growth
FROM Growing
JOIN czechia_payroll_industry_branch cpib ON Growing.industry_branch_code = cpib.code;


-- Celkový růst za období:

WITH Growing AS (
SELECT *
	/*cp.value,
	cp.payroll_year,
	cp.payroll_quarter,
	cp.industry_branch_code*/
FROM czechia_payroll cp
WHERE cp.value_type_code = 5958 AND cp.calculation_code = 100 AND cp.payroll_quarter = 4 AND cp.industry_branch_code IS NOT NULL AND (cp.payroll_year = 2000 OR cp.payroll_year = 2020)
ORDER BY cp.industry_branch_code, cp.payroll_year
)
SELECT
	value,
	payroll_year,
	industry_branch_code,
	cpib.name,
	LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year) AS previous_year_value,
	(value - LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year)) / LAG(value, 1) OVER (PARTITION BY industry_branch_code ORDER BY industry_branch_code, payroll_year) * 100 AS year_of_growth
FROM Growing
JOIN czechia_payroll_industry_branch cpib ON Growing.industry_branch_code = cpib.code
ORDER BY year_of_growth DESC;


  


-- Tvorba tabulky PRIMARY FINAL

-- Vytvoření primární tabulky s daty mezd a cen potravin pro ČR
CREATE TABLE t_Mariia_Ananieva_project_SQL_primary_final (
	id INT AUTO_INCREMENT PRIMARY KEY,
	code VARCHAR(10),
	name VARCHAR(255),
	type VARCHAR(50),
	date_year INT(11),
	average_value DECIMAL(10,2),
	year1 DECIMAL (10,2)
);

-- Vložení cen potravin do tabulky
INSERT INTO t_Mariia_Ananieva_project_SQL_primary_final (code, date_year, average_value)
SELECT
	category_code AS code,
	YEAR(date_to) AS date_year,
	AVG(value) AS average_value
FROM czechia_price 
WHERE region_code IS NULL 
  AND category_code != "212101" -- Vynechání kategorie
GROUP BY category_code, date_year
HAVING date_year BETWEEN 2000 AND 2020;

-- Vložení dat o mzdách do tabulky
INSERT INTO t_Mariia_Ananieva_project_SQL_primary_final (code, date_year, average_value)
SELECT
	industry_branch_code AS code,
	payroll_year AS date_year,
	AVG(value) AS average_value
FROM czechia_payroll cp
WHERE value_type_code = 5958 -- Pouze průměrné mzdy
  AND calculation_code = 100 -- Odpovídající kalkulace
  AND unit_code = 200 -- Správná jednotka (CZK)
  AND industry_branch_code IS NOT NULL
GROUP BY industry_branch_code, date_year
HAVING date_year BETWEEN 2000 AND 2020;

-- Aktualizace názvů odvětví a typů pro mzdy
UPDATE t_Mariia_Ananieva_project_SQL_primary_final f
JOIN czechia_payroll_industry_branch b ON f.code = b.code
SET f.name = b.name, f.type = 'payroll';

-- Aktualizace názvů kategorií a typů pro potraviny
UPDATE t_Mariia_Ananieva_project_SQL_primary_final f
JOIN czechia_price_category c ON f.code = c.code
SET f.name = c.name, f.type = 'price';

-- Vytvoření dočasné tabulky pro výpočet meziročního růstu cen a mezd
CREATE TEMPORARY TABLE temporar AS
SELECT
	id,
	average_value,
	code,
	date_year,
	(average_value - LAG(average_value, 1) OVER (PARTITION BY code ORDER BY date_year)) / LAG(average_value, 1) OVER (PARTITION BY code ORDER BY date_year) * 100 AS growing
FROM t_Mariia_Ananieva_project_SQL_primary_final;

-- Aktualizace meziročního růstu do tabulky primary_final
UPDATE t_Mariia_Ananieva_project_SQL_primary_final f
JOIN temporar t ON f.id = t.id
SET f.year1 = t.growing;

-- Kontrola chybějících hodnot pro jednotlivé roky a produkty
WITH Period AS (
	SELECT DISTINCT date_year
	FROM t_Mariia_Ananieva_project_SQL_primary_final
),
Products AS (
	SELECT DISTINCT code
	FROM t_Mariia_Ananieva_project_SQL_primary_final
),
Base AS (
	SELECT *
	FROM Period
	CROSS JOIN Products
),
JoinData AS (
	SELECT  
       base.date_year,
       base.code,
       f.average_value
	FROM Base base
	LEFT JOIN t_Mariia_Ananieva_project_SQL_primary_final f 
	       ON base.date_year = f.date_year
	       AND base.code = f.code
)
SELECT * 
FROM JoinData
WHERE average_value IS NULL;

   



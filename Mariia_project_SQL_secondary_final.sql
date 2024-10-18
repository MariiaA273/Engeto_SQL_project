-- Tvorba tabulky SECONDARY FINAL

-- Vytvoření sekundární tabulky s daty pro další evropské státy
CREATE TABLE t_Mariia_Ananieva_project_SQL_secondary_final (
	id INT AUTO_INCREMENT PRIMARY KEY,
	country VARCHAR(255),
	year INT(4),
	tall_hdp DECIMAL(20,2),
	hdp_year1 DECIMAL (10,2),
	gin DECIMAL(10,2),
	population DECIMAL(20,2),
	taxes DECIMAL(10,2)
);

-- Vložení dat z tabulek "countries" a "economies" do sekundární tabulky
INSERT INTO t_Mariia_Ananieva_project_SQL_secondary_final (country, year, tall_hdp, gin, population, taxes)
SELECT
	c.country,
	e.year,
	e.hdp AS tall_hdp,
	e.gin,
	e.population,
	e.taxes
FROM countries c
JOIN economies e ON c.country = e.country 
WHERE c.continent = 'Europe' 
  AND e.year BETWEEN 2000 AND 2020;

-- Dočasná tabulka pro výpočet meziročního růstu HDP
CREATE TEMPORARY TABLE temporary_hdp AS
SELECT
    id,
	country,
	year,
    tall_hdp,
	(tall_hdp - LAG(tall_hdp, 1) OVER (PARTITION BY country ORDER BY year)) / LAG(tall_hdp, 1) OVER (PARTITION BY country ORDER BY year) * 100 AS hdp
FROM t_Mariia_Ananieva_project_SQL_secondary_final
WHERE country NOT IN ('Hungary', 'Latvia', 'Sweden');

-- Aktualizace tabulky sekundárních dat s růstem HDP
UPDATE t_Mariia_Ananieva_project_SQL_secondary_final f
JOIN temporary_hdp h ON f.id = h.id
SET f.hdp_year1 = h.hdp;

-- Kontrola chybějících zemí nebo kontinentálních dat
WITH continent_check AS (
	SELECT
		e.country,
		c.continent,
		e.year
	FROM economies e
	JOIN countries c ON e.country = c.country
)
SELECT DISTINCT country
FROM continent_check
WHERE continent IS NULL
  AND year BETWEEN 2000 AND 2020;

-- Výběr chybějících hodnot HDP v jednotlivých letech
WITH country_list AS (
	SELECT DISTINCT country
	FROM t_Mariia_Ananieva_project_SQL_secondary_final
),
year_list AS (
	SELECT DISTINCT year
	FROM t_Mariia_Ananieva_project_SQL_secondary_final
),
base_data AS (
	SELECT *
	FROM year_list
	CROSS JOIN country_list
),
join_missing_data AS (
	SELECT  
       base_data.year,
       base_data.country,
       t.tall_hdp
	FROM base_data
	LEFT JOIN t_Mariia_Ananieva_project_SQL_secondary_final t
	       ON base_data.year = t.year
	       AND base_data.country = t.country
)
SELECT DISTINCT country 
FROM join_missing_data
WHERE tall_hdp IS NULL;


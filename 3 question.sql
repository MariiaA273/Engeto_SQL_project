-- 3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

SELECT
    name,
    ROUND(AVG(year1), 2) AS average_year1
FROM t_Mariia_Ananieva_project_SQL_primary_final t
WHERE type = "price"
GROUP BY name
ORDER BY average_year1;


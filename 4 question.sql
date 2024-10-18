-- 4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH pay AS (
SELECT
     ROUND(AVG(year1), 2) AS avg_1_payroll,
     date_year 
FROM t_Mariia_Ananieva_project_SQL_primary_final
WHERE type = "payroll" AND year1 IS NOT NULL
GROUP BY date_year
),
price AS (
SELECT
     ROUND(AVG(year1), 2) AS avg_1_price,
     date_year 
FROM t_Mariia_Ananieva_project_SQL_primary_final
WHERE type = "price" AND year1 IS NOT NULL
GROUP BY date_year
)
SELECT
    pr.date_year,
    pr.avg_1_price,
    pa.avg_1_payroll,
    ROUND(pr.avg_1_price - pa.avg_1_payroll, 2) AS difference
FROM pay pa
JOIN price pr ON pa.date_year = pr.date_year
WHERE (pr.avg_1_price - pa.avg_1_payroll) > 10;

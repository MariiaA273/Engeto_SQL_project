-- 2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH pay AS (
SELECT 
     AVG(average_value) AS avg_payroll,
     date_year 
FROM t_Mariia_Ananieva_project_SQL_primary_final
WHERE type = "payroll" AND (date_year = 2000 OR date_year = 2020)
GROUP BY date_year
)
SELECT
    t.name,
    t.date_year,
    t.average_value AS avg_price,
    ROUND(pay.avg_payroll, 0) AS avg_payroll,
    ROUND(pay.avg_payroll / t.average_value, 0) AS ppw
FROM t_Mariia_Ananieva_project_SQL_primary_final t
JOIN pay ON t.date_year = pay.date_year
WHERE t.code IN ("114201", "111301") AND (t.date_year = 2000 OR t.date_year = 2020);

-- 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?

WITH Average AS (
SELECT
     ROUND(AVG(year1), 2) AS avg_1,
     date_year,
     type
FROM t_Mariia_Ananieva_project_SQL_primary_final
GROUP BY date_year, type
),
hdp_cz AS (
SELECT
     country,
     year,
     tall_hdp AS hdp,
     hdp_year1 AS hdp_y
FROM t_Mariia_Ananieva_project_sql_secondary_final
WHERE country = "Czech Republic"
),
join AS(		
SELECT
      a.type,
      a.date_year,
      a.avg_1 AS average,
      LEAD(a.avg_1,1) OVER (PARTITION BY a.type ORDER BY a.date_year) AS next_avr,
      hdp_cz.hdp_y
FROM Average a
LEFT JOIN hdp_cz ON a.date_year = hdp_cz.year
)
SELECT
    type,
    date_year,
    average,
    next_avr,
    hdp_y,
    CASE	
        WHEN hdp_y > 4 AND (average > hdp_y OR next_avr > hdp_y) THEN "růst"
        WHEN hdp_y < -4 AND (average < hdp_y OR next_avr < hdp_y) THEN "pokles"
        ELSE ""
    END AS description
FROM join;

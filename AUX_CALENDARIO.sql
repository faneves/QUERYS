

WITH SEMANAS AS (
  SELECT
    DATEADD(day, 1 - DATEPART(weekday, '2024-01-01'), '2024-01-01') AS INICIO,
    DATEADD(day, 7 - DATEPART(weekday, '2024-01-01'), '2024-01-01') AS FIM
  UNION ALL
  SELECT 
    DATEADD(day, 7, INICIO),
    DATEADD(day, 7, FIM)
  FROM 
    SEMANAS
  WHERE 
    INICIO < '2025-01-01'
)

SELECT
  ROW_NUMBER() OVER (ORDER BY INICIO) AS NUM_SEMANA,
  INICIO,
  FIM
FROM 
  SEMANAS
ORDER BY 
  INICIO;

-- =======================================================

SELECT 
    DATENAME(month, DATEADD(month, number, '2024-01-01')) AS Nome_Mes,
    DATEADD(month, DATEDIFF(month, 0, DATEADD(month, number, '2024-01-01')), 0) AS Primeiro_Dia_Mes,
    DATEADD(day, -1, DATEADD(month, DATEDIFF(month, 0, DATEADD(month, number + 1, '2024-01-01')), 0)) AS Ultimo_Dia_Mes
FROM 
    master..spt_values
WHERE 
    type = 'P'
    AND number BETWEEN 0 AND 11

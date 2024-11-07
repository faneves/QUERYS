--==================================================================================================
--TAs BACKLOG
--==================================================================================================

DECLARE @DATA_REFERENCIA DATETIME = (SELECT MAX(DATA_REFERENCIA) FROM QUALIDADE..BACKLOG_TAs)

SELECT *
  FROM [QUALIDADE].[dbo].[BACKLOG_TAs]
  WHERE DATA_REFERENCIA = @DATA_REFERENCIA
  AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS'
  AND REGIONAL = 'SP'

--=============================================================================================

DECLARE @DATA_REFERENCIA DATETIME = (SELECT MAX(DATA_REFERENCIA) FROM QUALIDADE..BACKLOG_TAs)

SELECT GESTOR_ATUAL,
COUNT(1)
FROM [QUALIDADE].[dbo].[BACKLOG_TAs]
WHERE DATA_REFERENCIA = @DATA_REFERENCIA
      AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS'
GROUP BY GESTOR_ATUAL
ORDER BY GESTOR_ATUAL
  --AND REGIONAL = 'CO'




DECLARE @DATA_REFERENCIA DATETIME = (SELECT MAX(DATA_REFERENCIA) FROM QUALIDADE..BACKLOG_TAs)

SELECT *
  FROM [QUALIDADE].[dbo].[BACKLOG_TAs]
  WHERE 
  BACKLOG = 'BACKLOG CAMPO - 3 DIAS'
  AND REGIONAL = 'SP'
  AND DATA_REFERENCIA >= '2023-10-25' -- AND DATA_REFERENCIA <= '2023-10-26'
 



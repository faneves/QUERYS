DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
		MES,
		UF,
		DIA,
		'Disp' AS INDICADOR,
		MUNICIPIO,
		DISPONIBILIDADE_GERAL AS DISPONIBILIDADE
INTO #DISP
FROM
		INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_MUNICIPIO_HMM
WHERE
		MUNICIPIO IN ('SALVADOR', 'RECIFE', 'FORTALEZA', 'ARACAJU')
		AND ANO = 2024 AND MES >= 4
--ORDER BY DIA


SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(DIA)
        FROM #DISP
		GROUP BY DIA
		ORDER BY DIA
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(DISPONIBILIDADE) FOR DIA IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY 1,4'
PRINT @comando_sql
EXECUTE(@comando_sql)

-- DROP TABLE #DISP

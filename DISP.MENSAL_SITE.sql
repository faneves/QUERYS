--DISPONIBILIDADE MENSAL POR SITE

--===================================================================================
--3G+4G+5G
--===================================================================================
DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
		MES,
        REGIONAL,
		UF,
		MUNICIPIO,
        SITE,
		ISNULL(DISPONIBILIDADE_GERAL, 'NULL') AS DISPONIBILIDADE
INTO #DISP
FROM
		INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE
		ANO = 2023 AND MES IN (10,11,12)


SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(MES)
        FROM #DISP
		GROUP BY MES
		ORDER BY MES
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(DISPONIBILIDADE) FOR MES IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY REGIONAL, UF, MUNICIPIO, SITE'
PRINT @comando_sql
EXECUTE(@comando_sql)

--===================================================================================
--3G
--===================================================================================
DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
		MES,
        REGIONAL,
		UF,
		MUNICIPIO,
        SITE,
		DISPONIBILIDADE_3G AS DISPONIBILIDADE
INTO #DISP
FROM
		INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE
		ANO = 2023 AND MES IN (10,11,12)


SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(MES)
        FROM #DISP
		GROUP BY MES
		ORDER BY MES
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(DISPONIBILIDADE) FOR MES IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY REGIONAL, UF, MUNICIPIO, SITE'


--PRINT @comando_sql
EXECUTE(@comando_sql)


--===================================================================================
--4G
--===================================================================================
DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
		MES,
        REGIONAL,
		UF,
		MUNICIPIO,
        SITE,
		DISPONIBILIDADE_4G AS DISPONIBILIDADE
INTO #DISP
FROM
		INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE
		ANO = 2023 AND MES IN (10,11,12)


SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(MES)
        FROM #DISP
		GROUP BY MES
		ORDER BY MES
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(DISPONIBILIDADE) FOR MES IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY REGIONAL, UF, MUNICIPIO, SITE'


--PRINT @comando_sql
EXECUTE(@comando_sql)


--===================================================================================
--5G
--===================================================================================
DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
		MES,
        REGIONAL,
		UF,
		MUNICIPIO,
        SITE,
		DISPONIBILIDADE_5G AS DISPONIBILIDADE
INTO #DISP
FROM
		INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE
		ANO = 2023 AND MES IN (10,11,12)


SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(MES)
        FROM #DISP
		GROUP BY MES
		ORDER BY MES
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(DISPONIBILIDADE) FOR MES IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY REGIONAL, UF, MUNICIPIO, SITE'


--PRINT @comando_sql
EXECUTE(@comando_sql)





--DISP. MENSAL POR SITE (4G+5G)
SELECT
REGIONAL,
B.UF,
B.MUNICIPIO,
B.SITE,
'4G+5G' AS TECNOLOGIA,
SITE,
ROUND((1-(TEMPO / (CAST(PLANTA AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
FROM (
	SELECT
	*,
	COLETAS / CAST(PLANTA AS float) * 60 AS DENOMINADOR
	FROM (
		SELECT
		A.REGIONAL,
		A.UF,
        A.MUNICIPIO,
        A.SITE,
		COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
		ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM (SELECT * FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK) UNION ALL SELECT * FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES_HIST_2023 WITH(NOLOCK)) A 
		WHERE DATA_REFERENCIA >= '2023-08-01' AND DATA_REFERENCIA < '2023-09-01' AND TECNOLOGIA IN ('LTE', '5G') AND COLETAS_HMM > 0
		GROUP BY A.REGIONAL, A.UF, A.SITE
	)A
)B
ORDER BY REGIONAL, UF, B.SITE


--DISP. MENSAL POR SITE (3G+4G)
SELECT
UF+SITE,
'3G+4G' AS TECNOLOGIA,
REGIONAL,
UF,
SITE,
ROUND((1-(TEMPO / (CAST(PLANTA AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
FROM (
	SELECT
	*,
	COLETAS / CAST(PLANTA AS float) * 60 AS DENOMINADOR
	FROM (
		SELECT
		A.REGIONAL,
		A.UF,
        A.SITE,
		COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
		ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A
		WHERE DATA_REFERENCIA >= '2024-01-01' AND DATA_REFERENCIA < '2024-02-01' AND TECNOLOGIA IN ('WCDMA', 'LTE') AND COLETAS_HMM > 0
		GROUP BY A.REGIONAL, A.UF, A.SITE
	)A
)B
ORDER BY REGIONAL, UF, SITE

--===========================================================================================
SELECT COUNT (CASE WHEN TECNOLOGIA = 'LTE' THEN TECNOLOGIA ELSE 0 END) LTE ,
SIGLA_SITE 
FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
WHERE UF = 'SP' AND TECNOLOGIA = 'LTE'
GROUP BY UF, SIGLA_SITE


SELECT
    UF,
    SIGLA_SITE,
    TECNOLOGIA,
    COUNT(*) AS QTDE_SETORES
FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
GROUP BY UF, SIGLA_SITE, TECNOLOGIA
ORDER BY UF, SIGLA_SITE, TECNOLOGIA



DECLARE @colunas_pivot AS NVARCHAR(MAX)
DECLARE @comando_sql   AS NVARCHAR(MAX)

DROP TABLE IF EXISTS #DISP

SELECT
    UF,
    SIGLA_SITE,
    TECNOLOGIA,
    COUNT(*) AS QTDE_SETORES
INTO #DISP
FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
GROUP BY UF, SIGLA_SITE, TECNOLOGIA

SET @colunas_pivot = 
    STUFF((
        SELECT
             ',' + QUOTENAME(TECNOLOGIA)
        FROM #DISP
		GROUP BY TECNOLOGIA
		ORDER BY TECNOLOGIA
        FOR XML PATH('')
    ), 1, 1, '')
PRINT @colunas_pivot


SET @comando_sql = '
    SELECT * FROM (
        SELECT * FROM #DISP
    ) em_linha
    PIVOT (SUM(QTDE_SETORES) FOR TECNOLOGIA IN (' + @colunas_pivot + ')) em_colunas 
    ORDER BY UF, SIGLA_SITE'


--PRINT @comando_sql
EXECUTE(@comando_sql)

--=========================================================================
SELECT * FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES 
WHERE UF = 'BA' AND SITE = 'FCU' AND MONTH(DATA_REFERENCIA) = 10 AND YEAR(DATA_REFERENCIA) = 2023 AND TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0

SELECT * FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE UF = 'DF' AND SITE = 'HRT' AND MES = 12 AND ANO = 2023

--==========================================================
SELECT * FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_UF_HMM
WHERE ANO IN (2022,2023)
ORDER BY ANO, REGIONAL, UF, MES

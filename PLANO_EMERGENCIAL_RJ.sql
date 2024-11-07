--==================================================================================
--DISPONIBILIDADE MENSAL SITES RJ
--==================================================================================
DECLARE @DATA DATE = (SELECT MAX(DATA_REFERENCIA) FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM);
WITH TEMP AS
(
        SELECT
             DATA_REFERENCIA
            ,MENSAL.MES
            ,MENSAL.REGIONAL
            ,MENSAL.UF
            ,MENSAL.SITE
            ,MENSAL.MUNICIPIO
            ,CASE WHEN MENSAL.MUNICIPIO IN (
                'Belford Roxo',
                'Cachoeiras De Macacu',
                'Duque De Caxias',
                'Guapimirim',
                'Itaboraí',
                'Itaguaí',
                'Japeri',
                'Magé',
                'Mangaratiba',
                'Maricá',
                'Mesquita',
                'Nilópolis',
                'Niterói',
                'Nova Iguaçu',
                'Paracambi',
                'Queimados',
                'Rio Bonito',
                'Rio De Janeiro',
                'São Gonçalo',
                'São João De Meriti',
                'Seropédica',
                'Tanguá',
                'Teresópolis'
                ) 
                THEN 21
                ELSE '-'
             END CN
            ,MENSAL.DISPONIBILIDADE_GERAL
            ,DIARIO.DISPONIBILIDADE_GERAL AS 'DISP_D-1'
        FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM MENSAL
        INNER JOIN INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM DIARIO ON MENSAL.UF = DIARIO.UF AND MENSAL.SITE = DIARIO.SITE
        WHERE MENSAL.UF = 'RJ' AND MENSAL.ANO = 2023 AND MENSAL.MES IN (7,8,9,10) AND DIARIO.DATA_REFERENCIA = @DATA --AND MENSAL.SITE = '1DM'
)

SELECT
*
FROM 
(
SELECT
        DATA_REFERENCIA
        ,REGIONAL
        ,UF
        ,SITE
        ,MUNICIPIO
        ,CN
        ,[7] AS DISP_JUL
        ,[8] AS DISP_AGO
        ,[9] AS DISP_SET
        ,[10] AS DISP_OUT
        ,[DISP_D-1]
        ,CASE WHEN [10] >= 99.2 THEN 'A+'
              WHEN [10] >= 99 AND [10] < 99.2 THEN 'A'
              WHEN [10] >= 98 AND [10] < 99 THEN 'B'
              WHEN [10] >= 96 AND [10] < 98 THEN 'C'
              WHEN [10] >= 92 AND [10] < 96 THEN 'D'
              WHEN [10] < 92 THEN 'E'
        END NOTA_IND11_MES_ATUAL
FROM
        TEMP PIVOT (SUM(DISPONIBILIDADE_GERAL)
        FOR MES IN ([7],[8],[9],[10])) P
) A

EXCEPT

SELECT
*
FROM 
(
SELECT
        DATA_REFERENCIA
        ,REGIONAL
        ,UF
        ,SITE
        ,MUNICIPIO
        ,CN
        ,[7] AS DISP_JUL
        ,[8] AS DISP_AGO
        ,[9] AS DISP_SET
        ,[10] AS DISP_OUT
        ,[DISP_D-1]
        ,CASE WHEN [10] >= 99.2 THEN 'A+'
              WHEN [10] >= 99 AND [10] < 99.2 THEN 'A'
              WHEN [10] >= 98 AND [10] < 99 THEN 'B'
              WHEN [10] >= 96 AND [10] < 98 THEN 'C'
              WHEN [10] >= 92 AND [10] < 96 THEN 'D'
              WHEN [10] < 92 THEN 'E'
        END NOTA_IND11_MES_ATUAL
FROM
        TEMP PIVOT (SUM(DISPONIBILIDADE_GERAL)
        FOR MES IN ([7],[8],[9],[10])) P
) A
WHERE (DISP_JUL IS NULL AND DISP_AGO IS NULL AND DISP_SET IS NULL AND DISP_OUT IS NULL) OR (DISP_OUT IS NULL) OR ([DISP_D-1] IS NULL)

--==================================================================================
--MINUTOS CELLDOWNTIME MENSAL SITES RJ
--==================================================================================
WITH TEMP AS
(
        SELECT
             MES
            ,REGIONAL
            ,UF
            ,SITE
            ,MUNICIPIO
            ,CASE WHEN MUNICIPIO IN (
                'Belford Roxo',
                'Cachoeiras De Macacu',
                'Duque De Caxias',
                'Guapimirim',
                'Itaboraí',
                'Itaguaí',
                'Japeri',
                'Magé',
                'Mangaratiba',
                'Maricá',
                'Mesquita',
                'Nilópolis',
                'Niterói',
                'Nova Iguaçu',
                'Paracambi',
                'Queimados',
                'Rio Bonito',
                'Rio De Janeiro',
                'São Gonçalo',
                'São João De Meriti',
                'Seropédica',
                'Tanguá',
                'Teresópolis'
                ) 
                THEN 21
                ELSE '-'
             END CN
            ,MINUTOS_GERAL
        FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
        WHERE UF = 'RJ' AND ANO = 2023 AND MES IN (7,8,9,10)
)

SELECT
*
FROM 
(
SELECT
        REGIONAL
        ,UF
        ,SITE
        ,MUNICIPIO
        ,CN
        ,[7] AS JULHO
        ,[8] AS AGOSTO
        ,[9] AS SETEMBRO
        ,[10] AS OUTUBRO
FROM
        TEMP PIVOT (SUM(MINUTOS_GERAL)
        FOR MES IN ([7],[8],[9],[10])) P
) A

EXCEPT

SELECT
*
FROM 
(
SELECT
        REGIONAL
        ,UF
        ,SITE
        ,MUNICIPIO
        ,CN
        ,[7] AS JULHO
        ,[8] AS AGOSTO
        ,[9] AS SETEMBRO
        ,[10] AS OUTUBRO
FROM
        TEMP PIVOT (SUM(MINUTOS_GERAL)
        FOR MES IN ([7],[8],[9],[10])) P
) A
WHERE (JULHO IS NULL AND AGOSTO IS NULL AND SETEMBRO IS NULL AND OUTUBRO IS NULL)
ORDER BY OUTUBRO DESC

--=======================================================================================================================
--EVOLUCAO DIARIA DAS NOTAS DE DISP DOS SITES
--=======================================================================================================================
DECLARE @HOJE DATE = (SELECT MAX(DATA_REFERENCIA) FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM)
DECLARE @SEMANA DATE = DATEADD(DAY,-7,(SELECT MAX(DATA_REFERENCIA) FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM))

SELECT
DATA_REFERENCIA
,REGIONAL
,UF
,NOTA_IND11
,COUNT(NOTA_IND11) AS QTDE_TOTAL
,CASE   WHEN NOTA_IND11 = 'A+' THEN 1
        WHEN NOTA_IND11 = 'A' THEN 2
        WHEN NOTA_IND11 = 'B' THEN 3
        WHEN NOTA_IND11 = 'C' THEN 4
        WHEN NOTA_IND11 = 'D' THEN 5
        WHEN NOTA_IND11 = 'E' THEN 6
END AS NOTA_IND11_COD
FROM
(
        SELECT
        DATA_REFERENCIA
        ,REGIONAL
        ,UF
        ,MUNICIPIO
        ,SITE
        ,CASE WHEN DISPONIBILIDADE_GERAL >= 99.2 THEN 'A+'
                    WHEN DISPONIBILIDADE_GERAL >= 99 AND DISPONIBILIDADE_GERAL < 99.2 THEN 'A'
                    WHEN DISPONIBILIDADE_GERAL >= 98 AND DISPONIBILIDADE_GERAL < 99 THEN 'B'
                    WHEN DISPONIBILIDADE_GERAL >= 96 AND DISPONIBILIDADE_GERAL < 98 THEN 'C'
                    WHEN DISPONIBILIDADE_GERAL >= 92 AND DISPONIBILIDADE_GERAL < 96 THEN 'D'
                    WHEN DISPONIBILIDADE_GERAL < 92 THEN 'E'
                END NOTA_IND11
        FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM DIARIO
        WHERE DIARIO.UF = 'RJ' AND DIARIO.ANO = 2023 AND DATA_REFERENCIA BETWEEN @SEMANA AND @HOJE--AND DIARIO.SITE = '1DM'
) A
WHERE NOTA_IND11 IS NOT NULL
GROUP BY DATA_REFERENCIA, REGIONAL, UF, NOTA_IND11
ORDER BY DATA_REFERENCIA, NOTA_IND11_COD



--================================================================================================================================
--DISPONINIBLIDADE MENSAL UF
--================================================================================================================================
SELECT
*
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_UF_HMM
WHERE UF = 'RJ' AND ANO = 2023 AND MES IN (7, 8, 9, 10)
ORDER BY ANO, MES

--================================================================================================================================
--DISPONINIBLIDADE DIARIA UF
--================================================================================================================================
DECLARE @HOJE DATE = (SELECT MAX(DATA_REFERENCIA) FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM)
DECLARE @SEMANA DATE = DATEADD(DAY,-7,(SELECT MAX(DATA_REFERENCIA) FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM))

SELECT
DATA_REFERENCIA
,REGIONAL
,UF
,DISPONIBILIDADE_GERAL
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_UF_HMM WITH(NOLOCK)
WHERE UF = 'RJ' AND DATA_REFERENCIA BETWEEN @SEMANA AND @HOJE
ORDER BY DATA_REFERENCIA


--=========================================================================================================
--
--=========================================================================================================
WITH MIN_UF AS
(
SELECT
UF,
SUM(MINUTOS_GERAL) AS MINUTOS_UF
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM WITH(NOLOCK)
WHERE ANO = 2023 AND MES = 10 AND UF = 'RJ'
GROUP BY UF
),

MIN_SITE AS
(
SELECT
UF,
SITE,
SUM(MINUTOS_GERAL) AS MINUTOS_SITE
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM WITH(NOLOCK)
WHERE ANO = 2023 AND MES = 10 AND UF = 'RJ' AND SITE = 'TBP'
GROUP BY UF, SITE
)

SELECT
MIN_SITE.UF,
MIN_SITE.SITE,
MINUTOS_UF,
MINUTOS_SITE,
ROUND((CAST(MINUTOS_SITE AS FLOAT)/CAST(MINUTOS_UF AS FLOAT))*100,2) AS PERC_CONTRIBUICAO
FROM MIN_UF
INNER JOIN MIN_SITE ON MIN_UF.UF = MIN_SITE.UF



WITH MIN_UF AS
(
SELECT
UF,
SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_UF
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
WHERE YEAR(DATA_REFERENCIA) = 2023 AND MONTH(DATA_REFERENCIA) = 10 AND UF = 'RJ' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM'
GROUP BY UF
),

MIN_SITE AS
(
SELECT
UF,
SITE,
SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_SITE
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
WHERE YEAR(DATA_REFERENCIA) = 2023 AND MONTH(DATA_REFERENCIA) = 10 AND UF = 'RJ' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM' AND SITE = 'TBP'
GROUP BY UF, SITE
)

SELECT
MIN_SITE.UF,
MIN_SITE.SITE,
MINUTOS_UF,
MINUTOS_SITE,
ROUND((CAST(MINUTOS_SITE AS FLOAT)/CAST(MINUTOS_UF AS FLOAT))*100,2) AS PERC_CONTRIBUICAO
FROM MIN_UF
INNER JOIN MIN_SITE ON MIN_UF.UF = MIN_SITE.UF

--======================================================================================================================================================================
WITH MIN_MUNICIPIO AS
(
SELECT
UF,
MUNICIPIO,
SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_MUNICIPIO,
SUM(COLETAS_HMM) AS COLETAS_MUNICIPIO
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
WHERE YEAR(DATA_REFERENCIA) = 2023 AND MONTH(DATA_REFERENCIA) = 10 AND UF = 'RJ' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM' AND MUNICIPIO = 'RIO DE JANEIRO'
GROUP BY UF, MUNICIPIO
),

MIN_SITE AS
(
SELECT
UF,
MUNICIPIO,
SITE,
SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_SITE,
SUM(COLETAS_HMM) AS COLETAS_SITE
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
WHERE YEAR(DATA_REFERENCIA) = 2023 AND MONTH(DATA_REFERENCIA) = 10 AND UF = 'RJ' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM'-- AND SITE = 'TBP'
GROUP BY UF, MUNICIPIO, SITE
)


SELECT
MIN_SITE.UF,
MIN_SITE.SITE,
MIN_SITE.MUNICIPIO,
MIN_MUNICIPIO.MINUTOS_MUNICIPIO,
MIN_SITE.MINUTOS_SITE,
ROUND((CAST(MINUTOS_SITE AS FLOAT)/CAST(MINUTOS_MUNICIPIO AS FLOAT))*100,2) AS PERC_CONTRIBUICAO
FROM MIN_MUNICIPIO
INNER JOIN MIN_SITE ON MIN_MUNICIPIO.UF = MIN_SITE.UF AND MIN_MUNICIPIO.MUNICIPIO = MIN_SITE.MUNICIPIO
ORDER BY PERC_CONTRIBUICAO DESC


--================================================================================================================================================
--DISPONIBILIDADE MENSAL
--================================================================================================================================================

SELECT
ANO,
MES,
REGIONAL,
UF,
MUNICIPIO,
SUM(MINUTOS_MUNICIPIO) AS MINUTOS,
SUM(MINUTOS_MAX_MUNICIPIO) AS MINUTOS_MAX_MUNICIPIO,
ROUND((1-(CAST(SUM(MINUTOS_MUNICIPIO) AS FLOAT)/CAST(SUM(MINUTOS_MAX_MUNICIPIO) AS FLOAT)))*100,2) AS DISP_MENSAL_MUNICIPIO
FROM
(
		SELECT
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				CASE WHEN REGIONAL = 'MG/RJ/ES' THEN 'SUD'
				     WHEN REGIONAL = 'BA/SE/NE' THEN 'NE'
				ELSE REGIONAL
				END REGIONAL,
				UF,
				MUNICIPIO,
				SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_MUNICIPIO,
				SUM(COLETAS_HMM)*60 AS MINUTOS_MAX_MUNICIPIO
				--ROUND((1-(CAST(SUM(TEMPO_CONTADOR_HMM) AS FLOAT)/CAST(SUM(COLETAS_HMM)*60 AS FLOAT)))*100,2) AS DISP_DIARIA_MUNICIPIO
		FROM 
				SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
		WHERE 
				TECNOLOGIA <> 'GSM'
				AND TEMPO_CONTADOR_HMM >= 0				
				AND UF = 'RJ' AND MUNICIPIO = 'RIO DE JANEIRO'
                                AND MONTH(DATA_REFERENCIA) = 10 AND YEAR(DATA_REFERENCIA) = 2023
		GROUP BY 
				DATA_REFERENCIA,
                                REGIONAL,
				UF,
				MUNICIPIO
) A
WHERE MES = DATEPART(MONTH,GETDATE()) AND ANO = DATEPART(YEAR,GETDATE())
GROUP BY
		ANO,
		MES,
		REGIONAL,
		UF,
		MUNICIPIO

SELECT
SUM(MINUTOS_GERAL),
SUM(MAESTRO.TEMPO_CONTADOR_HMM)
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM IND
INNER JOIN SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES MAESTRO ON IND.UF = MAESTRO.UF AND IND.MUNICIPIO = MAESTRO.MUNICIPIO AND IND.MES = MONTH(MAESTRO.DATA_REFERENCIA) AND IND.ANO = YEAR(MAESTRO.DATA_REFERENCIA)
WHERE IND.UF = 'RJ' AND IND.MUNICIPIO = 'RIO DE JANEIRO' AND MAESTRO.TECNOLOGIA <> 'GSM' AND MAESTRO.TEMPO_CONTADOR_HMM >= 0 AND IND.ANO = 2023 AND IND.MES = 10

WITH IND AS
(
SELECT
UF,
MUNICIPIO,
SITE,
SUM(MINUTOS_GERAL) AS MIN_MUN
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
WHERE UF = 'RJ' AND MUNICIPIO = 'RIO DE JANEIRO' AND ANO = 2023 AND MES = 10
GROUP BY UF, MUNICIPIO, SITE
),

MAESTRO AS
(
SELECT
UF,
MUNICIPIO,
SUM(TEMPO_CONTADOR_HMM) AS MIN_MUNICIPIO,
SUM(COLETAS_HMM) AS MIN_MAX_MUNICIPIO
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
WHERE YEAR(DATA_REFERENCIA) = 2023 AND MONTH(DATA_REFERENCIA) = 10 AND UF = 'RJ' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM' AND UF = 'RJ' AND MUNICIPIO = 'RIO DE JANEIRO'
GROUP BY UF, MUNICIPIO
)


SELECT

FROM IND
INNER JOIN MAESTRO ON IND.UF = MAESTRO.UF AND IND.MUNICIPIO = MAESTRO.MUNICIPIO



--==================================================================================================================================================================
--TABELA DE OFENSORES
--==================================================================================================================================================================
DECLARE @MES INT = MONTH(GETDATE()-1)

SELECT DISTINCT
        --A.*,
        CONVERT(DATE,GETDATE(),103) AS DATA_REFERENCIA,
        A.ANO,
        A.MES,
        A.UF,
        A.CN,
        A.CLASSIFICACAO_MUNICIPIO AS CLASSIF,
        A.MUNICIPIO,
        A.DISP_MUNICIPIO_MES AS DISP_MUNICIPIO,
        A.SITE,
        A.DISP_SITE_DIA AS DISP_DIA,
        A.DISP_SITE_MES AS DISP_MES,
        A.TEMPO AS MINUTOS_CDT,
        CASE WHEN A.TIPO_SEM_CDT IS NULL THEN CONCAT('-',A.TIPO_CDT)
        ELSE A.TIPO_SEM_CDT
        END AS CDT

        --CASE WHEN B.TEMPO >= A.TEMPO THEN 1 ELSE 0 END FLG_PIORA,
        --CASE WHEN A.DISP_SITE_DIA < 99 AND EV.FLG_EVENTO IS NULL THEN 0 ELSE 1 END FLG_EVENTO
FROM    
        INDICADORES_CORAN.dbo.TBL_CELLDOWNTIME_RANKING_MENSAL_SITES_HMM A
        --LEFT JOIN (SELECT A.* FROM SISTEMA_MAESTRO..AUX_SEMANAS A INNER JOIN (SELECT MAX(DATA_REFERENCIA)-1 AS DTMAX FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES)DTMAX ON A.DATA_REFERENCIA = DTMAX.DTMAX)D ON A.ANO = D.ANO AND A.MES = D.MES
        LEFT JOIN INDICADORES_CORAN.dbo.TBL_CELLDOWNTIME_RANKING_MENSAL_SITES_HMM B ON A.UF = B.UF AND A.SITE = B.SITE AND B.MES = A.MES - 1
        LEFT JOIN (SELECT DISTINCT UF, SITE, 1 AS FLG_EVENTO FROM P1_REAL_TIME..TBT_IMP_ATIVOS_CAMPO_COMPLETA WITH (NOLOCK))EV ON A.UF = EV.UF AND A.SITE = EV.SITE
WHERE   
        A.ANO = YEAR(GETDATE())
        AND A.MES in (MONTH(GETDATE())-1,MONTH(GETDATE())) 
        AND A.UF = 'RJ'
        --AND A.SITE = 'GTS'
        AND A.MES = @MES
ORDER BY MINUTOS_CDT DESC

--==================================================================================================================================================================
--TABELA DE OFENSORES ENVIADA DIARIAMENTE
--==================================================================================================================================================================
SELECT
        --A.*,
        CONVERT(DATE,GETDATE(),103) AS DATA_REFERENCIA,
        A.UF,
        A.CN,
        A.CLASSIFICACAO_MUNICIPIO AS CLASSIF,
        A.MUNICIPIO,
        A.DISP_MUNICIPIO_MES AS DISP_MES_MUNICIPIO,
        A.SITE,
        A.DISP_SITE_DIA AS DISP_DIA,
        A.DISP_SITE_MES AS DISP_MES,
        A.TEMPO AS MINUTOS_CDT,
        CASE WHEN A.TIPO_SEM_CDT IS NULL THEN CONCAT('-',A.TIPO_CDT,' Dias')
        ELSE CONCAT(A.TIPO_SEM_CDT,' Dias')
        END AS CDT,
        '' AS CAUSA_RAIZ,
        '' AS AREA_TECNICA,
        '' AS DATA_OCORRENCIA,
        '' AS PLANO_ACAO,
        '' AS PRAZO
FROM    
        INDICADORES_CORAN.dbo.TBL_CELLDOWNTIME_RANKING_MENSAL_SITES_HMM A
        --LEFT JOIN (SELECT A.* FROM SISTEMA_MAESTRO..AUX_SEMANAS A INNER JOIN (SELECT MAX(DATA_REFERENCIA)-1 AS DTMAX FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES)DTMAX ON A.DATA_REFERENCIA = DTMAX.DTMAX)D ON A.ANO = D.ANO AND A.MES = D.MES
        --LEFT JOIN INDICADORES_CORAN.dbo.TBL_CELLDOWNTIME_RANKING_MENSAL_SITES_HMM B ON A.UF = B.UF AND A.SITE = B.SITE AND B.MES = A.MES - 1
        --LEFT JOIN (SELECT DISTINCT UF, SITE, 1 AS FLG_EVENTO FROM P1_REAL_TIME..TBT_IMP_ATIVOS_CAMPO_COMPLETA WITH (NOLOCK))EV ON A.UF = EV.UF AND A.SITE = EV.SITE
WHERE   
        A.ANO = YEAR(GETDATE())
        AND A.MES = MONTH(GETDATE()-1)
        AND A.DISP_SITE_DIA <= 95
        AND A.TEMPO >= 5000
        AND A.UF = 'RJ'
        --AND A.SITE = 'GTS'
ORDER BY MINUTOS_CDT DESC

--==================================================================================================================================================================
--EVOLUÇÃO DOS SITES OFENSORES
--==================================================================================================================================================================


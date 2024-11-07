--==================================================================================
--DISPONIBILIDADE MENSAL SITES REGIONAL NO
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
            ,MENSAL.DISPONIBILIDADE_GERAL
            ,DIARIO.DISPONIBILIDADE_GERAL AS 'DISP_D-1'
        FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM MENSAL
        INNER JOIN INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_SITE_HMM DIARIO ON MENSAL.UF = DIARIO.UF AND MENSAL.SITE = DIARIO.SITE
        WHERE MENSAL.UF IN ('AM','AP','PA','MA','RR') AND MENSAL.ANO = 2023 AND MENSAL.MES IN (7,8,9,10) AND DIARIO.DATA_REFERENCIA = @DATA --AND MENSAL.SITE = '1DM'
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
--MINUTOS CELLDOWNTIME MENSAL SITES REGIONAL NO
--==================================================================================
WITH TEMP AS
(
        SELECT
             MES
            ,REGIONAL
            ,UF
            ,SITE
            ,MUNICIPIO
            ,MINUTOS_GERAL
        FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_SITE_HMM
        WHERE UF IN ('AM','AP','PA','MA','RR') AND ANO = 2023 AND MES IN (7,8,9,10)
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
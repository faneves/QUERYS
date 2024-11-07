  --POR DIARIO POR MUNICIPIO

WITH SLA AS
(
    SELECT
            MES,
            DIA,
            STATUS_INDICADOR,
            INDICADOR,
            UF,
            MUNICIPIO,
            COUNT(STATUS_INDICADOR) AS QTDE_TAS
    FROM
    (
            SELECT
                    ANO,
                    MES,
                    DATEPART(DAY,DATA_ENCERRAMENTO) AS DIA,
                    INDICADOR,
                    UF,
                    MUNICIPIO,
                    STATUS_INDICADOR
            FROM  
                    AVALIACAO_CAMPO..TAS_FORA WITH(NOLOCK)
            WHERE
                    INDICADOR IN ('SLA P1 4 Horas', 'SLA P2 12 Horas') AND MUNICIPIO IN ('SALVADOR', 'RECIFE', 'FORTALEZA', 'ARACAJU')
                    AND ID_PLANTA =1 AND ANO = 2023 AND MES >=5
    )A
    GROUP BY
            MES, DIA, INDICADOR, STATUS_INDICADOR, UF, MUNICIPIO
),
DISP AS (
        SELECT
                UF,
                MES,
                DIA,
                'Disp' AS INDICADOR,
                MUNICIPIO,
                DISPONIBILIDADE_GERAL AS DISPONIBILIDADE
        FROM
                INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_MUNICIPIO_HMM
        WHERE
                MUNICIPIO IN ('SALVADOR', 'RECIFE', 'FORTALEZA', 'ARACAJU')
                AND ANO = 2023 AND MES >= 5
        )
--=================
--QUERY PRINCIPAL
--=================
        SELECT
                DISP.MES,
                DISP.DIA,
                DISP.UF,
                DISP.MUNICIPIO,
                SLA.INDICADOR,
                [0],
                [1],
                --DISP.INDICADOR,
                SLA,
                DISPONIBILIDADE
        FROM DISP
        LEFT JOIN (
                    SELECT
                        UF,
                        MES,
                        DIA,
                        CASE WHEN INDICADOR = 'SLA P1 4 Horas' THEN 'SLA P1'
                             WHEN INDICADOR = 'SLA P2 12 Horas' THEN 'SLA P2'
                             END INDICADOR,
                        MUNICIPIO,
                        [0],
                        [1],
                        --((CAST([1] AS NUMERIC(38,2))/CAST(([0]+[1]) AS NUMERIC(38,2))))*100 AS SLA
                        REPLACE((CAST([1] AS NUMERIC(38,2))/CAST(([0]+[1]) AS NUMERIC(38,2)))*100,'.',',') AS SLA
                    FROM
                    (
                        SELECT
                                MES,
                                DIA,
                                INDICADOR,
                                UF,
                                MUNICIPIO,
                                ISNULL([0],0) AS [0],
                                ISNULL([1],0) AS [1]
                        FROM
                                SLA PIVOT (SUM(QTDE_TAS)
                                FOR STATUS_INDICADOR IN ([0],[1]))P
                    ) A
        )SLA ON DISP.MES = SLA.MES AND DISP.DIA = SLA.DIA AND DISP.MUNICIPIO COLLATE Latin1_General_CI_AI = SLA.MUNICIPIO COLLATE Latin1_General_CI_AI
ORDER BY DIA, SLA.UF, SLA.MUNICIPIO, SLA.INDICADOR
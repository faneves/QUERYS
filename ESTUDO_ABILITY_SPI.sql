-- ESTUDO ABILITY_SPI
WITH EVENTOS AS (
    SELECT
        [ANO]
        ,[MES]
        ,[EVENTO]
        ,[EVENTO_ORIGEM]
        ,[EVENTO_RAIZ]
        ,[TIPO_BILHETE]
        ,[TIPO_REDE]
        ,[TIPO_TA]
        ,[PRIORIDADE]
        ,[REGIONAL]
        ,[GERENCIA]
        ,[UF]
        ,A.MUNICIPIO
        ,B.NOME_REGIONAL
        ,[SITE]
        ,[DATA_BAIXA]
        ,[AREA_BAIXA]
        ,[GRUPO_BAIXA]
        ,[GRUPO_RESPONSAVEL_BAIXA]
        ,[USUARIO_RESPONSAVEL_BAIXA]
        ,[CLASSIFICACAO_GRUPO_BAIXA]
        ,[FLAG_SLA_P1_4HORAS_CAMPO]
        ,[FLAG_SLA_P2_12HORAS_CAMPO]
        ,[FLAG_BASELINE]
        ,[REGIAO_OPERACIONAL]
        ,[NOME_TECNICO]
        ,[TEMPO_CAMPO_TERCEIRA]
        ,[EMPRESA_CONTRATO]
        ,[TEMPO_CAMPO_TERCEIRA_P1]
        ,[TEMPO_CAMPO_TERCEIRA_P2]
    FROM INDICADORES_CORAN..TBL_EVENTOS_FECHADOS A WITH(NOLOCK)
    LEFT JOIN INDICADORES_CORAN..TBA_DIVISAO_MUNICIPIOS_SP_FIXA B WITH(NOLOCK) ON A.UF = 'SP' AND A.MUNICIPIO = B.MUNICIPIO
    WHERE  
        ANO = 2023
        -- AND MES = 9 
        AND EMPRESA_CONTRATO = 'ABILITY' 
        AND UF = 'SP' 
        AND NOME_REGIONAL = 'SPI'
        AND FLAG_BASELINE = 1
        AND (TEMPO_CAMPO_TERCEIRA_P1 IS NOT NULL OR TEMPO_CAMPO_TERCEIRA_P2 IS NOT NULL)
),

GENESIS AS (

SELECT
    CASE WHEN PGT.NIVEL_ATENDIMENTO = 1 THEN 'Sem Atuação'
         WHEN PGT.NIVEL_ATENDIMENTO = 2 THEN 'Com Atuação'
         WHEN PGT.NIVEL_ATENDIMENTO = 3 THEN 'Energia Alternativa'
    END NIVEL_ATENDIMENTO,
    PGT.EVENTO,
    CASE WHEN ID_OS_FLUXOS = 4 THEN 'SIM' ELSE 'NAO' END AS FLUXO,
    ID_USUARIO
FROM GENESIS..WFM_TBF_OS_PAGAMENTO PGT WITH(NOLOCK)
LEFT JOIN GENESIS..WFM_TBA_OS_TIPO_PAGAMENTO TIPO_PGT WITH(NOLOCK) ON PGT.ID_OS_TIPO_PAGAMENTO = TIPO_PGT.ID_OS_TIPO_PAGAMENTO
LEFT JOIN GENESIS..WFM_TBF_OS_VIDA VIDA WITH(NOLOCK) ON PGT.NUM_OS = VIDA.NUM_OS
WHERE DATEPART(YEAR,PERIODO) = 2023
--  AND PGT.EVENTO = 311423650

),

VIDA AS (

SELECT
    CASE WHEN PGT.NIVEL_ATENDIMENTO = 1 THEN 'Sem Atuação'
         WHEN PGT.NIVEL_ATENDIMENTO = 2 THEN 'Com Atuação'
         WHEN PGT.NIVEL_ATENDIMENTO = 3 THEN 'Energia Alternativa'
    END NIVEL_ATENDIMENTO,
    PGT.EVENTO,
    CASE WHEN ID_OS_FLUXOS = 4 THEN 'SIM' ELSE 'NAO' END AS FLUXO,
    ID_USUARIO
FROM GENESIS..WFM_TBF_OS_PAGAMENTO PGT WITH(NOLOCK)
LEFT JOIN GENESIS..WFM_TBA_OS_TIPO_PAGAMENTO TIPO_PGT WITH(NOLOCK) ON PGT.ID_OS_TIPO_PAGAMENTO = TIPO_PGT.ID_OS_TIPO_PAGAMENTO
LEFT JOIN GENESIS..WFM_TBF_OS_VIDA VIDA WITH(NOLOCK) ON PGT.NUM_OS = VIDA.NUM_OS
WHERE DATEPART(YEAR,PERIODO) = 2023
 --AND PGT.EVENTO = 311423650
)




SELECT
    ANO,
    MES,
    COUNT(CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO <> -1 THEN 1 END) AS QTDE_FORAM_P1,
    COUNT(CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO <> -1 THEN 1 END) AS QTDE_FORAM_P2,
    COUNT(CASE WHEN (FLAG_SLA_P1_4HORAS_CAMPO <> -1 OR FLAG_SLA_P2_12HORAS_CAMPO <> -1) THEN 1 END) AS QTDE_P1_P2,
    COUNT(CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO = 1 THEN 1 END) AS P1_DENTRO_PRAZO,
    COUNT(CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO = 1 THEN 1 END) AS P2_DENTRO_PRAZO,
    ROUND((CAST(COUNT(CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO = 1 THEN 1 END) AS FLOAT)/CAST(COUNT(CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO <> -1 THEN 1 END) AS FLOAT))*100 ,0) AS SLA_P1,
    ROUND((CAST(COUNT(CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO = 1 THEN 1 END) AS FLOAT)/CAST(COUNT(CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO <> -1 THEN 1 END) AS FLOAT))*100 ,0)AS SLA_P2,
    COUNT(DISTINCT CASE WHEN GENESIS.NIVEL_ATENDIMENTO = 'Sem Atuação' THEN GENESIS.EVENTO END) AS 'SEM_ATUACAO',
    COUNT(DISTINCT CASE WHEN GENESIS.NIVEL_ATENDIMENTO = 'Com Atuação' THEN GENESIS.EVENTO END) AS 'COM_ATUACAO',
    COUNT(DISTINCT CASE WHEN GENESIS.NIVEL_ATENDIMENTO = 'Energia Alternativa' THEN GENESIS.EVENTO END) AS 'ENERGIA_ALTERNATIVA',
    COUNT(DISTINCT CASE WHEN GENESIS.FLUXO = 'SIM' AND ID_USUARIO <> 0 THEN GENESIS.ID_USUARIO END) AS QTDE_TECNICOS
FROM EVENTOS
LEFT JOIN GENESIS ON EVENTOS.EVENTO = GENESIS.EVENTO
GROUP BY ANO, MES





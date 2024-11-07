
-- 7 dias antes da data de migracao
SELECT
    'SETE_DIAS_ANTES' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103)-7 AND UF = 'MG' 
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 7 dias depois da data de migracao
SELECT
    'SETE_DIAS_DEPOIS' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103)+7 AND UF = 'MG' 
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 15 dias antes da data de migracao
SELECT
    'QUINZE_DIAS_ANTES' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103)-15 AND UF = 'MG' 
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 15 dias depois da data de migracao
SELECT
    'QUINZE_DIAS_DEPOIS' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103)+15 AND UF = 'MG'
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 30 dias antes da data de migracao
SELECT
    'TRINTA_DIAS_ANTES' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103)-30 AND UF = 'MG'
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 30 dias depois da data de migracao
SELECT
    'TRINTA_DIAS_DEPOIS' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103)+30 AND UF = 'MG'
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 45 dias antes da data de migracao
SELECT
    'QUARENTA_CINCO_DIAS_ANTES' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103)-45 AND UF = 'MG' 
GROUP BY A.DATA_REFERENCIA,REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS

UNION ALL

-- 45 dias depois da data de migracao
SELECT
    'QUARENTA_CINCO_DIAS_DEPOIS' AS TEMPO,
    A.DATA_REFERENCIA,
    A.UF,
    A.REGIONAL,
    A.SITE,
    B.DT_MIGRACAO,
    STATUS_ATIVACAO,
    EQUIPAMENTO,
    ID_METRO,
    HOSTNAME,
    LOCALIDADE,
    STATUS_ESTRUTURANTE,
    STATUS_SUBGRUPO,
    [HL4-PREDECESSOR],
    [HL5D-PREDECESSOR],
    EPS,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN CAST(TEMPO_CONTADOR_HMM AS FLOAT) END)/NULLIF((SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN CAST(COLETAS_HMM AS FLOAT) END)*60),0)))*100),2) AS DISP_4G
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN QUALIDADE..TBL_ESTRUTURANTES_MG_BI B WITH(NOLOCK) ON A.UF COLLATE Latin1_General_CI_AI = 'MG' AND A.UF+A.SITE COLLATE Latin1_General_CI_AI = B.SITE COLLATE Latin1_General_CI_AI
WHERE A.DATA_REFERENCIA >= CONVERT(DATETIME,DT_MIGRACAO,103) AND A.DATA_REFERENCIA <= CONVERT(DATETIME,DT_MIGRACAO,103)+45 AND UF = 'MG' 
GROUP BY A.DATA_REFERENCIA, REGIONAL, UF, A.SITE, DT_MIGRACAO,STATUS_ATIVACAO,EQUIPAMENTO,ID_METRO,HOSTNAME,LOCALIDADE,STATUS_ESTRUTURANTE,STATUS_SUBGRUPO,[HL4-PREDECESSOR],[HL5D-PREDECESSOR],EPS





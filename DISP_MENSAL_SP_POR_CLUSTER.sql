-- ===============================================================
-- DISP MENSAL SP POR CLUSTER
-- ===============================================================
DECLARE @ANO INT = (SELECT CASE WHEN YEAR(GETDATE()) = YEAR(GETDATE()-1) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()-1) END) 
DECLARE @MES INT = (SELECT CASE WHEN MONTH(GETDATE()) = MONTH(GETDATE()-1) THEN MONTH(GETDATE()) ELSE MONTH(GETDATE()-1) END) 

SELECT
    ANO,
    MES, 
	UF,
    C.CLUSTER AS CLUSTER,
    COUNT(DISTINCT SITE) AS QTDE_SITES,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_3G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '5G' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = '5G' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_5G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA <> 'GSM' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA <> 'GSM' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_GERAL,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G_5G
    
FROM (
    SELECT
        YEAR(DATA_REFERENCIA) AS ANO,
        MONTH(DATA_REFERENCIA) AS MES,
        A.TECNOLOGIA,
        A.UF,
        B.CLUSTER,
        CAST(TEMPO_CONTADOR_HMM AS FLOAT) AS TEMPO_CONTADOR_HMM,
        CAST(COLETAS_HMM AS FLOAT) AS COLETAS_HMM,
        A.SITE
    FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
    INNER JOIN SISTEMA_MAESTRO..TBA_PLANTA_MOVEL B WITH(NOLOCK) ON A.UF = B.UF AND A.SITE = B.SIGLA_SITE
    WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND A.UF = 'SP' AND B.CLUSTER IS NOT NULL
) C
GROUP BY ANO, MES, UF, C.CLUSTER


--SELECT * FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL WHERE UF = 'SP' AND CLUSTER IS NOT NULL


-- ===============================================================
-- DISP MENSAL SP POR CLUSTER E REGIAO_CLUSTER
-- ===============================================================
DECLARE @ANO INT = (SELECT CASE WHEN YEAR(GETDATE()) = YEAR(GETDATE()-1) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()-1) END) 
DECLARE @MES INT = (SELECT CASE WHEN MONTH(GETDATE()) = MONTH(GETDATE()-1) THEN MONTH(GETDATE()) ELSE MONTH(GETDATE()-1) END) 

SELECT
    ANO,
    MES, 
	UF,
    C.CLUSTER AS CLUSTER,
    C.REGIAO_CLUSTER,
    COUNT(DISTINCT SITE) AS QTDE_SITES, 
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_3G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '5G' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = '5G' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_5G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA <> 'GSM' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA <> 'GSM' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_GERAL,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G_5G
    
FROM (
    SELECT
        YEAR(DATA_REFERENCIA) AS ANO,
        MONTH(DATA_REFERENCIA) AS MES,
        A.TECNOLOGIA,
        A.UF,
        B.CLUSTER,
        B.REGIAO_CLUSTER,
        CAST(TEMPO_CONTADOR_HMM AS FLOAT) AS TEMPO_CONTADOR_HMM,
        CAST(COLETAS_HMM AS FLOAT) AS COLETAS_HMM,
        A.SITE
    FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
    INNER JOIN SISTEMA_MAESTRO..TBA_PLANTA_MOVEL B WITH(NOLOCK) ON A.UF = B.UF AND A.SITE = B.SIGLA_SITE
    WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND A.UF = 'SP' AND B.CLUSTER IS NOT NULL
) C
GROUP BY ANO, MES, UF, C.CLUSTER, C.REGIAO_CLUSTER



-- ===============================================================
-- SITES OFENSORES
-- ===============================================================
DECLARE @ANO INT = (SELECT CASE WHEN YEAR(GETDATE()) = YEAR(GETDATE()-1) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()-1) END) 
DECLARE @MES INT = (SELECT CASE WHEN MONTH(GETDATE()) = MONTH(GETDATE()-1) THEN MONTH(GETDATE()) ELSE MONTH(GETDATE()-1) END) 

SELECT
    ANO,
    MES, 
	UF,
    C.CLUSTER,
    C.REGIAO_CLUSTER,
    C.SITE, 
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_3G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '5G' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = '5G' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_5G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA <> 'GSM' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA <> 'GSM' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_GERAL,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G_5G
    
FROM (
    SELECT
        YEAR(DATA_REFERENCIA) AS ANO,
        MONTH(DATA_REFERENCIA) AS MES,
        A.TECNOLOGIA,
        A.UF,
        B.CLUSTER,
        B.REGIAO_CLUSTER,
        CAST(TEMPO_CONTADOR_HMM AS FLOAT) AS TEMPO_CONTADOR_HMM,
        CAST(COLETAS_HMM AS FLOAT) AS COLETAS_HMM,
        A.SITE
    FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
    INNER JOIN SISTEMA_MAESTRO..TBA_PLANTA_MOVEL B WITH(NOLOCK) ON A.UF = B.UF AND A.SITE = B.SIGLA_SITE
    WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND A.UF = 'SP' AND B.CLUSTER IS NOT NULL
) C
GROUP BY ANO, MES, UF, C.SITE, CLUSTER, REGIAO_CLUSTER


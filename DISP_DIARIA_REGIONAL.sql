
-- =================================
-- DISP DIARIA POR REGIONAL
-- =================================
DECLARE @ANO INT = (SELECT CASE WHEN YEAR(GETDATE()) = YEAR(GETDATE()-1) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()-1) END) 
DECLARE @MES INT = (SELECT CASE WHEN MONTH(GETDATE()) = MONTH(GETDATE()-1) THEN MONTH(GETDATE()) ELSE MONTH(GETDATE()-1) END) 

SELECT
    ANO,
    MES,
	DIA, 
    REGIONAL, 
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'WCDMA' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_3G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '5G' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA = '5G' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_5G,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA <> 'GSM' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA <> 'GSM' THEN COLETAS_HMM END)*60)))*100),2) AS DISP_GERAL,
    ROUND(((1-(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END)/(SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN COLETAS_HMM END)*60)))*100),2) AS DISP_4G_5G
    
FROM (
    SELECT
        YEAR(DATA_REFERENCIA) AS ANO,
        MONTH(DATA_REFERENCIA) AS MES,
		DAY(DATA_REFERENCIA) AS DIA,
        A.TECNOLOGIA,
        CASE WHEN A.UF = 'SP' THEN C.NOME_REGIONAL
            WHEN A.UF IN ('BA', 'SE', 'AL', 'RN', 'PB', 'CE', 'PI', 'PE') THEN 'NE' 
            WHEN A.UF = 'MG' THEN 'MG'
            WHEN A.UF IN ('RJ', 'ES') THEN 'RJ/ES'
            WHEN A.UF IN ('PR', 'SC', 'RS') THEN 'SUL'
            WHEN A.UF IN ('AM', 'PA', 'MA', 'AP', 'RR') THEN 'NO'
            WHEN A.UF IN ('AC', 'MS', 'MT', 'RO', 'DF', 'GO', 'TO') THEN 'CO'
        END REGIONAL,
        CAST(TEMPO_CONTADOR_HMM AS FLOAT) AS TEMPO_CONTADOR_HMM,
        CAST(COLETAS_HMM AS FLOAT) AS COLETAS_HMM
    FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
    INNER JOIN SISTEMA_MAESTRO..TBA_PLANTA_MOVEL B WITH(NOLOCK) ON A.UF = B.UF AND A.SITE = B.SIGLA_SITE AND A.CN = B.CN
	LEFT JOIN INDICADORES_CORAN..TBA_DIVISAO_MUNICIPIOS_SP_FIXA C WITH(NOLOCK) ON A.MUNICIPIO = C.MUNICIPIO AND A.UF = 'SP'
    WHERE DATEPART(YEAR,DATA_REFERENCIA) = 2024 AND DATEPART(MONTH,DATA_REFERENCIA) IN (9,10)  --AND DATEPART(DAY,DATA_REFERENCIA) BETWEEN 1 AND DATEPART(DAY,EOMONTH(GETDATE()))
) D
WHERE REGIONAL = 'SPC'
GROUP BY ANO, MES, DIA, REGIONAL
ORDER BY ANO, MES, DIA, REGIONAL





-- DIARIA POR CN
SELECT
ANO, MES, DIA, CN, MINUTOS_2G, DISPONIBILIDADE_2G AS DISP_2G, MINUTOS_3G, DISPONIBILIDADE_3G AS DISP_3G, MINUTOS_4G,DISPONIBILIDADE_4G AS DISP_4G, MINUTOS_5G, DISPONIBILIDADE_5G AS DISP_5G, MINUTOS_GERAL, DISPONIBILIDADE_GERAL AS DISP_GERAL
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_CN_HMM WITH(NOLOCK)
WHERE ANO = 2024 AND MES IN(9,10) AND CN IN (19)
ORDER BY MES, DIA, CN

SELECT
DATA_REFERENCIA, ANO, MES, DIA, EMPRESA, MINUTOS_2G, DISPONIBILIDADE_2G AS DISP_2G, MINUTOS_3G, DISPONIBILIDADE_3G AS DISP_3G, MINUTOS_4G,DISPONIBILIDADE_4G AS DISP_4G, MINUTOS_5G, DISPONIBILIDADE_5G AS DISP_5G, MINUTOS_GERAL, DISPONIBILIDADE_GERAL AS DISP_GERAL
FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_ALIADAS_HMM WITH(NOLOCK)
WHERE EMPRESA IN ('ABILITY SP') AND ANO = 2024 AND MES IN (9,10)
ORDER BY MES, DIA




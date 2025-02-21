-- ===============================================================
-- DISP MENSAL SP POR NOVO CLUSTER
-- ===============================================================
DECLARE @ANO INT = (SELECT CASE WHEN YEAR(GETDATE()) = YEAR(GETDATE()-1) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()-1) END) 
DECLARE @MES INT = (SELECT CASE WHEN MONTH(GETDATE()) = MONTH(GETDATE()-1) THEN MONTH(GETDATE()) ELSE MONTH(GETDATE()-1) END) 

SELECT
    ANO,
    MES, 
	UF,
    SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM END) AS TESTE,
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
        A.SITE,
        A.ERB,
        A.SETOR
    FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
    LEFT JOIN SISTEMA_MAESTRO..TBA_PLANTA_MOVEL B WITH(NOLOCK) ON A.UF = B.UF AND A.SITE = B.SIGLA_SITE
    WHERE YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 6 AND A.UF = 'SP' AND B.CLUSTER IS NOT NULL -- AND SITE = 'AHS' AND A.TECNOLOGIA = 'WCDMA'
) C
GROUP BY ANO, MES, UF, C.CLUSTER
-- =============================================================================================================================================================================================================
DROP TABLE #TEMP_RESULTADOS_SP

DECLARE @DATA_MANUAL VARCHAR(10)
DECLARE @ANO AS INT, @MES AS INT
DECLARE @DATA_REFERENCIA DATE

-- SET @DATA_REFERENCIA = CAST(CONCAT(@ANO,'-',@MES,'-01') AS DATE)

SELECT
        DISP.DATA_REFERENCIA,
        YEAR(DISP.DATA_REFERENCIA) AS ANO,
        MONTH(DISP.DATA_REFERENCIA) AS MES,
        ISNULL(REGIAO_SP.GESTAO, 'CAPITAL') AS REGIONAL,
        UF,
        CN,
        DISP.MUNICIPIO,
        SITE,
        ERB,
        SETOR,
        TECNOLOGIA,
        EMPRESA,
        CLUSTER,
        REGIAO_CLUSTER,
        MAX(TEMPO_CONTADOR_HMM) AS TEMPO_CONTADOR,
        MAX(COLETAS_HMM) AS COLETAS
	INTO #TEMP_RESULTADOS_SP
	FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES DISP WITH(NOLOCK)
	LEFT JOIN INDICADORES_CORAN.dbo.TBA_DIVISAO_MUNICIPIOS_SP_FIXA REGIAO_SP WITH(NOLOCK) ON DISP.MUNICIPIO = REGIAO_SP.MUNICIPIO
	LEFT JOIN (SELECT DISTINCT UF AS UF_B, SIGLA_SITE AS SITE_B, EMPRESA, CLUSTER, REGIAO_CLUSTER FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL WITH(NOLOCK) WHERE UF = 'SP') B ON DISP.UF = B.UF_B AND DISP.SITE = B.SITE_B
	WHERE YEAR(DISP.DATA_REFERENCIA) = 2024 AND MONTH(DISP.DATA_REFERENCIA) = 6 AND UF = 'SP' -- AND SITE = 'AHS' AND TECNOLOGIA = 'WCDMA'
	GROUP BY DISP.DATA_REFERENCIA, REGIONAL, UF, CN, DISP.MUNICIPIO, SITE, ERB, SETOR, TECNOLOGIA, REGIAO_SP.GESTAO, EMPRESA, CLUSTER, REGIAO_CLUSTER

/* CLUSTER SPC */
	SELECT
	ANO,
	MES,
	CONCAT(CLUSTER, ' SPC') AS CLUSTER,
	PLANTA_2G,
	MINUTOS_2G,
	CASE WHEN PLANTA_2G = 0 THEN NULL WHEN COLETAS_GSM = 0 THEN NULL WHEN COLETAS_GSM > 0 THEN ROUND((1-(MINUTOS_2G/(CAST(PLANTA_2G AS float)*DENOMINADOR_2G)))*100, 2) END DISPONIBILIDADE_2G,
	PLANTA_3G,
	MINUTOS_3G,
	CASE WHEN PLANTA_3G = 0 THEN NULL WHEN COLETAS_WCDMA = 0 THEN NULL WHEN COLETAS_WCDMA > 0 THEN ROUND((1-(MINUTOS_3G/(CAST(PLANTA_3G AS float)*DENOMINADOR_3G)))*100, 2) END DISPONIBILIDADE_3G,
	PLANTA_4G,
	MINUTOS_4G,
	CASE WHEN PLANTA_4G = 0 THEN NULL WHEN COLETAS_LTE = 0 THEN NULL WHEN COLETAS_LTE > 0 THEN ROUND((1-(MINUTOS_4G/(CAST(PLANTA_4G AS float)*DENOMINADOR_4G)))*100, 2) END DISPONIBILIDADE_4G,
	PLANTA_GERAL,
	MINUTOS_GERAL,
	CASE WHEN PLANTA_GERAL = 0 THEN NULL WHEN COLETAS_GERAL = 0 THEN NULL WHEN COLETAS_GERAL > 0 THEN ROUND((1-(MINUTOS_GERAL/(CAST(PLANTA_GERAL AS float)*DENOMINADOR_GERAL)))*100, 2) END DISPONIBILIDADE_GERAL,
	PLANTA_5G,
	MINUTOS_5G,
	CASE WHEN PLANTA_5G = 0 THEN NULL WHEN COLETAS_5G = 0 THEN NULL WHEN COLETAS_5G > 0 THEN ROUND((1-(MINUTOS_5G/(CAST(PLANTA_5G AS float)*DENOMINADOR_5G)))*100, 2) END DISPONIBILIDADE_5G,
	DATA_REFERENCIA,
	--DISP_3G+4G
	PLANTA_3G_4G,
	MINUTOS_3G_4G,
	CASE WHEN PLANTA_3G_4G = 0 THEN NULL WHEN COLETAS_3G_4G = 0 THEN NULL WHEN COLETAS_3G_4G > 0 THEN ROUND((1-(MINUTOS_3G_4G/(CAST(PLANTA_3G_4G AS float)*DENOMINADOR_3G_4G)))*100, 2) END DISPONIBILIDADE_3G_4G,
	--DISP_3G_5G
	PLANTA_3G_5G,
	MINUTOS_3G_5G,
	CASE WHEN PLANTA_3G_5G = 0 THEN NULL WHEN COLETAS_3G_5G = 0 THEN NULL WHEN COLETAS_3G_5G > 0 THEN ROUND((1-(MINUTOS_3G_5G/(CAST(PLANTA_3G_5G AS float)*DENOMINADOR_3G_5G)))*100, 2) END DISPONIBILIDADE_3G_5G,
	--DISP_4G_5G
	PLANTA_4G_5G,
	MINUTOS_4G_5G,
	CASE WHEN PLANTA_4G_5G = 0 THEN NULL WHEN COLETAS_4G_5G = 0 THEN NULL WHEN COLETAS_4G_5G > 0 THEN ROUND((1-(MINUTOS_4G_5G/(CAST(PLANTA_4G_5G AS float)*DENOMINADOR_4G_5G)))*100, 2) END DISPONIBILIDADE_4G_5G

	
	FROM (
		SELECT
		*,
		(CAST(COLETAS_GSM AS float)/PLANTA_2G*60) AS DENOMINADOR_2G,
		(CAST(COLETAS_WCDMA AS float)/PLANTA_3G*60) AS DENOMINADOR_3G,
		(CAST(COLETAS_LTE AS float)/PLANTA_4G*60) AS DENOMINADOR_4G,
		(CAST(COLETAS_GERAL AS float)/PLANTA_GERAL*60) AS DENOMINADOR_GERAL,
		(CAST(COLETAS_5G AS float)/PLANTA_5G*60) AS DENOMINADOR_5G,
		(CAST(COLETAS_3G_4G AS float)/PLANTA_3G_4G*60) AS DENOMINADOR_3G_4G,
		(CAST(COLETAS_3G_5G AS float)/PLANTA_3G_5G*60) AS DENOMINADOR_3G_5G,
		(CAST(COLETAS_4G_5G AS float)/PLANTA_4G_5G*60) AS DENOMINADOR_4G_5G
		FROM (
			SELECT
			@DATA_REFERENCIA DATA_REFERENCIA,
			ANO,
			MES,
			CLUSTER,
			COUNT(DISTINCT CASE WHEN TECNOLOGIA = 'GSM' THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_2G,
			SUM(CASE WHEN TECNOLOGIA = 'GSM' AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_2G,   
			COUNT(DISTINCT CASE WHEN TECNOLOGIA = 'WCDMA' THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_3G,
			SUM(CASE WHEN TECNOLOGIA = 'WCDMA' AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_3G,
			COUNT(DISTINCT CASE WHEN TECNOLOGIA = 'LTE' THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_4G,
			SUM(CASE WHEN TECNOLOGIA = 'LTE' AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_4G,
			--COUNT(DISTINCT CONCAT(DISP.UF, DISP.ERB, DISP.SETOR)) PLANTA_GERAL,
			COUNT(DISTINCT CASE WHEN TECNOLOGIA <> 'GSM' THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_GERAL,
			--SUM(CASE WHEN TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_GERAL,
			SUM(CASE WHEN TEMPO_CONTADOR >= 0 AND TECNOLOGIA <> 'GSM' THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_GERAL,
			SUM(CASE WHEN TECNOLOGIA = 'GSM' THEN COLETAS ELSE 0 END) COLETAS_GSM,
			SUM(CASE WHEN TECNOLOGIA = 'WCDMA' THEN COLETAS ELSE 0 END) COLETAS_WCDMA,
			SUM(CASE WHEN TECNOLOGIA = 'LTE' THEN COLETAS ELSE 0 END) COLETAS_LTE,
			--SUM(COLETAS) COLETAS_GERAL,
			SUM(CASE WHEN TECNOLOGIA <> 'GSM' THEN COLETAS ELSE 0 END) COLETAS_GERAL,
			COUNT(DISTINCT CASE WHEN TECNOLOGIA = '5G' THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_5G,
			SUM(CASE WHEN TECNOLOGIA = '5G' AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_5G,   
			SUM(CASE WHEN TECNOLOGIA = '5G' THEN COLETAS ELSE 0 END) COLETAS_5G,
			--3G+4G
			COUNT(DISTINCT CASE WHEN TECNOLOGIA IN ('WCDMA','LTE') THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_3G_4G,
			SUM(CASE WHEN TECNOLOGIA IN ('WCDMA','LTE') AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_3G_4G,   
			SUM(CASE WHEN TECNOLOGIA IN ('WCDMA','LTE') THEN COLETAS ELSE 0 END) COLETAS_3G_4G,
			--3G+5G
			COUNT(DISTINCT CASE WHEN TECNOLOGIA IN ('WCDMA','5G') THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_3G_5G,
			SUM(CASE WHEN TECNOLOGIA IN ('WCDMA','5G') AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_3G_5G,   
			SUM(CASE WHEN TECNOLOGIA IN ('WCDMA','5G') THEN COLETAS ELSE 0 END) COLETAS_3G_5G,
			--4G+5G
			COUNT(DISTINCT CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN CONCAT(DISP.UF, DISP.ERB, DISP.SETOR) END) PLANTA_4G_5G,
			SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') AND TEMPO_CONTADOR >= 0 THEN TEMPO_CONTADOR ELSE 0 END) MINUTOS_4G_5G,   
			SUM(CASE WHEN TECNOLOGIA IN ('LTE','5G') THEN COLETAS ELSE 0 END) COLETAS_4G_5G

			FROM #TEMP_RESULTADOS_SP DISP
			WHERE CLUSTER IS NOT NULL
			GROUP BY ANO, MES, CLUSTER
		)GERAL
	)FINAL


SELECT UF AS UF_B, SIGLA_SITE AS SITE_B, EMPRESA, CLUSTER, REGIAO_CLUSTER FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL WITH(NOLOCK) WHERE UF = 'SP'
SELECT DISTINCT UF, SIGLA_SITE, EMPRESA, CLUSTER, REGIAO_CLUSTER FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL WITH(NOLOCK) WHERE UF = 'SP'
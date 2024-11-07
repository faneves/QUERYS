--DISPONIBILIDADE MENSAL PROGRESSIVA
--=============================================================================================================

	DECLARE @DT_MAX AS DATETIME
	DECLARE @ANO AS INT
	DECLARE @MES AS INT

	
	SELECT @DT_MAX = MAX(DATA_REFERENCIA) FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
	SELECT @ANO = YEAR(@DT_MAX)
	SELECT @MES = MONTH(@DT_MAX)
	

	/* DELETE */
	
	--DELETE FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_VIVO WHERE ANO = @ANO AND MES = @MES
	--DELETE FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_REGIONAL WHERE ANO = @ANO AND MES = @MES
	--DELETE FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_UF WHERE ANO = @ANO AND MES = @MES
	--DELETE FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_MUNICIPIO WHERE ANO = @ANO AND MES = @MES

/*

	/* VIVO */
	--INSERT INTO INDICADORES_CORAN..TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_VIVO (ANO, MES, DIA, DISPONIBILIDADE)
	SELECT
	ANO,
	MES,
	DIA,
	ROUND((1-(TEMPO_ACUM / (CAST(PLANTA_ACUM AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		COLETAS_ACUM / CAST(PLANTA_ACUM AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			*,
			MAX(PLANTA) OVER (PARTITION BY ANO, MES ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PLANTA_ACUM,
			SUM(COLETAS) OVER (PARTITION BY ANO, MES ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS COLETAS_ACUM,
			SUM(TEMPO) OVER (PARTITION BY ANO, MES ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TEMPO_ACUM
			FROM (
				SELECT
				YEAR(DATA_REFERENCIA) AS ANO,
				MONTH(DATA_REFERENCIA) AS MES,
				DAY(DATA_REFERENCIA) AS DIA,
				COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
				ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
				SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
				WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND TECNOLOGIA <> 'GSM'
				GROUP BY YEAR(DATA_REFERENCIA), MONTH(DATA_REFERENCIA), DAY(DATA_REFERENCIA)
			)A
		)B
	)C ORDER BY DIA

*/


	/* REGIONAL */
	--INSERT INTO INDICADORES_CORAN.dbo.TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_REGIONAL (ANO, MES, DIA, REGIONAL, DISPONIBILIDADE)
	SELECT
	ANO,
	MES,
	DIA,
	REGIONAL,
	ROUND((1-(TEMPO_ACUM / (CAST(PLANTA_ACUM AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		COLETAS_ACUM / CAST(PLANTA_ACUM AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			*,
			MAX(PLANTA) OVER (PARTITION BY ANO, MES, REGIONAL ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PLANTA_ACUM,
			SUM(COLETAS) OVER (PARTITION BY ANO, MES, REGIONAL ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS COLETAS_ACUM,
			SUM(TEMPO) OVER (PARTITION BY ANO, MES, REGIONAL ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TEMPO_ACUM
			FROM (
				SELECT
				YEAR(DATA_REFERENCIA) AS ANO,
				MONTH(DATA_REFERENCIA) AS MES,
				DAY(DATA_REFERENCIA) AS DIA,
				-- CASE WHEN REGIONAL = 'BA/SE/NE' THEN 'NE' WHEN REGIONAL = 'MG/RJ/ES' THEN 'SUD' ELSE REGIONAL END REGIONAL,
				CASE WHEN A.UF = 'SP' THEN B.NOME_REGIONAL
             		WHEN A.UF IN ('BA', 'SE', 'AL', 'RN', 'PB', 'CE', 'PI', 'PE') THEN 'NE' 
             		WHEN A.UF = 'MG' THEN 'MG'
             		WHEN A.UF IN ('RJ', 'ES') THEN 'RJ/ES'
             		WHEN A.UF IN ('PR', 'SC', 'RS') THEN 'SUL'
             		WHEN A.UF IN ('AM', 'PA', 'MA', 'AP', 'RR') THEN 'NO'
             		WHEN A.UF IN ('AC', 'MS', 'MT', 'RO', 'DF', 'GO', 'TO') THEN 'CO'
             	END REGIONAL,
				COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
				ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
				SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
				LEFT JOIN INDICADORES_CORAN..TBA_DIVISAO_MUNICIPIOS_SP_FIXA B ON A.MUNICIPIO = B.MUNICIPIO AND A.UF = 'SP'
				WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND TECNOLOGIA <> 'GSM'
				GROUP BY YEAR(DATA_REFERENCIA), MONTH(DATA_REFERENCIA), DAY(DATA_REFERENCIA), UF, NOME_REGIONAL--, REGIONAL
			)A
		)B
	)C ORDER BY REGIONAL, DIA



	/* UF */
	--INSERT INTO INDICADORES_CORAN.dbo.TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_UF (ANO, MES, DIA, UF, DISPONIBILIDADE)
	SELECT
	ANO,
	MES,
	DIA,
	UF,
	ROUND((1-(TEMPO_ACUM / (CAST(PLANTA_ACUM AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		COLETAS_ACUM / CAST(PLANTA_ACUM AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			*,
			MAX(PLANTA) OVER (PARTITION BY ANO, MES, UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PLANTA_ACUM,
			SUM(COLETAS) OVER (PARTITION BY ANO, MES, UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS COLETAS_ACUM,
			SUM(TEMPO) OVER (PARTITION BY ANO, MES, UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TEMPO_ACUM
			FROM (
				SELECT
				YEAR(DATA_REFERENCIA) AS ANO,
				MONTH(DATA_REFERENCIA) AS MES,
				DAY(DATA_REFERENCIA) AS DIA,
				UF,
				COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
				ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
				SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
				WHERE YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND TECNOLOGIA <> 'GSM'
				GROUP BY YEAR(DATA_REFERENCIA), MONTH(DATA_REFERENCIA), DAY(DATA_REFERENCIA), UF
			)A
		)B
	)C ORDER BY UF, DIA



	/* MUNICIPIO */
	--INSERT INTO INDICADORES_CORAN.dbo.TBF_CELLDOWNTIME_MENSAL_PROGRESSIVO_MUNICIPIO (ANO, MES, DIA, UF, MUNICIPIO, DISPONIBILIDADE)
	DECLARE @DT_MAX AS DATETIME
	DECLARE @ANO AS INT
	DECLARE @MES AS INT

	
	SELECT @DT_MAX = MAX(DATA_REFERENCIA) FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
	SELECT @ANO = YEAR(@DT_MAX)
	SELECT @MES = MONTH(@DT_MAX)


	SELECT
	ANO,
	MES,
	DIA,
	UF,
	MUNICIPIO,
	ROUND((1-(TEMPO_ACUM / NULLIF((CAST(PLANTA_ACUM AS float) * DENOMINADOR),0))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		COLETAS_ACUM / CAST(PLANTA_ACUM AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
				*,
				MAX(PLANTA) OVER (PARTITION BY ANO, MES, UF, MUNICIPIO ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PLANTA_ACUM,
				SUM(COLETAS) OVER (PARTITION BY ANO, MES, UF, MUNICIPIO ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS COLETAS_ACUM,
				SUM(TEMPO) OVER (PARTITION BY ANO, MES, UF, MUNICIPIO ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TEMPO_ACUM
			FROM (
				SELECT
						YEAR(DATA_REFERENCIA) AS ANO,
						MONTH(DATA_REFERENCIA) AS MES,
						DAY(DATA_REFERENCIA) AS DIA,
						UF,
						MUNICIPIO,
						COUNT(DISTINCT CONCAT(UF, SITE, ERB, SETOR)) AS PLANTA,
						ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
						SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
				FROM 
						SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES WITH(NOLOCK)
				WHERE 
						YEAR(DATA_REFERENCIA) = @ANO AND MONTH(DATA_REFERENCIA) = @MES AND TECNOLOGIA <> 'GSM' AND MUNICIPIO = 'ARACAJU'
				GROUP BY 
						YEAR(DATA_REFERENCIA), MONTH(DATA_REFERENCIA), DAY(DATA_REFERENCIA), UF, MUNICIPIO
			)A
		)B
	)C ORDER BY UF, MUNICIPIO, DIA

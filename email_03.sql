--==================================================================================================================================
--TOP10 e TOP50 - REGIONAL NO
--==================================================================================================================================

WITH MENSAL AS (
	SELECT
	ANO,
	MES,
	C.UF,
	C.MUNICIPIO,
	SHARE_PLANTA,
	SHARE_TEMPO,
	ROUND((1-(TEMPO / (CAST(PLANTA AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		ROUND(PLANTA / CAST(SUM(PLANTA) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_PLANTA,
		ROUND(TEMPO / CAST(SUM(TEMPO) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_TEMPO,
		COLETAS / CAST(PLANTA AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			ANO,
			MES,
			A1.UF,
			MUNICIPIO,
			COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
			ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
			SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
			FROM (
				SELECT
				YEAR(DATA_REFERENCIA) AS ANO,
				MONTH(DATA_REFERENCIA) AS MES,
				A.*
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
				WHERE YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1 AND TECNOLOGIA <> 'GSM' AND REGIONAL = 'NO'
			)A1 GROUP BY ANO, MES, UF, MUNICIPIO
		)A
	)C INNER JOIN SISTEMA_MAESTRO..AUX_CLASSIFICACAO_MUNICIPIOS D ON C.MUNICIPIO = D.MUNICIPIO AND C.UF = D.UF WHERE D.CLASSIFICACAO IN('TOP 10', 'TOP 50')

), SEMANAL AS (

	SELECT
	ANO,
	SEMANA,
	C.UF,
	C.MUNICIPIO,
	SHARE_PLANTA,
	SHARE_TEMPO,
	ROUND((1-(TEMPO / (CAST(PLANTA AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		ROUND(PLANTA / CAST(SUM(PLANTA) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_PLANTA,
		ROUND(TEMPO / CAST(SUM(TEMPO) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_TEMPO,
		COLETAS / CAST(PLANTA AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			ANO,
			SEMANA,
			A1.UF,
			MUNICIPIO,
			COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
			ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
			SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
			FROM (
				SELECT
				ANO,
				SEMANA,
				A.*
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
				INNER JOIN SISTEMA_MAESTRO..AUX_SEMANAS C ON A.DATA_REFERENCIA = C.DATA_REFERENCIA
				WHERE ANO = 2024 AND SEMANA = 2 AND TECNOLOGIA <> 'GSM' AND REGIONAL = 'NO'
			)A1 GROUP BY ANO, SEMANA, UF, MUNICIPIO
		)A
	)C INNER JOIN SISTEMA_MAESTRO..AUX_CLASSIFICACAO_MUNICIPIOS D ON C.MUNICIPIO = D.MUNICIPIO AND C.UF = D.UF WHERE D.CLASSIFICACAO IN('TOP 10', 'TOP 50')

), DIARIO AS (

	SELECT
	ANO,
	MES,
	DIA,
	C.UF,
	C.MUNICIPIO,
	SHARE_PLANTA,
	SHARE_TEMPO,
	ROUND((1-(TEMPO / (CAST(PLANTA AS float) * DENOMINADOR))) * 100, 2) AS DISPONIBILIDADE
	FROM (
		SELECT
		*,
		ROUND(PLANTA / CAST(SUM(PLANTA) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_PLANTA,
		ROUND(TEMPO / CAST(SUM(TEMPO) OVER(ORDER BY MUNICIPIO ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE_TEMPO,
		COLETAS / CAST(PLANTA AS float) * 60 AS DENOMINADOR
		FROM (
			SELECT
			ANO,
			MES,
			DIA,
			A1.UF,
			MUNICIPIO,
			COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
			ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
			SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
			FROM (
				SELECT
				YEAR(DATA_REFERENCIA) AS ANO,
				MONTH(DATA_REFERENCIA) AS MES,
				DAY(DATA_REFERENCIA) AS DIA,
				A.*
				FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
				WHERE YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1 AND DAY(DATA_REFERENCIA) = 9 AND TECNOLOGIA <> 'GSM' AND REGIONAL = 'NO'
			)A1 GROUP BY ANO, MES, DIA, UF, MUNICIPIO
		)A
	)C INNER JOIN SISTEMA_MAESTRO..AUX_CLASSIFICACAO_MUNICIPIOS D ON C.MUNICIPIO = D.MUNICIPIO AND C.UF = D.UF WHERE D.CLASSIFICACAO IN('TOP 10', 'TOP 50')

), ESTATISTICA AS (

	SELECT
	UF,
	MUNICIPIO,
	AVG(PLANTA) AS AVG_PLANTA,
	SUM(PLANTA) AS SUM_PLANTA,
	AVG(COLETAS) AS AVG_COLETAS,
	SUM(COLETAS) AS SUM_COLETAS,
	AVG(TEMPO) AS AVG_TEMPO,
	SUM(TEMPO) AS SUM_TEMPO
	FROM (
		SELECT
		DATA_REFERENCIA,
		UF,
		MUNICIPIO,
		COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
		ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM (
			SELECT
			A.*
			FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
			INNER JOIN SISTEMA_MAESTRO..AUX_CLASSIFICACAO_MUNICIPIOS D ON A.MUNICIPIO = D.MUNICIPIO AND A.UF = D.UF AND D.CLASSIFICACAO IN('TOP 10', 'TOP 50')
			WHERE YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1 AND TECNOLOGIA <> 'GSM' AND REGIONAL = 'NO'
		)A GROUP BY DATA_REFERENCIA, UF, MUNICIPIO
	)A GROUP BY UF, MUNICIPIO

), DIAS_RESTANTE AS (

		SELECT
		COUNT(*) AS DIAS_RESTANTE
		FROM SISTEMA_MAESTRO..AUX_SEMANAS A LEFT JOIN (
			SELECT DISTINCT
			DATA_REFERENCIA,
			'CDT' AS TIPO
			FROM INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_REGIONAL_HMM A WITH(NOLOCK)
			WHERE ANO = 2024 AND MES = 1 AND REGIONAL = 'NO'
		)B ON A.DATA_REFERENCIA = B.DATA_REFERENCIA WHERE A.ANO = 2024 AND A.MES = 1 AND B.TIPO IS NULL

), PROJECOES AS (

	SELECT
	UF,
	MUNICIPIO,
	CONSUMO,
	ROUND((1-(SALDO_DIARIO_FORECAST / CAST((AVG_PLANTA * DENOMINADOR_FORECAST) AS float))) * 100, 2) AS FORECAST_DISPONIBILIDADE,
	ROUND((1-(SUM_TEMPO / CAST((SUM_PROJECAO_PLANTA * DENOMINADOR_PROJECAO) AS float))) * 100, 2) AS PROJECAO_DISPONIBILIDADE
	FROM (
		SELECT
		UF,
		MUNICIPIO,
		ROUND(SUM_TEMPO / CAST((((A.SUM_COLETAS * 60) + (A.AVG_COLETAS * 60 * NULLIF(B.DIAS_RESTANTE, 0))) / 100) AS float) * 100, 2) AS CONSUMO,
		((A.SUM_COLETAS * 60) + (A.AVG_COLETAS * 60 * NULLIF(B.DIAS_RESTANTE, 0))) AS SALDO_TOTAL,
		((((A.SUM_COLETAS * 60) + (A.AVG_COLETAS * 60 * NULLIF(B.DIAS_RESTANTE, 0))) / 100) - A.SUM_TEMPO) / NULLIF(B.DIAS_RESTANTE, 0) AS SALDO_DIARIO_FORECAST,
		(SUM_COLETAS + (AVG_COLETAS * 60 * NULLIF(B.DIAS_RESTANTE, 0))) / CAST(((SUM_PLANTA + (AVG_PLANTA * 60 * NULLIF(B.DIAS_RESTANTE, 0)))) AS float) * 60 AS DENOMINADOR_PROJECAO,
		AVG_COLETAS / CAST(AVG_PLANTA AS float) * 60 AS DENOMINADOR_FORECAST,
		AVG_PLANTA,
		SUM_PLANTA + (AVG_PLANTA * NULLIF(B.DIAS_RESTANTE, 0)) AS SUM_PROJECAO_PLANTA,
		SUM_TEMPO
		FROM ESTATISTICA A
		INNER JOIN DIAS_RESTANTE B ON 1 = 1
	)A

)



SELECT
'09/01/2024' AS DATA_REFERENCIA,
2024 AS ANO,
1 AS MES,
2 AS SEMANA,
9 AS DIA,
'MUNICIPIOS TOP 50' AS TIPO,
A.MUNICIPIO AS NOME,
A.DISPONIBILIDADE AS MENSAL,
B.DISPONIBILIDADE AS SEMANAL,
C.DISPONIBILIDADE AS DIARIO,
A.SHARE_PLANTA,
A.SHARE_TEMPO,
D.CONSUMO,
D.PROJECAO_DISPONIBILIDADE,
D.FORECAST_DISPONIBILIDADE,
'NO' AS REGIONAL
FROM MENSAL A
INNER JOIN SEMANAL B ON A.MUNICIPIO = B.MUNICIPIO
INNER JOIN DIARIO C ON A.MUNICIPIO = C.MUNICIPIO
INNER JOIN PROJECOES D ON A.MUNICIPIO = D.MUNICIPIO
ORDER BY A.SHARE_PLANTA DESC
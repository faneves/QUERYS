DECLARE @DT_REF AS DATETIME, @UF AS VARCHAR(2), @MUNICIPIO AS VARCHAR(100)
SELECT  @DT_REF = MAX(DATA_REFERENCIA) FROM REDE_EXTERNA..TBL_EVENTOS_ATIVOS_SIGITM;
SELECT @UF = 'MG', @MUNICIPIO = 'BELO HORIZONTE';
 
WITH PLANTA AS(
SELECT
UF,
MUNICIPIO,
SIGLA_SITE,
COUNT(DISTINCT SIGLA_ERB) AS PLANTA,
AVG(LAT) AS LAT,
AVG(LONG) AS LNG
FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
WHERE UF = @UF AND MUNICIPIO = @MUNICIPIO
GROUP BY UF, MUNICIPIO, SIGLA_SITE
 
), IMP_TOTAL AS(
 
	SELECT
	SIGLA_SITE,
	COUNT(DISTINCT EQUIPAMENTO) AS AFETACAO,
	MAX(EVENTO_REFERENCIA) AS EVENTO,
	MIN(DT_APRESENTACAO) AS DT_ALARME
	FROM REDE_EXTERNA..TBL_EVENTOS_ATIVOS_SIGITM A
	LEFT JOIN INDICADORES_CORAN..AUX_CLASSIFICACAO_GESTORES B ON A.GESTOR_EVENTO_REFERENCIA = B.GRUPO
	WHERE UF = @UF AND MUNICIPIO = @MUNICIPIO AND DATA_REFERENCIA >= @DT_REF AND TIPO_REDE = 'ERB / Repetidor' AND PRIORIDADE = 1 -- AND IMPACTO = 'TOTAL'
	GROUP BY SIGLA_SITE
 
), IMP_PARCIAL AS(
 
	SELECT
	SIGLA_SITE,
	COUNT(DISTINCT EQUIPAMENTO) AS AFETACAO
	FROM REDE_EXTERNA..TBL_EVENTOS_ATIVOS_SIGITM A
	LEFT JOIN INDICADORES_CORAN..AUX_CLASSIFICACAO_GESTORES B ON A.GESTOR_EVENTO_REFERENCIA = B.GRUPO
	WHERE UF = @UF AND MUNICIPIO = @MUNICIPIO AND DATA_REFERENCIA >= @DT_REF AND TIPO_REDE = 'ERB / Repetidor' AND PRIORIDADE = 2 -- AND IMPACTO = 'PARCIAL'
	GROUP BY SIGLA_SITE
 
), VIZINHANCA AS (
 
	SELECT
	UF_A,
	SITE_A,
	COUNT(CASE WHEN DISTANCIA < 0.5 THEN SITE_B END) RAIO_500M,
	COUNT(CASE WHEN DISTANCIA < 1 THEN SITE_B END) RAIO_1000M,
	COUNT(CASE WHEN DISTANCIA < 2 THEN SITE_B END) RAIO_2000M,
	COUNT(CASE WHEN DISTANCIA >= 2 THEN SITE_B END) RAIO_2000_MAIS
	FROM SISTEMA_MAESTRO..TBA_DISTANCIAS_SITES
	WHERE UF_A = 'MG' AND MUNICIPIO_A = 'BELO HORIZONTE' GROUP BY UF_A, SITE_A
)
 
SELECT
*
FROM (
	SELECT
	PLANTA.*,
	TOTAL.EVENTO,
	FORMAT(TOTAL.DT_ALARME, 'dd/MM/yyyy HH:mm:ss') AS DT_ALARME,
	CASE WHEN TOTAL.AFETACAO >= PLANTA.PLANTA THEN 'TOTAL' WHEN PARCIAL.AFETACAO > 0 THEN 'PARCIAL' ELSE 'SEM_AFETACAO' END FLG_AFETACAO,
	V.RAIO_500M,
	V.RAIO_1000M,
	V.RAIO_2000M,
	V.RAIO_2000_MAIS
	FROM PLANTA
	LEFT JOIN IMP_TOTAL TOTAL ON PLANTA.SIGLA_SITE = TOTAL.SIGLA_SITE
	LEFT JOIN IMP_PARCIAL PARCIAL ON PLANTA.SIGLA_SITE = PARCIAL.SIGLA_SITE
	LEFT JOIN VIZINHANCA V ON PLANTA.SIGLA_SITE = V.SITE_A
)A  WHERE FLG_AFETACAO IN ('TOTAL' ,'PARCIAL') AND EVENTO IS NOT NULL
ORDER BY PLANTA DESC, DT_ALARME
 
 
/*
SELECT * FROM REDE_EXTERNA..TBL_EVENTOS_ATIVOS_SIGITM
WHERE DATA_REFERENCIA >= '2024-05-03 15:00:00' AND UF = 'MG' AND MUNICIPIO = 'BELO HORIZONTE' AND SIGLA_SITE = 'CCO' AND TIPO_REDE = 'ERB / Repetidor' AND PRIORIDADE = 1 AND IMPACTO = 'TOTAL'
ORDER BY DATA_REFERENCIA DESC
*/

-- SELECT DISTINCT EVENTO_REFERENCIA, GESTOR_EVENTO_REFERENCIA FROM REDE_EXTERNA..TBL_EVENTOS_ATIVOS_SIGITM WHERE DATA_REFERENCIA >= '2024-05-02 16:01:00'
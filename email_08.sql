

WITH SITES_OFENSORES AS (
	SELECT
	*,
	ROUND(TEMPO / CAST(SUM(TEMPO) OVER (ORDER BY SITE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE
	FROM (
		SELECT
		A.MUNICIPIO,
		SITE,
		C.TIPO_SITE,
		'TEL' AS EMPRESA,
		COUNT(DISTINCT CASE WHEN TEMPO_CONTADOR_HMM > 0 THEN DATA_REFERENCIA END) DIAS_AFETADO,
		COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
		ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)	
		LEFT JOIN SISTEMA_MAESTRO..TBA_PLANTA_SITES_SIGITM C WITH(NOLOCK) ON A.SITE = C.SIGLA_SITE AND A.UF = C.UF
		WHERE TECNOLOGIA <> 'GSM' AND A.UF IN ('AM','AP','MA','PA','RR') AND YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1
		GROUP BY A.MUNICIPIO, SITE, CN, C.TIPO_SITE
	)A
), AFETACAO_DMENOS1 AS (
	SELECT
	SITE
	FROM (
		SELECT
		SITE,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
		WHERE TECNOLOGIA <> 'GSM' AND A.UF IN ('AM','AP','MA','PA','RR') AND  YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1 AND DAY(DATA_REFERENCIA) = 10
		GROUP BY SITE, CN
	)A WHERE A.TEMPO >= 60
), SLA_ALIADAS AS (
	SELECT
	UF,
	SITE,
	EVENTOS_P1,
	EVENTOS_P2,
	EVENTOS_P1 + EVENTOS_P2 AS BASELINE,
	CASE WHEN EVENTOS_P1 > 0 THEN ROUND(EVENTOS_P1_PRAZO / CAST(EVENTOS_P1 AS float) * 100, 0) END SLA_P1,
	CASE WHEN EVENTOS_P2 > 0 THEN ROUND(EVENTOS_P2_PRAZO / CAST(EVENTOS_P2 AS float) * 100, 0) END SLA_P2
	FROM (
		SELECT
		UF,
		SITE,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO IN(0,1) THEN EVENTO END) AS EVENTOS_P1,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO IN(1) THEN EVENTO END) AS EVENTOS_P1_PRAZO,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO IN(0,1) THEN EVENTO END) AS EVENTOS_P2,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO IN(1) THEN EVENTO END) AS EVENTOS_P2_PRAZO
		FROM (
			SELECT
			EVENTO,
			UF,
			SITE,
			FLAG_SLA_P1_4HORAS_CAMPO,
			FLAG_SLA_P2_12HORAS_CAMPO
			FROM INDICADORES_CORAN..TBL_EVENTOS_FECHADOS A WITH(NOLOCK)
			WHERE ANO = 2024 AND MES = 1 AND UF IN ('AM','AP','MA','PA','RR')
		)A GROUP BY UF, SITE
	)B
)




SELECT DISTINCT
'NO' AS REGIONAL,
A.SITE AS SITE_JOIN,
A.TEMPO AS TEMPO_ORDER,
CONCAT('<tr><td>', A.MUNICIPIO, '</td>') AS MUNICIPIO,
CONCAT('<td style="font-weight: bold;">', A.SITE, '</td>') AS SITE,
CONCAT('<td>','</td>') AS TIPO_PAGAMENTO,
CONCAT('<td>', A.PLANTA, '</td>') AS SETORES,
CONCAT('<td>', A.TIPO_SITE, '</td>') AS TIPO_SITE,
CONCAT('<td>', A.EMPRESA, '</td>') AS EMPRESA,
CONCAT('<td>', A.DIAS_AFETADO, '</td>') AS DIAS_AFETADO,
CONCAT('<td style="font-weight: bold;">', A.TEMPO, '</td>') AS TEMPO,
CONCAT('<td style="font-weight: bold;">', A.SHARE, '%</td>') AS SHARE,
CONCAT('<td>', C.BASELINE, '</td>') AS BASELINE,
CONCAT('<td>', ISNULL(C.EVENTOS_P1, 0), '</td>') AS EVENTOS_P1,
CONCAT('<td>', ISNULL(C.EVENTOS_P2, 0), '</td>') AS EVENTOS_P2
FROM SITES_OFENSORES A
INNER JOIN AFETACAO_DMENOS1 B ON A.SITE = B.SITE
LEFT JOIN SLA_ALIADAS C ON A.SITE = C.SITE
WHERE A.DIAS_AFETADO >= 2
ORDER BY A.TEMPO DESC



--===========================================================================================================================================================





WITH SITES_OFENSORES AS (
	SELECT
	*,
	ROUND(TEMPO / CAST(SUM(TEMPO) OVER (ORDER BY SITE ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS float) * 100, 2) AS SHARE
	FROM (
		SELECT
        A.UF,
		A.MUNICIPIO,
		SITE,
		C.TIPO_SITE,
		'TEL' AS EMPRESA,
		COUNT(DISTINCT CASE WHEN TEMPO_CONTADOR_HMM > 0 THEN DATA_REFERENCIA END) DIAS_AFETADO,
		COUNT(DISTINCT CONCAT(SITE, ERB, SETOR)) AS PLANTA,
		ISNULL(SUM(COLETAS_HMM), 0) AS COLETAS,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)	
		LEFT JOIN SISTEMA_MAESTRO..TBA_PLANTA_SITES_SIGITM C WITH(NOLOCK) ON A.SITE = C.SIGLA_SITE AND A.UF = C.UF
		WHERE TECNOLOGIA <> 'GSM' AND A.UF IN ('AM','AP','MA','PA','RR') AND YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1
		GROUP BY A.UF, A.MUNICIPIO, SITE, CN, C.TIPO_SITE
	)A
), AFETACAO_DMENOS1 AS (
	SELECT
	SITE
	FROM (
		SELECT
		SITE,
		SUM(CASE WHEN TEMPO_CONTADOR_HMM >= 0 THEN TEMPO_CONTADOR_HMM ELSE 0 END) TEMPO
		FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH (NOLOCK)
		WHERE TECNOLOGIA <> 'GSM' AND A.UF IN ('AM','AP','MA','PA','RR') AND  YEAR(DATA_REFERENCIA) = 2024 AND MONTH(DATA_REFERENCIA) = 1 AND DAY(DATA_REFERENCIA) = 10
		GROUP BY SITE, CN
	)A WHERE A.TEMPO >= 60
), SLA_ALIADAS AS (
	SELECT
	UF,
	SITE,
	EVENTOS_P1,
	EVENTOS_P2,
	EVENTOS_P1 + EVENTOS_P2 AS BASELINE,
	CASE WHEN EVENTOS_P1 > 0 THEN ROUND(EVENTOS_P1_PRAZO / CAST(EVENTOS_P1 AS float) * 100, 0) END SLA_P1,
	CASE WHEN EVENTOS_P2 > 0 THEN ROUND(EVENTOS_P2_PRAZO / CAST(EVENTOS_P2 AS float) * 100, 0) END SLA_P2
	FROM (
		SELECT
		UF,
		SITE,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO IN(0,1) THEN EVENTO END) AS EVENTOS_P1,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P1_4HORAS_CAMPO IN(1) THEN EVENTO END) AS EVENTOS_P1_PRAZO,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO IN(0,1) THEN EVENTO END) AS EVENTOS_P2,
		COUNT(DISTINCT CASE WHEN FLAG_SLA_P2_12HORAS_CAMPO IN(1) THEN EVENTO END) AS EVENTOS_P2_PRAZO
		FROM (
			SELECT
			EVENTO,
			UF,
			SITE,
			FLAG_SLA_P1_4HORAS_CAMPO,
			FLAG_SLA_P2_12HORAS_CAMPO
			FROM INDICADORES_CORAN..TBL_EVENTOS_FECHADOS A WITH(NOLOCK)
			WHERE ANO = 2024 AND MES = 1 AND UF IN ('AM','AP','MA','PA','RR')
		)A GROUP BY UF, SITE
	)B
)



SELECT
    'NO' AS REGIONAL,
    A.UF,
    A.SITE AS SITE_JOIN,
    A.TEMPO AS TEMPO_ORDER,
    A.MUNICIPIO AS MUNICIPIO,
    A.SITE AS SITE,
    A.PLANTA AS SETORES,
    A.TIPO_SITE AS TIPO_SITE,
    A.EMPRESA AS EMPRESA,
    A.DIAS_AFETADO AS DIAS_AFETADO,
    A.TEMPO AS TEMPO,
    A.SHARE AS SHARE,
    ISNULL(C.EVENTOS_P1, 0) AS EVENTOS_P1,
    ISNULL(C.EVENTOS_P2, 0) AS EVENTOS_P2
FROM SITES_OFENSORES A
INNER JOIN AFETACAO_DMENOS1 B ON A.SITE = B.SITE
LEFT JOIN SLA_ALIADAS C ON A.SITE = C.SITE
WHERE A.DIAS_AFETADO >= 2
ORDER BY A.TEMPO DESC



SELECT
CASE WHEN REGIONAL = 'BA/SE/NE' THEN 'NE'
WHEN REGIONAL = 'MG/RJ/ES' THEN 'SUD'
ELSE REGIONAL
END AS REGIONAL, COUNT(*)
FROM
    (
    SELECT REGIONAL, UF, NOME_SITE FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
    WHERE NOME_SITE LIKE '%HOSPITAL%'
    GROUP BY REGIONAL, UF, NOME_SITE
    )A
GROUP BY REGIONAL


SELECT REGIONAL, UF, MUNICIPIO, NOME_SITE FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
    WHERE NOME_SITE LIKE '%HOSPITAL%' AND UF = 'SP'



SELECT * FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
WHERE UF = 'MT' AND SITE = 'NA2'




SELECT REGIONAL, UF, NOME_SITE FROM SISTEMA_MAESTRO..TBA_PLANTA_MOVEL
    WHERE NOME_SITE LIKE '%HOSPITAL%'
    GROUP BY REGIONAL, UF, NOME_SITE


    SELECT CAST(CONVERT(DATETIME,[DATA_REFERENCIA], 3) AS DATE) AS DATA_REFERENCIA
                    ,[NOTA_CELL_DOWNTIME_AUTOMATICO_LTE]
                    ,[NOTA_EFICIENCIA_LTE]
                    ,[NOTA_EFICIENCIA_HANDOVER_LTE]
                    ,[NOTA_TAXA_QUEDA_SESSAO_LTE]
                    ,[NOTA_TAXA_QUEDA_VOZ_LTE]
                    ,[NOTA_GLOBAL_LTE]
                    FROM [SISTEMA_MAESTRO].[dbo].[TBF_NOTAS_SITE_LTE_HISTORICO] WITH (NOLOCK)
                    WHERE UF = 'MT' AND SITE = 'NA2'
                    ORDER BY  DATA_REFERENCIA
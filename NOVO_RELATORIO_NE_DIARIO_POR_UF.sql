
--POR DIARIO POR UF

WITH SLA AS
(
	SELECT
			MES,
			DIA,
			STATUS_INDICADOR,
			INDICADOR,
			UF,
			COUNT(STATUS_INDICADOR) AS QTDE_TAS
	FROM
	(
			SELECT 
					ANO,
					MES,
					DATEPART(DAY,DATA_ENCERRAMENTO) AS DIA,
					INDICADOR,
					UF,
					STATUS_INDICADOR
			FROM  
					AVALIACAO_CAMPO..TAS_FORA WITH(NOLOCK)
			WHERE 
					INDICADOR IN ('SLA P1 4 Horas', 'SLA P2 12 Horas') 
					AND UF IN ('BA','SE','AL','CE','PB','PE','PI','RN')
					AND ID_PLANTA = 1 AND ANO = 2023 AND MES >= 5
	)A
	GROUP BY 
			MES, DIA, INDICADOR, STATUS_INDICADOR, UF
	
),
DISP AS (
		SELECT
				UF,
				MES,
				DIA,
				'Disp' AS INDICADOR,
				DISPONIBILIDADE_GERAL AS DISPONIBILIDADE
		FROM
				INDICADORES_CORAN..TBF_CELLDOWNTIME_DIARIO_UF_HMM
		WHERE
				UF IN ('BA','SE','AL','CE','PB','PE','PI','RN')
				AND ANO = 2023 AND MES >= 5
		)

--=================
--QUERY PRINCIPAL
--=================

		SELECT
				SLA.MES,
				SLA.DIA,
				SLA.UF,
				SLA.INDICADOR,
				--DISP.INDICADOR,
				[0],
				[1],
				SLA,
				DISPONIBILIDADE
		FROM
		(
					SELECT
						UF,
						MES,
						DIA,
						CASE WHEN INDICADOR = 'SLA P1 4 Horas' THEN 'SLA P1'
							 WHEN INDICADOR = 'SLA P2 12 Horas' THEN 'SLA P2'
							 END INDICADOR,
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
								ISNULL([0],0) AS [0],
								ISNULL([1],0) AS [1]
						FROM
								SLA PIVOT (SUM(QTDE_TAS)
								FOR STATUS_INDICADOR IN ([0],[1]))P
					) A
		)SLA
		INNER JOIN DISP ON DISP.DIA = SLA.DIA AND DISP.MES = SLA.MES AND DISP.UF COLLATE Latin1_General_CI_AI = SLA.UF COLLATE Latin1_General_CI_AI
ORDER BY DIA, SLA.UF, SLA.INDICADOR
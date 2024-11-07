
SELECT 
		SUM(TEMPO_CONTADOR_HMM) AS MINUTOS_CELLDOWNTIME,
		SUM(COLETAS_HMM) AS QTDE_TOTAL_COLETAS,
		COUNT(1) AS QTDE_SETORES
FROM	
		SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
WHERE	
		MUNICIPIO = 'VITORIA' AND UF = 'ES' AND DATA_REFERENCIA = '2023-06-01 00:00:00.000' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM' 

SELECT
*
FROM	
		SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
WHERE	
		MUNICIPIO = 'VITORIA' AND UF = 'ES' AND DATA_REFERENCIA = '2023-06-01 00:00:00.000' AND TEMPO_CONTADOR_HMM >=0 AND TECNOLOGIA <> 'GSM'
		--AND TEMPO_CONTADOR_HMM > 0
		AND SITE = 'ABL'




1649 SETORES
2963 COLETAS
26624 MINUTOS CELL

(1-(26624/(2963*1649*60)))*100


SELECT MIN(DATA_REFERENCIA), MAX(DATA_REFERENCIA) FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES_HIST_2023
SELECT MIN(DATA_REFERENCIA), MAX(DATA_REFERENCIA) FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES
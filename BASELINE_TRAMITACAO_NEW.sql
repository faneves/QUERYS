--BASELINE DATA TRAMITACAO --> USA COMO BASE DE DADOS O BD MONITORA TRAMITACAO

--==============================================================================================================================
--EVOLUCAO
--==============================================================================================================================

--- MES ATUAL
SELECT
DIA,
MES = MONTH(GETDATE()),
ANO = YEAR(GETDATE()),
UF,
QTDE_TAS,
LEGENDA = 'Mês Atual',
SUM(QTDE_TAS) OVER (PARTITION BY UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TAS_ACUMULADO
FROM (
    SELECT
    DAY(DATA_TRAMITACAO) AS DIA,
    UF,
    COUNT(DISTINCT TA_ORIGEM) AS QTDE_TAS
    FROM MONITORA_TRAMITACAO..TBL_MONITORA_TRAMITACAO_TAS WITH(NOLOCK)
    WHERE YEAR(DATA_TRAMITACAO) = YEAR(GETDATE()) AND MONTH(DATA_TRAMITACAO) = MONTH(GETDATE()) AND UF <> '-' AND TIPO_PAGAMENTO = 'SOB DEMANDA'
    GROUP BY DAY(DATA_TRAMITACAO), UF
)A WHERE DIA <> DAY(GETDATE())

UNION ALL

--- MES ANTERIOR
SELECT
DIA,
MES= MONTH(GETDATE())-1,
ANO = YEAR(GETDATE()),
UF,
QTDE_TAS,
LEGENDA = 'Mês Anterior',
SUM(QTDE_TAS) OVER (PARTITION BY UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TAS_ACUMULADO
FROM (
    SELECT
    DAY(DATA_TRAMITACAO) AS DIA,
    UF,
    COUNT(DISTINCT TA_ORIGEM) AS QTDE_TAS
    FROM MONITORA_TRAMITACAO..TBL_MONITORA_TRAMITACAO_TAS WITH(NOLOCK)
    WHERE YEAR(DATA_TRAMITACAO) = YEAR(GETDATE()) AND MONTH(DATA_TRAMITACAO) = MONTH(GETDATE())-1 AND UF <> '-' AND TIPO_PAGAMENTO = 'SOB DEMANDA'
    GROUP BY DAY(DATA_TRAMITACAO), UF
)A 

UNION ALL

--- ANO ANTERIOR MES ATUAL
SELECT
DIA,
MES= MONTH(GETDATE()),
ANO = YEAR(GETDATE())-1,
UF,
QTDE_TAS,
LEGENDA = 'Ano Anterior',
SUM(QTDE_TAS) OVER (PARTITION BY UF ORDER BY DIA ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TAS_ACUMULADO
FROM (
    SELECT
    DAY(DATA_TRAMITACAO) AS DIA,
    UF,
    COUNT(DISTINCT TA_ORIGEM) AS QTDE_TAS
    FROM MONITORA_TRAMITACAO..TBL_MONITORA_TRAMITACAO_TAS WITH(NOLOCK)
    WHERE YEAR(DATA_TRAMITACAO) = YEAR(GETDATE())-1 AND MONTH(DATA_TRAMITACAO) = MONTH(GETDATE()) AND UF <> '-' AND TIPO_PAGAMENTO = 'SOB DEMANDA'
    GROUP BY DAY(DATA_TRAMITACAO), UF
)A 


--===================================================================
--ESTRATIFICADO
--===================================================================

SELECT
DIA,
MES,
ANO,
UF,
TIPO_REDE,
CLASS AS CLASSIFICACAO,
COUNT(CLASS) AS QTDE
--LEGENDA = 'Mês Atual'
FROM (
 SELECT DISTINCT
					TA_ORIGEM AS TA,
 DAY(DATA_TRAMITACAO) AS DIA,
 MONTH(DATA_TRAMITACAO) AS MES,
 YEAR(DATA_TRAMITACAO) AS ANO,
REDE AS TIPO_REDE,
UF,
	CLASS
 FROM MONITORA_TRAMITACAO..TBL_MONITORA_TRAMITACAO_TAS WITH(NOLOCK)
 WHERE YEAR(DATA_TRAMITACAO) IN (YEAR(GETDATE()),YEAR(GETDATE())-1,YEAR(GETDATE())-2) AND UF <> '-' AND TIPO_PAGAMENTO = 'SOB DEMANDA'
 )A
GROUP BY ANO, MES, DIA, UF, CLASS, TIPO_REDE
ORDER BY UF, MES, DIA

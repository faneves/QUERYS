
--***************************************************************************************************************************
--BACKLOG SEMANAL ICOMON  - SEMANA 9 EM DIANTE
--***************************************************************************************************************************
WITH DATAS
    AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS
    AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				UF, 
				EVENTO_ORIGEM
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )

SELECT	
		D.SEMANA,
		TAS.UF,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,TAS.UF
ORDER BY 1
--========================================================================================================================================
--BACKLOG DIARIO ICOMON  - SEMANA 9 EM DIANTE
--========================================================================================================================================
WITH DATAS
    AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS
    AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF, 
				EVENTO_ORIGEM
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )

SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF
ORDER BY 1,2,3,4



--==========================================================================================================================================================
--APENAS ALIADAS
--======================================================

WITH DATAS
    AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA >= '2024-01-01' 
				AND UF = 'SP'
				--AND UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS
    AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF, 
				EVENTO_ORIGEM
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA >= '2024-01-01'
				AND UF = 'SP'
				--AND	UF IN ('BA','SE','AL','CE','PB','PE','PI','RN','MG') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )

SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF
ORDER BY 1,2,3,4

--=========================================================================================================================================
--VIVO + ALIADAS
--=========================================================================================================================================
WITH DATAS AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('MA','PA') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF, 
				EVENTO_ORIGEM
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('MA','PA') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )


SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF
ORDER BY 1,2,3,4


--=========================================================================================================================================
--VIVO + ALIADAS POR PRIORIDADE POR UF
--=========================================================================================================================================
WITH DATAS AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('MA','PA') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF, 
				EVENTO_ORIGEM,
				PRIORIDADE
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('MA','PA') 
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )

SELECT
MES,
SEMANA,
DIA,
UF,
ISNULL([1],0) AS 'P1',
ISNULL([2],0) AS 'P2',
ISNULL([3],0) AS 'P3',
ISNULL([4],0) AS 'P4'
FROM(
SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		PRIORIDADE,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF, PRIORIDADE
) A
PIVOT (
	MAX(EVENTOS) FOR PRIORIDADE IN([1],[2],[3],[4])
)P
ORDER BY MES, DIA

--=========================================================================================================================================
--VIVO + ALIADAS DIÁRIO POR PRIORIDADE POR MUNICIPIO
--=========================================================================================================================================
WITH DATAS AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('SP') AND MUNICIPIO = 'SÃO VICENTE'
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF,
				MUNICIPIO,
				EVENTO_ORIGEM,
				PRIORIDADE
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('SP') AND MUNICIPIO = 'SÃO VICENTE'
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )

SELECT
MES,
SEMANA,
DIA,
UF,
MUNICIPIO,
ISNULL([1],0) AS 'P1',
ISNULL([2],0) AS 'P2',
ISNULL([3],0) AS 'P3',
ISNULL([4],0) AS 'P4'
FROM(
SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		TAS.MUNICIPIO,
		PRIORIDADE,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF, TAS.MUNICIPIO, PRIORIDADE
) A
PIVOT (
	MAX(EVENTOS) FOR PRIORIDADE IN([1],[2],[3],[4])
)P
ORDER BY MES, DIA


--=========================================================================================================================================
--VIVO + ALIADAS DIARIO POR MUNICIPIO
--=========================================================================================================================================
WITH DATAS AS
    (
        SELECT  
				MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00')) AS DATA, 
				MAX(DATEPART(week, DATA_REFERENCIA)) AS SEMANA,
				DATEPART(DAY,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS DIA,
				DATEPART(MONTH,MAX(FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00'))) AS MES
        FROM	
				QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('SP') AND MUNICIPIO = 'SÃO VICENTE'
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%')
        GROUP BY FORMAT(DATA_REFERENCIA,'yyyy-MM-dd')
    ),
    TAS AS
    (
        SELECT	FORMAT(DATA_REFERENCIA,'yyyy-MM-dd HH:00:00') AS DATA,
				DATEPART(DAY,DATA_REFERENCIA) AS DIA,
				DATEPART(MONTH,DATA_REFERENCIA) AS MES,
				UF,
				MUNICIPIO,
				EVENTO_ORIGEM
        FROM	QUALIDADE..BACKLOG_TAs WITH(NOLOCK)
        WHERE 
				DATA_REFERENCIA > '2023-01-01' 
				AND	UF IN ('SP') AND MUNICIPIO = 'SÃO VICENTE'
				AND BACKLOG = 'BACKLOG CAMPO - 3 DIAS' 
				--AND (GESTOR_ATUAL LIKE '%EMPRESAS%' OR GESTOR_ATUAL LIKE '%Terceiro%' OR GESTOR_ATUAL LIKE '%GRO%' OR GESTOR_ATUAL LIKE '%MASSIVA%') 
    )


SELECT	
		D.MES,
		D.SEMANA,
		D.DIA,
		TAS.UF,
		TAS.MUNICIPIO,
		COUNT(1) AS EVENTOS
FROM	
		DATAS D
		INNER JOIN TAS ON TAS.DATA = D.DATA
WHERE	
		D.SEMANA >= 9
GROUP BY 
		D.SEMANA ,D.MES, D.DIA, TAS.UF, TAS.MUNICIPIO
ORDER BY 1,2,3,4

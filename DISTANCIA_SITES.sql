--=========================================================================================
--DISTANCIA DOS SITES
--=========================================================================================
SELECT 
	B.REGIONAL AS REGIONAL_A,
	A.UF_A,
	SITE_A,
	LAT_A,
	LONG_A,
	C.REGIONAL AS REGIONAL_B,
	A.UF_B,
	SITE_B,
	LAT_B,
	LONG_B,
	A.DISTANCIA
FROM FABIO..TBL_SITE_MAIS_PROXIMO A
	LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF B ON A.UF_A = B.UF
	LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF C ON A.UF_B = C.UF
ORDER BY UF_A

SELECT 
B.REGIONAL AS REGIONAL_A,
AVG(DISTANCIA) AS MEDIA
FROM FABIO..TBL_SITE_MAIS_PROXIMO A
LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF B ON A.UF_A = B.UF
LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF C ON A.UF_B = C.UF
GROUP BY B.REGIONAL
ORDER BY MEDIA DESC

SELECT 
B.REGIONAL AS REGIONAL_A,
AVG(DISTANCIA) AS MEDIA
FROM FABIO..TBL_ATE_10_SITES_MAIS_PROXIMOS A
LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF B ON A.UF_A = B.UF
LEFT JOIN PROJETO_AGAIN..AUX_REGIONAL_UF C ON A.UF_B = C.UF
GROUP BY B.REGIONAL
ORDER BY MEDIA DESC

SELECT
UF_A,
AVG(DISTANCIA) AS MEDIA
FROM FABIO..TBL_SITE_MAIS_PROXIMO
GROUP BY UF_A
ORDER BY MEDIA DESC

SELECT
UF_A,
AVG(DISTANCIA) AS MEDIA
FROM FABIO..TBL_ATE_10_SITES_MAIS_PROXIMOS
GROUP BY UF_A
ORDER BY MEDIA DESC

SELECT * FROM FABIO..TBL_ATE_10_SITES_MAIS_PROXIMOS



------------------------------------------------------------------------------------------------------
--CALCULO DA DISTANCIA ENTRE O SITES A PARTIR DA TABELA DE COORDENADAS DOS SITES
------------------------------------------------------------------------------------------------------



--DROP TABLE #TEMP_SITES
BEGIN

	--SELECT COUNT(*) AS TOTAL FROM TBA_DISTANCIAS_SITES
	--SELECT * FROM TBA_DISTANCIAS_SITES WHERE UF_A = 'SP' AND SITE_A = 'VIV'

	TRUNCATE TABLE TBA_DISTANCIAS_SITES
	DROP INDEX [INDEX_BUSCA_SITE] ON [dbo].[TBA_DISTANCIAS_SITES]
	DROP INDEX [INDICE_PADRAO] ON [dbo].[TBA_DISTANCIAS_SITES] WITH ( ONLINE = OFF )
	DROP INDEX [INDICE_UF_SITE] ON [dbo].[TBA_DISTANCIAS_SITES]
/*
	CREATE TABLE QUALIDADE..TEMP_SITES (
		ID INT IDENTITY(1,1),
		UF VARCHAR(3),
		MUNICIPIO VARCHAR(40),
		SIGLA_SITE VARCHAR(10),
		LAT FLOAT,
		LONG FLOAT
	) ON [PRIMARY]

	INSERT INTO QUALIDADE..TEMP_SITES SELECT UF, MUNICIPIO, SIGLA_SITE, AVG(LAT) AS LAT, AVG(LONG) AS LONG FROM TBA_PLANTA_SETORES /*WHERE UF = 'PR'*/ GROUP BY UF, MUNICIPIO, SIGLA_SITE
*/
	DECLARE @LOOP_COUNTER INT = 1 
	DECLARE @LOOP_MAX INT
	DECLARE @DISTANCIA FLOAT

	SELECT @LOOP_MAX = 29505 --COUNT(ID) FROM QUALIDADE..TEMP_SITES

	/*
	DECLARE @UF_A VARCHAR(2), @MUNICIPIO_A VARCHAR(40), @SIGLA_SITE_A VARCHAR(3), @LAT_A FLOAT, @LONG_A FLOAT
	DECLARE @UF_B VARCHAR(2), @MUNICIPIO_B VARCHAR(40), @SIGLA_SITE_B VARCHAR(3), @LAT_B FLOAT, @LONG_B FLOAT
	*/
	

	WHILE @LOOP_COUNTER <= @LOOP_MAX
	BEGIN

		BEGIN TRY
			INSERT INTO TBA_DISTANCIAS_SITES (UF_A, MUNICIPIO_A, SITE_A, LAT_A, LONG_A, UF_B, MUNICIPIO_B, SITE_B, LAT_B, LONG_B, DISTANCIA)
			SELECT * FROM (
				SELECT 
					A.UF AS UF_A, 
					A.MUNICIPIO AS MUNICIPIO_A,
					A.SIGLA_SITE AS SITE_A, 
					A.LAT AS LAT_A, 
					A.LONG AS LONG_A,
					B.UF AS UF_B, 
					B.MUNICIPIO AS MUNICIPIO_B,
					B.SIGLA_SITE AS SITE_B, 
					B.LAT AS LAT_B, 
					B.LONG AS LONG_B,
					dbo.CALCULO_DISTANCIA_LAT_LONG(A.LAT, A.LONG, B.LAT, B.LONG) AS DISTANCIA
				FROM QUALIDADE..TEMP_SITES A
				LEFT JOIN QUALIDADE..TEMP_SITES B ON A.ID <> B.ID
				WHERE A.ID = @LOOP_COUNTER
			)A WHERE A.DISTANCIA <= 600
		END TRY

		BEGIN CATCH 
			SELECT @DISTANCIA = -1
		END CATCH

		SET @LOOP_COUNTER = @LOOP_COUNTER + 1

	END
END


	CREATE NONCLUSTERED INDEX [INDEX_BUSCA_SITE] ON [dbo].[TBA_DISTANCIAS_SITES]
	(
		[UF_A] ASC,
		[SITE_A] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	CREATE CLUSTERED INDEX [INDICE_PADRAO] ON [dbo].[TBA_DISTANCIAS_SITES]
	(
		[UF_A] ASC,
		[MUNICIPIO_A] ASC,
		[SITE_A] ASC,
		[UF_B] ASC,
		[MUNICIPIO_B] ASC,
		[SITE_B] ASC,
		[DISTANCIA] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

		CREATE NONCLUSTERED INDEX [INDICE_UF_SITE] ON [dbo].[TBA_DISTANCIAS_SITES]
	(
		[UF_A] ASC,
		[SITE_A] ASC
	)
	INCLUDE ( 	[ID],
		[DATA_REFERENCIA],
		[LAT_A],
		[LONG_A],
		[LAT_B],
		[LONG_B]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

END
GO


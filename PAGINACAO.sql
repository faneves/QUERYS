TRUNCATE TABLE FABIO..TBA_EVENTOS_PAGINADOS

BEGIN

DECLARE @TAB_EVENTOS_LOOP TABLE(A_EVENTOS VARCHAR(MAX))
DECLARE @COUNT INT = 0
DECLARE @EVENTOS FLOAT

DECLARE @QTD_POR_PAGINA INT = 2 ---QUANTIDADE DEFAULT DE EVENTOS POR PAGINAÇÃO

DECLARE @PAGINACAO INT

SELECT @EVENTOS =  COUNT(1) FROM FABIO..TBL_EVENTOS EVENTOS WITH(NOLOCK)
						 
SELECT @PAGINACAO = CASE WHEN @EVENTOS<=@QTD_POR_PAGINA THEN 1 ELSE CEILING(CAST(@EVENTOS AS DECIMAL)/CAST(@QTD_POR_PAGINA AS DECIMAL)) END 

WHILE @COUNT < @PAGINACAO

	BEGIN

INSERT INTO FABIO..TBA_EVENTOS_PAGINADOS
    SELECT STUFF((
                    SELECT DISTINCT
                        ',' + CAST(EVENTO AS VARCHAR) AS EVENTOS	
                    FROM FABIO..TBL_EVENTOS WITH(NOLOCK)
                    ORDER BY 1
                    OFFSET @COUNT*@QTD_POR_PAGINA ROWS 
                    FETCH NEXT @QTD_POR_PAGINA ROWS ONLY 
                    FOR XML PATH(''), TYPE
                    ).value('.', 'VARCHAR(MAX)'), 1, 1, ''
    )AS EVENTOS
    SET @COUNT+=1

	END

END
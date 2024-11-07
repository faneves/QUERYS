

DECLARE @DATA AS DATETIME, @DATA_FIM AS DATETIME, @HMM AS VARCHAR(5) = 'HMM', @AGRUPAMENTO AS VARCHAR(50) = 'REGIONAL', @TP_PERIODO VARCHAR(3) = 'W'

SET @DATA = GETDATE()-1

DECLARE @PERIODO AS VARCHAR(30)

SET @PERIODO = CASE WHEN @TP_PERIODO = 'W' THEN DATENAME(WW,@DATA) 
                    WHEN @TP_PERIODO = 'M' THEN CAST(DATEADD(MM,DATEDIFF(MM,0,@DATA),0) AS VARCHAR(30))--PRIMEIRO DIA DO MES
                    ELSE CONVERT(VARCHAR,@DATA,112) -- AS VARCHAR(30))
                    END

;WITH CALCULO AS (
SELECT
    CASE WHEN @TP_PERIODO = 'M' THEN DATEADD(MM,DATEDIFF(MM,0,DATA_REFERENCIA),0) --PRIMEIRO DIA DO MES
         WHEN @TP_PERIODO = 'S' THEN DATEPART(W,DATA_REFERENCIA)
         ELSE DATA_REFERENCIA
END AS PERIODO,
REGIONAL = CASE WHEN @AGRUPAMENTO IS NOT NULL THEN
                        CASE WHEN A.UF = 'SP' THEN B.NOME_REGIONAL
                             WHEN A.UF IN ('BA', 'SE', 'AL', 'RN', 'PB', 'CE', 'PI', 'PE') THEN 'NE' 
                             WHEN A.UF = 'MG' THEN 'MG'
                             WHEN A.UF IN ('RJ', 'ES') THEN 'RJ/ES'
                             WHEN A.UF IN ('PR', 'SC', 'RS') THEN 'SUL'
                             WHEN A.UF IN ('AM', 'PA', 'MA', 'AP', 'RR') THEN 'NO'
                             WHEN A.UF IN ('AC', 'MS', 'MT', 'RO', 'DF', 'GO', 'TO') THEN 'CO'
                        END
            ELSE NULL 
            END,
UF = CASE WHEN @AGRUPAMENTO IN ('UF', 'MUNICIPIO', 'SITE', 'ERB') THEN A.UF ELSE NULL END,
MUNICIPIO = CASE WHEN @AGRUPAMENTO IN ('MUNICIPIO', 'SITE', 'ERB') THEN A.MUNICIPIO ELSE NULL END,
SITE = CASE WHEN @AGRUPAMENTO IN ('SITE', 'ERB') THEN A.SITE ELSE NULL END,
ERB = CASE WHEN @AGRUPAMENTO = 'ERB' THEN A.ERB ELSE NULL END,
CASE WHEN TECNOLOGIA = 'GSM' THEN '2G'
     WHEN TECNOLOGIA = 'WCDMA' THEN '3G'
     WHEN TECNOLOGIA = 'LTE' THEN '4G'
     ELSE TECNOLOGIA
END AS TECNOLOGIA,
TEMPO_CONTADOR = SUM(CASE WHEN @HMM = 'HMM' THEN TEMPO_CONTADOR_HMM ELSE TEMPO_CONTADOR END),
COLETAS = SUM(CASE WHEN @HMM = 'HMM' THEN COLETAS_HMM ELSE COLETAS END)
FROM SISTEMA_MAESTRO..TBF_DISPONIBILIDADE_SETORES A WITH(NOLOCK)
LEFT JOIN INDICADORES_CORAN..TBA_DIVISAO_MUNICIPIOS_SP_FIXA B ON A.MUNICIPIO = B.MUNICIPIO AND A.UF = 'SP'
WHERE (TEMPO_CONTADOR_HMM >= 0 OR TEMPO_CONTADOR >=0 )
GROUP BY
CASE WHEN @TP_PERIODO = 'M' THEN DATEADD(MM,DATEDIFF(MM,0,DATA_REFERENCIA),0) 
     WHEN @TP_PERIODO = 'S' THEN DATEPART(W,DATA_REFERENCIA)
     ELSE DATA_REFERENCIA END,
        CASE WHEN @AGRUPAMENTO IS NOT NULL THEN
                        CASE WHEN A.UF = 'SP' THEN B.NOME_REGIONAL
                             WHEN A.UF IN ('BA', 'SE', 'AL', 'RN', 'PB', 'CE', 'PI', 'PE') THEN 'NE' 
                             WHEN A.UF = 'MG' THEN 'MG'
                             WHEN A.UF IN ('RJ', 'ES') THEN 'RJ/ES'
                             WHEN A.UF IN ('PR', 'SC', 'RS') THEN 'SUL'
                             WHEN A.UF IN ('AM', 'PA', 'MA', 'AP', 'RR') THEN 'NO'
                             WHEN A.UF IN ('AC', 'MS', 'MT', 'RO', 'DF', 'GO', 'TO') THEN 'CO'
                        END
            ELSE NULL 
            END,
        CASE WHEN @AGRUPAMENTO IN ('UF', 'MUNICIPIO', 'SITE', 'ERB') THEN A.UF ELSE NULL END,
        CASE WHEN @AGRUPAMENTO IN ('MUNICIPIO', 'SITE', 'ERB') THEN A.MUNICIPIO ELSE NULL END,
        CASE WHEN @AGRUPAMENTO IN ('SITE', 'ERB') THEN A.SITE ELSE NULL END,
        CASE WHEN @AGRUPAMENTO = 'ERB' THEN A.ERB 
        ELSE NULL 
        END,
DATA_REFERENCIA,
CASE WHEN TECNOLOGIA = 'GSM' THEN '2G' 
     WHEN TECNOLOGIA = 'WCDMA' THEN '3G'
     WHEN TECNOLOGIA = 'LTE' THEN '4G'
     ELSE TECNOLOGIA END

)


SELECT
-- DATEPART(YEAR,@DATA) AS ANO,
-- DATEPART(MONTH,@DATA) AS MES,
-- DATEPART(WEEK, @DATA) AS SEMANA,
REGIONAL,
UF,
MUNICIPIO,
SITE,
ERB,
MINUTOS_2G = SUM(CASE WHEN TECNOLOGIA = '2G' THEN TEMPO_CONTADOR ELSE 0 END),
DISP_2G = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '2G'  THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA = '2G' THEN CAST(COLETAS AS FLOAT) END)*60)))*100),6),
MINUTOS_3G = SUM(CASE WHEN TECNOLOGIA = '3G' THEN TEMPO_CONTADOR ELSE 0 END),
DISP_3G = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '3G'  THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA = '3G' THEN CAST(COLETAS AS FLOAT) END)*60)))*100),6),
MINUTOS_4G = SUM(CASE WHEN TECNOLOGIA = '4G' THEN TEMPO_CONTADOR ELSE 0 END),
DISP_4G = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '4G' THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA = '4G' THEN CAST(COLETAS AS FLOAT) END)*60)))*100),2),
MINUTOS_5G = SUM(CASE WHEN TECNOLOGIA = '5G' THEN TEMPO_CONTADOR ELSE 0 END),
DISP_5G = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA = '5G' THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA = '5G' THEN CAST(COLETAS AS FLOAT) END)*60)))*100),2),
MINUTOS_GERAL = SUM(CASE WHEN TECNOLOGIA <> '2G' THEN TEMPO_CONTADOR ELSE 0 END),
DISP_GERAL = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA <> '2G' THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA <> '2G' THEN CAST(COLETAS AS FLOAT) END)*60)))*100),2),
MINUTOS_4G_5G = SUM(CASE WHEN TECNOLOGIA IN ('4G','5G') THEN TEMPO_CONTADOR ELSE 0 END),
DISP_4G_5G = ROUND(((1-(SUM(CASE WHEN TECNOLOGIA IN ('4G','5G') THEN CAST(TEMPO_CONTADOR AS FLOAT) END)/(SUM(CASE WHEN TECNOLOGIA IN ('4G','5G') THEN CAST(COLETAS AS FLOAT) END)*60)))*100),2)
FROM CALCULO
WHERE PERIODO >= @PERIODO AND PERIODO < CASE WHEN @TP_PERIODO = 'W' THEN DATENAME(WW,@DATA)
                                             WHEN @TP_PERIODO = 'M' THEN CAST(DATEADD(MM,DATEDIFF(MM,0,@DATA),0) AS VARCHAR(30)) --PRIMEIRO DIA DO MES
                                             ELSE @DATA + 1-- AS VARCHAR(30))
                                             END
GROUP BY 
        PERIODO,
        REGIONAL,
        UF,
        MUNICIPIO,
        SITE,
        ERB

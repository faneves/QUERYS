SELECT
        TA.TQA_CODIGO AS EVENTO,
        TA.TQA_ORIGEM AS EVENTO_ORIGEM,
        TA_ORIGEM.TQA_RAIZ AS EVENTO_RAIZ,
        TA.TQA_DATA_CRIACAO AS DATA_CRIACAO,
        TIPO_PLANTA.TPL_NOME AS TIPO_PLANTA,
        TIPO_TA.TPB_NOME AS TIPO_TA,
        TIPO_REDE.TPJ_NOME AS TIPO_REDE,
        TA.TQA_TIPO_BILHETE AS TIPO_BILHETE,
        TA.TQA_ALARME_TIPO AS TIPO_ALARME,
        TA.TQA_ALARME AS ALARME,
        GRP.GRP_NOME AS GESTOR_ATUAL,
        CASE WHEN   TA.TQA_ESTADO_CODIGO IN('SP') 
                    THEN 'SP' WHEN TA.TQA_ESTADO_CODIGO IN('AC','MS','MT','RO','DF','GO','TO') 
                    THEN 'CO' WHEN TA.TQA_ESTADO_CODIGO IN('AM','RR','AP','MA','PA') 
                    THEN 'NO' WHEN TA.TQA_ESTADO_CODIGO IN('MG','ES','RJ') 
                    THEN 'SUD' WHEN TA.TQA_ESTADO_CODIGO IN('RS','PR','SC') 
                    THEN 'SUL' WHEN TA.TQA_ESTADO_CODIGO IN('BA','SE','AL','CE','PB','PE','PI','RN') 
                    THEN 'NE' END REGIONAL,
        TA.TQA_ESTADO_CODIGO AS UF,
        TA.TQA_DDD AS CN,
        TA.TQA_LOCALIDADE_NOME AS MUNICIPIO,
        TA.TQA_AREA_CODIGO AS SITE,
        TA.TQA_TIPO_SITE AS TIPO_SITE,
        EQP.AEQ_TIPO_ELEMENTO_REDE AS TIPO_ELEMENTO_REDE,
        EQP.AEQ_HOSTNAME AS ERB,
        EQP.AEQ_SETOR AS SETOR,
        LENGTH(EQP.AEQ_SETOR) - LENGTH(REPLACE(EQP.AEQ_SETOR,'#',null)) AS SETORES_AFETADOS,
        EQP.AEQ_TECNOLOGIA AS TECNOLOGIA,
        EQP.AEQ_FABRICANTE AS FABRICANTE,
        EQP.AEQ_IMPACTO_EQP AS IMPACTO,
        CASE WHEN TA.TQA_ALARME IN( 'SETOR FORA DE SERVICO', 
                                    'ENODEB FALHA DE COMUNICACAO', 
                                    'FALHA INDISPONIBILIDADE SETOR', 
                                    'FALHA INDISPONIBILIDADE ELEMENTO', 
                                    'FALHA COMUNICACAO ELEMENTO', 
                                    'ALERTA INDISPONIBILIDADE TRAFEGO', 
                                    'TODOS OS SETORES DA ERB ESTAO INDISPONIVEIS', 
                                    'CELULA SEM TRAFEGO', 
                                    'ALTAIA - SETOR SEM TRAFEGO', 
                                    'TG FORA DE SERVICO', 
                                    'TODOS OS SETORES DA ERB ESTAO INDISPONIVEIS (ERB FORA)', 
                                    'FALHA INDISPONIBILIDADE SERVICO', 
                                    'ALERTA INDISPONIBILIDADE DADOS', 
                                    'FALHA MAL_FUNCIONAMENTO SOFTWARE', 
                                    'BTS_FALHA DE COMUNICACAO ENTRE O TRX E A TMU', 
                                    'TÍQUETE DE QUALIDADE MAESTRO', 
                                    'FALHA COMUNICACAO SUBSISTEMA', 
                                    'FALHA DE COMUNICACAO DO RADIO', 
                                    'FALHA DE COMUNICACAO ENTRE A PMU E TMU', 
                                    'FALHA COMUNICACAO LINK', 
                                    'NODEB FORA DE SERVICO', 
                                    'BTS FORA DE SERVICO', 
                                    'FALHA INDISPONIBILIDADE RF', 
                                    'FALHA HARDWARE RRU') 
          OR TA.TQA_ALARME_TIPO IN( 'Cell Downtime - GSM', 
                                    'Cell Downtime - WCDMA', 
                                    'Cell Downtime - LTE') 
             THEN 1 ELSE 0 END FLG_CELLDOWNTIME
FROM    
        SIGITM3.TBL_TA_EQUIPAMENTO EQP
        INNER JOIN SIGITM3.TBL_TA TA                    ON EQP.AEQ_TA                           = TA.TQA_CODIGO
        INNER JOIN SIGITM3.TBC_TIPOS_REDE_TA TIPO_REDE  ON TA.TQA_TIPO_REDE                     = TIPO_REDE.TPJ_CODIGO
        INNER JOIN SIGITM3.TBC_TIPOS_TA TIPO_TA         ON TIPO_REDE.TPJ_TIPO_TA                = TIPO_TA.TPB_CODIGO
        INNER JOIN SIGITM3.TBC_TIPOS_PLANTA TIPO_PLANTA ON TA.TQA_TIPO_PLANTA                   = TIPO_PLANTA.TPL_CODIGO
        LEFT  JOIN SIGITM3.TBL_TA TA_ORIGEM             ON TA.TQA_ORIGEM                        = TA_ORIGEM.TQA_CODIGO
        INNER JOIN SIGITM3.TBL_GRUPOS GRP               ON TA_ORIGEM.TQA_RESPONSAVELPOR_GRUPO   = GRP.GRP_CODIGO
WHERE 
        TA.TQA_TIPO_PLANTA = 3 AND 
        TA.TQA_STATUS = 10 AND 
        EQP.AEQ_TIPO_ELEMENTO_REDE = 'ERB' AND 
        GRP.GRP_NOME <> 'HOMOLOGAÇÃO-TEMS'
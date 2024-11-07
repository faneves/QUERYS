USE [MAESTRO]
GO
/****** Object:  UserDefinedFunction [dbo].[CALCULO_DISTANCIA_LAT_LONG]    Script Date: 02/04/2020 17:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[CALCULO_DISTANCIA_LAT_LONG] (
    @LAT_A FLOAT,
    @LONG_A FLOAT,
    @LAT_B FLOAT,
    @LONG_B FLOAT
)
RETURNS FLOAT
AS
BEGIN

    DECLARE @PI FLOAT = PI()

    DECLARE @lat1Radianos FLOAT = @LAT_A * @PI / 180
    DECLARE @lng1Radianos FLOAT = @LONG_A * @PI / 180
    DECLARE @lat2Radianos FLOAT = @LAT_B * @PI / 180
    DECLARE @lng2Radianos FLOAT = @LONG_B * @PI / 180

    RETURN (ACOS(COS(@lat1Radianos) * COS(@lng1Radianos) * COS(@lat2Radianos) * COS(@lng2Radianos) + COS(@lat1Radianos) * SIN(@lng1Radianos) * COS(@lat2Radianos) * SIN(@lng2Radianos) + SIN(@lat1Radianos) * SIN(@lat2Radianos)) * 6371) * 1.15

END
DROP PROCEDURE IF EXISTS prCalculaDescuento;
DELIMITER //
CREATE PROCEDURE prCalculaDescuento (in prmKms integer, inout prmDiasUso integer, inout prmDiasPunta integer, in prmDiasSinMedicion integer, in prmScore integer, in prmDiasMes integer, in prmDiasVigencia integer,
	                                 out vo_nDescuento decimal(10,2), out vo_nDescuentoKM decimal(10,2), out vo_nDescDiaSinUso decimal(10,2), out vo_nDescNoHoraPunta decimal(10,2), out vo_nFactorDias float )
BEGIN
	-- Normalmente prmDiasMes y prmDiasVigencia son iguales, excpeto para las cuentas 
	-- que son creadas en el mes en curso.
	-- Por ejemplo si la cuenta fue creada el 20/Enero, prmDiasMes = 31 y
	-- prmDiasVigencia = 11 (i.e. 31-20).

	DECLARE kDescLimite			integer	     DEFAULT 40;
	DECLARE kParamDiaSinUso     decimal(5,2) DEFAULT 0.66;
    DECLARE kParamNoHoraPunta   decimal(5,2) DEFAULT 0.33;

	DECLARE vnKmsPond			integer;
    DECLARE vnDiasUso			integer;
    DECLARE vnDiasPunta			integer;

	IF prmDiasMes      IS NULL THEN 
		SET prmDiasMes = 30;
	END IF;
	IF prmDiasVigencia IS NULL THEN
		SET prmDiasVigencia = prmDiasMes;
	END IF;
	
    -- La cantidad de días de uso no puede ser mayor a las del mes
    IF prmDiasUso > prmDiasMes THEN
        SET prmDiasUso = prmDiasMes;
    END IF;
	-- Ajusta la NO Medición
    SET vnDiasUso = prmDiasUso + prmDiasSinMedicion;
    IF vnDiasUso > prmDiasMes THEN
		SET vnDiasUso = prmDiasMes ;
    END IF;
    SET vnDiasPunta = prmDiasPunta + prmDiasSinMedicion;
    IF vnDiasPunta > prmDiasMes THEN
		SET vnDiasPunta = prmDiasMes;
    END IF;
    
    -- La cantidad de días de uso en hora punta o nocturno, no puede ser mayor a la cantidad de días de uso
    IF prmDiasPunta > prmDiasUso THEN
        SET prmDiasPunta = prmDiasUso;
    END IF;
    IF vnDiasPunta > vnDiasUso THEN
        SET vnDiasPunta = vnDiasUso;
    END IF;
    
	-- Se considera la fracción de días desde el inicio de actividad del vehículo
	-- Normalmente el inicio es el primer día del mes, pero no para los vehículos 
	-- que entran en actividad en medio del mes en análisis (prmMes)
   	SET vo_nFactorDias = prmDiasVigencia / prmDiasMes;

   	-- Si es una fracción del mes, pondera la cantidad de KMS
   	SET vnKmsPond = prmKms / vo_nFactorDias;

	SELECT d.nValor INTO vo_nDescuentoKM
	FROM   tRangoDescuento d
	WHERE  d.cTpDescuento = 'KM' AND d.nInicio <= vnKmsPond AND vnKmsPond < d.nFin;

	-- Se considera la fracción de días desde el inicio de actividad del vehículo
	-- Normalmente el inicio es el primer día del mes, pero no para los vehículos 
	-- que entran en actividad en medio del mes.
	-- Ajusta el descuento a la fracción del mes
	SET vo_nDescuento = round(vo_nDescuentoKM * vo_nFactorDias, 0);
	-- Descuento por días sin uso
	SET vo_nDescDiaSinUso = round(( prmDiasMes - vnDiasUso ) * kParamDiaSinUso, 0);
	SET vo_nDescuento = vo_nDescuento + vo_nDescDiaSinUso;

	-- Descuento por días de uso fuera de hora Punta, es igual a los días usados - los días en Punta
	SET vo_nDescNoHoraPunta = round(( vnDiasUso - vnDiasPunta ) * kParamNoHoraPunta,0);
	SET vo_nDescuento = vo_nDescuento + vo_nDescNoHoraPunta;
	-- Ajusta por el puntaje
	IF vo_nDescuento > 0 THEN
		-- Descuento
		IF prmScore > 60 THEN
			SET vo_nDescuento = vo_nDescuento * prmScore / 100;
		ELSE
			SET vo_nDescuento = 0;
		END IF;
	ELSE
		-- Recargo, si maneja bien se disminuye el recargo
		IF prmScore > 60 THEN
			SET vo_nDescuento = vo_nDescuento * ( 100 - prmScore ) / 100;
		END IF;
	END IF;
	IF prmScore < 40 THEN
		-- Se recarga 1 punto por cada score bajo 40
		SET vo_nDescuento = vo_nDescuento - ( 40 - prmScore );
	END IF;

	IF vo_nDescuento > kDescLimite THEN
		SET vo_nDescuento = kDescLimite;
	END IF;
	IF vo_nDescuento < -kDescLimite THEN
		SET vo_nDescuento = -kDescLimite;
	END IF;
	SET vo_nDescuento = round(vo_nDescuento, 0);

-- select prmKms, prmDiasUso, prmDiasPunta, prmScore, prmDiasMes, prmDiasVigencia, vo_nDescuento, vo_nDescuentoKM, vo_nDescDiaSinUso, vo_nDescNoHoraPunta, vo_nFactorDias;
	 
END //
DELIMITER ;

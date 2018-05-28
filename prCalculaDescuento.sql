DELIMITER //
DROP PROCEDURE IF EXISTS prCalculaDescuento //
CREATE PROCEDURE prCalculaDescuento ( in	prmKms				INTEGER, inout	prmDiasUso	INTEGER, inout	prmDiasPunta	INTEGER
									, in	prmDiasSinMedicion	INTEGER, in		prmScore	INTEGER, in		prmDiasMes		INTEGER
									, in	prmDiasVigencia		INTEGER
									, out	vo_nDescuento		DECIMAL(10,2)	, out vo_nDescuentoKM		DECIMAL(10,2)
									, out	vo_nDescDiaSinUso	DECIMAL(10,2)	, out vo_nDescNoHoraPunta	DECIMAL(10,2)
									, out	vo_nFactorDias		float 			, out vo_kmsPond			INTEGER )
BEGIN
	-- Normalmente prmDiasMes y prmDiasVigencia son iguales, excpeto para las cuentas 
	-- que son creadas en el mes en curso.
	-- Por ejemplo si la cuenta fue creada el 20/Enero, prmDiasMes = 31 y
	-- prmDiasVigencia = 11 (i.e. 31-20).
	DECLARE kDescLimite				INTEGER			DEFAULT 40;
	DECLARE kParamDiaSinUso			DECIMAL(5,2)	DEFAULT 0.66;
	DECLARE kParamNoHoraPunta		DECIMAL(5,2)	DEFAULT 0.33;

	DECLARE kParamDescuentoByScore	DECIMAL(5,2)	DEFAULT 1.50;
	DECLARE kParamRecargoByScore	DECIMAL(5,2)	DEFAULT 2.00;

--  DECLARE vnKmsPond		INTEGER;
	DECLARE vnDiasUso		INTEGER;
	DECLARE vnDiasPunta		INTEGER;
    DECLARE bDescNoAplica	BOOLEAN DEFAULT FALSE;

	IF prmDiasMes IS NULL THEN 
		SET prmDiasMes = 30;
	END IF;
	IF prmDiasVigencia IS NULL OR prmDiasVigencia >= prmDiasMes THEN
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
    IF prmDiasSinMedicion > 0 THEN
		BEGIN
			DECLARE F FLOAT DEFAULT ( prmDiasVigencia - prmDiasSinMedicion ) / prmDiasMes;
   			-- La condición con F==0 es que desde que inició nunca midió, y si F < 0 debería ser una inconsistencia
			IF F > 0 THEN
				SET vo_kmsPond = round(prmKms / F,0);
			ELSEIF prmKms = 0 THEN
				-- Quiere decir que no hay información y que los días de no medición son iguales o mas a los días del periodo
				-- luego se puede considerar no descuento
				SET bDescNoAplica = TRUE;                    
			END IF;
		END;
		-- Como regla, si el vehículo tiene mas de 15 días de no medición tampoco hay descuento
		IF prmDiasSinMedicion >= 15 THEN
			SET bDescNoAplica = TRUE;
		END IF;
    END IF;
        
	IF vo_kmsPond IS NULL THEN
		SET vo_kmsPond = round(prmKms / vo_nFactorDias,0);
	END IF;                
        

	SELECT	d.nValor INTO vo_nDescuentoKM
	FROM	tRangoDescuento d
	WHERE	d.cTpDescuento = 'KM' AND d.nInicio <= vo_kmsPond AND vo_kmsPond < d.nFin;
    
-- DEBUG
-- IF vo_nDescuentoKM IS NULL THEN
-- SELECT vo_kmsPond;
-- END IF;    

	-- Se considera la fracción de días desde el inicio de actividad del vehículo
	-- Normalmente el inicio es el primer día del mes, pero no para los vehículos 
	-- que entran en actividad en medio del mes.
	-- Ajusta el descuento a la fracción del mes
	SET vo_nDescuentoKM = vo_nDescuentoKM * vo_nFactorDias;
	-- Descuento por días sin uso
	SET vo_nDescDiaSinUso = ( prmDiasMes - vnDiasUso ) * kParamDiaSinUso;
-- SET vo_nDescuento = vo_nDescuento + vo_nDescDiaSinUso;

	-- Descuento por días de uso fuera de hora Punta, es igual a los días usados - los días en Punta
	SET vo_nDescNoHoraPunta = ( vnDiasUso - vnDiasPunta ) * kParamNoHoraPunta;


    -- AGALAZ ( 23/04/2018 )
    -- Para el primer mes de la póliza que normalmente va a tener 23 días (periodo - 7 días), 
    -- para Febrero que tiene 28 y para finalmente para los meses que tiene 31 días, se ajusta
    -- el descuento sin uso a 30 días, así el 20% que es el máximo debería darse no importando
    -- la cantidad de días del periodo
	IF prmDiasMes > 0  AND prmDiasMes <> 30 THEN    
		SET vo_nDescDiaSinUso = vo_nDescDiaSinUso * 30 / prmDiasMes;
        SET vo_nDescNoHoraPunta = vo_nDescNoHoraPunta * 30 / prmDiasMes;
    END IF;
    
	SET vo_nDescuento = vo_nDescuentoKM + vo_nDescDiaSinUso + vo_nDescNoHoraPunta;
    
	-- Ajusta por el puntaje
	IF vo_nDescuento > 0 THEN
		-- Descuento
		IF prmScore >= 60 THEN
			SET vo_nDescuento = vo_nDescuento * ( 100 - ( 100 - prmScore ) * kParamDescuentoByScore ) / 100;
		ELSE
			SET vo_nDescuento = 0;
		END IF;
	ELSE
		-- Recargo, si maneja bien se disminuye el recargo
		IF prmScore >= 60 THEN
			SET vo_nDescuento = vo_nDescuento * ( 100 - prmScore ) * kParamRecargoByScore / 100;
		END IF;
	END IF;
	IF prmScore < 40 THEN
		-- Se recarga kParamRecargoByScore puntos por cada score bajo 40
		SET vo_nDescuento = vo_nDescuento - ( 40 - prmScore );
	END IF;

	IF vo_nDescuento > kDescLimite THEN
		SET vo_nDescuento = kDescLimite;
	END IF;
	IF vo_nDescuento < -kDescLimite THEN
		SET vo_nDescuento = -kDescLimite;
	END IF;
    
    IF bDescNoAplica AND vo_nDescuento > 0 THEN
		SET vo_nDescuento = 0;
    END IF;
	SET vo_nDescuento = round(vo_nDescuento, 0);

END //


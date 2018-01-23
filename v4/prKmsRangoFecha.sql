DELIMITER //
DROP PROCEDURE IF EXISTS prKmsRangoFecha //
CREATE PROCEDURE prKmsRangoFecha( IN prm_pUsuario INTEGER, IN prm_pVehiculo INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
LB_PRINCIPAL: BEGIN
	DECLARE vdIni			DATE;
	DECLARE vdIniVigencia		DATE;
	DECLARE vdFin			DATE;

	IF prm_nPeriodo IS NOT NULL THEN
		-- Rango de fechas a partir de la fecha de vigencia
		SELECT 	fnFechaCierreIni( dIniVigencia, prm_nPeriodo )
              , fnFechaCierreFin( dIniVigencia, prm_nPeriodo )
			  , dIniVigencia	
        INTO	vdIni, vdFin
			  , vdIniVigencia	
		FROM	tVehiculo
        WHERE 	pVehiculo = prm_pVehiculo;

	ELSEIF prm_dIni IS NOT NULL AND prm_dFin IS NOT NULL THEN
		IF prm_dIni IS NULL THEN
			SET vdIni = DATE(DATE_SUB(fnNow(), INTERVAL DAYOFMONTH(fnNow()) - 1 DAY));
		ELSE
			SET vdIni = prm_dIni;
		END IF;

		IF prm_dFin IS NULL THEN
			SET vdFin = fnNow();
		ELSE
			SET vdFin = prm_dFin;
		END IF;
		SET vdFin = ADDDATE(vdFin, INTERVAL 1 DAY);
	ELSE
		SELECT 4540 nCodigo, 'Se debe indicar periodo o rango de fechas' cMensaje;
		LEAVE LB_PRINCIPAL;
	END IF;

	-- La fecha de inicio no puede ser anterior a la fecha de la Póliza
	IF vdIni < vdIniVigencia THEN
		SET vdIni = vdIniVigencia;
	END IF;

	-- CURSOR 1: Rango de fechas utilizadas
	SELECT 	SUBSTRING(vdIni, 1, 10 )							AS dInicio,
			SUBSTRING(DATE_SUB(vdFin, INTERVAL 1 DAY), 1, 10 )	AS dFin;
	-- CURSOR 2: Kms x día
	SELECT 	v.cPatente, d.pScoreDia, d.dFecha, d.nKms 
    FROM	score.tScoreDia 		AS d
			INNER JOIN	tVehiculo	AS v ON v.pVehiculo = d.fVehiculo
    WHERE 	d.fUsuario = prm_pUsuario
    AND		d.fVehiculo = prm_pVehiculo
    AND		d.dFecha >= vdIni
    AND		d.dFecha <  vdFin
    ORDER	BY d.dFecha;

END //

DELIMITER //
DROP PROCEDURE IF EXISTS prRefactura //
CREATE PROCEDURE prRefactura ( IN prm_pVehiculo INTEGER, IN prm_nDiasNoSincro INTEGER, IN prm_bBorraAceleraciones BOOLEAN, IN prm_cUsuario VARCHAR(40))
BEGIN
	DECLARE vpPeriodo					DATE;
	DECLARE vdInicio						DATE;
    DECLARE vfUsuario					INTEGER;
    DECLARE vnDiasSinMedicion	INTEGER;
    
	-- select concat('call prRecalculaScore(','\'',  fnFechaCierreIni(dIniVigencia, 0) - interval 1 day, '\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) -- , dIniVigencia
    --  from tVehiculo where cPatente in ('LQB799','AB844YD') and bVigente='1'; -- pVehiculo in (494);
	SELECT	fnFechaCierreIni(dIniVigencia, -1) day, fUsuarioTitular
    INTO		vdInicio, vfUsuario
	FROM		tVehiculo
    WHERE	pVehiculo = prm_pVehiculo;

    IF prm_bBorraAceleraciones THEN
-- SELECT vdInicio - INTERVAL 1 MONTH;
		-- Borra aceleraciones
		UPDATE	snapcar.trip_observations_g
        SET			`status` = 'D'
		WHERE	prefix_observation = 'A'
		AND 		trip_id in (	SELECT t.id
											FROM	snapcar.clients c 
													JOIN snapcar.trips t ON t.client_id = c.id
											WHERE	c.vehicle_id = prm_pVehiculo
											AND		t.from_date >= vdInicio - INTERVAL 1 MONTH
										);		
		DELETE FROM tEvento
        WHERE	fTpEvento = 3 -- Aceleraciones
		AND		tEvento >= vdInicio - INTERVAL 1 MONTH
		AND		fVehiculo = prm_pVehiculo;

-- select 'Aceleraciones borradas';
    END IF;
    
 	SELECT	pPeriodo, nDiasSinMedicion
    INTO		vpPeriodo, vnDiasSinMedicion
    FROM		tFactura
    WHERE	pVehiculo	= prm_pVehiculo
    AND		dInicio			= vdInicio
    AND		pTpFactura	= 1
    ;
    
 	IF vpPeriodo IS NOT NULL AND vnDiasSinMedicion <> prm_nDiasNoSincro THEN
		INSERT INTO tFacturaSinMedicion
						( pVehiculo, pPeriodo, nDiasSinMedicion
                        , nDifDias, cUsuario )
        VALUES	( prm_pVehiculo, vpPeriodo, prm_nDiasNoSincro
						, prm_nDiasNoSincro -  nDiasSinMedicion, prm_cUsuario );
    END IF;
    
-- 	CALL prRecalculaScore( vdInicio, prm_pVehiculo, vfUsuario);
--  CALL prFacturador( prm_pVehiculo );

	select 'OK', prm_bBorraAceleraciones;

END //

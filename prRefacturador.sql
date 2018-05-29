DELIMITER //
DROP PROCEDURE IF EXISTS prRefactura //
CREATE PROCEDURE prRefactura ( IN prm_pVehiculo INTEGER, IN prm_dPeriodo DATE, IN prm_nDiasSinMedicion INTEGER, IN prm_bBorraAceleraciones BOOLEAN, IN prm_cUsuario VARCHAR(40), IN prm_tCreacion TIMESTAMP)
LB_PRINCIPAL:BEGIN
	DECLARE vcPatente			VARCHAR(40);
	DECLARE vpPeriodo			DATE;
	DECLARE vdInicio			DATE;
    DECLARE vfUsuario			INTEGER;
    DECLARE vnDiasSinMedicion	INTEGER;
    DECLARE vnDiasOriginal		INTEGER;
    DECLARE vnQAceleracion		INTEGER;
    
-- DEBUG : Parametros de entrada    
-- SELECT  prm_pVehiculo, prm_dPeriodo, prm_nDiasSinMedicion, prm_bBorraAceleraciones, prm_cUsuario;

	SELECT	fnFechaCierreIni(dIniVigencia, -1) day, fUsuarioTitular, cPatente
    INTO	vdInicio, vfUsuario, vcPatente
	FROM	tVehiculo
    WHERE	pVehiculo = prm_pVehiculo;
    
    IF vcPatente IS NULL THEN
		SELECT 4014 nCodigo, 'No existe vehículo ID: ' + prm_pVehiculo cMensaje;
		LEAVE LB_PRINCIPAL;
    END IF;

    IF prm_bBorraAceleraciones THEN
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

    END IF;
    
 	SELECT	f.pPeriodo		, f.nDiasSinMedicion
		  , f.nQAceleracion	, s.nDiasSinMedicionOriginal
    INTO	vpPeriodo		, vnDiasSinMedicion
		  , vnQAceleracion	, vnDiasOriginal
    FROM	tFactura f
			LEFT JOIN tFacturaSinMedicion s ON	s.pVehiculo = f.pVehiculo 
											AND s.pPeriodo  = f.pPeriodo
    WHERE	f.pVehiculo		= prm_pVehiculo
    AND		f.dInicio		= vdInicio
    AND		f.pTpFactura	= 1
    ;
    
 	IF vpPeriodo IS NOT NULL THEN

		IF IFNULL( vnDiasOriginal, vnDiasSinMedicion ) < prm_nDiasSinMedicion THEN
			SELECT 4014 nCodigo, concat('No se puede aumentar la cantidad de días sin medición. Patente =', vcPatente ) cMensaje;            
			LEAVE LB_PRINCIPAL;
		END IF;

		IF vnDiasOriginal IS NULL THEN
			INSERT INTO tFacturaSinMedicion
					( pVehiculo				, pPeriodo				, nDiasSinMedicionOriginal
                    , nDiasSinMedicion		, nQAceleracionOriginal	, cUsuario		)
			VALUES	( prm_pVehiculo			, vpPeriodo				, vnDiasSinMedicion	
					, prm_nDiasSinMedicion	, vnQAceleracion		, prm_cUsuario );
		ELSE
			UPDATE	tFacturaSinMedicion
			SET		nDiasSinMedicion	= prm_nDiasSinMedicion
			WHERE	pVehiculo			= prm_pVehiculo
			AND		pPeriodo			= vpPeriodo;
		END IF;
	END IF;
    
	CALL prRecalculaScore( vdInicio, prm_pVehiculo, vfUsuario);
	CALL prFacturador( prm_pVehiculo );

	-- Después de facturado se envian los nuevos valores como respuesta
	SELECT	f.nDescuento, f.nScore, vcPatente cPatente
	FROM 	tFactura f
    WHERE	f.pVehiculo		= prm_pVehiculo
    AND		f.dInicio		= vdInicio
    AND		f.pTpFactura	= 1
    ;

END //

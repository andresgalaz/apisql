DELIMITER //
DROP PROCEDURE IF EXISTS prFacturador //
CREATE PROCEDURE prFacturador (IN prm_pVehiculo INTEGER)
BEGIN
	-- En caso de querer facturar un mes anterior poner -1, u otro mes mas antiguo -2, y así sucesivamente
	SET @mesDesface = 0;

	-- Crea tabla temporal para procesar cada vehículo, si existe la limpia
	CALL prCreaTmpScoreVehiculo();

	BEGIN
		DECLARE vpVehiculo			INTEGER;
		DECLARE vdIniVigencia		DATE;
		DECLARE vdIniCierre			DATE;
		DECLARE vdFinCierre			DATE;
        
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		DECLARE curVeh CURSOR FOR
			SELECT	v.pVehiculo, v.dIniVigencia,
					score.fnPeriodoActual( v.dIniVigencia, -1 + @mesDesface ) dIniCierre,
					score.fnPeriodoActual( v.dIniVigencia, 0 + @mesDesface ) dFinCierre
			FROM	score.tVehiculo v
			WHERE	v.fTpDispositivo = 3
			AND		v.cIdDispositivo is not null
			AND		v.bVigente in ('1')
			AND		( prm_pVehiculo is null or v.pVehiculo=prm_pVehiculo );

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		OPEN curVeh;
		FETCH curVeh INTO	vpVehiculo, vdIniVigencia, vdIniCierre, vdFinCierre;
		WHILE NOT eofCurVeh DO
			-- No factura periodos anteriores al de inicio de la vigencia
			IF vdIniVigencia < vdFinCierre THEN
-- DEBUG            
-- SELECT vpVehiculo, vdIniVigencia, vdIniCierre, vdFinCierre;
				-- Calcula score y descuento del vehículo
				CALL prCalculaScoreVehiculo( vpVehiculo, vdIniCierre, vdFinCierre);
			END IF;
			FETCH curVeh INTO	vpVehiculo, vdIniVigencia, vdIniCierre, vdFinCierre;
		END WHILE;
		CLOSE curVeh;
	END;
    IF prm_pVehiculo IS NOT NULL THEN
		-- Se borra la factura antes de insertar de nuevo
		DELETE FROM tFactura 
        WHERE exists (	SELECT	'1'
						FROM	wMemoryScoreVehiculo w 
                        WHERE	w.pVehiculo = tFactura.pVehiculo AND fnPeriodo(w.dInicio) = tFactura.pPeriodo 
					 );
                     
		-- Registro de factura tpFactura = 1
		INSERT INTO tFactura
				( pVehiculo				, pPeriodo				, pTpFactura			,
				  dInicio				, dFin					, dInstalacion			,
				  tUltimoViaje			, tUltimaSincro			, nKms					,
				  nKmsPond				, nScore				, nQViajes				,
				  nQFrenada				, nQAceleracion			, nQVelocidad			,
				  nQCurva				, nDescuento			, nDescuentoKM			,
				  nDescuentoSinUso		, nDescuentoPunta		, nDiasTotal			,
				  nDiasUso				, nDiasPunta			, nDiasSinMedicion		)
		SELECT	  pVehiculo				, fnPeriodo(dInicio)	, 1						,
				  dInicio				, dFin					, dInstalacion			,
				  tUltimoViaje			, tUltimaSincro			, nKms					,
				  nKmsPond				, nScore				, nQViajes				,
				  nQFrenada				, nQAceleracion			, nQVelocidad			,
				  nQCurva				, nDescuento			, nDescuentoKM			,
				  nDescuentoSinUso		, nDescuentoPunta		, nDiasTotal			,
				  nDiasUso				, nDiasPunta			, nDiasSinMedicion
		FROM	wMemoryScoreVehiculo;

		-- Registro de calculo sin multas tpFactura = 2
		INSERT INTO tFactura
				( pVehiculo				, pPeriodo				, pTpFactura			,
				  dInicio				, dFin					, dInstalacion			,
				  tUltimoViaje			, tUltimaSincro			, nKms					,
				  nKmsPond				, nScore				, nQViajes				,
				  nQFrenada				, nQAceleracion			, nQVelocidad			,
				  nQCurva				, nDescuento			, nDescuentoKM			,
				  nDescuentoSinUso		, nDescuentoPunta		, nDiasTotal			,
				  nDiasUso				, nDiasPunta			, nDiasSinMedicion		)
		SELECT	  pVehiculo				, fnPeriodo(dInicio)	, 2						,
				  dInicio				, dFin					, dInstalacion			,
				  tUltimoViaje			, tUltimaSincro			, nKms					,
				  nKmsPond				, nScore				, nQViajes				,
				  nQFrenada				, nQAceleracion			, nQVelocidad			,
				  nQCurva				, nDescuento			, nDescuentoKM			,
				  nDescuentoSinUso		, nDescuentoPunta		, nDiasTotal			,
				  nDiasUso				, nDiasPunta			, nDiasSinMedicion
		FROM	wMemoryScoreVehiculoSinMulta;
	END IF;    
    
END //

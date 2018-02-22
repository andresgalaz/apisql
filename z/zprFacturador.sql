DELIMITER //
DROP PROCEDURE IF EXISTS zprFacturador //
CREATE PROCEDURE zprFacturador (IN prm_pVehiculo INTEGER)
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
			SELECT	v.pVehiculo, v.dIniVigencia
				  , zfnFechaCierreIni( v.dIniVigencia, -1 + @mesDesface ) dIniCierre
   				  , zfnFechaCierreFin( v.dIniVigencia, -1 + @mesDesface ) dFinCierre
			FROM	score.tVehiculo v
			WHERE	v.cPoliza is not null
            -- 08/01/2018: No cubría los casos que no instalaron
			-- AND		v.fTpDispositivo = 3
			-- AND		v.cIdDispositivo is not null
            AND     v.bVigente in ('1')
			AND		( prm_pVehiculo is null or v.pVehiculo=prm_pVehiculo );

		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		OPEN curVeh;
		FETCH curVeh INTO vpVehiculo, vdIniVigencia, vdIniCierre, vdFinCierre;
		WHILE NOT eofCurVeh DO
			-- No factura periodos anteriores al de inicio de la vigencia
			IF vdIniVigencia < vdFinCierre THEN
				IF prm_pVehiculo is not null THEN
					-- Si se indicó vehículo, para mejorar la precisión, se recalcula el Score Diario y por Viaje
                    call zprFacturadorSub( prm_pVehiculo, vdIniCierre );
                    SET eofCurVeh = 0;
				END IF;
				-- Calcula score y descuento del vehículo
				CALL zprCalculaScoreVehiculo( vpVehiculo, vdIniCierre, vdFinCierre);
			END IF;
			FETCH curVeh INTO vpVehiculo, vdIniVigencia, vdIniCierre, vdFinCierre;
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

DROP PROCEDURE IF EXISTS zprFacturadorSub //
CREATE PROCEDURE zprFacturadorSub (IN prm_pVehiculo INTEGER, IN prm_dInicio DATE )
BEGIN
	BEGIN
		DECLARE vnCount			INTEGER DEFAULT 0;
		DECLARE vnIdViaje		INTEGER;
		DECLARE eofCurEvento 	INTEGER DEFAULT 0;
		-- Cursor Eventos por Viaje
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT e.nIdViaje
			FROM   tEvento e
			WHERE  e.fVehiculo = prm_pVehiculo
			AND	   e.tEvento >= prm_dInicio;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		OPEN  CurEvento;
		FETCH CurEvento INTO vnIdViaje;
		WHILE NOT eofCurEvento DO
			CALL zprCalculaScoreViaje( vnIdViaje );
			FETCH CurEvento INTO vnIdViaje;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos
	
	BEGIN
		DECLARE vpVehiculo	INTEGER;
		DECLARE vpUsuario	INTEGER;
		DECLARE vdFecha	    date;
		-- Cursor Eventos: busca los registros unicos de Vehiculo, Usuario y 
        -- Fecha de evento para calcular el score diario
		DECLARE eofCurEvento INTEGER DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT DISTINCT e.fVehiculo, e.fUsuario, date( e.tEvento )
			FROM   tEvento e
			WHERE  e.fVehiculo = prm_pVehiculo
			AND	   e.tEvento >= prm_dInicio;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		WHILE NOT eofCurEvento DO
			-- Calcula Score diario
			CALL zprCalculaScoreDia( vdFecha, vpVehiculo, vpUsuario );
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vdFecha;
		END WHILE;
		CLOSE CurEvento;
	END; -- Fin cursor eventos

END //

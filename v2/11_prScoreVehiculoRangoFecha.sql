DELIMITER //
DROP PROCEDURE IF EXISTS prScoreVehiculoRangoFecha //
CREATE PROCEDURE prScoreVehiculoRangoFecha ( IN prm_pUsuario INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE, IN prm_fVehiculo INTEGER, IN prm_fConductor INTEGER )
BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;

	DECLARE kNivelApp_minimo    INTEGER DEFAULT 1;
	
	DECLARE vnKmsTotal			DECIMAL(10,2)	DEFAULT 0.0;
	DECLARE vnScoreGlobal		DECIMAL(10,2)	DEFAULT 0.0;
	DECLARE vnUsuario			INTEGER;

    SET vnUsuario = IFNULL( prm_fConductor, prm_pUsuario );

	-- Crea tabla temporal, si existe la limpia
	CALL prCreaTmpScoreVehiculo();

	BEGIN
		DECLARE vpVehiculo		INTEGER;
		DECLARE vdIniVigencia	DATE;
		DECLARE vdIni			DATE;
		DECLARE vdFin			DATE;
		DECLARE vnKms			DECIMAL(10,2);
		DECLARE vnScore			DECIMAL(10,2);
		-- Cursor Vehiculos para borrar 
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		DECLARE CurVeh CURSOR FOR
			SELECT	uv.pVehiculo, v.dIniVigencia
			FROM	tUsuarioVehiculo uv
					INNER JOIN tVehiculo v ON v.pVehiculo = uv.pVehiculo
			WHERE	uv.pUsuario		= vnUsuario
            AND		uv.pVehiculo	= IFNULL( prm_fVehiculo, uv.pVehiculo );
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		-- Si no se indicó periodo, se trae la misma fecha para todos los vehículos
		IF prm_nPeriodo IS NULL THEN
			IF prm_dIni IS NULL THEN
				SET vdIni = DATE(DATE_SUB(now(), INTERVAL DAYOFMONTH(now()) - 1 DAY));
			ELSE
				SET vdIni = prm_dIni;
			END IF;

			IF prm_dFin IS NULL THEN
				SET vdFin = now();
			ELSE
				SET vdFin = prm_dFin;
			END IF;
			SET vdFin = DATE_ADD(vdFin, INTERVAL 1 DAY);
		END IF;

		OPEN CurVeh;
		FETCH CurVeh INTO vpVehiculo, vdIniVigencia;
		WHILE NOT eofCurVeh DO
			IF prm_nPeriodo IS NOT NULL THEN
				SET vdIniVigencia = IFNULL( vdIniVigencia, DATE(NOW()));
				SET vdIni = fnPeriodoActual( vdIniVigencia, prm_nPeriodo - 1);
				SET vdFin = fnPeriodoActual( vdIniVigencia, prm_nPeriodo);
			END IF;
			-- Calcula score y descuento del vehículo
			CALL prCalculaScoreVehiculo( vpVehiculo, vdIni, vdFin );
			-- Calcula score del usuario por cada vehículo
			CALL prScoreVehiculoRangoSub( vnUsuario, vpVehiculo, vdIni, vdFin, vnKms, vnScore );
			SET vnKmsTotal		= vnKmsTotal	+ vnKms;
			SET vnScoreGlobal	= vnScoreGlobal + vnScore;
		
			FETCH CurVeh INTO vpVehiculo, vdIniVigencia;
		END WHILE;
		CLOSE CurVeh;
	END;
    
	-- CURSOR 1: Entrega un cursor con los totales globales del Usuario
	IF vnKmsTotal <= 0 THEN
		SELECT 0 AS kmsTotal, 100 AS scoreGlobal; 
	ELSE
		SELECT vnKmsTotal AS nKmsTotal, round( vnScoreGlobal / vnKmsTotal, 0 ) AS nScoreGlobal; 
	END IF;
    
	-- CURSOR 2: Entrega un cursor con el detalle por vehículo
	SELECT	w.pVehiculo			, v.cPatente,
			v.fUsuarioTitular	, ut.cNombre				AS cUsuarioTitular,
			SUBSTRING(w.dInicio					, 1, 10 )	AS dInicio,
			SUBSTRING(w.dFin + INTERVAL -1 DAY	, 1, 10 )	AS dFin,
			w.nKms				, w.nScore,
			w.nDescuento		, w.nDiasTotal,
			w.nDiasUso			, w.nDiasPunta,
			-- w.nQFrenada			, w.nQAceleracion		, w.nQVelocidad			, w.nQCurva,
			w.nQViajes,
			(	SELECT	max(trips.to_date) + INTERVAL -3 HOUR
				FROM	snapcar.trips 
						JOIN snapcar.clients ON clients.id = trips.client_id
                WHERE	clients.vehicle_id = w.pVehiculo )	AS tUltimoRegistro,
			(	SELECT	max(it.tRegistroActual)
				FROM	tInicioTransferencia it
				WHERE	it.fVehiculo = v.pVehiculo	)		AS tUltimaSincro,
			(	SELECT	fnEstadoSincro(max(trips.to_date) + INTERVAL -3 HOUR)
				FROM	snapcar.trips 
						JOIN snapcar.clients ON clients.id = trips.client_id
                WHERE	clients.vehicle_id = w.pVehiculo )	AS cEstadoSincroTrips,
			(	SELECT	fnEstadoSincro(max(it.tRegistroActual))
				FROM	tInicioTransferencia it
				WHERE	it.fVehiculo = v.pVehiculo	)		AS cEstadoSincroTrans
	FROM	wMemoryScoreVehiculo	w
			JOIN score.tVehiculo	v	ON v.pVehiculo = w.pVehiculo
			JOIN score.tUsuario		ut	ON ut.pUsuario = v.fUsuarioTitular;
            
	-- CURSOR 3: Entrega los eventos graves por vehículo
	SELECT	w.pVehiculo,
			SUM( IF( e.fTpEvento = kEventoAceleracion	, 1, 0 )) nQAceleracion,
			SUM( IF( e.fTpEvento = kEventoFrenada		, 1, 0 )) nQFrenada,
			SUM( IF( e.fTpEvento = kEventoVelocidad		, 1, 0 )) nQVelocidad,
			SUM( IF( e.fTpEvento = kEventoCurva			, 1, 0 )) nQCurva
	FROM	wMemoryScoreVehiculo w
			INNER JOIN tEvento e ON e.fVehiculo	=	w.pVehiculo
								AND e.tEvento	>=	w.dInicio
								AND e.tEvento	<	w.dFin
	WHERE	e.nNivelApp >= kNivelApp_minimo
	AND		e.fTpEvento IN ( kEventoAceleracion, kEventoFrenada, kEventoVelocidad, kEventoCurva )
    GROUP BY w.pVehiculo;

	-- CURSOR 4: Entrega un cursor con los conductores que pueden usar los vehiculos 
	-- 			 que este usuario puede usar
	SELECT	uv.pUsuario, uv.pVehiculo, u.cNombre cUsuario
		 ,	fnScoreConductorJson( uv.pUsuario, uv.pVehiculo, w.dInicio, w.dFin ) cJsonKmScore
	FROM	wMemoryScoreVehiculo	w
			JOIN tUsuarioVehiculo	uv	ON	uv.pVehiculo	=	w.pVehiculo
			JOIN tUsuario			u	ON	u.pUsuario		=	uv.pUsuario;

	-- CURSOR 5: Resumen final, cuenta todos los eventos de usuario
    -- Resumen de los eventos del CURSOR-3
	SELECT	SUM( IF( e.fTpEvento = kEventoAceleracion	, 1, 0 )) nQAceleracion,
			SUM( IF( e.fTpEvento = kEventoFrenada		, 1, 0 )) nQFrenada,
			SUM( IF( e.fTpEvento = kEventoVelocidad		, 1, 0 )) nQVelocidad,
			SUM( IF( e.fTpEvento = kEventoCurva			, 1, 0 )) nQCurva
	FROM	wMemoryScoreVehiculo w
			INNER JOIN tEvento e ON e.fVehiculo	=	w.pVehiculo
								AND e.tEvento	>=	w.dInicio
								AND e.tEvento	<	w.dFin
	WHERE	e.nNivelApp >= kNivelApp_minimo
	AND		e.fTpEvento IN ( kEventoAceleracion, kEventoFrenada, kEventoVelocidad, kEventoCurva );
                                        
	-- CURSOR 6: Detalle de los viajes del usuario. Solo si se especificó prm_fVehiculo ó prm_fConductor
    IF prm_fVehiculo is not null OR prm_fConductor is not null THEN
		SELECT	v.pVehiculo				AS	fVehiculo			,	v.cPatente				AS	cPatente
			 ,	v.fUsuarioTitular		AS	fUsuarioTitular 	,	ut.cNombre				AS	cNombreTitular
			 ,	ini.fUsuario			AS	fUsuario		 	,	IFNULL(uu.cNombre,'Desconocido') AS cNombreConductor
			 ,	ini.nIdViaje			AS	nIdViaje
			 ,	ini.cCalle				AS	cCalleInicio		,	fin.cCalle				AS	cCalleFin
			 ,	ini.cCalleCorta			AS	cCalleCortaInicio	,	fin.cCalleCorta			AS	cCalleCortaFin
			 ,	ini.tEvento				AS	tInicio				,	fin.tEvento				AS	tFin
			 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)								AS	nDuracionSeg
			 ,	ROUND(ini.nValor,0)		AS	nScore				,	ROUND(fin.nValor,2)		AS	nKms
			 ,	SUM( IF( eve.fTpEvento = kEventoAceleracion		, 1, 0 )) AS	nQAceleracion
			 ,	SUM( IF( eve.fTpEvento = kEventoFrenada			, 1, 0 )) AS	nQFrenada
			 ,	SUM( IF( eve.fTpEvento = kEventoVelocidad		, 1, 0 )) AS	nQVelocidad
			 ,	SUM( IF( eve.fTpEvento = kEventoCurva			, 1, 0 )) AS	nQCurva
		FROM	tParamCalculo					AS	prm
				INNER JOIN wMemoryScoreVehiculo	AS	w	ON	1 = 1
				-- Inicio del Viaje
				INNER JOIN tEvento				AS	ini ON	ini.fVehiculo	= 	w.pVehiculo
														AND	ini.fTpEvento	=	kEventoInicio
				-- Fin del Viaje
				INNER JOIN tEvento				AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
														AND	fin.fTpEvento	=	kEventoFin
														AND	fin.nValor		> 	prm.nDistanciaMin
				-- Eventos, solo muestra viajes que tienen al menos un evento grave
				INNER JOIN	tEvento				AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
														AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
														AND eve.nNivelApp	>=	kNivelApp_minimo
				-- Solo muestra los viajes de los usuario relacionados. Pueden existir viajes de usuario no identificados
				INNER JOIN	tUsuarioVehiculo	AS	uv	ON	uv.pVehiculo	= 	ini.fVehiculo
														AND	uv.pUsuario		=	ini.fUsuario
				INNER JOIN	tVehiculo			AS 	v	ON	v.pVehiculo		= 	w.pVehiculo
				INNER JOIN	tUsuario			AS	ut	ON	ut.pUsuario		=	v.fUsuarioTitular
				LEFT JOIN	tUsuario			AS	uu	ON	uu.pUsuario		=	ini.fUsuario
		WHERE	ini.fUsuario	=	vnUsuario
        AND		( prm_fVehiculo IS NULL OR ini.fVehiculo = prm_fVehiculo )
		AND		ini.tEvento		>=	w.dInicio
		AND		fin.tEvento		<	w.dFin
		GROUP BY	v.pVehiculo		,	v.cPatente		,	v.fUsuarioTitular	,	ut.cNombre
				,	ini.fUsuario	,	uu.cNombre		,	ini.nIdViaje		,	ini.cCalle
				,	ini.cCalleCorta	,	fin.cCalleCorta
				,	fin.cCalle		,	ini.tEvento		,	fin.tEvento			,	ini.nValor
				,	fin.nValor	
		ORDER BY ini.tEvento DESC;
	END IF;
    
END //

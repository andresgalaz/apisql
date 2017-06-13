DELIMITER //
DROP PROCEDURE IF EXISTS prScoreVehiculoRangoFecha //
CREATE PROCEDURE prScoreVehiculoRangoFecha ( IN prm_pUsuario INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	
	DECLARE vnKmsTotal			DECIMAL(10,2)	DEFAULT 0.0;
	DECLARE vnScoreGlobal		DECIMAL(10,2)	DEFAULT 0.0;

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
			WHERE	uv.pUsuario = prm_pUsuario;
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
			CALL prScoreVehiculoRangoSub( prm_pUsuario, vpVehiculo, vdIni, vdFin, vnKms, vnScore );
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
			v.fUsuarioTitular	, ut.cNombre			AS cUsuarioTitular,
			SUBSTRING(dInicio				, 1, 10 )	AS dInicio,
			SUBSTRING(dFin + INTERVAL -1 DAY, 1, 10 )	AS dFin,
			w.nKms				, w.nScore,
			w.nDescuento		, w.nDiasTotal,
			w.nDiasUso			, w.nDiasPunta,
			w.nQFrenada			, w.nQAceleracion		, w.nQVelocidad			, w.nQCurva,
			w.nQViajes,
			(	SELECT	max(e.tEvento)
				FROM	tEvento e
				WHERE	e.fVehiculo = w.pVehiculo	)	AS tUltimoRegistro,
			(	SELECT	max(it.tRegistroActual)
				FROM	tInicioTransferencia it
				WHERE	it.fVehiculo = v.pVehiculo	)	AS tUltimaSincro,
			(	SELECT	fnEstadoSincro(max(it.tRegistroActual))
				FROM	tInicioTransferencia it
				WHERE	it.fVehiculo = v.pVehiculo	)	AS cEstadoSincro
	FROM	wMemoryScoreVehiculo	w
			JOIN score.tVehiculo	v	ON v.pVehiculo = w.pVehiculo
			JOIN score.tUsuario		ut	ON ut.pUsuario = v.fUsuarioTitular;
	-- CURSOR 3: Entrega un cursor con los conductores que pueden usar los vehiculos 
	-- 			 que este usuario puede usar
	SELECT	uv2.pVehiculo, uv2.pUsuario, u.cNombre cUsuario
		 ,	SUM( t.nKms )	nKms
	FROM	tUsuarioVehiculo uv1 
			INNER JOIN tUsuarioVehiculo		uv2	ON	uv2.pVehiculo	=	uv1.pVehiculo
			INNER JOIN tUsuario				u	ON	u.pUsuario		=	uv2.pUsuario
			INNER JOIN wMemoryScoreVehiculo	w	ON	w.pVehiculo		=	uv1.pVehiculo
			INNER JOIN tScoreDia			t	ON	t.fUsuario		=	uv2.pUsuario
												AND	t.dFecha		>=	w.dInicio
												AND	t.dFecha		<	w.dFin
	WHERE	uv1.pUsuario =	prm_pUsuario
	GROUP BY uv2.pVehiculo, uv2.pUsuario, u.cNombre;
	-- CURSOR 4: Resumen final, cuenta todos los eventos de usuario
	SELECT	SUM( t.nQFrenada		)	nQFrenada
		 ,	SUM( t.nQAceleracion	)	nQAceleracion
		 ,	SUM( t.nQVelocidad		)	nQVelocidad
		 ,	SUM( t.nQCurva			)	nQCurva
	FROM	wMemoryScoreVehiculo	w
			INNER JOIN tScoreDia	t	ON	t.fUsuario		=	prm_pUsuario
										AND	t.dFecha		>=	w.dInicio
										AND	t.dFecha		<	w.dFin;
	-- CURSOR 5: Detalle de los viajes del usuario
	SELECT	v.pVehiculo				AS	fVehiculo		,	v.cPatente				AS	cPatente
		 ,	v.fUsuarioTitular		AS	fUsuarioTitular ,	ut.cNombre				AS	cNombreTitular
		 ,	ini.fUsuario			AS	fUsuario	 	,	IFNULL(uu.cNombre,'Desconocido') AS cNombreConductor
		 ,	ini.nIdViaje			AS	nIdViaje
		 ,	ini.cCalle				AS	cCalleInicio	,	fin.cCalle				AS	cCalleFin
		 ,	ini.tEvento				AS	tInicio			,	fin.tEvento				AS	tFin
		 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)							AS	nDuracionSeg
		 ,	ROUND(ini.nValor,0)	AS	nScore			,	ROUND(fin.nValor,2)	AS	nKms
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoAceleracion	THEN 1 ELSE 0 END ) AS	nQAceleracion
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoFrenada		THEN 1 ELSE 0 END ) AS	nQFrenada
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoVelocidad		THEN 1 ELSE 0 END ) AS	nQVelocidad
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoCurva			THEN 1 ELSE 0 END ) AS	nQCurva
	FROM	tParamCalculo					AS	prm
			-- Inicio del Viaje
			INNER JOIN tEvento				AS	ini ON	ini.fTpEvento	=	kEventoInicio
			INNER JOIN wMemoryScoreVehiculo	AS	w	ON	w.pVehiculo		=	ini.fVehiculo
			-- Fin del Viaje
			INNER JOIN tEvento				AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
										 			AND	fin.fTpEvento	=	kEventoFin
											 		AND	fin.nValor		> 	prm.nDistanciaMin
			-- Eventos
			INNER JOIN	tEvento				AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
													AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
			INNER JOIN	tVehiculo			AS 	v	ON	v.pVehiculo		= 	ini.fVehiculo
			-- Solo muestra los viajes de los usuario relacionados. Pueden existir viajes de usuario no identificados
			INNER JOIN	tUsuarioVehiculo	AS	uv	ON	uv.pVehiculo	= 	ini.fVehiculo
													AND	uv.pUsuario		=	ini.fUsuario
			INNER JOIN	tUsuario			AS	ut	ON	ut.pUsuario		=	v.fUsuarioTitular
			LEFT JOIN	tUsuario			AS	uu	ON	uu.pUsuario		=	ini.fUsuario
	WHERE	ini.fUsuario	=	prm_pUsuario
	AND		ini.tEvento		>=	w.dInicio
	AND		fin.tEvento		<	w.dFin
	GROUP BY	v.pVehiculo	,	v.cPatente	,	v.fUsuarioTitular	,	ut.cNombre
		 	,	ini.fUsuario,	uu.cNombre	,	ini.nIdViaje		,	ini.cCalle
			,	fin.cCalle 	,	ini.tEvento	,	fin.tEvento			,	ini.nValor
			,	fin.nValor	
	ORDER BY ini.tEvento DESC;
END //

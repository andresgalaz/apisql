DELIMITER //
DROP PROCEDURE IF EXISTS prScoreConductorRangoFecha //
CREATE PROCEDURE prScoreConductorRangoFecha ( IN prm_pUsuarioTitular INTEGER, IN prm_pVehiculo INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;
	DECLARE kEventoCurva		integer DEFAULT 6;

	-- Crea tabla temporal, si existe la limpia
	CALL prCreaTmpScoreVehiculo();
   
	BEGIN
		DECLARE vpUsuario		INTEGER;
		DECLARE vpVehiculo		INTEGER;
		DECLARE vdIniPoliza		DATE;
		DECLARE vdIniVigencia	DATE;
		DECLARE vdIni			DATE;
		DECLARE vdFin			DATE;
		-- Cursor Vehiculos para borrar 
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		DECLARE CurVeh CURSOR FOR
			SELECT	uv.pUsuario, uv.pVehiculo, v.dIniPoliza, v.dIniVigencia
			FROM	tUsuarioVehiculo uv
					INNER JOIN tVehiculo v ON v.pVehiculo = uv.pVehiculo
			WHERE	uv.fUsuarioTitular	= prm_pUsuarioTitular
            AND		uv.pVehiculo		= IFNULL( prm_pVehiculo, uv.pVehiculo );
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
		FETCH CurVeh INTO vpUsuario, vpVehiculo, vdIniPoliza, vdIniVigencia;
		WHILE NOT eofCurVeh DO
			IF prm_nPeriodo IS NOT NULL THEN
				SET vdIniVigencia = IFNULL( vdIniVigencia, DATE(NOW()));
				SET vdIni = fnPeriodoActual( vdIniVigencia, prm_nPeriodo);
				SET vdFin = fnPeriodoActual( vdIniVigencia, prm_nPeriodo + 1);
			END IF;
            
			-- La fecha de inicio no puede ser anterior a la fecha de la Póliza
			IF vdIni < vdIniPoliza THEN
				SET vdIni = vdIniPoliza;
			END IF;
            
			-- Calcula score y descuento del vehículo
			CALL prCalculaScoreConductor( vpUsuario, vpVehiculo, vdIni, vdFin );
			FETCH CurVeh INTO vpUsuario, vpVehiculo, vdIniPoliza, vdIniVigencia;
		END WHILE;
		CLOSE CurVeh;
	END;

	-- CURSOR 1: Entrega un cursor con los totales globales del conductor
	SELECT	w.pUsuario	, u.cNombre         AS cUsuario	,
			SUM(w.nKms)										AS nKms,
            ( CASE WHEN SUM(w.nKms) = 0 THEN 100 ELSE ROUND(SUM(w.nScore * w.nKms)/SUM(w.nKms),0) END ) AS nScore,
			SUM(w.nQViajes	) AS nQViajes	, SUM(w.nQAceleracion	) AS nQAceleracion,
			SUM(w.nQFrenada	) AS nQFrenada	, SUM(w.nQVelocidad		) AS nQVelocidad,
			SUM(w.nQCurva	) AS nQCurva
	FROM	wMemoryScoreVehiculo	AS w
			JOIN tUsuario 			AS u ON u.pUsuario = w.pUsuario
	GROUP 	BY w.pUsuario, u.cNombre;

	-- CURSOR 2: Entrega un cursor con el detalle vehículos del conductor
	SELECT	uv.pUsuario			,
			w.pVehiculo			, v.cPatente					,
			SUBSTRING(w.dInicio					, 1, 10 )	AS dInicio,
			SUBSTRING(w.dFin + INTERVAL -1 DAY	, 1, 10 )	AS dFin,
			v.fUsuarioTitular	, ut.cNombre AS cUsuarioTitular	,
			w.nKms				, w.nScore						,
			w.nQViajes
	FROM	score.tUsuarioVehiculo uv
			JOIN wMemoryScoreVehiculo	w	ON	w.pVehiculo	= uv.pVehiculo
											AND w.pUsuario	= uv.pUsuario
			JOIN score.tVehiculo		v	ON	v.pVehiculo	= w.pVehiculo
			JOIN score.tUsuario			ut	ON	ut.pUsuario	= v.fUsuarioTitular
	WHERE	uv.fUsuarioTitular = prm_pUsuarioTitular
 -- GROUP 	BY w.pUsuario, u.cNombre, w.dInicio, w.dFin
	ORDER	BY pUsuario, pVehiculo;

	-- CURSOR 3: Resumen final, cuenta todos los eventos de todos los conductores
	SELECT	SUM( w.nQFrenada		)	nQFrenada
		 ,	SUM( w.nQAceleracion	)	nQAceleracion
		 ,	SUM( w.nQVelocidad		)	nQVelocidad
		 ,	SUM( w.nQCurva			)	nQCurva
	FROM	wMemoryScoreVehiculo		AS w;

	-- CURSOR 4: Detalle de los viajes del usuario
    IF prm_pVehiculo IS NOT NULL THEN
		SELECT	w.pVehiculo										,	v.cPatente				AS	cPatente
			 ,	v.fUsuarioTitular		AS	fUsuarioTitular 	,	ut.cNombre				AS	cNombreTitular
			 ,	w.pUsuario				AS	fUsuario		 	,	uu.cNombre				AS	cNombreConductor
			 ,	ini.nIdViaje			AS	nIdViaje
			 ,	ini.cCalle				AS	cCalleInicio		,	fin.cCalle				AS	cCalleFin
			 ,	ini.cCalleCorta			AS	cCalleCortaInicio	,	fin.cCalleCorta			AS	cCalleCortaFin
			 ,	ini.tEvento				AS	tInicio				,	fin.tEvento				AS	tFin
			 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)								AS	nDuracionSeg
			 ,	ROUND(ini.nValor,0)		AS	nScore				,	ROUND(fin.nValor,2)		AS	nKms
			 ,	SUM( CASE WHEN eve.fTpEvento = kEventoAceleracion	THEN 1 ELSE 0 END ) 	AS	nQAceleracion
			 ,	SUM( CASE WHEN eve.fTpEvento = kEventoFrenada		THEN 1 ELSE 0 END ) 	AS	nQFrenada
			 ,	SUM( CASE WHEN eve.fTpEvento = kEventoVelocidad		THEN 1 ELSE 0 END ) 	AS	nQVelocidad
			 ,	SUM( CASE WHEN eve.fTpEvento = kEventoCurva			THEN 1 ELSE 0 END ) 	AS	nQCurva
		FROM	wMemoryScoreVehiculo		AS	w
				-- Inicio del Viaje
				INNER JOIN tEvento			AS	ini ON	ini.fUsuario	=	w.pUsuario
													AND	ini.fVehiculo	=	w.pVehiculo
													AND	ini.fTpEvento	=	kEventoInicio
													AND ini.tEvento		>=	w.dInicio
													AND ini.tEvento		<	w.dFin
				-- Fin del Viaje
				INNER JOIN tEvento			AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
													AND	fin.fTpEvento	=	kEventoFin
				-- Eventos
				INNER JOIN tEvento			AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
													AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
				INNER JOIN tVehiculo		AS 	v	ON	v.pVehiculo		= 	w.pVehiculo
				INNER JOIN tUsuario			AS	ut	ON	ut.pUsuario		=	v.fUsuarioTitular
				INNER JOIN tUsuario			AS	uu	ON	uu.pUsuario		=	w.pUsuario
		GROUP BY
				w.pVehiculo			, v.cPatente			, v.fUsuarioTitular		, ut.cNombre		,
				w.pUsuario			, uu.cNombre			, ini.nIdViaje			, ini.cCalle		,
				fin.cCalle			, ini.cCalleCorta		, fin.cCalleCorta		, ini.tEvento		,
				fin.tEvento			, ROUND(ini.nValor,0)	, ROUND(fin.nValor,2)
		ORDER BY ini.tEvento DESC;
    END IF;

END //


DELIMITER //
DROP PROCEDURE IF EXISTS prScoreConductorRangoFecha //
CREATE PROCEDURE prScoreConductorRangoFecha ( IN prm_pUsuario INTEGER, IN prm_pVehiculo INTEGER, IN prm_nPeriodo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;
	DECLARE kEventoCurva		integer DEFAULT 6;

--	DECLARE vnScoreGlobal		decimal(10,2) default 0;

	DECLARE vdIni				DATE;
	DECLARE vdFin				DATE;

	IF prm_nPeriodo IS NOT NULL THEN
		-- Primer día mes actual
		SET vdIni = DATE(DATE_SUB(now(), INTERVAL DAY(now()) - 1 DAY));
		SET vdIni = fnPeriodoActual( vdIni, prm_nPeriodo);
		SET vdFin = fnPeriodoActual( vdIni, prm_nPeriodo + 1);
	ELSE
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
		SET vdFin = ADDDATE(vdFin, INTERVAL 1 DAY);
	END IF;
/*
	IF prm_dIni > prm_dFin THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio no puede ser inferior a la fecha de fin';
	END IF;
*/

	-- Crea tabla temporal, si existe la limpia
	CALL prCreaTmpScoreVehiculo();
	-- Tabla temporal de resultados por usuario y vehiculo
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryScoreConductor (
		pUsuario				INTEGER		UNSIGNED	NOT NULL,
		nKms					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
		nScore					DECIMAL(10,2)	UNSIGNED	NOT NULL	DEFAULT '0.0',
		nQViajes				INTEGER		UNSIGNED	NOT NULL	DEFAULT '0',
		nQFrenada				INTEGER		UNSIGNED	NOT NULL	DEFAULT '0',
		nQAceleracion			INTEGER		UNSIGNED	NOT NULL	DEFAULT '0',
		nQVelocidad				INTEGER		UNSIGNED	NOT NULL	DEFAULT '0',
		nQCurva					INTEGER		UNSIGNED	NOT NULL	DEFAULT '0',
		PRIMARY KEY (pUsuario)
	) ENGINE=MEMORY;
	DELETE FROM wMemoryScoreConductor;

	BEGIN
		DECLARE vpUsuario			integer;
		DECLARE vpVehiculo			integer;
		DECLARE vnKms				decimal(10,2);
		DECLARE vnQViajes			INTEGER;
		DECLARE vnSumaFrenada		decimal(10,2);
		DECLARE vnSumaAceleracion	decimal(10,2);
		DECLARE vnSumaVelocidad		decimal(10,2);
		DECLARE vnSumaCurva			decimal(10,2);
		DECLARE vnQFrenada			INTEGER;
		DECLARE vnQAceleracion		INTEGER;
		DECLARE vnQVelocidad		INTEGER;
		DECLARE vnQCurva			INTEGER;
		DECLARE vnPtjFrenada		decimal(10,2) default 0;
		DECLARE vnPtjAceleracion	decimal(10,2) default 0;
		DECLARE vnPtjVelocidad		decimal(10,2) default 0;
		DECLARE vnPtjCurva			decimal(10,2) default 0;
		DECLARE vnScore				decimal(10,2) DEFAULT 0;

		-- Cursor Vehiculos para borrar 
		DECLARE eofCurVeh INTEGER DEFAULT 0;
		-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
		DECLARE CurVeh CURSOR FOR
			SELECT	uv.pUsuario, uv.pVehiculo,
					SUM( t.nAceleracion		)	AS nSumaAceleracion	, SUM( t.nVelocidad		)		AS nSumaVelocidad	,
					SUM( t.nFrenada			)	AS nSumaFrenada		, SUM( t.nCurva			) 		AS nSumaCurva		,
					SUM( t.nKms				)	AS nKms				,
					SUM( t.nQAceleracion	)	AS nQAceleracion	, SUM( t.nQVelocidad		)	AS nQVelocidad		,
					SUM( t.nQFrenada		)	AS nQFrenada		, SUM( t.nQCurva			)	AS nQCurva
			FROM	tUsuarioVehiculo uv
					JOIN tScoreDia t ON t.fUsuario	= uv.pUsuario
									AND t.fVehiculo	= uv.pVehiculo
			WHERE	uv.fUsuarioTitular = prm_pUsuario
			AND		( prm_pVehiculo is null OR uv.pVehiculo = prm_pVehiculo )
			AND		t.dFecha >= vdIni
			AND		t.dFecha <	vdFin
			GROUP BY uv.pUsuario, uv.pVehiculo;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;

		OPEN CurVeh;
		FETCH CurVeh INTO	vpUsuario			, vpVehiculo		,
							vnSumaAceleracion	, vnSumaVelocidad	,
							vnSumaFrenada		, vnSumaCurva		,
							vnKms				,
							vnQAceleracion		, vnQVelocidad		,
							vnQFrenada			, vnQCurva			;
		WHILE NOT eofCurVeh DO
			IF NOT EXISTS (SELECT 1 FROM wMemoryScoreVehiculo WHERE pVehiculo = vpVehiculo ) THEN
				CALL prCalculaScoreVehiculo( vpVehiculo, vdIni, vdFin );
			END IF;

			IF IFNULL(vnKms, 0) > 0 THEN
				SET vnPtjFrenada	= vnSumaFrenada		* 100 / vnKms;
				SET vnPtjAceleracion= vnSumaAceleracion * 100 / vnKms;
				SET vnPtjVelocidad	= vnSumaVelocidad	* 100 / vnKms;
				SET vnPtjCurva		= vnSumaCurva		* 100 / vnKms;
				
				SELECT	nValor INTO vnPtjFrenada
				FROM	tRangoPuntaje WHERE fTpevento = kEventoFrenada AND nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;

				SELECT	nValor INTO vnPtjAceleracion
				FROM	tRangoPuntaje WHERE fTpevento = kEventoAceleracion AND nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;

				SELECT nValor INTO vnPtjVelocidad
				FROM   tRangoPuntaje WHERE fTpevento = kEventoVelocidad AND nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;

				SELECT nValor INTO vnPtjCurva
				FROM   tRangoPuntaje WHERE fTpevento = kEventoCurva AND nInicio <= vnPtjCurva and vnPtjCurva < nFin;

                -- Parámetros de ponderación por tipo de evento
				SELECT	( vnPtjFrenada		* nPorcFrenada		/ 100 )
					+	( vnPtjAceleracion	* nPorcAceleracion	/ 100 )
					+	( vnPtjVelocidad	* nPorcVelocidad	/ 100 )
					+	( vnPtjCurva		* nPorcCurva		/ 100 )
				INTO	vnScore
				FROM	tParamCalculo;
				
				SELECT	COUNT(*) INTO vnQViajes
				FROM	tEvento e
						INNER JOIN tParamCalculo p ON 1 = 1
				WHERE	e.fUsuario	= 	vpUsuario
				AND		e.fVehiculo	=	vpVehiculo
				AND		e.tEvento	>=	vdIni
				AND		e.tEvento	<	vdFin
				AND		e.fTpEvento =	kEventoFin
				AND		e.nValor	>	p.nDistanciaMin;
			ELSE
		        SET vnKms  			= 0;
		        SET vnScore 		= 100;
				SET vnQViajes		= 0;
				SET vnQAceleracion	= 0;
				SET vnQVelocidad	= 0;
				SET vnQFrenada		= 0;
				SET vnQCurva		= 0;
			END IF;

			IF EXISTS (SELECT 1 FROM wMemoryScoreConductor WHERE pUsuario = vpUsuario ) THEN
				UPDATE wMemoryScoreConductor 
				SET		nKms			= nKms			+ vnKms				,
						nScore			= nScore		+ vnScore * vnKms	,
						nQAceleracion	= nQAceleracion + vnQAceleracion	,
						nQVelocidad		= nQVelocidad	+ vnQVelocidad		,
						nQFrenada		= nQFrenada		+ vnQFrenada		,
						nQCurva			= nQCurva		+ vnQCurva			,
						nQViajes		= nQViajes 		+ vnQViajes
				WHERE	pUsuario = vpUsuario;
			ELSE
				INSERT INTO wMemoryScoreConductor(
						pUsuario		, nKms			, nScore		    , nQViajes	,
						nQAceleracion	, nQVelocidad	, nQFrenada	    	, nQCurva	)
				VALUES( vpUsuario		, vnKms			, vnScore * vnKms   , vnQViajes ,
						VnQAceleracion	, VnQVelocidad	, VnQFrenada	    , VnQCurva 	);
			END IF;

			FETCH CurVeh INTO	vpUsuario			, vpVehiculo		,
								vnSumaAceleracion	, vnSumaVelocidad	,
								vnSumaFrenada		, vnSumaCurva		,
								vnKms				,
								vnQAceleracion		, vnQVelocidad		,
								vnQFrenada			, vnQCurva			;
		END WHILE;
		CLOSE CurVeh;
	END;

	-- CURSOR 1: Rango de fechas de la consulta
	SELECT 	SUBSTRING(vdIni, 1, 10 )							AS dInicio,
			SUBSTRING(DATE_SUB(vdFin, INTERVAL 1 DAY), 1, 10 )	AS dFin;
	
	-- CURSOR 2: Entrega un cursor con los totales globales del conductor
	SELECT	w.pUsuario	, u.cNombre         AS cUsuario	,
			w.nKms		,
            ( CASE WHEN w.nKms = 0 THEN 100 ELSE ROUND(w.nScore / w.nKms,0) END ) AS nScore	,
			w.nQViajes	, w.nQAceleracion       		,
			w.nQFrenada	, w.nQVelocidad	        		,
			w.nQCurva
	FROM	wMemoryScoreConductor	AS w
			JOIN tUsuario 			AS u ON u.pUsuario = w.pUsuario;

	-- CURSOR 3: Entrega un cursor con el detalle vehículos del conductor
	SELECT	uv.pUsuario			,
			w.pVehiculo			, v.cPatente					,
			v.fUsuarioTitular	, ut.cNombre AS cUsuarioTitular	,
			w.nKms				, w.nScore						,
			w.nQViajes
	FROM	score.tUsuarioVehiculo uv
			JOIN wMemoryScoreVehiculo	w	ON w.pVehiculo = uv.pVehiculo
			JOIN score.tVehiculo		v	ON v.pVehiculo = w.pVehiculo
			JOIN score.tUsuario			ut	ON ut.pUsuario = v.fUsuarioTitular
	WHERE	uv.fUsuarioTitular = prm_pUsuario
	ORDER	BY pUsuario, pVehiculo;

	-- CURSOR 4: Resumen final, cuenta todos los eventos de usuario
	SELECT	SUM( t.nQFrenada		)	nQFrenada
		 ,	SUM( t.nQAceleracion	)	nQAceleracion
		 ,	SUM( t.nQVelocidad		)	nQVelocidad
		 ,	SUM( t.nQCurva			)	nQCurva
	FROM	score.tUsuarioVehiculo	uv
			JOIN tScoreDia			t	ON t.fUsuario = uv.pUsuario
	WHERE	uv.fUsuarioTitular	=	prm_pUsuario
	AND		t.dFecha			>=	vdIni
	AND		t.dFecha			<	vdFin;

	-- CURSOR 5: Detalle de los viajes del usuario
	SELECT	uv.pVehiculo									,	v.cPatente				AS	cPatente
		 ,	v.fUsuarioTitular		AS	fUsuarioTitular 	,	ut.cNombre				AS	cNombreTitular
		 ,	ini.fUsuario			AS	fUsuario		 	,	uu.cNombre				AS	cNombreConductor
		 ,	ini.nIdViaje			AS	nIdViaje
		 ,	ini.cCalle				AS	cCalleInicio		,	fin.cCalle				AS	cCalleFin
		 ,	ini.cCalleCorta			AS	cCalleCortaInicio	,	fin.cCalleCorta			AS	cCalleCortaFin
		 ,	ini.tEvento				AS	tInicio				,	fin.tEvento				AS	tFin
		 ,	TIMESTAMPDIFF(SECOND, ini.tEvento, fin.tEvento)							AS	nDuracionSeg
		 ,	ROUND(ini.nValor,0)	AS	nScore			,	ROUND(fin.nValor,2)	AS	nKms
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoAceleracion	THEN 1 ELSE 0 END ) AS	nQAceleracion
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoFrenada		THEN 1 ELSE 0 END ) AS	nQFrenada
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoVelocidad		THEN 1 ELSE 0 END ) AS	nQVelocidad
		 ,	SUM( CASE WHEN eve.fTpEvento = kEventoCurva			THEN 1 ELSE 0 END ) AS	nQCurva
	FROM	tUsuarioVehiculo 			AS	uv
			INNER JOIN tParamCalculo	AS	prm	ON	1 = 1
			-- Inicio del Viaje
			INNER JOIN tEvento			AS	ini ON	ini.fUsuario	=	uv.pUsuario
												AND	ini.fVehiculo	=	uv.pVehiculo
												AND	ini.fTpEvento	=	kEventoInicio
			-- Fin del Viaje
			INNER JOIN tEvento			AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
										 		AND	fin.fTpEvento	=	kEventoFin
											 	AND	fin.nValor		> 	prm.nDistanciaMin
			-- Eventos
			INNER JOIN tEvento			AS	eve ON	eve.nIdViaje	=	ini.nIdViaje
												AND	eve.fTpEvento not in ( kEventoInicio, kEventoFin )
			INNER JOIN tVehiculo		AS 	v	ON	v.pVehiculo		= 	uv.pVehiculo
			INNER JOIN tUsuario			AS	ut	ON	ut.pUsuario		=	uv.fUsuarioTitular
			INNER JOIN tUsuario			AS	uu	ON	uu.pUsuario		=	uv.pUsuario
	WHERE	uv.fUsuarioTitular	=	prm_pUsuario
	AND		ini.tEvento			>=	vdIni
	AND		fin.tEvento			<	vdFin
	GROUP BY	v.pVehiculo		,	v.cPatente		,	v.fUsuarioTitular	,	ut.cNombre
		 	,	ini.fUsuario	,	uu.cNombre		,	ini.nIdViaje		,	ini.cCalle
			,	ini.cCalleCorta	,	fin.cCalle 		,	fin.cCalleCorta		,	ini.tEvento
            ,	fin.tEvento		,	ini.nValor		,	fin.nValor	
	ORDER BY ini.tEvento DESC;

END //


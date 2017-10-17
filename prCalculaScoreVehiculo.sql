DELIMITER //
DROP PROCEDURE IF EXISTS prCalculaScoreVehiculo //
CREATE PROCEDURE prCalculaScoreVehiculo (IN prm_pVehiculo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
LB_PRINCIPAL:BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	
	DECLARE vdInicioScore		DATE;
    DECLARE vdInstalacion		DATE;
	DECLARE vdInicio			DATE;
	DECLARE vnDiasTotal			INTEGER;
	DECLARE vnDiasUso			INTEGER;
	DECLARE vnDiasPunta			INTEGER;	
	DECLARE vnDiasSinMedicion	INTEGER;
	DECLARE vnKms				INTEGER;
	DECLARE vnKmsPond			INTEGER;
	DECLARE vnSumaFrenada		DECIMAL(10,2);
	DECLARE vnSumaAceleracion	DECIMAL(10,2);
	DECLARE vnSumaVelocidad		DECIMAL(10,2);
	DECLARE vnSumaCurva			DECIMAL(10,2);
	DECLARE vnQViajes			INTEGER;
	DECLARE vnQFrenada			INTEGER;
	DECLARE vnQAceleracion		INTEGER;
	DECLARE vnQVelocidad		INTEGER;
	DECLARE vnQCurva			INTEGER;
	DECLARE vnPtjFrenada		DECIMAL(10,2) DEFAULT 0;
	DECLARE vnPtjAceleracion	DECIMAL(10,2) DEFAULT 0;
	DECLARE vnPtjVelocidad		DECIMAL(10,2) DEFAULT 0;
	DECLARE vnPtjCurva			DECIMAL(10,2) DEFAULT 0;
	DECLARE vnDescDiaSinUso		DECIMAL(10,2);
	DECLARE vnDescNoHoraPunta	DECIMAL(10,2);
	DECLARE vnScore				DECIMAL(10,2);
	DECLARE vnDescuentoKM		DECIMAL(10,2);
	DECLARE vnDescuento			DECIMAL(10,2);
	DECLARE vnFactorDias		FLOAT;

-- DEBUG
-- SELECT CONCAT('CALL prCalculaScoreVehiculo(', prm_pVehiculo,',''', prm_dIni, ''',''', prm_dFin, ''' );' ) as `CALL`;

	SELECT	MIN( t.dFecha )				dInicio			, SUM( t.nKms )				nKms
		 ,	SUM( t.nFrenada )			nSumaFrenada	, SUM( t.nAceleracion )		nSumaAceleracion
		 ,	SUM( t.nVelocidad )			nSumaVelocidad	, SUM( t.nCurva )			nSumaCurva
		 ,	SUM( t.nQFrenada )			nQFrenada		, SUM( t.nQAceleracion )	nQAceleracion
		 ,	SUM( t.nQVelocidad )		nQVelocidad		, SUM( t.nQCurva )			nQCurva
	INTO 	vdInicioScore								, vnKms
		 ,	vnSumaFrenada								, vnSumaAceleracion
		 ,	vnSumaVelocidad								, vnSumaCurva
		 ,	vnQFrenada									, vnQAceleracion
		 ,	vnQVelocidad								, vnQCurva
	FROM	tScoreDia t
	WHERE	t.fVehiculo =	prm_pVehiculo
	AND		t.dFecha	>=	prm_dIni
	AND		t.dFecha	<	prm_dFin;
          
-- DEBUG
/*
SELECT	MIN( t.dFecha )				dInicio			, SUM( t.nKms )				nKms
	 ,	SUM( t.nFrenada )			nSumaFrenada	, SUM( t.nAceleracion )		nSumaAceleracion
	 ,	SUM( t.nVelocidad )			nSumaVelocidad	, SUM( t.nCurva )			nSumaCurva
	 ,	SUM( t.nQFrenada )			nQFrenada		, SUM( t.nQAceleracion )	nQAceleracion
	 ,	SUM( t.nQVelocidad )		nQVelocidad		, SUM( t.nQCurva )			nQCurva
FROM	tScoreDia t
WHERE	t.fVehiculo =	prm_pVehiculo
AND		t.dFecha	>=	prm_dIni
AND		t.dFecha	<	prm_dFin;
*/

	IF IFNULL(vnKms,0) = 0 THEN
		SET vnDiasUso			= 0;
		SET vnDiasPunta			= 0;
        SET vnDiasSinMedicion	= 0;
		SET vnKms				= 0;
		SET vnQViajes			= 0;
		SET vnSumaFrenada		= 0;
		SET vnSumaAceleracion	= 0;
		SET vnSumaVelocidad		= 0;
		SET vnSumaCurva			= 0;
		SET vnQFrenada			= 0;
		SET vnQAceleracion		= 0;
		SET vnQVelocidad		= 0;
		SET vnQCurva			= 0;
		SET vdInicioScore		= prm_dIni;
		SET vnDiasTotal			= DATEDIFF( prm_dFin, vdInicioScore );
		SET vnFactorDias		= 1 / vnDiasTotal;
	ELSE
		IF vnKms > 0 THEN
			SET vnPtjFrenada		= vnSumaFrenada			* 100 / vnKms;
			SET vnPtjAceleracion	= vnSumaAceleracion		* 100 / vnKms;
			SET vnPtjVelocidad		= vnSumaVelocidad		* 100 / vnKms;
			SET vnPtjCurva			= vnSumaCurva			* 100 / vnKms;
		END IF;
	END IF;

	SELECT	GREATEST( dIniVigencia, IFNULL( dInstalacion, dIniVigencia )) dInstalacion
    INTO	vdInstalacion
    FROM	tVehiculo
    WHERE	pVehiculo = prm_pVehiculo;

    IF prm_dIni < vdInstalacion THEN
		SET vdInicio = vdInstalacion;
		-- Si el vehículo paso el vencimiento del mes sin haber instalado
		IF vdInicio >= prm_dFin THEN
			SET vnDiasTotal = DATEDIFF(prm_dFin, prm_dIni);
        
			INSERT INTO wMemoryScoreVehiculo 
					( pVehiculo 		, dInicio			, dFin				, nKms				, nScore
					, nQViajes			, nDescuento		, nDiasTotal		, nDiasUso			, nDiasPunta
					, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva			, nDiasSinMedicion
					, nDescuentoKM		, nDescuentoSinUso	, nDescuentoPunta	, nKmsPond
					, tUltimaSincro		, tUltimoViaje		, dInstalacion
					)
			VALUES	( prm_pVehiculo		, prm_dIni			, prm_dFin			, 0					, 100
					, 0					, 0					, vnDiasTotal		, 0					, 0 
					, 0					, 0					, 0					, 0					, 0
					, 0					, 0					, 0					, 0
					, null			    , null				, vdInstalacion
					);
			-- Abandona
			LEAVE LB_PRINCIPAL;
		END IF;
	ELSE
		SET vdInicio = prm_dIni;
    END IF;
    
	-- Tabla temporal de cantidad de días totales y de uso
	CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryScoreVehiculoCount (
		dFecha				DATE					NOT NULL,
		bUso				TINYINT(1)	UNSIGNED	NOT NULL	DEFAULT '0',
		bHoraPunta			TINYINT(1)	UNSIGNED	NOT NULL	DEFAULT '0',
		-- bDiasSinMedicion	TINYINT(1)	UNSIGNED	NOT NULL	DEFAULT '0',
		PRIMARY KEY (dFecha)
	) ENGINE=MEMORY;
	
	DELETE FROM wMemoryScoreVehiculoCount;
	-- Por cada fecha solo interesa si uso, por eso se busca el máximo por día, sin embargo
	-- Si no hay medición, es igual que si lo hubiese usado en hora punta/nocturna, es decir,
	-- no tiene descuento.
	INSERT INTO wMemoryScoreVehiculoCount 
	SELECT	dFecha, MAX(bUso), MAX(bHoraPunta) -- , MIN( bSinMedicion )
	FROM	tScoreDia
	WHERE	fVehiculo	=	prm_pVehiculo
	AND		dFecha		>=	vdInicio
	AND		dFecha		<	prm_dFin
	GROUP BY dFecha;

-- DEBUG
-- SELECT * FROM wMemoryScoreVehiculoCount ;

	-- Con el máximo por día se suma la cantidad de días de uso
	SELECT	COUNT(*)	, SUM(bUso)	, SUM(bHoraPunta)	-- 	, SUM(nDiasSinMedicion)
	INTO	vnDiasTotal	, vnDiasUso	, vnDiasPunta		-- 	, vnDiasSinMedicion
	FROM	wMemoryScoreVehiculoCount;

	-- Calcula días sin medición
    BEGIN
		-- Los días sin medición, es la cantidad de días que hay a la última fecha que hubo medición, hasta el fin de periodo de cálculo.
		-- Se mide desde la vigencia de la poliza, no desde la instalación.
		DECLARE vdUltMovim	DATE;
		DECLARE eofCurUlt	INTEGER DEFAULT 0;
		DECLARE curUlt		CURSOR FOR
			-- Inicio de transferencia
			SELECT	MAX(DATE(t.tRegistroActual  + INTERVAL -3 HOUR)) tUltMovim
			FROM	score.tInicioTransferencia t
			WHERE	t.fVehiculo			=	prm_pVehiculo
			AND		t.tRegistroActual	>=	vdInicio
			UNION ALL
			-- Archivo de control sin actividad por hora
			SELECT	MAX(DATE(f.event_date + INTERVAL -3 HOUR))
			FROM	snapcar.control_files f JOIN snapcar.clients c on c.id=f.client_id 
			WHERE	c.vehicle_id	=	prm_pVehiculo
			AND		f.event_date	>=	vdInicio
			UNION ALL
			-- Viajes realizados o no (acepta los Status='N' y los que tienen 0 km
			SELECT	MAX(DATE(f.from_date + INTERVAL -3 HOUR))
			FROM	snapcar.trips f 
					JOIN snapcar.clients c on c.id=f.client_id 
			WHERE	c.vehicle_id	=	prm_pVehiculo
			AND		f.from_date		>=	vdInicio
            ORDER BY 1 DESC
            LIMIT 1;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurUlt = 1;
		-- Ejecuta cursor y lee
		OPEN curUlt;
		FETCH curUlt INTO vdUltMovim;
		CLOSE curUlt;
        
		-- Si el fin del periodo es mayor a la fecha actual se toma la fecha actual.
		SET vnDiasSinMedicion = DATEDIFF( LEAST(prm_dFin + INTERVAL 0 DAY,DATE(NOW())), IFNULL(vdUltMovim + INTERVAL 1 DAY, vdInicio));
    END;

-- DEBUG

/*
SELECT	dFecha, min(bSinMedicion) bSinMedicion
FROM	tScoreDia
WHERE	fVehiculo		=	prm_pVehiculo
AND		dFecha			>=	prm_dIni
AND		dFecha			<	prm_dFin
group by dFecha order by 1;
SELECT	prm_dIni, prm_dFin, MAX( dFecha) + INTERVAL 1 DAY maxDFecha, LEAST(prm_dFin,DATE(NOW())) fechaFinReal
			, DATEDIFF( LEAST(prm_dFin,DATE(NOW())), IFNULL(MAX( dFecha ) + INTERVAL 1 DAY , prm_dIni)) diasSinMedicion
            , vnDiasUso
			, DATEDIFF( LEAST(prm_dFin,DATE(NOW())), IFNULL(MAX( dFecha ) + INTERVAL 1 DAY , prm_dIni)) + vnDiasUso diasMes
FROM	tScoreDia
WHERE	fVehiculo		=	prm_pVehiculo
AND		dFecha			>=	prm_dIni
AND		bSinMedicion	= '0';
*/

    IF vnDiasSinMedicion < 0 THEN
		SET vnDiasSinMedicion = 0;
    END IF;

	SELECT	COUNT(*) INTO vnQViajes
	FROM	tEvento e
			INNER JOIN tParamCalculo p ON 1 = 1
	WHERE	e.fVehiculo =	prm_pVehiculo
	AND		e.tEvento	>=	vdInicio
	AND		e.tEvento	<	prm_dFin
	AND		e.fTpEvento =	kEventoFin
	AND		e.nValor	>	p.nDistanciaMin;

	-- Calcula Score y Descuento Vehículo
	-- De acuerdo al tipo de evento, se hace la conversión usando la tablas de rangos por puntaje
	SELECT	nValor INTO vnPtjFrenada FROM tRangoPuntaje
	WHERE	fTpevento = kEventoFrenada AND nInicio <= vnPtjFrenada AND vnPtjFrenada < nFin;

	SELECT	nValor INTO vnPtjAceleracion FROM tRangoPuntaje
	WHERE	fTpevento = kEventoAceleracion AND nInicio <= vnPtjAceleracion AND vnPtjAceleracion < nFin;

	SELECT	nValor INTO vnPtjVelocidad FROM tRangoPuntaje
	WHERE	fTpevento = kEventoVelocidad AND nInicio <= vnPtjVelocidad AND vnPtjVelocidad < nFin;

	SELECT	nValor INTO vnPtjCurva FROM tRangoPuntaje
	WHERE	fTpevento = kEventoCurva AND nInicio <= vnPtjCurva AND vnPtjCurva < nFin;

	-- Trae el descuento a aplicar por los puntos y aplica la ponderación segun tParamCalculo
	SELECT	( vnPtjFrenada		* nPorcFrenada		/ 100 )
		+	( vnPtjAceleracion	* nPorcAceleracion	/ 100 )
		+	( vnPtjVelocidad	* nPorcVelocidad	/ 100 )
		+	( vnPtjCurva		* nPorcCurva		/ 100 )
	INTO	vnScore
	FROM	tParamCalculo;

	IF vnDiasTotal > 0 AND vnDiasUso IS NOT NULL THEN
		BEGIN
			DECLARE vtUltimoViaje		DATETIME;
			DECLARE vtUltimaSincro		DATETIME;
			
			SELECT	max(trips.to_date) + INTERVAL - 3 HOUR
			INTO	vtUltimoViaje
			FROM	snapcar.trips 
					JOIN snapcar.clients ON clients.id = trips.client_id
			WHERE	clients.vehicle_id = prm_pVehiculo
            AND		trips.distance > 300
            AND		trips.`status` = 'S';
			
			SELECT	max(it.tRegistroActual)
			INTO	vtUltimaSincro
			FROM	tInicioTransferencia it
			WHERE	it.fVehiculo = prm_pVehiculo;

			SET vtUltimaSincro = IFNULL(vtUltimaSincro, vtUltimoViaje);
			IF vtUltimaSincro < vtUltimoViaje THEN
				SET vtUltimaSincro = vtUltimoViaje;
			END IF;
			IF vnDiasSinMedicion > 0 THEN
				-- Se calcula e inserta este caso, solo para efectos de comparación, de lo que hubiese ahorrado
				CALL prCalculaDescuento( vnKms, vnDiasUso, vnDiasPunta, 0, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicioScore ),
										 vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond );

-- DEBUG
-- SELECT 'CALL prCalculaDescuento: Sin medicion', vnKms, vnDiasUso, vnDiasPunta, 0, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicioScore )
--       , vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond;

				-- Se espera que ya exista la tabla wMemoryScoreVehiculo, la cual es creada por prCreaTmpScoreVehiculo
				-- Inserta en tabla temporal
				INSERT INTO wMemoryScoreVehiculoSinMulta
						( pVehiculo 		, dInicio			, dFin				, nKms				, nScore
						, nQViajes			, nDescuento		, nDiasTotal		, nDiasUso			, nDiasPunta
						, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva			, nDiasSinMedicion
						, nDescuentoKM		, nDescuentoSinUso	, nDescuentoPunta	, nKmsPond
						, tUltimaSincro		, tUltimoViaje		, dInstalacion
						)
				VALUES	( prm_pVehiculo		, prm_dIni			, prm_dFin			, vnKms				, vnScore
						, vnQViajes			, vnDescuento		, vnDiasTotal		, vnDiasUso			, vnDiasPunta 
						, vnQFrenada		, vnQAceleracion	, vnQVelocidad		, vnQCurva			, 0
						, vnDescuentoKM		, vnDescDiaSinUso	, vnDescNoHoraPunta , vnKmsPond
						, vtUltimaSincro	, vtUltimoViaje		, vdInstalacion
						);
			END IF;

			CALL prCalculaDescuento( vnKms, vnDiasUso, vnDiasPunta, vnDiasSinMedicion, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicioScore ),
									 vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond );
-- DEBUG
-- SELECT 'CALL prCalculaDescuento', vnKms, vnDiasUso, vnDiasPunta, 0, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicioScore )
--       , vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond;
					
			-- Se espera que ya exista la tabla wMemoryScoreVehiculo, la cual es creada por prCreaTmpScoreVehiculo
			-- Inserta en tabla temporal
			INSERT INTO wMemoryScoreVehiculo 
					( pVehiculo 		, dInicio			, dFin				, nKms				, nScore
					, nQViajes			, nDescuento		, nDiasTotal		, nDiasUso			, nDiasPunta
					, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva			, nDiasSinMedicion
					, nDescuentoKM		, nDescuentoSinUso	, nDescuentoPunta	, nKmsPond
					, tUltimaSincro		, tUltimoViaje		, dInstalacion
					)
			VALUES	( prm_pVehiculo		, prm_dIni			, prm_dFin			, vnKms				, vnScore
					, vnQViajes			, vnDescuento		, vnDiasTotal		, vnDiasUso			, vnDiasPunta 
					, vnQFrenada		, vnQAceleracion	, vnQVelocidad		, vnQCurva			, vnDiasSinMedicion
					, vnDescuentoKM		, vnDescDiaSinUso	, vnDescNoHoraPunta , vnKmsPond
					, vtUltimaSincro	, vtUltimoViaje		, vdInstalacion
					);
		END;
	END IF;
-- DEBUG
-- SELECT * FROM wMemoryScoreVehiculo;

END //


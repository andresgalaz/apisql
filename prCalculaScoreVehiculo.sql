DROP PROCEDURE IF EXISTS score.prCalculaScoreVehiculo;
CREATE PROCEDURE score.prCalculaScoreVehiculo(IN prm_pVehiculo INTEGER, IN prm_dIni DATE, IN prm_dFin DATE )
BEGIN
	DECLARE kEventoInicio		INTEGER	DEFAULT 1;
	DECLARE kEventoFin			INTEGER	DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER	DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER	DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER	DEFAULT 5;
	DECLARE kEventoCurva		INTEGER	DEFAULT 6;
	
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
	INTO 	vdInicio									, vnKms
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
		SET vdInicio			= prm_dIni;
		SET vnDiasTotal			= DATEDIFF( prm_dFin, vdInicio );
		SET vnFactorDias		= 1 / vnDiasTotal;
	ELSE
		IF vnKms > 0 THEN
			SET vnPtjFrenada		= vnSumaFrenada			* 100 / vnKms;
			SET vnPtjAceleracion	= vnSumaAceleracion		* 100 / vnKms;
			SET vnPtjVelocidad		= vnSumaVelocidad		* 100 / vnKms;
			SET vnPtjCurva			= vnSumaCurva			* 100 / vnKms;
		END IF;
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
	AND		dFecha		>=	prm_dIni
	AND		dFecha		<	prm_dFin
	GROUP BY dFecha;

	-- Con el máximo por día se suma la cantidad de días de uso
	SELECT	COUNT(*)	, SUM(bUso)	, SUM(bHoraPunta)	-- 	, SUM(nDiasSinMedicion)
	INTO	vnDiasTotal	, vnDiasUso	, vnDiasPunta		-- 	, vnDiasSinMedicion
	FROM	wMemoryScoreVehiculoCount;
    
    -- Los días sin medición, es la cantidad de días que hay a la última fecha que hubo medición, 
	-- hasta el fin del periodo o la fecha actual, dependiendo si la fecha final es futura
    SELECT	DATEDIFF( LEAST(prm_dFin,DATE(NOW())), IFNULL(MAX( dFecha ), prm_dIni))
    INTO	vnDiasSinMedicion
	FROM	tScoreDia
	WHERE	fVehiculo		=	prm_pVehiculo
	AND		dFecha			>=	prm_dIni
-- 	AND		dFecha			<	prm_dFin
    AND		bSinMedicion	= '0';

-- DEBUG
/*
SELECT	prm_dFin, MAX( dFecha) maxDFecha, prm_dIni, LEAST(prm_dFin,DATE(NOW())), DATEDIFF( prm_dFin, IFNULL(MAX( dFecha ), prm_dIni))
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
	AND		e.tEvento	>=	prm_dIni
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
				CALL prCalculaDescuento( vnKms, vnDiasUso, vnDiasPunta, 0, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicio ),
										 vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond );

				-- Se espera que ya exista la tabla wMemoryScoreVehiculo, la cual es creada por prCreaTmpScoreVehiculo
				-- Inserta en tabla temporal
				INSERT INTO wMemoryScoreVehiculoSinMulta
						( pVehiculo 		, dInicio			, dFin				, nKms				, nScore
						, nQViajes			, nDescuento		, nDiasTotal		, nDiasUso			, nDiasPunta
						, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva			, nDiasSinMedicion
						, nDescuentoKM		, nDescuentoSinUso	, nDescuentoPunta	, nKmsPond
						, tUltimaSincro		, tUltimoViaje
						)
				VALUES	( prm_pVehiculo		, prm_dIni			, prm_dFin			, vnKms				, vnScore
						, vnQViajes			, vnDescuento		, vnDiasTotal		, vnDiasUso			, vnDiasPunta 
						, vnQFrenada		, vnQAceleracion	, vnQVelocidad		, vnQCurva			, 0
						, vnDescuentoKM		, vnDescDiaSinUso	, vnDescNoHoraPunta , vnKmsPond
						, vtUltimaSincro	, vtUltimoViaje
						);
			END IF;

			CALL prCalculaDescuento( vnKms, vnDiasUso, vnDiasPunta, vnDiasSinMedicion, vnScore, vnDiasTotal, DATEDIFF( prm_dFin, vdInicio ),
									 vnDescuento, vnDescuentoKM, vnDescDiaSinUso, vnDescNoHoraPunta, vnFactorDias, vnKmsPond );
					
			-- Se espera que ya exista la tabla wMemoryScoreVehiculo, la cual es creada por prCreaTmpScoreVehiculo
			-- Inserta en tabla temporal
			INSERT INTO wMemoryScoreVehiculo 
					( pVehiculo 		, dInicio			, dFin				, nKms				, nScore
					, nQViajes			, nDescuento		, nDiasTotal		, nDiasUso			, nDiasPunta
					, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva			, nDiasSinMedicion
					, nDescuentoKM		, nDescuentoSinUso	, nDescuentoPunta	, nKmsPond
					, tUltimaSincro		, tUltimoViaje
					)
			VALUES	( prm_pVehiculo		, prm_dIni			, prm_dFin			, vnKms				, vnScore
					, vnQViajes			, vnDescuento		, vnDiasTotal		, vnDiasUso			, vnDiasPunta 
					, vnQFrenada		, vnQAceleracion	, vnQVelocidad		, vnQCurva			, vnDiasSinMedicion
					, vnDescuentoKM		, vnDescDiaSinUso	, vnDescNoHoraPunta , vnKmsPond
					, vtUltimaSincro	, vtUltimoViaje
					);
		END;
	END IF;
-- DEBUG
-- SELECT * FROM wMemoryScoreVehiculo;

END;


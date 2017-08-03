DROP PROCEDURE IF EXISTS prCalculaScoreDia;
DELIMITER //
CREATE PROCEDURE prCalculaScoreDia	(	in prmDia		DATE
									,	in prmVehiculo	INTEGER
									,	in prmUsuario	INTEGER )
BEGIN
	-- Parametros
	DECLARE vdDia				DATE;
	DECLARE vdDiaSgte			DATE;

	-- Constantes
	DECLARE kEventoInicio		INTEGER DEFAULT 1;
	DECLARE kEventoFin			INTEGER DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER DEFAULT 5;
	DECLARE kEventoCurva		INTEGER DEFAULT 6;

	-- Acumuladores
	DECLARE vnAceleracion		DECIMAL(10,2);
	DECLARE vnFrenada			DECIMAL(10,2);
	DECLARE vnVelocidad			DECIMAL(10,2);
	DECLARE vnCurva 			DECIMAL(10,2);
	DECLARE vnQAceleracion		INTEGER;
	DECLARE vnQFrenada			INTEGER;
	DECLARE vnQVelocidad		INTEGER;
	DECLARE vnQCurva 			INTEGER;
	DECLARE vnKms				DECIMAL(10,2);
	DECLARE vnHoraPunta			INTEGER;
	DECLARE vnEventos			INTEGER;

	SET vdDia = prmDia;
	SET vdDiaSgte = ADDDATE( vdDia, INTERVAL 1 DAY);

	-- Cursor Eventos
	-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
	SELECT SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje	ELSE 0 END ) AS nAceleracion
		 , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje	ELSE 0 END ) AS nFrenada
		 , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje	ELSE 0 END ) AS nVelocidad
		 , SUM( CASE ev.fTpEvento WHEN kEventoCurva			THEN ev.nPuntaje	ELSE 0 END ) AS nCurva
		 , SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN 1				ELSE 0 END ) AS nQAceleracion
		 , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN 1				ELSE 0 END ) AS nQFrenada
		 , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN 1				ELSE 0 END ) AS nQVelocidad
		 , SUM( CASE ev.fTpEvento WHEN kEventoCurva			THEN 1				ELSE 0 END ) AS nQCurva
		 , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor		ELSE 0 END ) AS nKms
		 , SUM( esHoraPunta( ev.tEvento ))	AS vnHoraPunta
		 , COUNT( * )						AS vnEventos
	INTO	vnAceleracion, vnFrenada, vnVelocidad, vnCurva
		 ,	vnQAceleracion, vnQFrenada, vnQVelocidad, vnQCurva
		 ,	vnKms, vnHoraPunta, vnEventos
	FROM	vEvento ev
	WHERE	ev.fVehiculo	=	prmVehiculo
	AND		ev.fUsuario		=	prmUsuario
	AND		ev.tEvento		>=	vdDia
	AND		ev.tEvento		<	vdDiaSgte;

	-- No hubieron eventos este día
	IF vnEventos is null or vnEventos = 0 THEN
		SET vnEventos		= 0;
		SET vnHoraPunta		= 0;
		SET vnKms			= 0;
		SET vnFrenada		= 0;
		SET vnAceleracion	= 0;
		SET vnVelocidad		= 0;
		SET vnCurva			= 0;
		SET vnQFrenada		= 0;
		SET vnQAceleracion	= 0;
		SET vnQVelocidad	= 0;
		SET vnQCurva		= 0;
	ELSE
		-- Ajusta booleano
		SET vnEventos		= 1;
	END IF;
		
	-- Ajusta booleano, basta con un evento en hora punta para que el día sea hora punta
	IF vnHoraPunta > 0 THEN
		SET vnHoraPunta = 1;
	END IF;
    
	BEGIN
		DECLARE vdUltimaSincro		DATE;
		DECLARE vbSinMedicion		CHAR(1) DEFAULT '0';
		DECLARE bInsert				CHAR(1);
 		DECLARE CONTINUE HANDLER FOR NOT FOUND SET bInsert = '1';
		
		SELECT '0' INTO bInsert
		FROM 	tScoreDia
		WHERE	fVehiculo	= prmVehiculo
		AND		fUsuario	= prmUsuario
		AND		dFecha	 	= vdDia;

		-- Ajusta días sin medición
		SELECT	max(tRegistroActual)
		FROM	score.tInicioTransferencia
		WHERE 	fVehiculo = prmVehiculo
		UNION ALL
		SELECT	max(tEvento) 
		FROM	score.tEvento
		WHERE	fVehiculo = prmVehiculo
		UNION ALL
		SELECT	max(event_date)  		INTO vdUltimaSincro
		FROM	snapcar.control_files f 
				JOIN snapcar.clients c 	ON c.id = f.client_id
		WHERE	c.vehicle_id = prmVehiculo
		ORDER BY 1 DESC
		LIMIT 1;

		IF IFNULL(vdUltimaSincro,'2017-01-01') < vdDia THEN
			-- Este día no está sincronizado
            SET vbSinMedicion := 1;
		END IF;

		IF bInsert = '0' THEN
			-- Actualiza
			UPDATE tScoreDia
			SET		nKms			= vnKms
				 ,	nFrenada		= vnFrenada			, nQFrenada		= vnQFrenada
				 ,	nAceleracion	= vnAceleracion		, nQAceleracion	= vnQAceleracion
				 ,	nVelocidad		= vnVelocidad		, nQVelocidad	= vnQVelocidad
				 ,	nCurva			= vnCurva			, nQCurva		= vnQCurva
				 ,	bHoraPunta		= vnHoraPunta		, bSinMedicion	= vbSinMedicion
				 ,	bUso			= vnEventos
			WHERE	fVehiculo	= prmVehiculo
			AND		fUsuario	= prmUsuario
			AND		dFecha	 	= vdDia;
		ELSE			
			INSERT INTO tScoreDia
					( fVehiculo			, fUsuario			, dFecha
					, nKms				, bHoraPunta		, bUso				, bSinMedicion
					, nFrenada			, nAceleracion		, nVelocidad		, nCurva
					, nQFrenada			, nQAceleracion		, nQVelocidad		, nQCurva
					 )
			VALUES	( prmVehiculo		, prmUsuario		, vdDia
					, vnKms				, vnHoraPunta		, vnEventos			, vbSinMedicion
					, vnFrenada			, vnAceleracion		, vnVelocidad		, vnCurva
					, vnQFrenada		, vnQAceleracion	, vnQVelocidad		, vnQCurva
			 		 );
		END IF;
	END;
    
END //



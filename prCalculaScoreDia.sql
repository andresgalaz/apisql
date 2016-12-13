DROP PROCEDURE IF EXISTS prCalculaScoreDia;
DELIMITER //
CREATE PROCEDURE prCalculaScoreDia ( in prmDia      date
                                   , in prmVehiculo integer
                                   , in prmUsuario  integer )
BEGIN
    -- Parametros
    DECLARE vdDia				date;
	DECLARE vdDiaSgte			date;

	-- Constantes
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;

	-- Acumuladores
	DECLARE vnAceleracion	    decimal(10,2);
	DECLARE vnFrenada		    decimal(10,2);
	DECLARE vnVelocidad		    decimal(10,2);
	DECLARE vnKms				decimal(10,2);
	DECLARE vnHoraPunta			integer;
	DECLARE vnEventos			integer;
	
	-- Contadores
	DECLARE vnRegs				integer;

	SET vdDia = prmDia;
	SET vdDiaSgte = ADDDATE( vdDia, INTERVAL 1 DAY);

	-- Cursor Eventos
	-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
	SELECT SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ) AS nAceleracion
		 , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ) AS nFrenada
		 , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ) AS nVelocidad
		 , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ) AS nKms
		 , SUM( esHoraPunta( ev.tEvento ))	AS vnHoraPunta
		 , COUNT( * )						AS vnEventos
	INTO   vnAceleracion, vnFrenada, vnVelocidad, vnKms
		 , vnHoraPunta, vnEventos
	FROM   tEvento ev
	WHERE  ev.fVehiculo = prmVehiculo
	AND	   ev.fUsuario  = prmUsuario
	AND	   ev.tEvento  >= vdDia
	AND    ev.tEvento   < vdDiaSgte;

	-- No hubieron eventos este día
	IF vnEventos is null or vnEventos = 0 THEN
		SET vnEventos		= 0;
		SET vnHoraPunta     = 0;
		SET vnKms           = 0;
		SET vnVelocidad     = 0;
		SET vnFrenada       = 0;
		SET vnAceleracion   = 0;
	ELSE
		-- Ajusta booleano
		SET vnEventos		= 1;
	END IF;
		
	-- Ajusta booleano, basta con un evento en hora punta para que el día sea hora punta
	IF vnHoraPunta > 0 THEN
		SET vnHoraPunta     = 1;
	END IF;

	-- Actualiza
	UPDATE tScoreDia
	SET	   nKms			= vnKms
		 , nFrenada		= vnFrenada
		 , nAceleracion	= vnAceleracion
		 , nVelocidad	= vnVelocidad
		 , bHoraPunta	= vnHoraPunta
		 , bUso			= vnEventos
	WHERE  fVehiculo = prmVehiculo
	AND	   fUsuario  = prmUsuario
	AND	   dFecha	 = vdDia;
		
	SET vnRegs = ROW_COUNT();
	-- Si no actualizó nada, es porque no existe el registro, esto
	-- es poco probable porque el proceso calculaScoreDiaInicio crea
	-- a la hora 00:00 todos los registros de usuario vehiculo en cero
	IF vnRegs = 0 THEN
		INSERT INTO tScoreDia
				( fVehiculo      	, fUsuario			, dFecha
				, nKms				, nFrenada  	 	
				, nAceleracion	    , nVelocidad
				, bHoraPunta		, bUso )
		VALUES	( prmVehiculo     	, prmUsuario		, vdDia
				, vnKms				, vnFrenada
				, vnAceleracion     , vnVelocidad
		 		, vnHoraPunta		, vnEventos );
	END IF;
    /*
	SELECT 'MSG 500', 'Fin CurEvento', now()
         , prmVehiculo     	, prmUsuario		, vdDia
		 , vnKms		    , vnFrenada
		 , vnAceleracion    , vnVelocidad
		 , vnHoraPunta		, vnEventos;
    */         
END //
DELIMITER ;
-- call prCalculaScoreDia(now());

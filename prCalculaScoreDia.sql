DROP PROCEDURE IF EXISTS prCalculaScoreDia;
DELIMITER //
CREATE PROCEDURE prCalculaScoreDia (in prmDia date, in prmVehiculo integer, in prmUsuario integer )
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
	DECLARE vfVehiculo			integer;
	DECLARE vfUsuario			integer;
	DECLARE vnSumaAceleracion	decimal(5,2);
	DECLARE vnSumaFrenada		decimal(5,2);
	DECLARE vnSumaVelocidad		decimal(5,2);
	DECLARE vnKms				decimal(8,2);
	DECLARE vnHoraPunta			integer;
	DECLARE vnEventos			integer;
	
	-- Contadores
	DECLARE vnRegs				integer;

	SET vdDia = prmDia;
	SET vdDiaSgte = ADDDATE( vdDia, INTERVAL 1 DAY);

	BEGIN
		-- Cursor Eventos
		-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CurEvento CURSOR FOR
			SELECT SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ) AS nSumaAceleracion
				 , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ) AS nSumaFrenada
				 , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ) AS nSumaVelocidad
				 , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ) AS nKms
				 , SUM( esHoraPunta( ev.tEvento ))	AS vnHoraPunta
				 , COUNT( * )						AS vnEventos
			FROM   tEvento ev
			WHERE  ev.fVehiculo = prmVehiculo
			AND	   ev.fUsuario  = prmUsuario
			AND	   ev.tEvento  >= vdDia
			AND    ev.tEvento   < vdDiaSgte;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

		OPEN  CurEvento;
		FETCH CurEvento INTO vfVehiculo, vfUsuario
						   , vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms
						   , vnHoraPunta, vnEventos;
		WHILE NOT eofCurEvento DO

			-- No hubieron eventos este día
			IF vnEventos = 0 THEN
				-- Ajusta booleano
				SET vnEventos			= 0;
				SET vnHoraPunta         = 0;
				SET vnKms               = 0;
				SET vnSumaVelocidad     = 0;
				SET vnSumaFrenada       = 0;
				SET vnSumaAceleracion   = 0;
			ELSE
				SET vnEventos			= 1;
			END IF;
			
			-- Ajusta booleano
			IF vnHoraPunta > 0 THEN
				SET vnHoraPunta         = 1;
			END IF;

			-- Actualiza
			UPDATE tScoreDia
			SET	   nKms				= vnKms
				 , nSumaFrenada		= vnSumaFrenada
				 , nSumaAceleracion	= vnSumaAceleracion
				 , nSumaVelocidad	= vnSumaVelocidad
				 , bHoraPunta		= vnHoraPunta
				 , bUso				= vnEventos
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
						, nKms				, nSumaFrenada  	 	
						, nSumaAceleracion	, nSumaVelocidad
						, bHoraPunta		, bUso )
				VALUES	( vpVehiculo     	, vpCuenta			, vdDia
						, vnKms				, vnSumaFrenada
						, vnSumaAceleracion	, vnSumaVelocidad
				 		, vnHoraPunta		, vnEventos );
			END IF;
			FETCH CurEvento INTO vfVehiculo, vfUsuario
							   , vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms
							   , vnHoraPunta, vnEventos;
		END WHILE;
		CLOSE CurEvento;
		SELECT 'MSG 500', 'Fin CurEvento', now(), vpScoreDia;
	END; -- Fin cursor eventos
END //
DELIMITER ;
-- call prCalculaScoreDia(now());

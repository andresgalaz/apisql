DROP PROCEDURE IF EXISTS calculaScoreDiaInicio;
DELIMITER //
CREATE PROCEDURE calculaScoreDiaInicio (in prmDia date)			integer;
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
	DECLARE vpVehiculo			integer;
	DECLARE vpUsuario			integer;
	DECLARE vnCount			integer;


	SELECT 'MSG 100', 'Inicio proceso CurEvento', now();
	-- Ajusta filtro del Where
	SET vdDia = prmDia;
	SET vdDiaSgte = ADDDATE( vdDia, INTERVAL 1 DAY);

	BEGIN
		-- Cursor Eventos
		-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;
		DECLARE CurEvento CURSOR FOR
			SELECT uv.pVehiculo, uv.pUsuario
			     , COUNT( sd.pScoreDia )	AS vnEventos
			FROM   tUsuarioVehiculo uv
			LEFT OUTER JOIN tScoreDia sd ON sd.fVehiculo = uv.pVehiculo
										AND sd.fUsuario  = uv.pUsuario
										AND sd.dFecha    >= vdDia
										AND sd.dFecha    <  vdDiaSgte
			GROUP BY uv.pVehiculo, uv.pUsuario;

		OPEN  CurEvento;
		FETCH CurEvento INTO vpVehiculo, vpUsuario, vnCount;
		WHILE NOT eofCurEvento DO
			-- No hay registros para este día, se inserta un registro en cero
			IF vnCount = 0 THEN
				INSERT INTO tScoreDia
						( fVehiculo    		, fUsuario		, dFecha )
				VALUES	( vpVehiculo     	, vpCuenta		, vdDia  );
			END IF;
			-- Siguiente registro
			FETCH CurEvento INTO vpVehiculo, vpUsuario, vnCount;
		END WHILE;
		CLOSE CurEvento;
		SELECT 'MSG 500', 'Fin CurEvento', now();
	END; -- FIn cursor eventos
END //
DELIMITER ;
-- call calculaScoreDiaInicio(now());

DROP PROCEDURE IF EXISTS calculaScoreDia;
DELIMITER //
CREATE PROCEDURE calculaScoreDia (in prmDia date)			integer;
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

	SET vdDia = prmDia;
	SET vdDiaSgte = ADDDATE( vdDia, INTERVAL 1 DAY);

	BEGIN
		-- Cursor Eventos
		-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;
		DECLARE CurEvento CURSOR FOR
			SELECT ev.fVehiculo, ev.fUsuario
				 , SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ) AS nSumaAceleracion
				 , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ) AS nSumaFrenada
				 , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ) AS nSumaVelocidad
				 , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ) AS nKms
				 , SUM( esHoraPunta( ev.tEvento ))	AS vnHoraPunta
				 , COUNT( * )						AS vnEventos
			FROM   tEvento ev
			WHERE  ev.tEvento >= vdDia
			AND    ev.tEvento <  vdDiaSgte
			GROUP BY ev.fVehiculo, ev.fUsuario;

		OPEN  CurEvento;
		FETCH CurEvento INTO vfVehiculo, vfUsuario
						   , vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms
						   , vnHoraPunta, vnEventos;
		WHILE NOT eofCurEvento DO

			-- No hubieron eventos este día
			IF vnEventos = 0 THEN
				SET vnHoraPunta         = 0;
				SET vnKms               = 0;
				SET vnSumaVelocidad     = 0;
				SET vnSumaFrenada       = 0;
				SET vnSumaAceleracion   = 0;
			END IF;

				INSERT INTO tScoreDia
				( fVehiculo      	, fUsuario
				, dPeriodo			, nKms
				, nSumaFrenada  	 	, nSumaAceleracion		, nSumaVelocidad
				, nFrenada	   	 	, nAceleracion			, nVelocidad
				, nTotalDias			, nDiasUso				, nDiasPunta
				, nScore				, nDescuento			, nDescuentoKM
				, nDescuentoPtje
				, nDescuentoSinUso
				, nDescuentoNoUsoPunta	)
				VALUES ( vpVehiculo     	, vpCuenta
				, dMes				, round(vnKms,2)
				, vnSumaFrenada  	, vnSumaAceleracion		, vnSumaVelocidad
				, vnPtjFrenada   	, vnPtjAceleracion		, vnPtjVelocidad
				, vnTotalDias		, vnDiasUso				, vnDiasPunta
				, round( vnScore, 2) , round( vnDescuento, 2), round( vnDescuentoKM, 2 )
				, round( vnDescuentoPtje, 2)
				, round( ( vnTotalDias - vnDiasUso ) * kDescDiaSinUso, 2 )
				, round( ( vnDiasUso - vnDiasPunta ) * kDescNoUsoPunta, 2 )
				);
				SET vpScoreDia = LAST_INSERT_ID();
				-- Siguiente cuenta
				FETCH CurEvento INTO vfVehiculo, vfUsuario
								   , vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnKms
								   , vnHoraPunta, vnEventos;
		END WHILE;
		CLOSE CurEvento;
		SELECT 'MSG 500', 'Fin CurEvento', now(), vpScoreDia;
	END; -- FIn cursor eventos
END //
DELIMITER ;
-- call calculaScoreDia(now());

DROP PROCEDURE IF EXISTS calculaScoreDiario;
CREATE PROCEDURE calculaScoreDiario (in dInicio date, in dFin date)
BEGIN
	DECLARE kEventoInicio      integer DEFAULT 1;
	DECLARE kEventoFin         integer DEFAULT 2;
	DECLARE kEventoAceleracion integer DEFAULT 3;
	DECLARE kEventoFrenada     integer DEFAULT 4;
	DECLARE kEventoVelocidad   integer DEFAULT 5;

	BEGIN
		DECLARE vpEvento			integer;
		DECLARE vfTpEvento			integer;
		DECLARE vnVelocidadMaxima	float;
		DECLARE vnValor				float;
		DECLARE vnPuntaje			integer;

		DECLARE eofCurEvento integer DEFAULT 0;
		DECLARE curEvento CURSOR FOR
			SELECT e.pEvento
			     , e.fTpEvento
			     , e.nVelocidadMaxima
			     , CASE e.fTpEvento
			         WHEN kEventoVelocidad THEN
			           100 * ( e.nValor - e.nVelocidadMaxima ) / e.nVelocidadMaxima
			         ELSE
			           e.nValor
			       END as nValor
			  FROM tEvento e
			 WHERE e.fTpEvento in ( kEventoAceleracion, kEventoFrenada, kEventoVelocidad )
			   AND e.tEvento >= dInicio AND e.tEvento <  adddate(dFin, INTERVAL 1 DAY);
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurEvento = 1;

    	SELECT 'Inicio curEvento';
		OPEN  curEvento;
		FETCH curEvento INTO vpEvento, vfTpEvento, vnVelocidadMaxima, vnValor;
		WHILE NOT eofCurEvento DO
  			SELECT vfTpEvento, vnValor;

			SELECT points INTO vnPuntaje
			  FROM observations_ranges
			 WHERE observation_id = vfTpEvento
			   AND start_range_num <= vnValor AND vnValor < end_range_num;

		 	UPDATE tEvento SET nPuntaje = vnPuntaje WHERE pEvento = vpEvento;

			FETCH curEvento INTO vpEvento, vfTpEvento, vnVelocidadMaxima, vnValor;
		END WHILE;
		CLOSE curEvento;
    	SELECT 'Fin curEvento';
	END;

	BEGIN
		DECLARE dCount				date;
		DECLARE vfVehiculo			integer;
		DECLARE vfUsuario			integer;
		DECLARE vnKms				float;
		DECLARE vnPtjVelocidad		float;
		DECLARE vnPtjFrenada		float;
		DECLARE vnPtjAceleracion	float;
		DECLARE vnValor					float;

		DECLARE eofCurUsrVeh integer DEFAULT 0;
		DECLARE curUsrVeh CURSOR FOR
			SELECT v.pVehiculo, cu.pUsuario
			  FROM tVehiculo v
			       INNER JOIN tCuentaUsuario cu ON cu.pCuenta = v.fCuenta
			 WHERE v.bVigente = '1';
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurUsrVeh = 1;

    	SELECT 'Inicio curUsrVeh';
		OPEN  curUsrVeh;
		FETCH curUsrVeh INTO vfVehiculo, vfUsuario;
		WHILE NOT eofCurUsrVeh DO
			-- Calcula para el día
			SET dCount = dInicio;
			WHILE dCount <= dFin DO
				SELECT sum(nKms)        , avg(nPtjVelocidad)
				     , avg(nPtjFrenada)	, avg(nPtjAceleracion)
				  INTO vnKms            , vnPtjVelocidad
				     , vnPtjFrenada     , vnPtjAceleracion
				  FROM vPuntaje
				 WHERE fVehiculo =  vfVehiculo
				   AND fUsuario  =  vfUsuario
				   AND tInicio   >= dCount
				   AND tInicio   <  adddate(dCount, INTERVAL 1 DAY);

				IF vnKms IS NULL OR vnKms = 0 THEN
					SET vnKms = 0;
					SET vnValor = 100;
				ELSE
					SET vnValor = round(( vnPtjAceleracion + vnPtjFrenada + vnPtjVelocidad ) / 3, 2);
				END IF;
				INSERT INTO tScore
				       ( fVehiculo , fUsuario , dScore, nValor , nKms  )
				VALUES ( vfVehiculo, vfUsuario, dCount, vnValor, vnKms );
				-- Avanza un día
				SET dCount = adddate(dCount, INTERVAL 1 DAY);
			END WHILE;
			FETCH curUsrVeh INTO vfVehiculo, vfUsuario;
		END WHILE;
		CLOSE curUsrVeh;
    	SELECT 'Fin curUsrVeh';
	END;
END;

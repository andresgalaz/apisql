DELIMITER //
DROP PROCEDURE IF EXISTS prScoreVehiculoRangoFecha //
CREATE PROCEDURE prScoreVehiculoRangoFecha (in prm_pUsuario integer, in prm_dIni date, in prm_dFin date )
BEGIN
	DECLARE kDescLimite			integer	DEFAULT 40;
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;
	DECLARE kEventoCurva        integer DEFAULT 6;
    DECLARE vdFin               date;

    IF prm_dIni > prm_dFin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio no puede ser inferior a la fecha de fin';
    END IF;
    
    SET vdFin = ADDDATE(prm_dFin, INTERVAL 1 DAY);

    CREATE TEMPORARY TABLE IF NOT EXISTS wMemoryScoreVehiculo (
       pVehiculo    INT             UNSIGNED NOT NULL,
       nKms         DECIMAL(10,2)   UNSIGNED NOT NULL   DEFAULT '0.0',
       nScore       DECIMAL(10,2)   UNSIGNED NOT NULL   DEFAULT '0.0',
       nDescuento   DECIMAL( 5,2)                       DEFAULT '0.0',
      PRIMARY KEY (pVehiculo)
    ) ENGINE=MEMORY;
    DELETE FROM wMemoryScoreVehiculo;

    BEGIN    
	    DECLARE vpVehiculo          integer;

    	DECLARE vdInicio			date;
    	DECLARE vnKmsPond			decimal(10,2);
    	DECLARE vnKms				decimal(10,2);
    	DECLARE vnSumaFrenada		decimal(10,2);
    	DECLARE vnSumaAceleracion	decimal(10,2);
    	DECLARE vnSumaVelocidad		decimal(10,2);
    	DECLARE vnSumaCurva         decimal(10,2);
    	DECLARE vnPorcFrenada 		decimal(10,2);
    	DECLARE vnPorcAceleracion 	decimal(10,2);
    	DECLARE vnPorcVelocidad 	decimal(10,2);
    	DECLARE vnPorcCurva         decimal(10,2);
    	DECLARE vnParamDiaSinUso    decimal(5,2);
    	DECLARE vnParamNoHoraPunta  decimal(5,2);
    	DECLARE vnPtjFrenada		decimal(10,2) default 0;
    	DECLARE vnPtjAceleracion	decimal(10,2) default 0;
    	DECLARE vnPtjVelocidad		decimal(10,2) default 0;
    	DECLARE vnPtjCurva          decimal(10,2) default 0;
    	DECLARE vnDescDiaSinUso		decimal(10,2);
    	DECLARE vnDescNoHoraPunta	decimal(10,2);
    	DECLARE vnDiasUso			integer;
    	DECLARE vnDiasPunta			integer;
    	DECLARE vnScore				decimal(10,2);
    	DECLARE vnDescuentoKM		decimal(10,2);
--	    DECLARE vnDescuentoPtje		decimal(10,2);
    	DECLARE vnDescuento			decimal(10,2);

    	DECLARE vnDiasTotal         integer;
    	DECLARE vnFactorDias        float;        
        -- Cursor Vehiculos para borrar 
        DECLARE eofCurVeh integer DEFAULT 0;
        DECLARE CurVeh CURSOR FOR
            SELECT t.fVehiculo
                 , MIN( t.dFecha )          dInicio       , SUM( t.nKms )            nSumaKms
                 , SUM( t.nFrenada )        nSumaFrenada  , SUM( t.nAceleracion )    nSumaAceleracion
                 , SUM( t.nVelocidad )      nSumaVelocidad, SUM( t.nCurva )          nSumaCurva
                 , COUNT(DISTINCT t.dFecha) nDiasTotal
                 , SUM( t.bUso )            nDiasUso      , SUM( t.bHoraPunta )      nDiasPunta
            FROM   tScoreDia t
                   JOIN tVehiculo v ON v.pVehiculo = t.fVehiculo
            WHERE  t.fUsuario = prm_pUsuario
            AND    t.dFecha >= prm_dIni
            AND    t.dFecha <  vdFin
            GROUP BY t.fVehiculo;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurVeh = 1;
        
        OPEN  CurVeh;
        FETCH CurVeh INTO vpVehiculo
                        , vdInicio                            , vnKms
                        , vnSumaFrenada                       , vnSumaAceleracion
                        , vnSumaVelocidad                     , vnSumaCurva
                        , vnDiasTotal
                        , vnDiasUso                           , vnDiasPunta;
        WHILE NOT eofCurVeh DO
        
        	IF IFNULL(vnDiasTotal,0) = 0 THEN
        		SET vnDiasUso           = 0;
        		SET vnDiasPunta         = 0;
        		SET vnKms               = 0;
        		SET vnSumaFrenada       = 0;
        		SET vnSumaAceleracion   = 0;
        		SET vnSumaVelocidad     = 0;
        		SET vnSumaCurva         = 0;
                SET vdInicio            = prm_dIni;
            	SET vnKmsPond           = 0;
            	SET vnFactorDias        = 1 / DATEDIFF( vdFin, vdInicio );
        	ELSE
        		IF vnKms > 0 THEN
        			SET vnPtjFrenada	 = vnSumaFrenada     * 100 / vnKms;
           			SET vnPtjAceleracion = vnSumaAceleracion * 100 / vnKms;
        			SET vnPtjVelocidad	 = vnSumaVelocidad   * 100 / vnKms;
        			SET vnPtjCurva   	 = vnSumaCurva       * 100 / vnKms;
        		END IF;
                -- Se considera la fracción de días desde el inicio de actividad del vehículo
                -- Normalmente el inicio es el primer día del mes, pero no para los vehículos 
                -- que entran en actividad en medio del mes en análisis (prmMes)
            	SET vnFactorDias = vnDiasTotal / DATEDIFF( vdFin, vdInicio );
            	-- Trae el descuento por kilómetros recorridos en el mes (o mes ponderado)
            	-- si vnDescuento resulta negativo, en realidad es un recargo
            	SET vnKmsPond = vnKms / vnFactorDias;
        	END IF;
            
            -- De acuerdo al tipo de evento, se hace la conversión usando la tablas de
            -- rangos por puntaje
        	SELECT nValor INTO vnPtjFrenada
        	FROM   tRangoPuntaje
        	WHERE  fTpevento = kEventoFrenada
        	AND     nInicio <= vnPtjFrenada AND vnPtjFrenada < nFin;

            SELECT nValor INTO vnPtjAceleracion
        	FROM   tRangoPuntaje
        	WHERE  fTpevento = kEventoAceleracion
        	AND    nInicio <= vnPtjAceleracion AND vnPtjAceleracion < nFin;

        	SELECT nValor INTO vnPtjVelocidad
        	FROM   tRangoPuntaje
        	WHERE  fTpevento = kEventoVelocidad
        	AND    nInicio <= vnPtjVelocidad AND vnPtjVelocidad < nFin;

            SELECT nValor INTO vnPtjCurva
        	FROM   tRangoPuntaje
        	WHERE  fTpevento = kEventoCurva
        	AND    nInicio <= vnPtjCurva AND vnPtjCurva < nFin;

            SELECT d.nValor
        	INTO   vnDescuentoKM
        	FROM   tRangoDescuento d
        	WHERE  d.cTpDescuento = 'KM'
        	AND    d.nInicio <= vnKmsPond AND vnKmsPond < nFin;
            
            -- Parámetros de ponderación por tipo de evento
        	SELECT nPorcFrenada / 100 , nPorcAceleracion / 100, nPorcVelocidad / 100, nPorcCurva / 100
        	     , nDescDiaSinUso     , nDescNoHoraPunta
        	INTO   vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad     , vnPorcCurva
        	     , vnParamDiaSinUso   , vnParamNoHoraPunta
        	FROM   tParamCalculo;

        	-- Trae el descuento a aplicar por los puntos
        	SET vnScore = ( vnPtjFrenada     * vnPorcFrenada     )
        				+ ( vnPtjAceleracion * vnPorcAceleracion )
        				+ ( vnPtjVelocidad   * vnPorcVelocidad   )
                        + ( vnPtjCurva       * vnPorcCurva       );

        	SET vnDescuento = vnDescuentoKM * vnFactorDias;
        	-- Descuento por días sin uso
            SET vnDescDiaSinUso = ( vnDiasTotal - vnDiasUso ) * vnParamDiaSinUso;
        	SET vnDescuento = vnDescuento + vnDescDiaSinUso;
        	-- Descuento por días de uso fuera de hora Punta, es igual a los días usados - los días en Punta
            SET vnDescNoHoraPunta = ( vnDiasUso - vnDiasPunta ) * vnParamNoHoraPunta;
        	SET vnDescuento = vnDescuento + vnDescNoHoraPunta;
        	-- Ajusta por el puntaje
        	IF vnDescuento > 0 THEN
        		-- Descuento
        		IF vnScore > 60 THEN
        			SET vnDescuento = vnDescuento * vnScore / 100;
        		ELSE
        			SET vnDescuento = 0;
        		END IF;
        	ELSE
        		-- Recargo, si maneja bien se disminuye el recargo
        		IF vnScore > 60 THEN
                	SET vnDescuento = vnDescuento * ( 100 - vnScore ) / 100;
                END IF;
        		-- Si maneja mal se aumenta el recargo
        		IF vnScore < 40 THEN
        			-- Se recarga 1 punto por cada score bajo 40
        			SET vnDescuento = vnDescuento - ( 40 - vnScore );
        		END IF;
        	END IF;

        	-- SET vnDescuento = vnDescuento * vnDescuentoPtje;
        	IF vnDescuento > kDescLimite THEN
        		SET vnDescuento = kDescLimite;
        	END IF;
        	IF vnDescuento < -kDescLimite THEN
        		SET vnDescuento = -kDescLimite;
        	END IF;
        	IF vdInicio <> prm_dIni THEN
        		SET vnDescuento = vnDescuento / vnFactorDias / DATEDIFF( vdFin, vdInicio );
        	END IF;
        	SET vnDescuento = round(vnDescuento, 0);

            -- Inserta en tabla temporal
            INSERT INTO wMemoryScoreVehiculo 
                   ( pVehiculo , nKms , nScore , nDescuento )
            VALUES ( vpVehiculo, vnKms, vnScore, vnDescuento );
            
            FETCH CurVeh INTO vpVehiculo
                            , vdInicio                            , vnKms
                            , vnSumaFrenada                       , vnSumaAceleracion
                            , vnSumaVelocidad                     , vnSumaCurva
                            , vnDiasTotal
                            , vnDiasUso                           , vnDiasPunta;
        END WHILE;
        CLOSE CurVeh;
    END;

    SELECT w.pVehiculo       AS idVehiculo          , v.cPatente        AS patente
         , v.fUsuarioTitular AS idTitular           , ut.cNombre        AS titular
         , w.nKms            AS kms
         , w.nScore          AS score               , w.nDescuento      AS descuento
    FROM wMemoryScoreVehiculo w
         JOIN score.tVehiculo        v  ON v.pVehiculo  = w.pVehiculo
         JOIN score.tUsuario         ut ON ut.pUsuario  = v.fUsuarioTitular;

END //
-- call prScoreVehiculoRangoFecha( 66, date('2017-04-11'), date(now())) //

DROP PROCEDURE IF EXISTS prCalculaScoreViaje;
DELIMITER //
CREATE PROCEDURE prCalculaScoreViaje (in prmViaje integer )
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;
	DECLARE kEventoCurva    	integer DEFAULT 6;

    DECLARE vnPorcFrenada		decimal(10,2);
    DECLARE vnPorcAceleracion	decimal(10,2);
    DECLARE vnPorcVelocidad 	decimal(10,2);
    DECLARE vnPorcCurva 	    decimal(10,2);
    DECLARE vnPtjFrenada		decimal(10,2) DEFAULT 0;
    DECLARE vnPtjAceleracion	decimal(10,2) DEFAULT 0;
    DECLARE vnPtjVelocidad	    decimal(10,2) DEFAULT 0;
    DECLARE vnPtjCurva          decimal(10,2) DEFAULT 0;
    DECLARE vnSumaAceleracion   decimal(10,2);
    DECLARE vnSumaFrenada       decimal(10,2);
    DECLARE vnSumaVelocidad     decimal(10,2);
    DECLARE vnSumaCurva         decimal(10,2);
    DECLARE vnKms               decimal(10,2);
    DECLARE vnCantidad          integer;

    -- Suma los puntajes de cada tipo de evento y cuenta los días de uso
    SELECT SUM( CASE ev.fTpEvento WHEN kEventoAceleracion	THEN ev.nPuntaje ELSE 0 END ) AS nSumaAceleracion
         , SUM( CASE ev.fTpEvento WHEN kEventoFrenada		THEN ev.nPuntaje ELSE 0 END ) AS nSumaFrenada
         , SUM( CASE ev.fTpEvento WHEN kEventoVelocidad		THEN ev.nPuntaje ELSE 0 END ) AS nSumaVelocidad
         , SUM( CASE ev.fTpEvento WHEN kEventoCurva 		THEN ev.nPuntaje ELSE 0 END ) AS nSumaCurva
         , SUM( CASE ev.fTpEvento WHEN kEventoFin			THEN ev.nValor   ELSE 0 END ) AS nKms
         , COUNT( * )
    INTO   vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnSumaCurva,vnKms, vnCantidad
    FROM   vEvento ev
    WHERE  ev.nIdViaje = prmViaje;

	IF IFNULL(vnCantidad,0) = 0 THEN
        SET vnCantidad        = 0;
		SET vnSumaAceleracion = 0;
		SET vnSumaFrenada	  = 0;
		SET vnSumaVelocidad   = 0;
		SET vnSumaCurva       = 0;
		SET vnKms             = 0;
	ELSE
        IF vnKms > 0 THEN
    		SET vnPtjFrenada	 = ( vnSumaFrenada		* 100 ) / vnKms;
    		SET vnPtjAceleracion = ( vnSumaAceleracion	* 100 ) / vnKms;
    		SET vnPtjVelocidad	 = ( vnSumaVelocidad	* 100 ) / vnKms;
    		SET vnPtjCurva  	 = ( vnSumaCurva    	* 100 ) / vnKms;
        END IF;
	END IF;

	SELECT nValor INTO vnPtjFrenada
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoFrenada
    AND    nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;

    SELECT nValor INTO vnPtjAceleracion
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoAceleracion
    AND    nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;

    SELECT nValor INTO vnPtjVelocidad
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoVelocidad
    AND    nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;

    SELECT nValor INTO vnPtjCurva
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoCurva
    AND    nInicio <= vnPtjCurva and vnPtjCurva < nFin;

    SELECT nPorcFrenada / 100 , nPorcAceleracion /100 , nPorcVelocidad /100 , nPorcCurva /100
    INTO   vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad     , vnPorcCurva
    FROM   tParamCalculo;

    -- El Score del viaje se guarda en el valor del evento Inicio
    UPDATE tEvento 
    SET    nValor = ( vnPtjFrenada		* vnPorcFrenada		)
    			  + ( vnPtjAceleracion	* vnPorcAceleracion	)
    			  + ( vnPtjVelocidad	* vnPorcVelocidad 	)
    			  + ( vnPtjCurva	    * vnPorcCurva 	)
    WHERE  nIdViaje  = prmViaje
    AND    fTpEvento = kEventoInicio;

END //

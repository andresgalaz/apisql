DROP PROCEDURE IF EXISTS prCalculaScoreMesConductor;
DELIMITER //
CREATE PROCEDURE prCalculaScoreMesConductor (in prmMes date, in prmVehiculo integer, in prmUsuario integer )
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;

	DECLARE dMes				date;
	DECLARE dMesSgte			date;

    DECLARE vdInicio            date;
	DECLARE vnKms				decimal(10,2);
	DECLARE vnSumaVelocidad		decimal(10,2);
	DECLARE vnSumaFrenada		decimal(10,2);
	DECLARE vnSumaAceleracion	decimal(10,2);
    DECLARE vnPorcFrenada       decimal(10,2);
    DECLARE vnPorcAceleracion   decimal(10,2);
    DECLARE vnPorcVelocidad     decimal(10,2);
	DECLARE vnPtjVelocidad		decimal(10,2);
	DECLARE vnPtjFrenada		decimal(10,2);
	DECLARE vnPtjAceleracion	decimal(10,2);
	DECLARE vnDiasTotal         integer;
	DECLARE vnDiasUso			integer;
	DECLARE vnDiasPunta			integer;
	DECLARE vnScore				decimal(10,2);

	-- Asegura que la fecha sea el primer día del Mes y sin Hora
	SET dMes	 = DATE(DATE_SUB(prmMes, INTERVAL DAYOFMONTH(prmMes) - 1 DAY));
	SET dMesSgte = ADDDATE(dMes, INTERVAL 1 MONTH);

	-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
	SELECT MIN( t.dFecha )          AS dInicio 
         , SUM( t.nAceleracion )    AS nSumaAceleracion
	     , SUM( t.nFrenada )        AS nSumaFrenada
	     , SUM( t.nVelocidad )      AS nSumaVelocidad
		 , SUM( t.nKms )            AS nKms
		 , COUNT(DISTINCT t.dFecha) AS nDiasTotal
         , SUM( t.bUso )            AS nDiasUso
         , SUM( t.bHoraPunta )      AS nDiasPunta
	INTO   vdInicio, vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad
         , vnKms, vnDiasTotal, vnDiasUso, vnDiasPunta
	FROM   tScoreDia t
	WHERE  t.fUsuario  = prmUsuario
	AND    t.fVehiculo = prmVehiculo
	AND    t.dFecha   >= dMes
	AND    t.dFecha    < dMesSgte;

    IF vnDiasTotal = 0 THEN
        SET vnDiasUso           = 0;
        SET vnDiasPunta         = 0;
        SET vnKms               = 0;
        SET vnSumaVelocidad     = 0;
        SET vnSumaFrenada       = 0;
        SET vnSumaAceleracion   = 0;
        SET vnPtjVelocidad      = 0;
        SET vnPtjFrenada        = 0;
        SET vnPtjAceleracion    = 0;
        SET vnScore             = 0;
    ELSE
        IF vnKms > 0 THEN
            SET vnPtjVelocidad   = vnSumaVelocidad   * 100 / vnKms;
            SET vnPtjFrenada     = vnSumaFrenada     * 100 / vnKms;
            SET vnPtjAceleracion = vnSumaAceleracion * 100 / vnKms;
        ELSE
            SET vnPtjVelocidad   = 0;
            SET vnPtjFrenada     = 0;
            SET vnPtjAceleracion = 0;
        END IF;
    END IF;

	SELECT nValor INTO vnPtjVelocidad
	FROM   tRangoPuntaje
	WHERE  fTpevento = kEventoVelocidad
	AND    nInicio <= vnPtjVelocidad and vnPtjVelocidad < nFin;

    SELECT nValor INTO vnPtjFrenada
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoFrenada
    AND    nInicio <= vnPtjFrenada and vnPtjFrenada < nFin;

    SELECT nValor INTO vnPtjAceleracion
    FROM   tRangoPuntaje
    WHERE  fTpevento = kEventoAceleracion
    AND    nInicio <= vnPtjAceleracion and vnPtjAceleracion < nFin;


    SELECT nPorcFrenada / 100 , nPorcAceleracion /100 , nPorcVelocidad /100
    INTO   vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad
    FROM   tParamCalculo;

    IF( vnKms > 0 ) THEN
        SET vnScore = ( vnPtjFrenada     * vnPorcFrenada )
                    + ( vnPtjAceleracion * vnPorcAceleracion )
                    + ( vnPtjVelocidad   * vnPorcVelocidad );
    ELSE
        SET vnScore = 100;
        SET vnKms       = 0;
    END IF;

	INSERT INTO tScoreMesConductor
		   ( fVehiculo      	, fUsuario
		   , dPeriodo			, nScore				, nKms
		   , nSumaFrenada  	 	, nSumaAceleracion		, nSumaVelocidad
		   , nFrenada	   	 	, nAceleracion			, nVelocidad
		   , nTotalDias			, nDiasUso				, nDiasPunta	)
	VALUES ( prmVehiculo     	, prmUsuario
		   , dMes				, vnScore  	            , vnKms
		   , vnSumaFrenada  	, vnSumaAceleracion		, vnSumaVelocidad
		   , vnPtjFrenada   	, vnPtjAceleracion		, vnPtjVelocidad
		   , vnDiasTotal		, vnDiasUso				, vnDiasPunta	);
END //
DELIMITER ;
-- call calculaScoreMesConductor(now());

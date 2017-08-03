DROP PROCEDURE IF EXISTS prCalculaScoreMesConductor;
DELIMITER //
CREATE PROCEDURE prCalculaScoreMesConductor (in prmMes date, in prmVehiculo integer, in prmUsuario integer )
BEGIN
	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;
	DECLARE kEventoCurva	    integer DEFAULT 6;

	DECLARE vdMes				date;
	DECLARE vdMesSgte			date;

	DECLARE vnKms				decimal(10,2);
	DECLARE vnSumaFrenada		decimal(10,2);
	DECLARE vnSumaAceleracion	decimal(10,2);
	DECLARE vnSumaVelocidad		decimal(10,2);
	DECLARE vnSumaCurva         decimal(10,2);
    DECLARE vnPorcFrenada       decimal(10,2);
    DECLARE vnPorcAceleracion   decimal(10,2);
    DECLARE vnPorcVelocidad     decimal(10,2);
    DECLARE vnPorcCurva         decimal(10,2);
	DECLARE vnPtjFrenada		decimal(10,2) default 0;
	DECLARE vnPtjAceleracion	decimal(10,2) default 0;
	DECLARE vnPtjVelocidad		decimal(10,2) default 0;
	DECLARE vnPtjCurva  		decimal(10,2) default 0;
	DECLARE vnDiasTotal         integer;
	DECLARE vnDiasUso			integer;
	DECLARE vnDiasPunta			integer;
	DECLARE vnScore				decimal(10,2);

	-- Asegura que la fecha sea el primer día del Mes y sin Hora
	SET vdMes 	  = DATE(DATE_SUB(prmMes, INTERVAL DAYOFMONTH(prmMes) - 1 DAY));
	SET vdMesSgte = ADDDATE(vdMes, INTERVAL 1 MONTH);

	-- Suma los puntajes de cada tipo de evento y cuenta los días de uso
	SELECT SUM( t.nAceleracion )    AS nSumaAceleracion
	     , SUM( t.nFrenada )        AS nSumaFrenada
	     , SUM( t.nVelocidad )      AS nSumaVelocidad
	     , SUM( t.nCurva )          AS nSumaCurva
		 , SUM( t.nKms )            AS nKms
		 , COUNT(DISTINCT t.dFecha) AS nDiasTotal
         , SUM( t.bUso )            AS nDiasUso
         , SUM( t.bHoraPunta )      AS nDiasPunta
	INTO   vnSumaAceleracion, vnSumaFrenada, vnSumaVelocidad, vnSumaCurva
         , vnKms, vnDiasTotal, vnDiasUso, vnDiasPunta
	FROM   tScoreDia t
	WHERE  t.fUsuario  = prmUsuario
	AND    t.fVehiculo = prmVehiculo
	AND    t.dFecha   >= vdMes
	AND    t.dFecha    < vdMesSgte;

    IF IFNULL(vnDiasTotal, 0) = 0 THEN
        SET vnDiasUso           = 0;
        SET vnDiasPunta         = 0;
        SET vnKms               = 0;
        SET vnSumaFrenada       = 0;
        SET vnSumaAceleracion   = 0;
        SET vnSumaVelocidad     = 0;
        SET vnSumaCurva         = 0;
        SET vnScore             = 0;
    ELSE
        IF vnKms > 0 THEN
            SET vnPtjFrenada     = vnSumaFrenada     * 100 / vnKms;
            SET vnPtjAceleracion = vnSumaAceleracion * 100 / vnKms;
            SET vnPtjVelocidad   = vnSumaVelocidad   * 100 / vnKms;
            SET vnPtjCurva       = vnSumaCurva       * 100 / vnKms;
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

    IF( vnKms > 0 ) THEN
        SET vnScore = ( vnPtjFrenada     * vnPorcFrenada )
                    + ( vnPtjAceleracion * vnPorcAceleracion )
                    + ( vnPtjVelocidad   * vnPorcVelocidad )
                    + ( vnPtjCurva       * vnPorcCurva );
    ELSE
        SET vnScore = 100;
        SET vnKms   = 0;
    END IF;

    DELETE FROM tScoreMesConductor
    WHERE  fVehiculo = prmVehiculo
    AND    fUsuario  = prmUsuario
    AND    dPeriodo  = vdMes;

	INSERT INTO tScoreMesConductor
		   ( fVehiculo      	, fUsuario
		   , dPeriodo			, nScore				, nKms
		   , nSumaFrenada  	 	, nSumaAceleracion		, nSumaVelocidad   , nSumaCurva
		   , nFrenada	   	 	, nAceleracion			, nVelocidad       , nCurva
		   , nTotalDias			, nDiasUso				, nDiasPunta	)
	VALUES ( prmVehiculo     	, prmUsuario
		   , vdMes				, vnScore  	            , vnKms
		   , vnSumaFrenada  	, vnSumaAceleracion		, vnSumaVelocidad  , vnSumaCurva
		   , vnPtjFrenada   	, vnPtjAceleracion		, vnPtjVelocidad   , vnPtjCurva
		   , vnDiasTotal		, vnDiasUso				, vnDiasPunta	);
END //

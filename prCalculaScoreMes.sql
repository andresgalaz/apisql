DROP PROCEDURE IF EXISTS prCalculaScoreMes;
DELIMITER //
CREATE PROCEDURE prCalculaScoreMes (in prmMes date, in prmVehiculo integer)
BEGIN
	DECLARE kDescDiaSinUso		float   DEFAULT 0.66;
	DECLARE kDescNoUsoPunta		float	DEFAULT 0.33;
	DECLARE kDescLimite			integer	DEFAULT 40;

	DECLARE kEventoInicio		integer DEFAULT 1;
	DECLARE kEventoFin			integer DEFAULT 2;
	DECLARE kEventoAceleracion	integer DEFAULT 3;
	DECLARE kEventoFrenada		integer DEFAULT 4;
	DECLARE kEventoVelocidad	integer DEFAULT 5;

	DECLARE vdMes				date;
	DECLARE vdMesSgte			date;

	DECLARE vdInicio			date;
	DECLARE vfCuenta			integer;
	DECLARE vnKmsPond			decimal(10,2);
	DECLARE vnKms				decimal(10,2);
	DECLARE vnSumaVelocidad		decimal(10,2);
	DECLARE vnSumaFrenada		decimal(10,2);
	DECLARE vnSumaAceleracion	decimal(10,2);
	DECLARE vnPorcFrenada 		decimal(10,2);
	DECLARE vnPorcAceleracion 	decimal(10,2);
	DECLARE vnPorcVelocidad 	decimal(10,2);
	DECLARE vnPtjVelocidad		decimal(10,2) default 0;
	DECLARE vnPtjFrenada		decimal(10,2) default 0;
	DECLARE vnPtjAceleracion	decimal(10,2) default 0;
	DECLARE vnDescDiaSinUso		decimal(10,2);
	DECLARE vnDescNoHoraPunta	decimal(10,2);
	DECLARE vnDiasUso			integer;
	DECLARE vnDiasPunta			integer;
	DECLARE vnScore				decimal(10,2);
	DECLARE vnDescuentoKM		decimal(10,2);
--	DECLARE vnDescuentoPtje		decimal(10,2);
	DECLARE vnDescuento			decimal(10,2);

	DECLARE vnDiasTotal         integer;
	DECLARE nFactorDias         float;

	-- Asegura que la fecha sea el primer día del Mes y sin Hora
	SET vdMes	  = DATE(DATE_SUB(prmMes, INTERVAL DAYOFMONTH(prmMes) - 1 DAY));
	SET vdMesSgte = ADDDATE(vdMes, INTERVAL 1 MONTH);

    SELECT v.fCuenta
         , MIN( t.dFecha )       dInicio       , SUM( t.nKms )            nSumaKms
         , SUM( t.nFrenada )     nSumaFrenada  , SUM( t.nAceleracion )    nSumaAceleracion
         , SUM( t.nVelocidad )   nSumaVelocidad, COUNT(DISTINCT t.dFecha) nDiasTotal
         , SUM( t.bUso )         nDiasUso
         , SUM( t.bHoraPunta )   nDiasPunta
    INTO   vfCuenta
         , vdInicio                            , vnKms
         , vnSumaFrenada                       , vnSumaAceleracion
         , vnSumaVelocidad                     , vnDiasTotal
         , vnDiasUso                           , vnDiasPunta
    FROM   tScoreDia t
    INNER JOIN tVehiculo v ON v.pVehiculo = t.fVehiculo
    WHERE  t.fVehiculo = prmVehiculo
    AND    t.dFecha >= vdMes
    AND    t.dFecha  < vdMesSgte;  

	IF vnDiasTotal = 0 THEN
		SET vnDiasUso           = 0;
		SET vnDiasPunta         = 0;
		SET vnKms               = 0;
		SET vnSumaVelocidad     = 0;
		SET vnSumaFrenada       = 0;
		SET vnSumaAceleracion   = 0;
        SET vdInicio            = vdMes;
    	SET vnKmsPond           = 0;
	ELSE
		IF vnKms > 0 THEN
			SET vnPtjVelocidad	 = vnSumaVelocidad   * 100 / vnKms;
			SET vnPtjFrenada	 = vnSumaFrenada     * 100 / vnKms;
   			SET vnPtjAceleracion = vnSumaAceleracion * 100 / vnKms;
		END IF;
        -- Se considera la fracción de días desde el inicio de actividad del vehículo
        -- Normalmente el inicio es el primer día del mes, pero no para los vehículos 
        -- que entran en actividad en medio del mes en análisis (prmMes)
    	SET nFactorDias = vnDiasTotal / DATEDIFF( vdMesSgte, vdInicio );
    	-- Trae el descuento por kilómetros recorridos en el mes (o mes ponderado)
    	-- si vnDescuento resulta negativo, en realidad es un recargo
    	SET vnKmsPond = vnKms / nFactorDias;
	END IF;
    
    -- De acuerdo al tipo de evento, se hace la conversión usando la tablas de
    -- rangos por puntaje
	SELECT nValor INTO vnPtjVelocidad
	FROM   tRangoPuntaje
	WHERE  fTpevento = kEventoVelocidad
	AND    nInicio <= vnPtjVelocidad AND vnPtjVelocidad < nFin;

	SELECT nValor INTO vnPtjFrenada
	FROM   tRangoPuntaje
	WHERE  fTpevento = kEventoFrenada
	AND     nInicio <= vnPtjFrenada AND vnPtjFrenada < nFin;

    SELECT nValor INTO vnPtjAceleracion
	FROM   tRangoPuntaje
	WHERE  fTpevento = kEventoAceleracion
	AND    nInicio <= vnPtjAceleracion AND vnPtjAceleracion < nFin;

	SELECT d.nValor
	INTO   vnDescuentoKM
	FROM   tRangoDescuento d
	WHERE  d.cTpDescuento = 'KM'
	AND    d.nInicio <= vnKmsPond AND vnKmsPond < nFin;

    -- Parámetros de ponderación por tipo de evento
	SELECT nPorcFrenada / 100 , nPorcAceleracion /100 , nPorcVelocidad /100
		 , nDescDiaSinUso     , nDescNoHoraPunta
	INTO   vnPorcFrenada      , vnPorcAceleracion     , vnPorcVelocidad
		 , vnDescDiaSinUso    , vnDescNoHoraPunta
	FROM   tParamCalculo;

	-- Trae el descuento a aplicar por los puntos
	SET vnScore = ( vnPtjFrenada     * vnPorcFrenada )
				+ ( vnPtjAceleracion * vnPorcAceleracion )
				+ ( vnPtjVelocidad   * vnPorcVelocidad );
	/*
	SELECT d.nValor
	INTO   vnDescuentoPtje
	FROM   tRangoDescuento d
	WHERE  d.cTpDescuento = 'SCORE'
	AND    d.nInicio <= vnScore AND vnScore < nFin;
    */

	SET vnDescuento = vnDescuentoKM;
	-- Descuento por días sin uso
	SET vnDescuento = vnDescuento + ( vnDiasTotal - vnDiasUso ) * kDescDiaSinUso;
	-- Descuento por días de uso fuera de hora Punta, es igual a los días usados - los días en Punta
	SET vnDescuento = vnDescuento + ( vnDiasUso - vnDiasPunta ) * kDescNoUsoPunta;
	-- Ajusta por el puntaje
	IF vnDescuento > 0 THEN
		-- Descuento
		IF vnScore > 60 THEN
			SET vnDescuento = vnDescuento * vnScore / 100;
		ELSE
			SET vnDescuento = 0;
		END IF;
	ELSE
		-- Recargo
		IF vnScore > 60 THEN
        	SET vnDescuento = vnDescuento * ( 100 - vnScore ) / 100;
        END IF;
        -- else: Se aplica el 100% del recargo
	END IF;

	-- SET vnDescuento = vnDescuento * vnDescuentoPtje;
	IF vnDescuento > kDescLimite THEN
		SET vnDescuento = kDescLimite;
	END IF;
	IF vnDescuento < -kDescLimite THEN
		SET vnDescuento = -kDescLimite;
	END IF;

    DELETE FROM tScoreMes 
    WHERE  fVehiculo = prmVehiculo
    AND    dPeriodo  = vdMes;

	INSERT INTO tScoreMes
		   ( fVehiculo      	, fCuenta
		   , dPeriodo			, nKms
		   , nSumaFrenada  	 	, nSumaAceleracion		, nSumaVelocidad
		   , nFrenada	   	 	, nAceleracion			, nVelocidad
		   , nTotalDias			, nDiasUso				, nDiasPunta
	   	   , nScore				, nDescuento			, nDescuentoKM
		   , nDescuentoPtje	    , nDescuentoSinUso
		   , nDescuentoNoUsoPunta	)
	VALUES ( prmVehiculo    	, vfCuenta
		   , vdMes				, vnKms
		   , vnSumaFrenada  	, vnSumaAceleracion		, vnSumaVelocidad
		   , vnPtjFrenada   	, vnPtjAceleracion		, vnPtjVelocidad
		   , vnDiasTotal		, vnDiasUso				, vnDiasPunta
	   	   , vnScore            , vnDescuento           , vnDescuentoKM
		   , vnDescuentoPtje    , ( vnDiasTotal - vnDiasUso ) * kDescDiaSinUso
		   , ( vnDiasUso - vnDiasPunta ) * kDescNoUsoPunta  );
END //
DELIMITER ;
-- call prCalculaScoreMes(now());

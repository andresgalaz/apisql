DELIMITER //
DROP FUNCTION IF EXISTS fnFechaCierreIni //
CREATE FUNCTION fnFechaCierreIni(prm_dIni DATE, prm_nPeriodo INTEGER) RETURNS DATE
BEGIN
	DECLARE DCORTE		DATE	DEFAULT '2018-01-17';
    DECLARE DIAS_PREV	INTEGER DEFAULT 7;
	DECLARE nDia		INTEGER;
	DECLARE dIniPrev 		DATE;
	DECLARE dIni		DATE;
    DECLARE nPeriodo	INTEGER DEFAULT 0;
    DECLARE dNowAjustada DATE DEFAULT fnNowTest() + INTERVAL prm_nPeriodo MONTH;
    
    -- Ultimo día mes fecha ajustada
   	SET nDia = DAY( prm_dIni );
	-- Ajusta la fecha actual al mismo dìa del mes y ya le resta los 7 días
	SET dIniPrev = fnNowTest() - INTERVAL (DAY(fnNowTest()) - nDia) DAY;
    IF nDia > DAY( dIniPrev ) THEN
		SET dIniPrev = prm_dIni + INTERVAL ROUND( DATEDIFF( dNowAjustada, prm_dIni ) / 30, 0 ) MONTH;
	ELSE
		SET dIniPrev = dIniPrev + INTERVAL prm_nPeriodo MONTH;
    END IF;
    
    IF dIniPrev > LAST_DAY(dNowAjustada) THEN
		SET dIniPrev = LAST_DAY(dNowAjustada);
    END IF;
	-- Idem a la anterior meno 7 días
	SET dIni = dIniPrev - INTERVAL DIAS_PREV DAY;

    IF dIniPrev BETWEEN DCORTE AND ( DCORTE + INTERVAL DIAS_PREV DAY ) THEN	
		set dIni = DCORTE;
    END IF;

    IF dIni < DCORTE THEN
		SET dIni = dIniPrev;
    END IF;
	IF dIni + INTERVAL prm_nPeriodo MONTH >= dNowAjustada THEN
		SET dIni = dIni - INTERVAL 1 MONTH;
	END IF;
    
	RETURN dIni;
END //

DROP PROCEDURE IF EXISTS prFechaCierreIni //
CREATE PROCEDURE prFechaCierreIni(prm_dIni DATE, prm_nPeriodo INTEGER) 
BEGIN
	DECLARE DCORTE		DATE	DEFAULT '2018-01-17';
    DECLARE DIAS_PREV	INTEGER DEFAULT 7;
	DECLARE nDia		INTEGER;
	DECLARE dIniPrev 	DATE;
	DECLARE dIni		DATE;
	DECLARE dFin		DATE;
    DECLARE nPeriodo	INTEGER DEFAULT 0;
    DECLARE dNowAjustada DATE DEFAULT fnNowTest() + INTERVAL prm_nPeriodo MONTH;
    
    -- Ultimo día mes fecha ajustada
   	SET nDia = DAY( prm_dIni );
    
    -- Calcula Fecha Inicio
    
	-- Ajusta la fecha actual al mismo dìa del mes y ya le resta los 7 días
	SET dIniPrev = fnNowTest() - INTERVAL (DAY(fnNowTest()) - nDia) DAY;
--    IF nDia > DAY( dIniPrev ) THEN
-- 		SET dIniPrev = prm_dIni + INTERVAL ROUND( DATEDIFF( dNowAjustada, prm_dIni ) / 30, 0 ) MONTH;
-- SELECT 0.1, dIniPrev, fnNowTest(), dNowAjustada, LAST_DAY(dNowAjustada) as dNowFin;
-- 	ELSE
	SET dIniPrev = dIniPrev + INTERVAL prm_nPeriodo MONTH;
-- SELECT 0.2, dIniPrev, fnNowTest(), dNowAjustada, LAST_DAY(dNowAjustada) as dNowFin;
--     END IF;
    IF dIniPrev > LAST_DAY(dNowAjustada) THEN
		SET dIniPrev = LAST_DAY(dNowAjustada);
    END IF;

SELECT 1.0, dIniPrev, dIni, dNowAjustada, fnNowTest() ;
	IF dIniPrev > DCORTE THEN
		-- Idem a la anterior meno 7 días
		SET dIni = dIniPrev - INTERVAL DIAS_PREV DAY;
		IF dIniPrev < ( DCORTE + INTERVAL DIAS_PREV DAY ) THEN	
			set dIni = DCORTE;        
		END IF;
	ELSE
		-- Idem a la anterior meno 7 días
		SET dIni = dIniPrev;
    END IF;
-- SELECT 1.1, dIniPrev, dIni, dNowAjustada, fnNowTest() ;

SELECT 6, prm_dIni, prm_nPeriodo, nPeriodo, fnNowTest(), dNowAjustada, dIniPrev, dIni;    

    -- Calcula Fecha Fin
    
	-- Ajusta la fecha actual al mismo dìa del mes y ya le resta los 7 días
	SET dIniPrev = fnNowTest() - INTERVAL (DAY(fnNowTest()) - nDia) DAY;
	SET dIniPrev = dIniPrev + INTERVAL ( prm_nPeriodo + 1 ) MONTH;
-- SELECT 0.2, dIniPrev, fnNowTest(), dNowAjustada, LAST_DAY(dNowAjustada) as dNowFin;
--    END IF;
    IF dIniPrev > LAST_DAY(dNowAjustada + INTERVAL 1 MONTH ) THEN
		SET dIniPrev = LAST_DAY(dNowAjustada + INTERVAL 1 MONTH );
    END IF;

SELECT 1.0, dIniPrev, dFin, dNowAjustada, fnNowTest() ;
	IF dIniPrev > DCORTE THEN
		-- Idem a la anterior meno 7 días
		SET dFin = dIniPrev - INTERVAL DIAS_PREV DAY;
		IF dIniPrev < ( DCORTE + INTERVAL DIAS_PREV DAY ) THEN	
			set dFin = DCORTE;        
		END IF;
	ELSE
		-- Idem a la anterior meno 7 días
		SET dFin = dIniPrev;
    END IF;
-- SELECT 1.1, dIniPrev, dIni, dNowAjustada, fnNowTest() ;


-- SELECT 3.0, dFin + INTERVAL prm_nPeriodo MONTH, dNowAjustada;
-- 	IF dFin + INTERVAL prm_nPeriodo MONTH >= ( dNowAjustada + INTERVAL 1 MONTH) THEN
-- 		SET dFin = dFin - INTERVAL 1 MONTH;
-- 	END IF;

    
SELECT 6, prm_dIni, prm_nPeriodo, nPeriodo, fnNowTest(), dNowAjustada, dIniPrev, dFin;    

END //


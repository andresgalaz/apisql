DELIMITER //
DROP FUNCTION IF EXISTS fnFechaCierreFin //
CREATE FUNCTION fnFechaCierreFin(prm_dIniVig DATE, prm_nPeriodo INTEGER) RETURNS DATE
BEGIN
	RETURN fnFechaCierreIni( prm_dIniVig, prm_nPeriodo + 1 );
    /*
	DECLARE DCORTE		DATE	DEFAULT '2018-01-17';
    DECLARE DIAS_PREV	INTEGER DEFAULT 7;
	-- La fecha de Cierre es un mes después de la fecha inicio
	DECLARE dFin 	DATE;
	DECLARE nDia 	INTEGER DEFAULT DAY( prm_dIniVig );
	-- Ajusta la fecha actual al mismo dìa del mes
	DECLARE dFin DATE DEFAULT DATE_SUB(fnNowTest(), INTERVAL DAY(fnNowTest()) - nDia DAY);
    
    IF nDia >= DAY(fnNowTest()) THEN
		SET prm_nPeriodo = prm_nPeriodo - 1;
    END IF;
	-- Lleva al periodo deseado
	SET dFin = DATE_ADD(dFin, INTERVAL prm_nPeriodo MONTH );
    -- Calcula fecha fin cierre
	SET dFin = dFin + INTERVAL 1 MONTH;
    -- El día DCORTE fue el día que se retrocedió en 4 días la fecha de facturación
    IF dFin >= DCORTE THEN
		SET dFin = dFin + INTERVAL -DIAS_PREV DAY;
	END IF;
    
	RETURN dFin;
    */
END //

DROP PROCEDURE IF EXISTS prFechaCierreFin //
CREATE PROCEDURE prFechaCierreFin(prm_dIniVig DATE, prm_nPeriodo INTEGER) 
BEGIN    
	DECLARE DCORTE			DATE	DEFAULT '2018-01-17';
    DECLARE DIAS_PREV		INTEGER DEFAULT 7;
	DECLARE nDia			INTEGER;
	DECLARE dFin			DATE;
    DECLARE nPeriodo		INTEGER DEFAULT 0;
    DECLARE dNowAjustada	DATE;

	SET prm_nPeriodo = prm_nPeriodo + 1;
    SET dNowAjustada = fnNowTest() + INTERVAL ( prm_nPeriodo - 1 ) MONTH;

   	SET nDia = DAY( prm_dIniVig );
	-- Ajusta la fecha actual al mismo dìa del mes
	SET dFin = fnNowTest() - INTERVAL (DAY(fnNowTest()) - nDia) DAY;
-- SELECT 1.0, dFin, nDia, nPeriodo;
    
    IF nDia >= DAY(fnNowTest()) THEN
		SET nPeriodo = -1;
    END IF;
	-- Lleva al periodo deseado
	SET dFin = DATE_ADD(dFin, INTERVAL ( prm_nPeriodo + nPeriodo ) MONTH );
-- SELECT 1.1, dFin, nDia, nPeriodo;
    IF dFin BETWEEN DCORTE AND ( DCORTE + INTERVAL DIAS_PREV DAY ) THEN
		SET dFin = DCORTE;
	ELSEIF dFin > ( DCORTE + INTERVAL DIAS_PREV DAY ) THEN
		SET dFin = dFin + INTERVAL -DIAS_PREV DAY;
        SET nPeriodo = 0;
        WHILE dFin < dNowAjustada DO
-- SELECT 3.0, nPeriodo, dFin, dNowAjustada ;
			SET dFin = fnNowTest() - INTERVAL (DAY(fnNowTest()) - DAY( prm_dIniVig )) DAY;
-- SELECT 3.1, dFin, dNowAjustada ;
			SET dFin = dFin + INTERVAL ( prm_nPeriodo + nPeriodo ) MONTH;
-- SELECT 3.2, dFin;
			SET dFin = dFin + INTERVAL -DIAS_PREV DAY;
-- SELECT 3.3, dFin;
			SET nPeriodo = nPeriodo + 1;
        END WHILE;        
	END IF;

SELECT 6, prm_dIniVig, prm_nPeriodo, nPeriodo, fnNowTest(), dNowAjustada, dFin, nDia;    

END //


DELIMITER //
DROP FUNCTION IF EXISTS fnFechaCierreIni //
CREATE FUNCTION fnFechaCierreIni(prm_dIni DATE, prm_nPeriodo INTEGER) RETURNS DATE
BEGIN
	DECLARE dIni		DATE DEFAULT prm_dIni;
	DECLARE dFin		DATE;

	CALL prFechasCierre( dIni, dFin, prm_nPeriodo );    
	RETURN dIni;
END //

DROP FUNCTION IF EXISTS fnFechaCierreFin //
CREATE FUNCTION fnFechaCierreFin(prm_dIni DATE, prm_nPeriodo INTEGER) RETURNS DATE
BEGIN
	DECLARE dIni		DATE DEFAULT prm_dIni;
	DECLARE dFin		DATE;

	CALL prFechasCierre( dIni, dFin, prm_nPeriodo );    
	RETURN dFin;
END //

DROP PROCEDURE IF EXISTS prFechasCierre //
CREATE PROCEDURE prFechasCierre(INOUT prm_dIni DATE, OUT prm_dFin DATE, prm_nPeriodo INTEGER) 
BEGIN
	IF prm_nPeriodo = -1 THEN
		BEGIN
			-- Determina si es hay periodo perdido en la fecha límite y lo ajusta
            -- No interesa por ahora el -2
			DECLARE dIni0 DATE DEFAULT prm_dIni;
			DECLARE dFin0 DATE;
			CALL prFechasCierreOriginal( dIni0, dFin0, 0 );
			CALL prFechasCierreOriginal( prm_dIni, prm_dFin, -1 );
            IF prm_dFin < dIni0 THEN
				SET prm_dIni = prm_dFin;
                SET prm_dFin = dIni0;
            END IF;
		END;
	ELSE 
		CALL zprFechasCierreOriginal( prm_dIni, prm_dFin, prm_nPeriodo );
    END IF;
END //

DROP PROCEDURE IF EXISTS prFechaCierreOriginal //
CREATE PROCEDURE prFechasCierreOriginal(INOUT prm_dIni DATE, OUT prm_dFin DATE, prm_nPeriodo INTEGER)
BEGIN
	DECLARE nAvance		INTEGER DEFAULT 1;
	DECLARE dIni		DATE;
	DECLARE dFin		DATE;
    DECLARE dNowAjustada DATE DEFAULT fnNow() + INTERVAL prm_nPeriodo MONTH;
    
    SET dIni = prm_dIni;
	call prFechaCierreSub( dIni, prm_nPeriodo - 1 );
    SET dFin = prm_dIni;
	call prFechaCierreSub( dFin, prm_nPeriodo );
    WHILE dIni > dNowAjustada OR dNowAjustada > ( dFin - INTERVAL 1 DAY ) DO
		-- SELECT 'AVANZAR', dIni, dNowAjustada, dFin;
		SET dIni = dFin;
		SET dFin = prm_dIni;
		call prFechaCierreSub( dFin, prm_nPeriodo + nAvance );
        SET nAvance = nAvance + 1;
	END WHILE;
    
-- SELECT 6, prm_dIni, prm_nPeriodo, dNowAjustada, dIni, dFin, CASE WHEN dIni <= dNowAjustada AND dNowAjustada < dFin THEN 'OK' ELSE 'ERROR' END as TEST;

    SET prm_dIni = dIni;
    SET prm_dFin = dFin;

END //

DROP PROCEDURE IF EXISTS prFechaCierreSub //
CREATE PROCEDURE prFechaCierreSub( INOUT prm_dIni DATE, IN prm_nPeriodo INTEGER) 
BEGIN
	DECLARE DCORTE			DATE	DEFAULT '2018-01-17';
    DECLARE DIAS_PREV		INTEGER DEFAULT 7;
	DECLARE nDia			INTEGER;
    DECLARE dNowAjustada	DATE	DEFAULT fnNow() + INTERVAL prm_nPeriodo MONTH;
	DECLARE dIniPrev		DATE;
	DECLARE dIni			DATE;
    
    -- Ultimo día mes fecha ajustada
   	SET nDia = DAY( prm_dIni );
    
    -- Calcula Fecha Inicio
	-- Ajusta la fecha actual al mismo dìa del mes y ya le resta los 7 días
	SET dIniPrev = fnNow() - INTERVAL (DAY(fnNow()) - nDia) DAY;
	SET dIniPrev = dIniPrev + INTERVAL prm_nPeriodo MONTH;
    IF dIniPrev > LAST_DAY(dNowAjustada) THEN
		SET dIniPrev = LAST_DAY(dNowAjustada);
    END IF;

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
	SET prm_dIni = dIni;

END //


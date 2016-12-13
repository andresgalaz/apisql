DROP PROCEDURE IF EXISTS prResetScoreMes;
DELIMITER //
CREATE PROCEDURE prResetScoreMes ()
BEGIN
    -- Inicializa la tabla tScoreMes
    DECLARE vdPeriodo    date;
    DECLARE vdPeriodoAnt date;
    DECLARE vnCount      integer DEFAULT 0;
    DECLARE vfVehiculo   integer;
    DECLARE cStmt        varchar(500);
	DECLARE eofCur       integer DEFAULT 0;
	DECLARE Cur CURSOR FOR
        SELECT DISTINCT CONCAT(SUBSTR( t.dFecha,1,8),'01'), t.fVehiculo
        FROM   tScoreDia t
        ORDER BY 1, 2;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
    
    -- Limpia tabla
    DELETE FROM tScoreMes;
    
    SET @SQL := CONCAT( 'ALTER TABLE tScoreMes AUTO_INCREMENT=1');
    PREPARE cStmt FROM @SQL;
    EXECUTE cStmt;
    DEALLOCATE PREPARE cStmt;
    
	OPEN  Cur;
	FETCH Cur INTO vdPeriodo, vfVehiculo;
    SET vdPeriodoAnt = vdPeriodo;
	WHILE NOT eofCur DO
        IF vdPeriodo <> vdPeriodoAnt THEN
            SELECT vdPeriodoAnt periodo, vnCount cantidad;
            SET vdPeriodoAnt = vdPeriodo;
            SET vnCount = 0;
        END IF;
        SET vnCount = vnCount + 1;
        CALL prCalculaScoreMes( vdPeriodo, vfVehiculo );
    	FETCH Cur INTO vdPeriodo, vfVehiculo;    
    END WHILE;
    SELECT vdPeriodoAnt periodo, vnCount cantidad;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS prResetScoreMesConductor;
DELIMITER //
CREATE PROCEDURE prResetScoreMesConductor ()
BEGIN
    -- Inicializa la tabla tScoreMes
    DECLARE vdPeriodo    date;
    DECLARE vdPeriodoAnt date;
    DECLARE vnCount      integer DEFAULT 0;
    DECLARE vfVehiculo   integer;
    DECLARE vfUsuario    integer;
    DECLARE cStmt        varchar(500);
	DECLARE eofCur       integer DEFAULT 0;
	DECLARE Cur CURSOR FOR
        SELECT DISTINCT CONCAT(SUBSTR( t.dFecha,1,8),'01'), t.fVehiculo, t.fUsuario
        FROM   tScoreDia t
        ORDER BY 1, 2, 3;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
    
    -- Limpia tabla
    DELETE FROM tScoreMesConductor;
    
    SET @SQL := CONCAT( 'ALTER TABLE tScoreMesConductor AUTO_INCREMENT=1');
    PREPARE cStmt FROM @SQL;
    EXECUTE cStmt;
    DEALLOCATE PREPARE cStmt;
    
	OPEN  Cur;
	FETCH Cur INTO vdPeriodo, vfVehiculo, vfUsuario;
    SET vdPeriodoAnt = vdPeriodo;
	WHILE NOT eofCur DO
        IF vdPeriodo <> vdPeriodoAnt THEN
            SELECT vdPeriodoAnt periodo, vnCount cantidad;
            SET vdPeriodoAnt = vdPeriodo;
            SET vnCount = 0;
        END IF;
        SET vnCount = vnCount + 1;
        CALL prCalculaScoreMesConductor( vdPeriodo, vfVehiculo, vfUsuario );
    	FETCH Cur INTO vdPeriodo, vfVehiculo, vfUsuario;    
    END WHILE;
    SELECT vdPeriodoAnt periodo, vnCount cantidad;
END //
DELIMITER ;

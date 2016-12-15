DROP TRIGGER IF EXISTS trgUsuarioVehiculoIns;
DELIMITER //
CREATE TRIGGER trgUsuarioVehiculoIns
	AFTER INSERT
    ON tUsuarioVehiculo
	FOR EACH ROW
BEGIN
    call prCalculaScoreDia( date(now()), NEW.pVehiculo, NEW.pUsuario );
    call prCalculaScoreMes( date(now()), NEW.pVehiculo  );
    call prCalculaScoreMesConductor( date(now(), NEW.pVehiculo, NEW.pUsuario );
END //
DELIMITER ;

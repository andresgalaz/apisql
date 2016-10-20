DROP TRIGGER IF EXISTS trgUsuarioVehiculoDel;
DELIMITER //
CREATE TRIGGER trgUsuarioVehiculoDel BEFORE DELETE
    ON tUsuarioVehiculo FOR EACH ROW
BEGIN
    INSERT INTO tUsuarioVehiculoHist (pUsuario, pVehiculo, fUsuarioTitular, tActiva )
    VALUES ( OLD.pUsuario, OLD.pVehiculo, OLD.fUsuarioTitular, OLD.tActiva );    
END //
DELIMITER ;

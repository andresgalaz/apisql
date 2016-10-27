DROP TRIGGER IF EXISTS trgInvitacionVehiculoIns;
DELIMITER //
CREATE TRIGGER trgInvitacionVehiculoIns AFTER INSERT
    ON tInvitacionVehiculo FOR EACH ROW
BEGIN
	INSERT INTO tUsuarioVehiculo ( pUsuario, pVehiculo, fUsuarioTitular )
	SELECT u.pUsuario, NEW.pVehiculo, c.fUsuarioTitular
	  FROM tInvitacion i
           INNER JOIN tCuenta  c ON c.pCuenta   = i.fCuenta
           INNER JOIN tUsuario u ON u.cEmail    = i.cEmailInvitado
	 WHERE i.pInvitacion = NEW.pInvitacion
       AND NOT EXISTS ( SELECT '1'
                          FROM tUsuarioVehiculo uv
                         WHERE uv.pUsuario  = u.pUsuario
                           AND uv.pVehiculo = NEW.pVehiculo
                      );
END //
DELIMITER ;

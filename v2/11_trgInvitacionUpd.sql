DELIMITER //
DROP TRIGGER if exists trgInvitacionUpd //
CREATE TRIGGER trgInvitacionUpd AFTER UPDATE
    ON tInvitacion FOR EACH ROW
BEGIN
	IF NEW.bRecibido = '1' THEN
		IF NOT EXISTS( SELECT pUsuario FROM tUsuario WHERE cEmail = NEW.cEmailInvitado ) then
			INSERT INTO tUsuario (cEmail, cPassword, cNombre, cSexo ) VALUES (NEW.cEmailInvitado, '.', '.', 'M');
		END IF;            
		INSERT INTO tUsuarioVehiculo ( pUsuario, pVehiculo, fUsuarioTitular )
		SELECT	u.pUsuario, iv.pVehiculo, c.fUsuarioTitular
		FROM	tInvitacionVehiculo iv,
				tCuenta  c ,
				tUsuario u 
		WHERE	iv.pInvitacion	= NEW.pInvitacion
		AND		c.pCuenta		= NEW.fCuenta
		AND		u.cEmail		= NEW.cEmailInvitado
		AND NOT EXISTS 	(	
							SELECT	'1'
							FROM	tUsuarioVehiculo uv
							WHERE	uv.pUsuario  = u.pUsuario
							AND		uv.pVehiculo = iv.pVehiculo
						);
	END IF;
END //


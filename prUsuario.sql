DELIMITER //
DROP PROCEDURE IF EXISTS prUsuario //
CREATE PROCEDURE prUsuario( IN prm_cEmail VARCHAR(200))
BEGIN
	/*
    Procedimiento ustilizado para la WEB de Asministración.
    Autor: AGalaz
    */
	SELECT	pUsuario, cEmail, cPassword, cNombre, nDni, dNacimiento, cSexo, bConfirmado
    FROM	tUsuario
    WHERE	cEmail = prm_cEmail;    
END //

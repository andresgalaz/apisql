DELIMITER //
DROP PROCEDURE IF EXISTS prLoginInstalador //
CREATE PROCEDURE prLoginInstalador( IN prm_cEmail VARCHAR(200), IN prm_cPerfil VARCHAR(20))
BEGIN
	SELECT	pUsuario, cEmail, cPassword, cNombre, nDni, dNacimiento, cSexo, bConfirmado,fnUsuarioPerfil(cEmail, prm_cPerfil) as bPermiso
    FROM	tUsuario
    WHERE	cEmail = prm_cEmail;

	SELECT	*
	FROM	vVehiculoLast
    WHERE	fUsuario IN ( SELECT pUsuario FROM tUsuario WHERE cEmail = prm_cEmail );
    
END //

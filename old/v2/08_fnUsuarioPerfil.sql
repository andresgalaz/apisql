DELIMITER //
USE score //
DROP FUNCTION IF EXISTS fnUsuarioPerfil //
CREATE FUNCTION fnUsuarioPerfil( prm_cEmail VARCHAR(200) CHARSET utf8, prm_cPerfil VARCHAR(100) CHARSET utf8) RETURNS BOOLEAN
BEGIN
	DECLARE nCount INTEGER DEFAULT 0;
    
    IF ifnull(prm_cPerfil,'*') = '*' THEN
		SELECT	count(*) INTO nCount
		FROM	tUsuario u
		WHERE	u.bVigente		= '1'
		AND		u.cEmail		= prm_cEmail;
    ELSE
		SELECT	count(*) INTO nCount
		FROM	tUsuario u
				INNER JOIN tUsuarioPerfil	AS up	ON up.pUsuario = u.pUsuario
				INNER JOIN tPerfil			AS p	ON p.pPerfil = up.pPerfil
		WHERE	u.bVigente		= '1'
		AND		u.cEmail		= prm_cEmail
		AND		p.cDescripcion	= prm_cPerfil;
	END IF;
    
    RETURN nCount > 0;
    
END //

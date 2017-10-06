DELIMITER //
DROP PROCEDURE IF EXISTS prNotifica //
CREATE PROCEDURE prNotifica ()
BEGIN

	-- Verifica desde los movimientos de Integrity
    -- ===========================================
    -- 1. Nuevos Usuarios
    -- Cursor de Movimientos en los cuales solo interesa los que tienen Nº de Póliza
	BEGIN
		DECLARE eofCurMovim			INTEGER DEFAULT 0;
		DECLARE vpMovim				INTEGER;
		DECLARE vcPatente			VARCHAR(40);
		DECLARE vcPoliza			VARCHAR(40);
		DECLARE vdIniVigencia		DATE;
		DECLARE vcNombre			VARCHAR(140);
		DECLARE vcTpDoc				VARCHAR(40);
		DECLARE vcDocumento			VARCHAR(40);
		DECLARE vcEmail				VARCHAR(140);
		DECLARE vdNacimiento		DATE;
        
        DECLARE vpUsuario			INTEGER;
        DECLARE vfMovimCreacion		INTEGER;
        
		DECLARE curMovim CURSOR FOR
			SELECT	m.pMovim										,
					m.NRO_PATENTE					as cPatente		,
					m.poliza						as cPoliza		,
					m.FECHA_INICIO_VIG				as dIniVigencia	,
                    concat( m.NOMBRE, m.APELLIDO )	as cNombre		,
                    m.TIPO_DOC						as cTpDoc		,
                    m.DOCUMENTO						as cDocumento	,
                    m.MAIL							as cEmail		,
                    m.FECHA_NACIMIENTO				as dNacimiento
			FROM	integrity.tMovim m 
			WHERE 	m.POLIZA IS NOT NULL
            AND		m.NRO_PATENTE	<> 'A/D'
            AND		m.COD_ENDOSO	= '00000'
			ORDER BY m.NRO_PATENTE, m.tModif;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurMovim = 1;

		OPEN curMovim;
		FETCH curMovim INTO	vpMovim				, vcPatente			, vcPoliza			,
							vdIniVigencia		, vcNombre			, vcTpDoc			,
                            vcDocumento			, vcEmail			, vdNacimiento;
		WHILE NOT eofCurMovim DO
			IF NOT EXISTS( SELECT '1' FROM score.tVehiculo WHERE cPatente = vcPatente ) THEN
				-- Vehículo no existe
                -- 1. Busca si existe un usuario con ese MAIL
                SELECT u.pUsuario INTO vpUsuario FROM tUsuario u WHERE u.cEmail = vcEmail;
                IF vpUsuario IS NULL THEN
					-- SI el usuario no existe se crea
                END IF;
                -- 1. Se crea tCuenta (tabla Deprecated)
                INSERT INTO tCuenta ( fUsuarioTitular ) values ( vpUsuario );
                -- 1: Se verifica si el MAIL informado del usuario existe
                
            END IF;
			SELECT	u.pMovim	, u.fMovimCreacion
            INTO	vpUsuario	, vfMovimCreacion
            FROM	score.tUsuario u
            WHERE	u.cEmail = vcEmail;
			IF NOT EXISTS( SELECT '1' FROM score.tUsuario WHERE cEmail = vcEmail ) THEN
				SELECT 'No existe', vcEmail;
            END IF;
			FETCH curMovim INTO	vpMovim				, vcPatente			, vcPoliza			,
								vdIniVigencia		, vcNombre			, vcTpDoc			,
								vcDocumento			, vcEmail			, vdNacimiento;
		END WHILE;
		CLOSE curMovim;
	END;    
END //

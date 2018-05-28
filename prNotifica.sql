DELIMITER //
DROP PROCEDURE IF EXISTS prNotifica //
CREATE PROCEDURE prNotifica ()
BEGIN
    -- Autor: Andrés Galaz
    --
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
		DECLARE vdEmision			DATE;
		DECLARE vcNombre			VARCHAR(140);
		DECLARE vcTpDoc				VARCHAR(40);
		DECLARE vcDocumento			VARCHAR(40);
		DECLARE vcEmail				VARCHAR(140);
		DECLARE vcMarca				VARCHAR(100);
		DECLARE vcModelo			VARCHAR(100);
        DECLARE vcTpEndoso			VARCHAR(20);
		DECLARE vdNacimiento		DATE;
        DECLARE vnDNI				BIGINT;
        
		DECLARE vcPatenteAnt		VARCHAR(40);
		DECLARE vcPolizaAnt			VARCHAR(40);

		DECLARE curMovim CURSOR FOR
			SELECT	m.pMovim											,
					m.NRO_PATENTE						AS cPatente		,
					m.poliza							AS cPoliza		,
					m.FECHA_INICIO_VIG					AS dIniVigencia	,
                    m.FECHA_EMISION						AS dEmision		,
                    CONCAT( m.NOMBRE, ' ', m.APELLIDO )	AS cNombre		,
                    m.TIPO_DOC							AS cTpDoc		,
                    m.DOCUMENTO							AS cDocumento	,
                    m.MAIL								AS cEmail		,
                    m.FECHA_NACIMIENTO					AS dNacimiento	,
					m.COD_MARCA							AS cMarca		,
					m.COD_MODELO						AS cModelo		,
                    IFNULL(m.COD_ENDOSO, '0000')		AS cTpEndoso
			FROM	integrity.tMovim m 
			WHERE 	m.MAIL IS NOT NULL
            AND		m.NRO_PATENTE <> 'A/D'
			AND		m.COD_TIPO_ESTADO in ( '04', '07' ) -- En Inspección y Póliza
      --    AND		m.POLIZA IS NOT NULL
      --    AND		m.ENDOSO	= '00000'
			ORDER BY m.NRO_PATENTE, m.pMovim DESC;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurMovim = 1;

		OPEN curMovim;
		FETCH curMovim INTO	vpMovim			, vcPatente		, vcPoliza	,
							vdIniVigencia	, vdEmision		, vcNombre	,
                            vcTpDoc			, vcDocumento	, vcEmail	,
                            vdNacimiento	, vcMarca		, vcModelo	,
                            vcTpEndoso		;
		WHILE NOT eofCurMovim DO        
			/*
				Anulación Total
				0053	0052	0917	1205	1486
				3528	3545	3546	9592	9593
				1571	5423

				Anulación por Saldo
				1235	0871	1407	1445	3520
				3536	3537	5425

				Anulación Parcial a Prorrata
				0952	1367	0443	0339	0470
				0365	1483	3322	3728	3741
				3725	9594	0377
			*/
            IF vcTpEndoso IN ( '0053','0052','0917','1205','1486','3528','3545','3546','9592','9593','1571','5423',
							   '1235','0871','1407','1445','3520','3536','3537','5425',
							   '0952','1367','0443','0339','0470','0365','1483','3322','3728','3741','3725','9594','0377' ) THEN
				/*
					AGALAZ 08/05/2018
                    Se deja de anular el auto cuando hay anulaciones de Pólizas, solo de borrar el Nº de Póliza
                    relacionado al vehículo, de esta manera no se le factura ni se le envían correos ni notificaciones.
                */
				-- UPDATE	score.tVehiculo 
                -- SET		tBaja = vdEmision
				-- 	  , bVigente = '0'
                -- WHERE	cPatente = vcPatente
                -- AND		cPoliza = vcPoliza
                -- AND 	tBaja = '0000-00-00 00:00:00';
				UPDATE	score.tVehiculo 
                SET		cPoliza = null
                WHERE	cPatente = vcPatente
                AND		cPoliza = vcPoliza;
                
			ELSE
				-- Limpia email
				SET vcEmail = REPLACE( vcEmail, ';', '' );
				call prNotificaCursor( vpMovim		, vcPatente	, vcPoliza		,
									   vdIniVigencia, vcNombre	, vcTpDoc		,
									   vcDocumento	, vcEmail	, vdNacimiento	,
									   vcMarca		, vcModelo	);
			END IF;
			-- Solo el primer registro de cada Patente
            SET eofCurMovim  = 0;
			SET vcPatenteAnt = vcPatente;
			SET vcPolizaAnt = IFNULL(vcPoliza,'NO_POLIZA');
			WHILE NOT eofCurMovim AND vcPatenteAnt = vcPatente  AND vcPolizaAnt = IFNULL(vcPoliza,'NO_POLIZA') DO
				FETCH curMovim INTO	vpMovim			, vcPatente		, vcPoliza	,
									vdIniVigencia	, vdEmision		, vcNombre	,
									vcTpDoc			, vcDocumento	, vcEmail	,
									vdNacimiento	, vcMarca		, vcModelo	,
									vcTpEndoso		;
			END WHILE;
		END WHILE;
		CLOSE curMovim;
	END;    
END //

DROP PROCEDURE IF EXISTS prNotificaCursor //
CREATE PROCEDURE prNotificaCursor ( IN vpMovim			INTEGER		, IN vcPatente	VARCHAR( 40), IN vcPoliza		VARCHAR(40)
								  , IN vdIniVigencia	DATE		, IN vcNombre	VARCHAR(140), IN vcTpDoc		VARCHAR(40)
								  , IN vcDocumento		VARCHAR( 40), IN vcEmail	VARCHAR(140), IN vdNacimiento	DATE
								  , IN vcMarca			VARCHAR(100), IN vcModelo	VARCHAR(100))
BEGIN
	DECLARE vnDNI				BIGINT;       
	DECLARE vpUsuario			INTEGER;
	DECLARE vpCuenta			INTEGER;
	DECLARE vfMovimCreacion		INTEGER;
	DECLARE vcMensaje			TEXT;
	DECLARE bCreaVehiculo		BOOLEAN;
	DECLARE CONTINUE HANDLER FOR NOT FOUND BEGIN END; -- SET eofCurMovimX = 1;
    
-- DEBUG
/*
SELECT vpMovim		, vcPatente	, vcPoliza		,
	   vdIniVigencia, vcNombre	, vcTpDoc		,
	   vcDocumento	, vcEmail	, vdNacimiento	,
	   vcMarca		, vcModelo	;
*/       
	-- Vehículo existe
	SET bCreaVehiculo = FALSE;
	IF EXISTS( SELECT '1' FROM score.tVehiculo WHERE cPatente = vcPatente ) THEN
		-- Vehículo existe pero está dado de baja
		IF NOT EXISTS (SELECT '1' FROM score.tVehiculo v WHERE v.cPatente = vcPatente AND v.tBaja = '0000-00-00 00:00:00' ) THEN
			-- La póliza ya está asociada al vehículo
			SET bCreaVehiculo = TRUE;
		END IF;
	ELSE
		SET bCreaVehiculo = TRUE;
	END IF;
    
-- DEBUG
-- SELECT vcPatente, vcEmail, bCreaVehiculo;

	IF bCreaVehiculo THEN
		-- 1. Busca si existe un usuario con ese MAIL
		SELECT u.pUsuario INTO vpUsuario FROM tUsuario u WHERE u.cEmail = vcEmail;
		IF vpUsuario IS NULL THEN
			-- Si el usuario no existe se crea
			INSERT INTO tUsuario
					( cEmail		, cPassword		, cNombre		, nDNI
					, dNacimiento	, bConfirmado	, fMovimCreacion)
			VALUES	( vcEmail		, 'none'		, vcNombre		, cast(vcDocumento as unsigned)
					, vdNacimiento	, '0'			, vpMovim		);
			SET vpUsuario = LAST_INSERT_ID();
			-- 2. Se crea tCuenta (tabla Deprecated)
			INSERT INTO tCuenta ( fUsuarioTitular ) values ( vpUsuario );
			SET vpCuenta = LAST_INSERT_ID();
			-- 3. Crea notificación: Mail de creación usuario
			-- cMensaje contine un JSON con email y nombre
			SET vcMensaje = CONCAT(' "email":' ,'"', vcEmail, '"' );
			SET vcMensaje = CONCAT(vcMensaje, ', "id":' , vpUsuario );
			SET vcMensaje = CONCAT(vcMensaje, ', "nombre":' ,'"', vcNombre, '"' );
			INSERT INTO tNotificacion ( cMensaje, fTpNotificacion )
			VALUE (CONCAT('{', vcMensaje ,'}'), 1);
		ELSE
			SELECT	max(pCuenta) INTO	vpCuenta
			FROM	tCuenta WHERE	fUsuarioTitular = vpUsuario;
		END IF;
		-- 4. Se crea registro vehículo
		INSERT INTO tVehiculo
				( cPatente			, cMarca			, cModelo			, bVigente			
				, fCuenta			, fUsuarioTitular	, dIniVigencia
                , cPoliza			, fMovimCreacion	)
		VALUE	( vcPatente			, vcMarca			, vcModelo			, '1'
				, vpCuenta			, vpUsuario			, vdIniVigencia
                , vcPoliza			, vpMovim			);
	ELSE
		BEGIN
			DECLARE vcPolizaActual	VARCHAR(40);
			DECLARE vpVehiculo		INTEGER;
			-- Busca PK vehículo, no debe estar dado de BAJA                                
			SELECT	v.pVehiculo	, v.cPoliza
			INTO 	vpVehiculo	, vcPolizaActual
			FROM	score.tVehiculo v
			WHERE	v.cPatente	= vcPatente
			AND		v.bVigente	= '1';
            
			IF vpVehiculo IS NOT NULL AND vcPolizaActual IS NULL THEN
				UPDATE	tVehiculo
				SET		cPoliza			= vcPoliza
					,	fMovimCreacion	= vpMovim
                    ,	dIniVigencia	= vdIniVigencia
				WHERE	pVehiculo		= vpVehiculo;
			END IF;
		END;
	END IF;
END //


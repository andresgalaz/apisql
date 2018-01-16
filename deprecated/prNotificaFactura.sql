DELIMITER //
DROP PROCEDURE IF EXISTS prNotificaFactura //
CREATE PROCEDURE prNotificaFactura ()
BEGIN
	DECLARE vpVehiculo			INTEGER;
	DECLARE vdPeriodo			DATE;
	DECLARE nDiasUltCicloFact	SMALLINT;
    
	DECLARE vcMensaje			TEXT	DEFAULT '';
	DECLARE eofCur				INTEGER DEFAULT 0;
	DECLARE cur CURSOR FOR
		SELECT	v.pVehiculo
			  , fnPeriodo(fnFechaCierreIni( v.dIniVigencia, -1 ))		dPeriodo
			  , datediff(now(),fnFechaCierreFin( v.dIniVigencia, -1 ))	nDiasUltCicloFact
		FROM	tVehiculo v
		WHERE	v.cPoliza IS NOT NULL
        AND		v.bVigente = '1'
		ORDER BY 3;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCur = 1;
    
	-- Crea tabla temporal wMemoryCierreTransf
	CALL prControlCierreTransferenciaInicioDef(0);
	OPEN cur;    
	FETCH cur INTO vpVehiculo, vdPeriodo, nDiasUltCicloFact;
	WHILE NOT eofCur DO
		-- DEBUG    
		-- IF nDiasUltCicloFact = 2 THEN
		-- 	SELECT vpVehiculo, vdPeriodo, nDiasUltCicloFact;
		-- END IF;

		-- Se factura dos días después de vencido el periodo
		IF nDiasUltCicloFact = 2 THEN
            IF NOT EXISTS ( SELECT '1' FROM tFactura f WHERE f.pVehiculo = vpVehiculo and f.pPeriodo = vdPeriodo ) THEN
				-- Factura
				call prFacturador( vpVehiculo );
				IF LENGTH( vcMensaje ) > 0 THEN
					SET vcMensaje = CONCAT(vcMensaje, ',' );
				END IF;
                -- Factura real
				SET vcMensaje = CONCAT(vcMensaje, fnNotificaFacturaDet( vpVehiculo, vdPeriodo, 1 ) );
                -- Factura sin multa
                BEGIN
					DECLARE vcFactTp2 TEXT DEFAULT fnNotificaFacturaDet( vpVehiculo, vdPeriodo, 2 );
                    IF LENGTH( vcFactTp2 ) > 0 THEN
						SET vcMensaje = CONCAT(vcMensaje, ', ', vcFactTp2 );
					END IF;
                END;
            END IF;
		END IF;
        SET eofCur = 0;
		FETCH cur INTO vpVehiculo, vdPeriodo, nDiasUltCicloFact;
	END WHILE;
	CLOSE cur;

	IF LENGTH( vcMensaje ) > 0 THEN    
		INSERT INTO tNotificacion ( cMensaje, fTpNotificacion )
		VALUE (CONCAT('[ ', vcMensaje ,' ]'), 2);
    END IF;

END //

DROP FUNCTION IF EXISTS fnNotificaFacturaDet //
CREATE FUNCTION fnNotificaFacturaDet (vpVehiculo INTEGER, vdPeriodo DATE, vnTpFactura INTEGER ) RETURNS TEXT
BEGIN
	/* Autor: Andrés Galaz 
	   Proposito: Arma la información de la factura para posteriormente incluir en la notificación enviada por mail 
       Fecha: 25/10/2017
	*/
 	DECLARE vcTpCalculo			VARCHAR( 30);
	DECLARE vcPatente			VARCHAR( 40);
	DECLARE vcPoliza			VARCHAR( 40);
	DECLARE vdIniVigencia		DATE;
	DECLARE vdInstalacion		DATE;
	DECLARE vcEmail				VARCHAR(200);
	DECLARE vpUsuario			INTEGER;
	DECLARE vcNombre			VARCHAR(140);
	DECLARE vdInicio			DATE;
	DECLARE vdFin				DATE;
	DECLARE vnKms				DECIMAL(10,2);
	DECLARE vnKmsPond			DECIMAL(10,2);
	DECLARE vnScore				DECIMAL(10,2);
	DECLARE vnDescuentoKM		DECIMAL( 5,2);
	DECLARE vnDescuentoSinUso	DECIMAL( 5,2);
	DECLARE vnDescuentoPunta	DECIMAL( 5,2);
    DECLARE vnDescSinPonderar	DECIMAL( 5,2);
	DECLARE vnDescuento			DECIMAL( 5,2);
	DECLARE vnQViajes			INTEGER;
	DECLARE vnQFrenada			INTEGER;
	DECLARE vnQAceleracion		INTEGER;
	DECLARE vnQVelocidad		INTEGER;
	DECLARE vnQCurva			INTEGER;
	DECLARE vnDiasTotal			INTEGER;
	DECLARE vnDiasUso			INTEGER;
	DECLARE vnDiasPunta			INTEGER;
	DECLARE vnDiasSinMedicion	INTEGER;
	DECLARE vtUltimoViaje		DATETIME;
	DECLARE vtUltimaSincro		DATETIME;
	DECLARE vtFacturacion		DATETIME;
    -- Variable de salida
	DECLARE vcMensaje			TEXT	DEFAULT '';
    
	SELECT v.cPatente, v.cPoliza, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre
		 , t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore, t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
		 , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
		 , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva
		 , t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
	INTO   vcPatente, vcPoliza, vdIniVigencia, vdInstalacion, vcEmail, vpUsuario, vcNombre
		 , vdInicio , vdFin, vnKms,  vnKmsPond, vnScore, vnDescuentoKM , vnDescuentoSinUso, vnDescuentoPunta
		 , vnDescSinPonderar, vnDescuento
		 , vnQViajes, vnQFrenada, vnQAceleracion, vnQVelocidad, vnQCurva
		 , vnDiasTotal, vnDiasUso, vnDiasPunta, vnDiasSinMedicion, vtUltimoViaje, vtUltimaSincro, vtFacturacion                
	FROM tVehiculo v
		JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular
		LEFT JOIN tFactura t  ON t.pVehiculo  = v.pVehiculo
							 AND t.pPeriodo   = vdPeriodo
							 AND t.pTpFactura = vnTpFactura        
	WHERE t.pVehiculo = vpVehiculo ;
    
    IF vnTpFactura = 1 THEN
		SET vcTpCalculo = 'Real';
		IF vdInicio IS NULL THEN
			SET vcMensaje = fnJsonAdd( vcMensaje, 'error'		, 'No se pudo facturar' );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'idVehiculo'	, vpVehiculo );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'patente'		, vcPatente );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'poliza'		, vcPoliza );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'periodo'		, SUBSTR( vdPeriodo, 1, 7 ) );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'idUsuario'	, vpUsuario );
			SET vcMensaje = fnJsonAdd( vcMensaje, 'nombre'		, vcNombre );
-- 			RETURN CONCAT('{', vcMensaje ,'}' );
		END IF;
    ELSEIF vnTpFactura = 2 THEN
		SET vcTpCalculo = 'Sin multa';
    ELSE
		SET vcMensaje = fnJsonAdd( vcMensaje, 'error'		, 'Tipo cálculo desconocido' );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'idVehiculo'	, vpVehiculo );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'patente'		, vcPatente );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'poliza'		, vcPoliza );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'periodo'		, SUBSTR( vdPeriodo, 1, 7 ) );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'idUsuario'	, vpUsuario );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'nombre'		, vcNombre );
-- 		RETURN CONCAT('{', vcMensaje ,'}' );
    END IF;

	IF vdInicio IS NOT NULL THEN
		SET vcMensaje = fnJsonAdd( vcMensaje, 'tpCalculo'		, vcTpCalculo );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'idVehiculo'		, vpVehiculo );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'patente'			, vcPatente );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'poliza'			, vcPoliza );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'periodo'			, SUBSTR(vdPeriodo, 1, 7 ) );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'inicioVigencia'	, vdIniVigencia );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'fecInstalacion'	, vdInstalacion );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'email'			, vcEmail );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'idUsuario'		, vpUsuario );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'nombre'			, vcNombre );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'iniPeriodo'		, vdInicio );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'finPeriodo'		, vdFin );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'kms'				, vnKms );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'kmsPond'			, vnKmsPond );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'score'			, vnScore );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'descuentoKm'		, vnDescuentoKM );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'descuentoSinUso'	, vnDescuentoSinUso );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'descuentoPunta'	, vnDescuentoPunta );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'descuentoSinPond', vnDescSinPonderar );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'descuento'		, vnDescuento );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'qViajes'			, vnQViajes );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'qFrenadas'		, vnQFrenada );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'qAceleraciones'	, vnQAceleracion );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'qExcesosVel'		, vnQVelocidad );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'qCurvas'			, vnQCurva );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'diasTotal'		, vnDiasTotal );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'diasUso'			, vnDiasUso );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'diasPunta'		, vnDiasPunta );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'diasSinMedicion'	, vnDiasSinMedicion );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'ultViaje'		, vtUltimoViaje );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'ultSincro'		, vtUltimaSincro );
		SET vcMensaje = fnJsonAdd( vcMensaje, 'fecFacturacion'	, vtFacturacion );
		return CONCAT('{', vcMensaje ,'}' );
	ELSE
		return '';
    END IF;

END //


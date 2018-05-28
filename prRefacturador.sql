DELIMITER //
DROP PROCEDURE IF EXISTS prRefactura //
CREATE PROCEDURE prRefactura ( IN prm_pVehiculo INTEGER, IN prm_dPeriodo DATE, IN prm_nDiasSinMedicion INTEGER, IN prm_bBorraAceleraciones BOOLEAN, IN prm_cUsuario VARCHAR(40))
LB_PRINCIPAL:BEGIN
	DECLARE vpPeriodo					DATE;
	DECLARE vdInicio						DATE;
    DECLARE vfUsuario					INTEGER;
    DECLARE vnDiasSinMedicion	INTEGER;
    
-- DEBUG : Parametros de entrada    
-- SELECT  prm_pVehiculo, prm_dPeriodo, prm_nDiasSinMedicion, prm_bBorraAceleraciones, prm_cUsuario;

	-- select concat('call prRecalculaScore(','\'',  fnFechaCierreIni(dIniVigencia, 0) - interval 1 day, '\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) -- , dIniVigencia
    --  from tVehiculo where cPatente in ('LQB799','AB844YD') and bVigente='1'; -- pVehiculo in (494);
	SELECT	fnFechaCierreIni(dIniVigencia, -1) day, fUsuarioTitular
    INTO		vdInicio, vfUsuario
	FROM		tVehiculo
    WHERE	pVehiculo = prm_pVehiculo;

    IF prm_bBorraAceleraciones THEN
		-- Borra aceleraciones
		UPDATE	snapcar.trip_observations_g
        SET			`status` = 'D'
		WHERE	prefix_observation = 'A'
		AND 		trip_id in (	SELECT t.id
											FROM	snapcar.clients c 
													JOIN snapcar.trips t ON t.client_id = c.id
											WHERE	c.vehicle_id = prm_pVehiculo
											AND		t.from_date >= vdInicio - INTERVAL 1 MONTH
										);		
		DELETE FROM tEvento
        WHERE	fTpEvento = 3 -- Aceleraciones
		AND		tEvento >= vdInicio - INTERVAL 1 MONTH
		AND		fVehiculo = prm_pVehiculo;

-- select 'Aceleraciones borradas';
    END IF;
    
 	SELECT	pPeriodo, nDiasSinMedicion
    INTO		vpPeriodo, vnDiasSinMedicion
    FROM		tFactura
    WHERE	pVehiculo	= prm_pVehiculo
    AND		dInicio			= vdInicio
    AND		pTpFactura	= 1
    ;
    
 	IF vpPeriodo IS NOT NULL THEN
		-- Existe una facturación la cual re-facturar
		IF vnDiasSinMedicion > prm_nDiasSinMedicion THEN
			INSERT INTO tFacturaSinMedicion
							( pVehiculo, pPeriodo, nDiasSinMedicion
							, nDifDias, cUsuario )
			VALUES	( prm_pVehiculo, vpPeriodo, prm_nDiasSinMedicion
							, prm_nDiasSinMedicion -  vnDiasSinMedicion, prm_cUsuario );
		ELSE
			SELECT 4010 nCodigo, 'No se puede aumentar la cantidad de días sin medición' cMensaje;
			LEAVE LB_PRINCIPAL;
         END IF;
    END IF;
    
	CALL prRecalculaScore( vdInicio, prm_pVehiculo, vfUsuario);
	CALL prFacturador( prm_pVehiculo );

-- select 'OK', vpPeriodo, vnDiasSinMedicion;

select v.cPatente patente, u.cNombre nombre, v.dIniVigencia inicioVigencia
	 , t.dInicio iniPeriodo, (t.dFin + INTERVAL -1 DAY ) finPeriodo
     , t.nDescuento descuento, t.nKms kms, t.nKmsPond kmsPond
     , t.nScore score
     , t.nQFrenada qFrenadas, t.nQAceleracion qAceleraciones, t.nQVelocidad qExcesosVel, t.nQCurva qCurvas
     , t.nQViajes qViajes, t.nDiasTotal diasTotal, t.nDiasUso diasUso, t.nDiasPunta diasPunta, t.nDiasSinMedicion diasSinMedicion
   , t.tCreacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 1 and v.dIniVigencia < t.dFin
and t.tCreacion >= now() + INTERVAL -10 SECOND
;

END //

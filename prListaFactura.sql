DELIMITER //
DROP PROCEDURE IF EXISTS prListaFactura //
CREATE PROCEDURE prListaFactura( IN prm_cPatente VARCHAR(20), IN prm_cNombre VARCHAR(80), IN prm_dIni DATE, IN prm_dFin DATE)
BEGIN

-- 	SET @likePatente=CONCAT('%', IFNULL( prm_cPatente, '' ),'%');
-- 	SET @likeNombre=CONCAT('%', IFNULL( prm_cNombre, '' ),'%');
    SET @dIni=IFNULL( prm_dIni, '2017-01-01') - INTERVAL 1 DAY;
    SET @dFin=IFNULL( prm_dFin, fnNow())      - INTERVAL 1 DAY;
    
-- VER MOVMIENTOS DESDE INTEGRITY
	SELECT 'Real' cTpCalculo, v.cPatente, substr(t.pPeriodo,1,7) pPeriodo, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
		 , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
		 , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
		 , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion tFacturacion
	FROM   tFactura t
		   JOIN tVehiculo v ON v.pVehiculo = t.pVehiculo
		   JOIN tUsuario  u ON u.pUsuario  = v.fUsuarioTitular
	WHERE	t.pTpFactura = 1 
    AND		v.dIniVigencia < t.dFin 
 	AND		t.dFin BETWEEN @dIni AND @dFin
    AND		v.cPatente	LIKE CONCAT('%', IFNULL( prm_cPatente, '' ),'%') -- @likePatente
    AND		u.cNombre	LIKE CONCAT('%', IFNULL( prm_cNombre, '' ),'%') -- @likeNombre
	UNION ALL
	SELECT 'Sin multa' cTpCalculo, v.cPatente, substr(t.pPeriodo,1,7) pPeriodo, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
		 , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
		 , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
		 , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion tFacturacion
	FROM   tFactura t
		   JOIN tVehiculo v ON v.pVehiculo = t.pVehiculo
		   JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular
	WHERE	t.pTpFactura = 2 
    AND		v.dIniVigencia < t.dFin 
 	AND		t.dFin BETWEEN @dIni AND @dFin
    AND		v.cPatente	LIKE CONCAT('%', IFNULL( prm_cPatente, '' ),'%') -- @likePatente
    AND		u.cNombre	LIKE CONCAT('%', IFNULL( prm_cNombre, '' ),'%') -- @likeNombre
	ORDER BY dIniVigencia, pPeriodo, cPatente, cTpCalculo ; 
	
END //

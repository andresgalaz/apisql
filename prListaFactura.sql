DELIMITER //
DROP PROCEDURE IF EXISTS prListaFactura //
CREATE PROCEDURE prListaFactura ()
BEGIN

	SELECT 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
		 , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
		 , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
		 , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
	FROM   tFactura t
		   JOIN tVehiculo v ON v.pVehiculo = t.pVehiculo
		   JOIN tUsuario  u ON u.pUsuario  = v.fUsuarioTitular
	WHERE  t.pTpFactura = 1 
    AND    v.dIniVigencia < t.dFin 
	AND	   t.tCreacion >= NOW() + INTERVAL -1 DAY
	UNION ALL
	SELECT 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
		, t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
		 , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
		 , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
	FROM   tFactura t
		   JOIN tVehiculo v ON v.pVehiculo = t.pVehiculo
		   JOIN tUsuario  u ON u.pUsuario = v.fUsuarioTitular
	WHERE  t.pTpFactura = 2 
    AND    v.dIniVigencia < t.dFin 
	AND	   t.tCreacion >= NOW() + INTERVAL -1 DAY
	ORDER BY dIniVigencia, cPatente, cTpCalculo ; 
	
END //

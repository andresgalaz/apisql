drop table wMemoryScoreVehiculo;
drop table wMemoryScoreVehiculoSinMulta;
drop table wMemoryScoreVehiculoCount;
call prFacturador(null);
call prCreaTmpScoreVehiculo();call prCalculaScoreVehiculo(343,'2017-08-10','2017-09-10');
select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, w.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculo w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.dIniVigencia < w.dFin
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, w.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculoSinMulta w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.dIniVigencia < w.dFin
order by dIniVigencia, cPatente, cTpCalculo ; 

SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
		v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
		v.dIniVigencia			,
		score.fnPeriodoActual( v.dIniVigencia, -1 ) dIniCierre,
		score.fnPeriodoActual( v.dIniVigencia, 0 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.fTpDispositivo = 3
AND		v.cIdDispositivo is not null
AND		v.bVigente in ('1');


call prFacturador(392);
select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 1 and v.dIniVigencia < t.dFin and cPatente <> 'NMZ478'
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 2 and v.dIniVigencia < t.dFin
order by dIniVigencia, cPatente, cTpCalculo ; 

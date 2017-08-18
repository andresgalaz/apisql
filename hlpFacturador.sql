
drop table wMemoryScoreVehiculo;
drop table wMemoryScoreVehiculoCount;
call prFacturador(null);
select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculo w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculoSinMulta w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
order by 2,1; 

SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
		v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
		v.dIniVigencia			,
		score.fnPeriodoActual( v.dIniVigencia, -1 ) dIniCierre,
		score.fnPeriodoActual( v.dIniVigencia, 0 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.fTpDispositivo = 3
AND		v.cIdDispositivo is not null
AND		v.bVigente in ('1');

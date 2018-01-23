SELECT	v.pVehiculo, v.dIniVigencia
	  , score.fnFechaCierreIni( v.dIniVigencia, -1 ) dIniCierre
	  , score.fnFechaCierreFin( v.dIniVigencia, -1 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.cPoliza is not null
-- 08/01/2018: No cubría los casos que no instalaron
-- AND		v.fTpDispositivo = 3
-- AND		v.cIdDispositivo is not null
AND     v.bVigente in ('1')
AND		v.pVehiculo = 442 ;

drop table wMemoryScoreVehiculo;
drop table wMemoryScoreVehiculoSinMulta;
drop table wMemoryScoreVehiculoCount;
call prFacturador(null);
-- call prCreaTmpScoreVehiculo();call prCalculaScoreVehiculo(343,'2017-08-10','2017-09-10');
select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, w.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculo w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.dIniVigencia < w.dFin
and  v.cPoliza is not null
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, w.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, w.pVehiculo, w.dInicio, (w.dFin + INTERVAL -1 DAY ) dFin, w.nKms, w.nKmsPond, w.nScore
     , w.nDescuentoKM, w.nDescuentoSinUso, w.nDescuentoPunta
     , w.nDescuentoKM + w.nDescuentoSinUso + w.nDescuentoPunta as nDescSinPonderar, w.nDescuento
     , w.nQViajes, w.nQFrenada, w.nQAceleracion, w.nQVelocidad, w.nQCurva, w.nDiasTotal, w.nDiasUso, w.nDiasPunta, w.nDiasSinMedicion, w.tUltimoViaje, w.tUltimaSincro
from wMemoryScoreVehiculoSinMulta w
join tVehiculo v on v.pVehiculo = w.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.dIniVigencia < w.dFin
and  v.cPoliza is not null
order by dInicio, cPatente, cTpCalculo ; 

SELECT	v.pVehiculo				, v.cPatente				, v.cIdDispositivo			, v.bVigente				,
		v.fTpDispositivo		, v.fCuenta					, v.fUsuarioTitular			, v.tModif					,
		v.dIniVigencia			,
		score.fnFechaCierreIni( v.dIniVigencia, -1 ) dIniCierre,
		fnFechaCierreFin( v.dIniVigencia, -1 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.fTpDispositivo = 3
AND		v.cIdDispositivo is not null
AND		v.bVigente in ('1');


select pVehiculo, cPatente, cPoliza, dIniVigencia, dInstalacion, bVigente
     , cIdDispositivo
     , fnFechaCierreIni(dIniVigencia,-1) dIniCierre, fnFechaCierreFin(dIniVigencia,-1) dFinCierre
     , zfnFechaCierreIni(dIniVigencia,-1) dIniCierreZ, zfnFechaCierreFin(dIniVigencia,-1) dFinCierreZ, zfnNow()
from tVehiculo where cPatente in ( 'LQB799','NAG223','FAA680')
union 
select pVehiculo, cPatente, cPoliza, dIniVigencia, dInstalacion, bVigente
     , cIdDispositivo
     , fnFechaCierreIni(dIniVigencia,0) dIniCierre, fnFechaCierreFin(dIniVigencia,0) dFinCierre
     , zfnFechaCierreIni(dIniVigencia,0) dIniCierreZ, zfnFechaCierreFin(dIniVigencia,0) dFinCierreZ, zfnNow()
from tVehiculo where cPatente in ( 'LQB799','NAG223','FAA680')
order by cPatente, dIniCierre;

-- Paz dario (2 meses)	'MJK040'

select concat('call prFacturador(', pVehiculo, '); -- ', cPatente) 
from tVehiculo where cPatente in ( 'LQB799','NAG223','FAA680');

-- Lista Aceleraciones
select * from tEvento e where e.fVehiculo in (414)
and e.tEvento >= '2017-12-12' and e.tEvento < '2018-01-12'
and fTpEvento=3;

-- Borra Aceleraciones
delete from tEvento  where fVehiculo in (414)
and tEvento >= '2017-12-12' -- and tEvento < '2018-01-12'
and fTpEvento=3;

-- Genera proceso a recalcular
select concat('call prRecalculaScore(','\'2017-12-12\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) 
from tVehiculo where pVehiculo in (414);
-- Recalcula
call prRecalculaScore('2017-12-12',414,222); call prFacturador(414); -- NXL561

-- 2018-01
call prFacturador(505); -- FAA680
call prFacturador(392); -- LQB799
call prFacturador(394); -- NAG223



select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 1 and v.dIniVigencia < t.dFin -- and cPatente <> 'NMZ478'
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AB686YD'
-- and t.pVehiculo in ( 481)
and t.tCreacion >= now() + INTERVAL -3 MINUTE
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 2 and v.dIniVigencia < t.dFin
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AB686YD'
-- and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
and t.tCreacion >= now() + INTERVAL -3 MINUTE
order by dIniVigencia, cPatente, cTpCalculo, dInicio ; 



set @d='2017-10-24';set @f=null;call zprFechasCierre(@d,@f,-2);set @d='2017-10-24';call zprFechasCierre(@d,@f,-1);set @d='2017-10-24';call zprFechasCierre(@d,@f,0);set @d='2017-10-24';call zprFechasCierre(@d,@f,1);set @d='2017-10-24';call zprFechasCierre(@d,@f,2);

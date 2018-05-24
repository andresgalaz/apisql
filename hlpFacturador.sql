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

-- Lista Aceleraciones
select v.cPatente, u.cNombre, u.cEmail, e.* 
from tEvento e 
	 inner join tVehiculo v on v.pVehiculo = e.fVehiculo
     inner join tUsuario u on u.pUsuario = v.fUsuarioTitular
where v.cPatente in ('AA429CP','FAA680','JBH851','ONV367' )
-- and e.tEvento >= '2018-01-01' -- and e.tEvento < now()
and e.fTpEvento = 3
;

-- Borra Aceleraciones
delete from tEvento  where fVehiculo in (494)
and tEvento >= '2018-01-15' 
and fTpEvento=3;

-- Lista Fenadas
select * from tEvento e where e.nIdViaje = 103964
and fTpEvento<4
;
-- Borra Frenadas
delete from tEvento where e.nIdViaje = 103964
and fTpEvento=4;


-- Genera proceso a recalcular
select concat('call prRecalculaScore(','\'',  fnFechaCierreIni(dIniVigencia, -1) - interval 1 day, '\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) -- , dIniVigencia
from tVehiculo 
where cPatente in ('AB508RX')
and bVigente='1' -- pVehiculo=544 -- OR cPatente in ('KZI628') and bVigente='1'; -- pVehiculo in (494)
;

call prRecalculaScore('2018-04-14',552,401); call prFacturador(552); -- AA021MA

call prRecalculaScore('2018-04-15',514,350); call prFacturador(514); -- AC156IE
call prRecalculaScore('2018-04-06',550,397); call prFacturador(550); -- HQX926

call prRecalculaScore('2018-04-19',394,183); call prFacturador(394); -- NAG223
call prRecalculaScore('2018-04-19',534,365); call prFacturador(534); -- AB508RX

--
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
-- and t.dInicio = '2017-11-30'
-- AND v.cPatente in ( 'HQX926')
-- and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
-- and u.cEmail = 'gonzalopuebla@icloud.com'
and t.tCreacion >= now() + INTERVAL -5 hour
order by dIniVigencia, cPatente, dInicio
;
-- union all

select v.cPatente patente, u.cNombre nombre, v.dIniVigencia inicioVigencia
	 , t.dInicio iniPeriodo, (t.dFin + INTERVAL -1 DAY ) finPeriodo
     , t.nDescuento descuento, t.nKms kms, t.nKmsPond kmsPond
     , t.nScore score
     , t.nQFrenada qFrenadas, t.nQAceleracion qAceleraciones, t.nQVelocidad qExcesosVel, t.nQCurva qCurvas
     , t.nQViajes qViajes, t.nDiasTotal diasTotal, t.nDiasUso diasUso, t.nDiasPunta diasPunta, t.nDiasSinMedicion diasSinMedicion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 2 and v.dIniVigencia < t.dFin
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AA929DU'
-- and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
and u.cEmail = 'gonzalopuebla@icloud.com'
and t.tCreacion >= now() + INTERVAL -18 HOUR

order by inicioVigencia, patente, iniPeriodo
;

select * from tFactura t where t.pVehiculo = 532;
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
		score.fnPeriodoActual( v.dIniVigencia, -1 ) dIniCierre,
		score.fnPeriodoActual( v.dIniVigencia, 0 ) dFinCierre
FROM	score.tVehiculo v
WHERE	v.fTpDispositivo = 3
AND		v.cIdDispositivo is not null
AND		v.bVigente in ('1');


select pVehiculo, cPatente, dIniVigencia from tVehiculo where cPatente in ( 'KXZ633','AA929DU','KXZ633','MKZ002','FUZ056','LJL447');
-- Lista Aceleraciones
select * from tEvento e where e.fVehiculo in (402,422,404,482,421)
and e.tEvento >= '2017-12-01' and e.tEvento < '2018-01-01'
and fTpEvento=3;

select * from tEvento e where e.fVehiculo in (402,422,404,482,421)
and e.tEvento >= '2017-12-01' 
and fTpEvento=3
order by tEvento desc ;

	SELECT SUM( CASE ev.fTpEvento WHEN 3	THEN ev.nPuntaje	ELSE 0 END ) AS nAceleracion
		 , SUM( esHoraPunta( ev.tEvento ))	AS vnHoraPunta
		 , COUNT( * )						AS vnEventos
	FROM	vEvento ev
	WHERE	1=1 -- ev.fVehiculo	=	403
 AND		ev.fUsuario		=	179
	AND		ev.tEvento		>=	'2017-12-01'
-- AND		ev.tEvento		<	vdDiaSgte
;


-- Borra Aceleraciones
delete from tEvento  where fVehiculo in (403,101,426,393,491,423,432,504,85,416)
and tEvento >= '2017-11-30' and tEvento < '2018-01-01'
and fTpEvento=3;

-- Genera proceso a recalcular
select concat('call prRecalculaScore(','\'2017-11-30\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) 
from tVehiculo where pVehiculo in (402,422,404,482,421);
-- Recalcula
call prRecalculaScore('2017-11-30',402,208); call prFacturador(402); -- AA929DU
call prRecalculaScore('2017-11-30',404,179); call prFacturador(404); -- KXZ633
call prRecalculaScore('2017-11-30',421,233); call prFacturador(421); -- MKZ002
call prRecalculaScore('2017-11-30',422,235); call prFacturador(422); -- FUZ056
call prRecalculaScore('2017-11-30',482,289); call prFacturador(482); -- LJL447


-- 2018-01
call prFacturador(486);

select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 1 and v.dIniVigencia < t.dFin -- and cPatente <> 'NMZ478'
-- and v.cPatente = 'NDR954'
-- and t.pVehiculo in ( 486 )
and t.tCreacion >= now() + INTERVAL -5 MINUTE
;
/*
union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where t.pTpFactura = 2 and v.dIniVigencia < t.dFin
-- and v.cPatente = 'NDR954'
and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
-- and t.tCreacion >= now() + INTERVAL -5 DAY
order by dIniVigencia, cPatente, cTpCalculo ; 
*/
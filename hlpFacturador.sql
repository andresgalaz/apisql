DELIMITER //
DROP FUNCTION IF EXISTS zfnNow //
CREATE FUNCTION zfnNow() RETURNS DATE
BEGIN
	RETURN DATE('2018-02-19');
    -- RETURN DATE(NOW());
END //
DELIMITER ;

-- Factura Admin Z
SELECT v.pVehiculo
     , v.cPatente
     , v.cPoliza
     , v.fUsuarioTitular
     , u.cNombre, u.cEmail
     , v.dIniVigencia
     , zfnNow() zHoy
     , zfnFechaCierreIni(v.dIniVigencia, 0) dIni_0
     , DATEDIFF(zfnFechaCierreIni(v.dIniVigencia, 0),zfnNow()) alCierre_0
     , zfnFechaCierreFin(v.dIniVigencia, 1) dIni_1
     , DATEDIFF(zfnFechaCierreIni(v.dIniVigencia, 1),zfnNow()) alCierre_1
     , (zfnFechaCierreIni(v.dIniVigencia, 1) > v.dIniVigencia) bVigValida
 FROM  tVehiculo v
       JOIN tUsuario u ON u.pUsuario = v.fUsuarioTitular
 WHERE v.cPoliza is not null
 AND   v.bVigente = '1'
-- AND   zfnFechaCierreIni(v.dIniVigencia, 1) > v.dIniVigencia
--  Dias al cierre 3
-- AND    DATEDIFF(fnFechaCierreIni(v.dIniVigencia, 1),fnNow()) = 3;
and v.cPatente in ( 'AB844YD' )
ORDER BY day(v.dIniVigencia);
                
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
from tVehiculo where cPatente in ( 'LGH390')
union 
select pVehiculo, cPatente, cPoliza, dIniVigencia, dInstalacion, bVigente
     , cIdDispositivo
     , fnFechaCierreIni(dIniVigencia,0) dIniCierre, fnFechaCierreFin(dIniVigencia,0) dFinCierre
     , zfnFechaCierreIni(dIniVigencia,0) dIniCierreZ, zfnFechaCierreFin(dIniVigencia,0) dFinCierreZ, zfnNow()
from tVehiculo where cPatente in ( 'LGH390')
order by cPatente, dIniCierre;

-- Paz dario (2 meses)	'MJK040'

select concat('call prFacturador(', pVehiculo, '); -- ', cPatente) 
from tVehiculo where cPatente in ( 'LGH390' );

-- Lista Aceleraciones
select v.cPatente, u.cNombre, u.cEmail, e.* 
from tEvento e 
	 inner join tVehiculo v on v.pVehiculo = e.fVehiculo
     inner join tUsuario u on u.pUsuario = v.fUsuarioTitular
where v.cPatente in ('AA429CP','FAA680','JBH851','ONV367' )
-- and e.tEvento >= '2018-01-01' -- and e.tEvento < now()
and e.fTpEvento = 3
;

-- usuarioClase.BSH 
SELECT u.pUsuario, u.cEmail , u.cNombre, u.nDNI, v.pVehiculo, v.cPatente
     , d.cDescripcion cTpDispositivo, v.cIdDispositivo
     , max( e.tEvento ) tEvento
 FROM  tUsuario u
       LEFT OUTER JOIN tUsuarioVehiculo uv ON uv.pUsuario      = u.pUsuario
       LEFT OUTER JOIN tVehiculo        v  ON v.pVehiculo      = uv.pVehiculo
       LEFT OUTER JOIN tTpDispositivo   d  ON d.pTpDispositivo = v.fTpDispositivo
       LEFT OUTER JOIN tEvento          e  ON e.fUsuario       = uv.pUsuario
                                          AND e.fVehiculo      = uv.pVehiculo
 WHERE 1 = 1
 GROUP BY u.pUsuario, u.cEmail , u.cNombre, u.nDNI, v.pVehiculo, v.cPatente
        , d.cDescripcion, v.cIdDispositivo
 ORDER BY tEvento DESC
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
select concat('call prRecalculaScore(','\'',  fnFechaCierreIni(dIniVigencia, 0) - interval 1 day, '\'',',',pVehiculo,',',fUsuarioTitular,'); call prFacturador(', pVehiculo, '); -- ', cPatente) -- , dIniVigencia
from tVehiculo where cPatente in ('LGH390'); -- pVehiculo in (494);
-- 2018-02-19

call prRecalculaScore('2018-02-21',504,330); call prFacturador(504); -- LGH390


select 'Real' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 1 and v.dIniVigencia < t.dFin -- and cPatente <> 'NMZ478'
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AB844YD'
-- and t.pVehiculo in ( 481)
and t.tCreacion >= now() + INTERVAL -3 MINUTE
; -- union all
select 'Sin multa' cTpCalculo, v.cPatente, v.dIniVigencia, t.dInstalacion, u.cEmail, u.pUsuario, u.cNombre, t.pVehiculo, t.dInicio, (t.dFin + INTERVAL -1 DAY ) dFin, t.nKms, t.nKmsPond, t.nScore
     , t.nDescuentoKM, t.nDescuentoSinUso, t.nDescuentoPunta
     , t.nDescuentoKM + t.nDescuentoSinUso + t.nDescuentoPunta as nDescSinPonderar, t.nDescuento
     , t.nQViajes, t.nQFrenada, t.nQAceleracion, t.nQVelocidad, t.nQCurva, t.nDiasTotal, t.nDiasUso, t.nDiasPunta, t.nDiasSinMedicion, t.tUltimoViaje, t.tUltimaSincro, t.tCreacion dFacturacion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 2 and v.dIniVigencia < t.dFin
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AB686YD'
-- and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
and t.tCreacion >= now() + INTERVAL -3 MINUTE
order by dIniVigencia, cPatente, cTpCalculo, dInicio ; 

-- diasViaje
select v.cPoliza, v.cPatente patente, u.cNombre nombre, v.dIniVigencia inicioVigencia
	 , t.dInicio iniPeriodo, (t.dFin + INTERVAL -1 DAY ) finPeriodo
     , t.nDescuento descuento, t.nKms kms, t.nKmsPond kmsPond
     , t.nScore score
     , t.nQFrenada qFrenadas, t.nQAceleracion qAceleraciones, t.nQVelocidad qExcesosVel, t.nQCurva qCurvas
     , t.nQViajes qViajes, t.nDiasTotal diasTotal, t.nDiasUso diasUso, t.nDiasPunta diasPunta, t.nDiasSinMedicion diasSinMedicion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 1 and v.dIniVigencia < t.dFin -- and cPatente <> 'NMZ478'
-- and t.dInicio = '2017-11-30'
and v.cPatente = 'AB844YD'
-- and t.pVehiculo in ( 481)
-- and t.tCreacion >= now() + INTERVAL -1 DAY + INTERVAL -1 hour -- MINUTE
;
--
select v.cPatente patente, u.cNombre nombre, v.dIniVigencia inicioVigencia
	 , t.dInicio iniPeriodo, (t.dFin + INTERVAL -1 DAY ) finPeriodo
     , t.nDescuento descuento, t.nKms kms, t.nKmsPond kmsPond
     , t.nScore score
     , t.nQFrenada qFrenadas, t.nQAceleracion qAceleraciones, t.nQVelocidad qExcesosVel, t.nQCurva qCurvas
     , t.nQViajes qViajes, t.nDiasTotal diasTotal, t.nDiasUso diasUso, t.nDiasPunta diasPunta, t.nDiasSinMedicion diasSinMedicion
from tFactura t
join tVehiculo v on v.pVehiculo = t.pVehiculo
join tUsuario  u on u.pUsuario = v.fUsuarioTitular
where v.cPoliza <> 'TEST' and t.pTpFactura = 1 and v.dIniVigencia < t.dFin
-- and t.dInicio = '2017-11-30'
-- and v.cPatente = 'AB686YD'
-- and t.pVehiculo in ( 442, 392 )
-- and t.tCreacion >= '2017-12-07 10:30:00'
and t.tCreacion >= now() + INTERVAL -5 MINUTE
-- order by dIniVigencia, cPatente, dInicio

union all

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
and t.tCreacion >= now() + INTERVAL -5 MINUTE

order by inicioVigencia, patente, iniPeriodo
;
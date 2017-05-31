use score;
set @dIni=date('2017-05-01');
set @dFin=date(now());
set @vehiculo=351;
set @usuario=54;

select @dIni as dIni, @dFin as dFin, @vehiculo as idVehiculo, @usuario as idUsuario;
/*
select smc.fVehiculo,  v.cPatente, v.fUsuarioTitular, u.cNombre , smc.nKms, smc.nScore
from tScoreMesConductor smc 
      inner join tVehiculo v on v.pVehiculo = smc.fVehiculo
      inner join tUsuario u on u.pUsuario = v.fUsuarioTitular
where smc.fUsuario=@usuario and smc.fVehiculo=@vehiculo and smc.dPeriodo=@dIni;
call prScoreConductorRangoFecha( @usuario,@vehiculo, @dIni, @dFin);
*/
-- Desde prCalculaScoreMes
SELECT v.fCuenta, t.fVehiculo, t.fUsuario
     , MIN( t.dFecha )          dInicio       , SUM( t.nKms )            nSumaKms
     , SUM( t.nFrenada )        nSumaFrenada  , SUM( t.nAceleracion )    nSumaAceleracion
     , SUM( t.nVelocidad )      nSumaVelocidad, SUM( t.nCurva )          nSumaCurva
     , COUNT(DISTINCT t.dFecha) nDiasTotal
     , SUM( t.bUso )            nDiasUso      , SUM( t.bHoraPunta )      nDiasPunta
/* INTO   vfCuenta
     , vdInicio                            , vnKms
     , vnSumaFrenada                       , vnSumaAceleracion
     , vnSumaVelocidad                     , vnSumaCurva
     , vnDiasTotal
     , vnDiasUso                           , vnDiasPunta */
FROM   tScoreDia t
       INNER JOIN tVehiculo v ON v.pVehiculo = t.fVehiculo
WHERE  t.fVehiculo = @vehiculo
AND    t.dFecha >= @dIni
AND    t.dFecha < adddate(@dFin, interval 1 day)
group by v.fCuenta, t.fVehiculo, t.fUsuario;

select m.fVehiculo, v.cPatente, v.fUsuarioTitular, u.cNombre, m.nKms, m.nScore, m.nDescuento
from tScoreMes m 
      inner join tVehiculo v on v.pVehiculo = m.fVehiculo
      inner join tUsuario u on u.pUsuario = v.fUsuarioTitular
      inner join tUsuarioVehiculo uv on uv.pVehiculo = v.pVehiculo
where uv.pUsuario = @usuario and m.dPeriodo=@dIni;
call prScoreVehiculoRangoFecha( @usuario, @dIni, @dFin);
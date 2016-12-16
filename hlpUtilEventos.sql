/* 
truncate table tScoreMes;
ALTER TABLE tScoreMes AUTO_INCREMENT=1;
truncate table tScoreMesConductor;
ALTER TABLE tScoreMesConductor AUTO_INCREMENT=1;
truncate table tScoreDia;
ALTER TABLE tScoreDia AUTO_INCREMENT=1;
truncate table tEvento;
ALTER TABLE tEvento AUTO_INCREMENT=1;
truncate table wEvento;
ALTER TABLE wEvento AUTO_INCREMENT=1;

-- Llena las tablas de Score con valores en cero para cada mes o dia, segun corresponda
call prResetScore();

*/
select 'T',count(*) from tEvento t union all
select 'I',sum(t.nValor) from tEvento t where t.fTpEvento = 1 union all
select 'SD',count(*) from tScoreDia t union all
select 'SM',count(*) from tScoreMes t union all
select 'SMC',count(*) from tScoreMesConductor t union all
select 'W',count(*) from wEvento t ;

-- Muestra los meses que tienen eventos
select substr( t.dFecha,1,7) ,count(*) from tScoreDia t
group by substr( t.dFecha,1,7);

select t.fVehiculo, t.fUsuario, concat(substr(t.dFecha,1,8),'01'), count(*) from tScoreDia t
group by t.fVehiculo, t.fUsuario, concat(substr(t.dFecha,1,8),'01')
order by 3 desc, 1, 2;

select min(t.dFecha) dInicio
     , sum(t.nKms) nSumaKms
     , sum(t.nFrenada) nSumaFrenada, sum(t.nAceleracion) nSumaAceleracion
     , sum(t.nVelocidad) nSumaVelocidad, sum(t.nScore) nSumaScore
     , count(*) nDiasTotal, sum(t.bUso) nDiasUso, sum(t.bHoraPunta) nDiasPunta from tScoreDia t
where t.fVehiculo = 103 -- , t.fUsuario
order by 1, 2;

-- Compara Score Mes desa vs prod
select m1.fVehiculo            , m1.dPeriodo
, m1.nScore               , m2.nScore
, m1.nSumaVelocidad       , m2.nSumaVelocidad
, m1.nVelocidad           , m2.nVelocidad
, m1.nSumaFrenada         , m2.nSumaFrenada
, m1.nFrenada             , m2.nFrenada
, m1.nSumaAceleracion     , m2.nSumaAceleracion
, m1.nAceleracion         , m2.nAceleracion
, m1.nKms                 , m2.nKms
, m1.nDescuento           , m2.nDescuento
, m1.nDescuentoKM         , m2.nDescuentoKM
, m1.nDescuentoPtje       , m2.nDescuentoPtje
, m1.nDescuentoSinUso     , m2.nDescuentoSinUso
, m1.nDescuentoNoUsoPunta , m2.nDescuentoNoUsoPunta
, m1.nDiasPunta           , m2.nDiasPunta
, m1.nTotalDias           , m2.nTotalDias
, m1.nDiasUso             , m2.nDiasUso
from   score.tScoreMes m1 
left outer join score_desa.tScoreMes m2 
on  m2.fVehiculo = m1.fVehiculo
and m2.dPeriodo  = m1.dPeriodo
where m1.fVehiculo = 142; -- m1.dPeriodo >= '2016-12-01';

select m1.fVehiculo            , m1.fUsuario, m1.dPeriodo
, m1.nScore               , m2.nScore
, m1.nSumaVelocidad       , m2.nSumaVelocidad
, m1.nVelocidad           , m2.nVelocidad
, m1.nSumaFrenada         , m2.nSumaFrenada
, m1.nFrenada             , m2.nFrenada
, m1.nSumaAceleracion     , m2.nSumaAceleracion
, m1.nAceleracion         , m2.nAceleracion
, m1.nKms                 , m2.nKms
, m1.nDiasPunta           , m2.nDiasPunta
, m1.nTotalDias           , m2.nTotalDias
, m1.nDiasUso             , m2.nDiasUso
from   score.tScoreMesConductor m1 
left outer join score_desa.tScoreMesConductor m2 
on  m2.fVehiculo = m1.fVehiculo
and m2.fUsuario  = m1.fUsuario
and m2.dPeriodo  = m1.dPeriodo
    where m1.dPeriodo >= '2016-12-01'

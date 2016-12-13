select * from tEvento where fUsuario=21 and fVehiculo=67 and tEvento>='2016-09-01' and tEvento<'2016-10-01' and fTpEvento=2 order by nValor desc;
select * from tEvento where nIdViaje=300;
select nIdViaje, sum(case when fTpEvento=2 then nValor else 0 end) kms
, min(case when fTpEvento=1 then tEvento else null end) fecha_ini,count(*) cant_eventos 
from tEvento where tEvento between '2016-09-01' and '2016-09-30'
group by nIdViaje order by kms desc;

delete from tEvento where nIdViaje in (10,11);
INSERT INTO tEvento
     ( nIdViaje , nIdTramo, fTpEvento, tEvento
     , nLG      , nLT     , cCalle   , nVelocidadMaxima, nValor
     , fVehiculo, fUsuario, nPuntaje , tModif) 
select 10       , nIdTramo, fTpEvento, date_add(tEvento, interval 31 day)
     , nLG      , nLT     , cCalle   , nVelocidadMaxima, nValor
     , 68       , 23      , nPuntaje , tModif
from tEvento where nIdViaje=300;



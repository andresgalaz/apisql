-- call prResetScore( '2017-04-01' );
-- Busca Viajes ordena por kilometros
select (select count(*) from tEvento t2 where t2.nIdViaje=t.nIdViaje) cantEventos, t.* from tEvento t where t.fTpEvento=2 and t.nValor between 20 and 50 order by t.nValor desc;

-- Copia Viajes seleccionados
-- insert into tEvento ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario, nPuntaje)
select t.nIdViaje, t.nIdTramo, t.fTpEvento, date_add( t.tEvento, Interval 97 day) tEvento, t.nLG, t.nLT, t.cCalle, t.nVelocidadMaxima, t.nValor
     , 185 fVehiculo, 54 fUsuario, nPuntaje from tEvento t
where t.nIdViaje in (2725,2739,2747,2749);
-- Borra Original de Viaje copiado
delete from tEvento 
where nIdViaje in (2725,2739,2747,2749)
and tEvento < '2017-04-01';

-- Copia Viajes seleccionados
-- insert into tEvento ( nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario, nPuntaje)
select t.nIdViaje, t.nIdTramo, t.fTpEvento, date_add( t.tEvento, Interval 107 day) tEvento, t.nLG, t.nLT, t.cCalle, t.nVelocidadMaxima, t.nValor
     , 185 fVehiculo, 54 fUsuario, nPuntaje from tEvento t
where t.nIdViaje in (2507,2520,2534,2539);
-- Borra Original de Viaje copiado
delete from tEvento 
where nIdViaje in (2507,2520,2534,2539)
and tEvento < '2017-04-01';


-- Corrrige excesos de velocidad
delete from tEvento
where fUsuario=54 and fVehiculo=185 and tEvento >= '2017-04-01'
and fTpEvento=5 and nPuntaje>5;

-- Resetea valores de Inicio DIA - MES, puede no ser necesario si no se borraron registros de 
-- las tablas tScoreDia, tScoreMes y tScoreMesConductor
call prResetScore( '2017-04-01' );

-- Recalcula
-- AGalaz - AD478SS
call prRecalculaScore( '2017-04-01', 56, 23 );
-- 101	JAM Mondolo	228	AA822AG
call prRecalculaScore( '2017-04-01', 228, 101 );
-- 77	Bruno Gielczynsky 	203	AA909NM	66	Gonzalo Delger
call prRecalculaScore( '2017-04-01', 203, 77 );

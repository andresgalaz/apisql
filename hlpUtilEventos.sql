/* 
-- Esto está comentado por seguridad, al correrlo por error
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

*/
-- Llena las tablas de Score con valores en cero para cada mes o dia, segun corresponda
call prResetScore( '2016-08-01' );

-- Correr la SHELL en el servidor de snapcar
-- Dentro del dir: /home/ubuntu/migraObservations
-- corre: node proceso.js

select 'T',count(*) from tEvento t union all
select 'I',sum(t.nValor) from tEvento t where t.fTpEvento = 1 union all
select 'SD',count(*) from tScoreDia t union all
select 'SM',count(*) from tScoreMes t union all
select 'SMC',count(*) from tScoreMesConductor t union all
select 'W',count(*) from wEvento t ;

-- Muestra los meses que tienen eventos
select substr( t.dFecha,1,7) ,count(*) from tScoreDia t
group by substr( t.dFecha,1,7);

-- Muestra los días que tienen eventos
select t.fVehiculo, t.fUsuario, concat(substr(t.dFecha,1,8),'01'), count(*) from tScoreDia t
group by t.fVehiculo, t.fUsuario, concat(substr(t.dFecha,1,8),'01')
order by 3 desc, 1, 2;




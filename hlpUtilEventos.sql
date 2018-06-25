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
truncate table wEventoDeleted;
ALTER TABLE wEventoDeleted AUTO_INCREMENT=1;
truncate table wEventoHist;

-- Llena las tablas de Score con valores en cero para cada mes o dia, segun corresponda
-- call prResetScore( '2016-08-01' );
call prResetScore( '2017-01-01' );

-- Correr la SHELL en el servidor de snapcar
-- Dentro del dir: /home/ubuntu/migraObservations
-- corre: node proceso.js
select 'T',count(*) from tEvento t union all
select 'I',sum(t.nValor) from tEvento t where t.fTpEvento = 1 union all
select 'SD',count(*) from tScoreDia t union all
select 'SM',count(*) from tScoreMes t union all
select 'SMC',count(*) from tScoreMesConductor t union all
select 'W',count(*) from wEvento t union all 
select 'WD',count(*) from wEventoDeleted t;

/*
Cuando solo se limpia Score Dia, Mes y Conductor:
truncate table tScoreMes;
ALTER TABLE tScoreMes AUTO_INCREMENT=1;
truncate table tScoreMesConductor;
ALTER TABLE tScoreMesConductor AUTO_INCREMENT=1;
truncate table tScoreDia;
ALTER TABLE tScoreDia AUTO_INCREMENT=1;
call prResetScore( '2017-01-01' );
call prRecalculaScoreCursor( '2017-01-01' );
*/

-- Corrige fechas de tEvento, talque la fecha inicial no puede ser mayor a la fecha de los eventos posteriores
drop table agv;
create table agv as 
select ini.pEvento, ini.nIdViaje, ini.tEvento tEventoIni, ini.cCalle, fin.tEvento tEventoFin, fin.cCalle cCalleFin, min(eve.tEvento) tEvento
from tEvento ini 
inner join tEvento fin ON ini.nIdViaje = fin.nIdViaje and fin.ftpevento=2
inner join tEvento eve ON eve.nIdViaje = ini.nIdViaje
 where ini.ftpevento=1
 and ini.tEvento > fin.tEvento
group by ini.pEvento, ini.nIdViaje, ini.tEvento, ini.cCalle, fin.tEvento, fin.cCalle;
select * from agv;
update tEvento set tEvento = (select agv.tEvento from agv where agv.pEvento = tEvento.pEvento)
where tEvento.pEvento in ( select agv.pEvento from agv );

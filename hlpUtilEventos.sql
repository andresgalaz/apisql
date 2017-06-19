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

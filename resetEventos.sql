select min(tEvento) from tEvento;
delete from tEvento where tEvento >= '2016-08-01 00:00:00';
delete from tScoreDia where dFecha >= '2016-08-01';
delete from tScoreMes where dPeriodo >= '2016-08-01';
delete from tScoreMesConductor where dPeriodo >= '2016-08-01';
call prResetScore( '2016-08-01' );
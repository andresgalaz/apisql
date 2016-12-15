call prCalculaScoreDia('2016-12-14',142,77);
call prCalculaScoreDia('2016-12-15',142,77);
call prCalculaScoreMes('2016-12-14',142);
call prCalculaScoreMesConductor('2016-12-14',142,77);

select sm.* from tScoreMes sm where sm.fVehiculo = 142 
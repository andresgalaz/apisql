insert into score.tEvento (nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario, nPuntaje)
SELECT nIdViaje, nIdTramo, fTpEvento, adddate(tEvento ,interval 60 day) tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, 185, 66, nPuntaje
FROM score.tEvento
where nIdViaje in (2811,2813,2814);

call prCalculaScoreDia('2017-03-01',185,66);
call prCalculaScoreMes('2017-03-01',185);
call prCalculaScoreMesConductor('2017-03-01',185,66);



select * from tVehiculo where fTpDispositivo=3 and bVigente<>'0';
update tVehiculo set cIdDispositivo=substring(ciddispositivo,3) where cIdDispositivo like 'VL%';



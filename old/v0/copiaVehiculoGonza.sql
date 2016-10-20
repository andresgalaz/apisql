select max(nIdViaje) from tEvento;

insert into tEvento (nIdViaje, nIdTramo, fTpEvento, tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, fVehiculo, fUsuario, nPuntaje)
select nIdViaje+215,1,fTpEvento, tEvento, nLG, nLT, cCalle, nVelocidadMaxima, nValor, 56, 23, nPuntaje
from tEvento where fVehiculo=33

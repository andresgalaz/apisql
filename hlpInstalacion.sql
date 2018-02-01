SELECT i.fVehiculo, i.cPatente, max(date(i.tModif)) dInstalacion, i.fUsuario, u.cNombre 
from tInstalacion i 
left join tUsuario u on u.pUsuario = i.fUsuario
where i.tModif >= date( '2017-12-01' )
group by i.fVehiculo, i.cPatente, i.fUsuario, u.cNombre 
order by dInstalacion desc

SELECT i.fVehiculo, i.cPatente, max(date(i.tModif)) dInstalacion, i.fUsuario, u.cNombre, c.cNombre conductor
from tInstalacion i 
left join tUsuario u on u.pUsuario = i.fUsuario
left join tVehiculo v on v.pVehiculo = i.fVehiculo
left join tUsuario c on c.pUsuario = v.fUsuarioTitular
where i.tModif >= date( '2017-10-01' )
group by i.fVehiculo, i.cPatente, i.fUsuario, u.cNombre 
order by dInstalacion desc
;
select * from tInstalacion
;
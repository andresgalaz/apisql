DROP VIEW IF EXISTS vVehiculo;
create VIEW vVehiculo AS 
select	  v.pVehiculo			AS fVehiculo
		, v.cPatente			AS cPatente
		, v.cMarca				AS cMarca
		, v.cModelo				AS cModelo
		, v.cIdDispositivo		AS cIdDispositivo
		, v.bVigente			AS bVigente
		, v.fTpDispositivo		AS fTpDispositivo
		, v.fCuenta				AS fCuenta
		, u.pUsuario			AS fUsuario
        , uu.cNombre            AS cUsuario
		, c.fUsuarioTitular		AS fUsuarioTitular
        , ut.cNombre            AS cUsuarioTitular
from	tVehiculo v 
		left join tCuentaUsuario u	on u.pCuenta = v.fCuenta
		left join tCuenta c			on c.pCuenta = u.pCuenta
        left join tUsuario ut       on ut.pUsuario = c.fUsuarioTitular
        left join tUsuario uu       on uu.pUsuario = u.pUsuario
where	v.bVigente = '1'

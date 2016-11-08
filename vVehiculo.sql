DROP VIEW IF EXISTS vVehiculo;
create VIEW vVehiculo AS
select	  v.pVehiculo			AS fVehiculo
		, v.cPatente			AS cPatente
		, v.cMarca				AS cMarca
		, v.cModelo				AS cModelo
		, v.cIdDispositivo		AS cIdDispositivo
		, v.bVigente			AS bVigente
		, v.fTpDispositivo		AS fTpDispositivo
--		, v.fCuenta				AS fCuenta
		, uv.pUsuario			AS fUsuario
        , uu.cNombre            AS cUsuario
		, uv.fUsuarioTitular	AS fUsuarioTitular
        , ut.cNombre            AS cUsuarioTitular
		, s.dPeriodo			AS dPeriodo
		, s.nKms				AS nKms
		, s.nScore				AS nScore
		, s.nDescuento			AS nDescuento
from	tVehiculo v
        inner join tUsuario			ut	on ut.pUsuario			= v.fUsuarioTitular
		-- Trae todos los usuarios que pueden usar el vehículo
		inner join tUsuarioVehiculo uv	on uv.pVehiculo			= v.pVehiculo
        inner join tUsuario			uu	on uu.pUsuario			= uv.pUsuario
		inner join tScoreMes		s	on s.fVehiculo			= v.pVehiculo
where	v.bVigente = '1'
-- De la fecha actual, toma el primer día del mes (i.e. el periodo)
and     s.dPeriodo = DATE(DATE_SUB(now(), INTERVAL DAYOFMONTH(now()) - 1 DAY))
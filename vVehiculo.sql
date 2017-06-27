DROP VIEW IF EXISTS vVehiculo;
CREATE VIEW vVehiculo AS
SELECT	  v.pVehiculo			AS fVehiculo
		, v.cPatente			AS cPatente
		, v.cMarca				AS cMarca
		, v.cModelo				AS cModelo
		, v.cIdDispositivo		AS cIdDispositivo
		, v.bVigente			AS bVigente
		, v.fTpDispositivo		AS fTpDispositivo
--		, v.fCuenta				AS fCuenta
		, uv.pUsuario			AS fUsuario
        , uu.cNombre            AS cUsuario
		, v.fUsuarioTitular	    AS fUsuarioTitular
        , ut.cNombre            AS cUsuarioTitular
		, s.dPeriodo			AS dPeriodo
		, s.nKms				AS nKms
		, s.nScore				AS nScore
		, s.nDescuento			AS nDescuento
FROM	tVehiculo v
        inner join tUsuario			ut	on ut.pUsuario			= v.fUsuarioTitular
		-- Trae todos los usuarios que pueden usar el vehículo
		inner join tUsuarioVehiculo uv	on uv.pVehiculo			= v.pVehiculo
        inner join tUsuario			uu	on uu.pUsuario			= uv.pUsuario
		inner join tScoreMes		s	on s.fVehiculo			= v.pVehiculo
WHERE	v.bVigente = '1';
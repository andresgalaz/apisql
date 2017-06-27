DROP VIEW IF EXISTS vUsuarioVehiculo;
CREATE VIEW vUsuarioVehiculo AS
SELECT	  uv.pUsuario			AS fUsuario
        , uu.cNombre            AS cUsuario
		, uv.pVehiculo			AS fVehiculo
		, v.cPatente			AS cPatente
		, uv.fUsuarioTitular	AS fUsuarioTitular
        , ut.cNombre            AS cUsuarioTitular
FROM	tUsuarioVehiculo uv
        inner join tVehiculo		v	on v.pVehiculo			= uv.pVehiculo
        inner join tUsuario			ut	on ut.pUsuario			= uv.fUsuarioTitular
        inner join tUsuario			uu	on uu.pUsuario			= uv.pUsuario;

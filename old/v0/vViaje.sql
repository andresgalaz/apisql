DROP VIEW IF EXISTS vViaje;
CREATE VIEW vViaje AS
SELECT	v.pVehiculo			AS	fVehiculo		,	v.cPatente	AS	cPatente
	 ,	uv.fUsuarioTitular	AS	fUsuarioTitular
	 ,	ut.cNombre			AS	cNombreTitular
	 ,	ini.fUsuario		AS	fUsuario
	 ,	uu.cNombre			AS	cNombreConductor
	 ,	ini.nIdViaje		AS	nIdViaje
	 ,	ini.cCalle			AS	cCalleInicio	,	fin.cCalle	AS	cCalleFin
	 ,	ini.tEvento			AS	tInicio			,	fin.tEvento	AS	tFin
	 ,	ini.nValor			AS	nScore			,	fin.nValor	AS	nKms
FROM	tVehiculo v
--		inner join tCuenta			c	ON	c.pCuenta		=	v.fCuenta
--		inner join tCuentaUsuario	cu	ON	cu.pCuenta		=	v.fCuenta
		INNER JOIN tUsuarioVehiculo	uv	ON	uv.pVehiculo	=	v.pVehiculo
		INNER JOIN tUsuario			ut	ON	ut.pUsuario		=	uv.fUsuarioTitular
		INNER JOIN tUsuario			uu	ON	uu.pUsuario		=	uv.pUsuario
		INNER JOIN tEvento			ini	ON	ini.fVehiculo	=	v.pVehiculo
										AND	ini.fUsuario	=	uv.pUsuario
										AND	ini.fTpEvento	=	1 -- Inicio del Viaje
		LEFT JOIN  tEvento			fin	ON	fin.nIdViaje	=	ini.nIdViaje
										AND	fin.fTpEvento	=	2 -- Fin del Viaje

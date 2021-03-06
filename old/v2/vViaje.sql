DROP VIEW IF EXISTS vViaje;
CREATE VIEW vViaje AS
SELECT	v.pVehiculo			AS	fVehiculo		,	v.cPatente	AS	cPatente
	 ,	v.fUsuarioTitular	AS	fUsuarioTitular
	 ,	ut.cNombre			AS	cNombreTitular
	 ,	ini.fUsuario		AS	fUsuario
	 ,	IFNULL(uu.cNombre,'Desconocido')			AS	cNombreConductor
	 ,	ini.nIdViaje		AS	nIdViaje
	 ,	ini.cCalle			AS	cCalleInicio	,	fin.cCalle	AS	cCalleFin
	 ,	ini.tEvento			AS	tInicio			,	fin.tEvento	AS	tFin
	 ,	ini.nValor			AS	nScore			,	fin.nValor	AS	nKms
FROM	tEvento			ini
		INNER JOIN tVehiculo		 	v	ON	v.pVehiculo		= 	ini.fVehiculo
		-- Solo muestra los viajes de los usuario relacionados. Pueden existir viajes de usuario no identificados
		INNER JOIN tUsuarioVehiculo 	uv	ON	uv.pVehiculo	= 	ini.fVehiculo
										   AND	uv.pUsuario		=	ini.fUsuario
		INNER JOIN tUsuario				ut	ON	ut.pUsuario		=	v.fUsuarioTitular
		LEFT JOIN  tUsuario				uu	ON	uu.pUsuario		=	ini.fUsuario
		LEFT JOIN  tEvento				fin	ON	fin.nIdViaje	=	ini.nIdViaje
									AND	fin.fTpEvento	=	2 -- Fin del Viaje
WHERE	ini.fTpEvento	=	1 -- Inicio del Viaje

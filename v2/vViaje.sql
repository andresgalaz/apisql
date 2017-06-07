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
FROM	tParamCalculo				AS	prm
		-- Inicio del Viaje
		INNER JOIN tEvento			AS	ini ON	ini.fTpEvento	=	1 
		-- Fin del Viaje
		INNER JOIN tEvento			AS	fin	ON	fin.nIdViaje	=	ini.nIdViaje
									       AND	fin.fTpEvento   =	2 -- Fin del Viaje
										   AND	fin.nValor		> 	prm.nDistanciaMin
		INNER JOIN tVehiculo		AS 	v	ON	v.pVehiculo		= 	ini.fVehiculo
		-- Solo muestra los viajes de los usuario relacionados. Pueden existir viajes de usuario no identificados
		INNER JOIN tUsuarioVehiculo AS	uv	ON	uv.pVehiculo	= 	ini.fVehiculo
										   AND	uv.pUsuario		=	ini.fUsuario
		INNER JOIN tUsuario			AS	ut	ON	ut.pUsuario		=	v.fUsuarioTitular
		LEFT JOIN  tUsuario			AS	uu	ON	uu.pUsuario		=	ini.fUsuario
ORDER BY ini.tEvento DESC
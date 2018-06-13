DELIMITER //
DROP PROCEDURE IF EXISTS prNoSincroProgramadaLista //
CREATE PROCEDURE prNoSincroProgramadaLista( IN prm_pVehiculo INTEGER)
BEGIN
	/*
    Procedimiento ustilizado para la WEB de Administración.
    Autor: AGalaz
    Modulo: Factura
    Opcion Vacaciones
    */
	SELECT	ns.pVehiculo	, ns.pNoSincro		, ns.dInicio		,
			ns.dTermino		, ns.fTpNoSincro	, tp.cDescripcion	cTpNoSinco,
			ns.cObservacion	, ns.bProcesado		, ns.fUsuario		,
			ns.tCreacion	, ns.tModif
	FROM 	score.tNoSincroProgramada ns
			INNER JOIN score.tTpNoSincro tp ON tp.pTpNoSincro = ns.fTpNoSincro
	WHERE	pVehiculo = prm_pVehiculo;

END //

call prNoSincroProgramadaLista( 101 )
//

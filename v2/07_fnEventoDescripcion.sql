DELIMITER //

DROP FUNCTION IF EXISTS fnEventoDescripcion //

CREATE FUNCTION fnEventoDescripcion( prmTpEvento INTEGER,  prmValorG SMALLINT ) RETURNS VARCHAR( 200 )
BEGIN
	DECLARE kEventoInicio		INTEGER DEFAULT 1;
	DECLARE kEventoFin			INTEGER DEFAULT 2;
	DECLARE kEventoAceleracion	INTEGER DEFAULT 3;
	DECLARE kEventoFrenada		INTEGER DEFAULT 4;
	DECLARE kEventoVelocidad	INTEGER DEFAULT 5;
	DECLARE kEventoCurva        INTEGER DEFAULT 6;
    -- Lapso de tiempo para hacer mas claro el concepto de aceleración
    DECLARE kLapsoTiempo		INTEGER DEFAULT 5;
	-- La aceleración( o desaceleración) es el valorG, está en milesimas de la gravedad (m/s2), se pasa a KM/(hr * seg)
    DECLARE vnAcel DOUBLE DEFAULT prmValorG * ( 9.8 / 1000 ) * ( 3600 / 1000 );
    IF prmTpEvento = kEventoAceleracion THEN
		RETURN CONCAT('Aceleraste el equivalente desde 0 a ', ROUND( vnAcel * kLapsoTiempo, 0 ), ' [km/h] en ', kLapsoTiempo, ' segundos' );
	END IF;
    IF prmTpEvento = kEventoFrenada THEN
		RETURN CONCAT('Frenaste el equivalente desde ', ROUND( vnAcel * kLapsoTiempo, 0 ), ' [km/h] a 0 en ', kLapsoTiempo, ' segundos' );
	END IF;
	RETURN '';
END //

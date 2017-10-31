DELIMITER //
DROP FUNCTION IF EXISTS fnEstadoSincro //
CREATE FUNCTION fnEstadoSincro(prm_tUltimo TIMESTAMP) RETURNS VARCHAR(20)
BEGIN
	DECLARE nDias INTEGER DEFAULT DATEDIFF( DATE(NOW()), DATE(prm_tUltimo));
	IF nDias < 5 THEN
		RETURN 'Actualizado';
	END IF;
	IF nDias < 10 THEN
		RETURN 'Desactualizado';
	END IF;
	RETURN 'Crítico';
END //

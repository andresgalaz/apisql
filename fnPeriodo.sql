DELIMITER //
DROP FUNCTION IF EXISTS fnPeriodo //
CREATE FUNCTION fnPeriodo(prm_fecha DATE) RETURNS DATE
BEGIN
	RETURN DATE(CONCAT(substr(prm_fecha,1,8),'01'));
END //

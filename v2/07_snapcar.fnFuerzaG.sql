DELIMITER //
USE snapcar //
DROP FUNCTION IF EXISTS fnFuerzaG //
CREATE FUNCTION fnFuerzaG ( prm_prefix varchar(10), prm_x SMALLINT, prm_y SMALLINT ) RETURNS SMALLINT
BEGIN
	IF prm_prefix = 'A' THEN
		RETURN prm_y;
	END IF;
	IF prm_prefix = 'F' OR prm_prefix = 'X' THEN
		RETURN -prm_y;
	END IF;
	IF prm_prefix = 'C' THEN
		RETURN ABS(prm_x);
	END IF;
    RETURN NULL;
END //


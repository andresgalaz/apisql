DELIMITER //
DROP FUNCTION IF EXISTS fnJsonAdd //
CREATE FUNCTION fnJsonAdd ( vcEntrada TEXT, vcNombre VARCHAR(90), vcValor VARCHAR(500) ) RETURNS TEXT
BEGIN
	DECLARE vcSalida TEXT DEFAULT vcEntrada;
        
	IF vcSalida IS NULL THEN
		SET vcSalida = '';
	END IF;
    
    IF vcValor IS NULL THEN
		RETURN vcSalida;
	END IF;
    
    IF LENGTH(vcSalida)>0 THEN
		SET vcSalida = CONCAT(vcSalida, ', ');
    END IF;
    
	SET vcSalida = CONCAT(vcSalida, '"', vcNombre, '" : "', vcValor , '"' );
    
    RETURN vcSalida;
END //


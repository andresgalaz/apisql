DELIMITER //
USE snapcar //
DROP FUNCTION IF EXISTS fnNombreCalle //
CREATE FUNCTION fnNombreCalle (	prm_tipo			char(1)		, prm_name	varchar(100),
								prm_street_number	varchar(100), prm_town	varchar(100), prm_city			varchar(100),
								prm_substate		varchar(100), prm_state	varchar(100), prm_country		varchar(100) ) RETURNS varchar(500)
BEGIN
	/*
	Devuelve el nombre de la calle. Si prm_tipo:
		'L' : Devuelve el nombre largo
		'C' : Devuelve el nombre corto
	*/
    
	DECLARE nombreCorto VARCHAR(500) DEFAULT '';
	IF PRM_TIPO = 'L' AND IFNULL(prm_name,'') <> '' THEN
		SET nombreCorto = CONCAT(nombreCorto, prm_name );
		IF IFNULL(prm_street_number,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, ' ', prm_street_number );
		END IF;
		SET nombreCorto = CONCAT(nombreCorto, ', ' );
	END IF;
	IF prm_state = 'Ciudad Autónoma de Buenos Aires' OR prm_substate like 'Comuna %' THEN
		IF IFNULL(prm_town,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_town, ', CABA, ' );
		ELSEIF IFNULL(prm_city,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_city, ', CABA, ' );
		ELSEIF IFNULL(prm_substate,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_substate, ', CABA, ' );
		ELSE
			SET nombreCorto = CONCAT(nombreCorto, 'CABA, ' );
		END IF;
	ELSEIF prm_state = 'Buenos Aires' THEN
		IF IFNULL(prm_city,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_city, ', ' );
		END IF;
		IF IFNULL(prm_substate,'') <> '' AND IFNULL(prm_substate,'') <> IFNULL(prm_city,'') THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_substate, ', ' );
		END IF;
		SET nombreCorto = CONCAT(nombreCorto, 'Bs.As., '  );
	ELSE
		IF IFNULL(prm_town,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_town, ', ' );
		END IF;
		IF IFNULL(prm_city,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_city, ', ' );
		END IF;
		IF IFNULL(prm_substate,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_substate, ', ' );
		END IF;
		IF IFNULL(prm_state,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_state, ', ' );
		END IF;
		IF IFNULL(prm_country,'') <> '' THEN
			SET nombreCorto = CONCAT(nombreCorto, prm_country, ', ' );
		END IF;
	END IF;
	
	RETURN SUBSTRING(nombreCorto, 1, CHAR_LENGTH(nombreCorto)-2);
	
END //

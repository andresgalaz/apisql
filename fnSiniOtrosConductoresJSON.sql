DROP FUNCTION IF EXISTS fnSiniOtrosConductoresJSON;
DELIMITER //
CREATE FUNCTION fnSiniOtrosConductoresJSON( prmIdSiniestro int ) RETURNS varchar(999)
BEGIN
	DECLARE cJson           varchar(999);
	DECLARE vcConductor   	varchar(200);
	DECLARE eofCurSiniSub   integer DEFAULT 0;
	DECLARE curSiniSub CURSOR FOR
		SELECT CONCAT('{"nombreConductor":"',s.cNombreConductor,'","patente":"', s.cPatente, '"}')
		  FROM tSiniestroSub s
		 WHERE s.pSiniestro = prmIdSiniestro;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET eofCurSiniSub = 1;
	OPEN  curSiniSub;
	FETCH curSiniSub INTO vcConductor;
	WHILE NOT eofCurSiniSub DO
		IF cJson IS NULL THEN
			SET cJson := vcConductor;
		ELSE
			SET cJson := CONCAT( cJson,',',vcConductor);
		END IF;
		-- Siguiente conductor
		FETCH curSiniSub INTO vcConductor;
	END WHILE;
	CLOSE curSiniSub;
	IF cJson IS NULL THEN
		SET cJson := '';
	END IF;

	RETURN CONCAT('[',cJson,']');
END //

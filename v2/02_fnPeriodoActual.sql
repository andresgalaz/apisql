DELIMITER //
DROP FUNCTION IF EXISTS fnPeriodoActual //
CREATE FUNCTION fnPeriodoActual(prm_dIni DATE, prm_nPeriodo INTEGER) RETURNS DATE
BEGIN
	DECLARE nDia INTEGER DEFAULT DAY( prm_dIni );
	-- Ajusta la fecha actual al mismo dìa del mes
	DECLARE dIni DATE DEFAULT DATE_SUB(NOW(), INTERVAL DAY(NOW()) - nDia DAY);
	-- Lleva al periodo deseado
	SET dIni = DATE_ADD(dIni, INTERVAL prm_nPeriodo MONTH );
	IF nDIA > 29 AND DAY(dIni) < 3 THEN
		-- Si es mayor a 29 existe la posibilidad que el otro mes termine antes: 29, 30 31.
		SET dIni = DATE_SUB( dIni, INTERVAL DAY(dIni) DAY );
	END IF;
	RETURN dIni;
END //

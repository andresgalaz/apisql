DROP VIEW IF EXISTS vVehiculoLast;
CREATE VIEW vVehiculoLast AS
SELECT	*
FROM	vVehiculo v
WHERE	v.dPeriodo = DATE(DATE_SUB(now(), INTERVAL DAYOFMONTH(now()) - 1 DAY));
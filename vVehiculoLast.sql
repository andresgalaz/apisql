DROP VIEW IF EXISTS vVehiculoLast;
create VIEW vVehiculoLast AS
select	*
from	vVehiculo v
where	v.dPeriodo = DATE(DATE_SUB(now(), INTERVAL DAYOFMONTH(now()) - 1 DAY))
-- Detecta Virloc de Vechículos asignados
select	u.cNombre, u.cEmail, v.*
from	tVehiculo v
		left join tUsuario u
			on u.pUsuario = v.fUsuarioTitular
where	v.cIdDispositivo is not null 
and		v.fTpDispositivo = 3
and		v.bVigente='0';

select * from tVehiculo where cIdDispositivo in ( '0162', '0445');

-- Limpia VIRLOC sin poliza y dados de baja
update	tVehiculo 
set		fTpDispositivo = null, cIdDispositivo = null 
where	cIdDispositivo is not null 
and		fTpDispositivo = 3 
-- and		bVigente='0' 
and		pVehiculo in ( 406, 419, 430 )
-- and		cPoliza is null
;
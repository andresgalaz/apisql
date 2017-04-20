drop table agv_cpa;
create table agv_cpa as
select l.id idLocalidad, l.nombre localidad, pa.id idParaje, pa.nombre paraje, pr.id idProvincia, pr.nombre provincia, cp.cod_postal cod_postal_1974, cpa.cpa cod_postal
from localidades l
inner join cp_1974 cp on cp.id = l.id_cp_1974
inner join cpa on cpa.id = l.id_cpa
inner join parajes pa on pa.id = l.id_paraje
inner join provincias pr on pr.id = pa.id_provincia
where pr.id = 1;

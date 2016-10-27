delete from tUsuarioVehiculo;
insert into tUsuarioVehiculo (pVehiculo, pUsuario, fUsuarioTitular, tActiva)
select fVehiculo, fUsuario, fUsuarioTitular, now()  from vVehiculo v;

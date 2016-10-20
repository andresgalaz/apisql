select * from tCuenta where fUsuarioTitular=3;

-- Lista duplicados de titular por cuenta
select c.pCuenta, count(*) from  tCuentaUsuario c where c.bTitular = '1'
group by c.pCuenta
having COUNT(*) > 1;

-- Actualiza tCuenta con el fUsuarioTitular
update tCuenta c set fUsuarioTitular = (select u.pUsuario from tCuentaUsuario u where u.pCuenta = c.pCuenta and u.bTitular = '1');

-- Lista Usuarios sin Cuenta como Titular
select * from tUsuario u left outer join tCuentaUsuario c on c.pUsuario = u.pUsuario and bTitular='1'
where c.pCuenta is null;

-- Lista cuentas con mas de un titular
select pCuenta, bTitular,count(*) from tCuentaUsuario 
group by pCuenta, bTitular;

-- Lista cuentas sin usuarios asignados
select * from tCuenta c where not exists ( select '1' from tCuentaUsuario u where u.pCuenta = c.pCuenta )


DROP TRIGGER `score`.`trgUsuarioIns`;
CREATE TRIGGER `score`.`trgUsuarioIns` AFTER INSERT
    ON score.tUsuario FOR EACH ROW
BEGIN
  declare fCuenta int;
  if not exists ( select fCuenta from tCuenta where fUsuarioTitular = NEW.pUsuario ) then
    insert into tCuenta (fUsuarioTitular) values (NEW.pUsuario);
  end if;
END;

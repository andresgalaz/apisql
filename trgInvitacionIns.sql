DROP TRIGGER if exists trgInvitacionIns;
CREATE TRIGGER trgInvitacionIns AFTER INSERT
    ON tInvitacion FOR EACH ROW
BEGIN
  if not exists ( select pUsuario from tUsuario where cEmail = NEW.cEmailInvitado ) then
    insert into tUsuario (cEmail, cPassword, cNombre, cSexo ) values (NEW.cEmailInvitado, '.', '.', 'M');
  end if;
END;

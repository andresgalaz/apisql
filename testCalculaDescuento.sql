SET @diasUso=30;
SET @diasPunta=9;
call prCalculaDescuento(3001, @diasUso, @diasPunta, 30, 30, 30,
@vnDescuento, @vnDescuentoKM, @vnDescDiaSinUso, @vnDescNoHoraPunta, @vnFactorDias);
select @diasUso, @diasPunta, @vnDescuento, @vnDescuentoKM, @vnDescDiaSinUso, @vnDescNoHoraPunta, @vnFactorDias;

select fnCalculaDescuento(3001, 30, 9, 10, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 20, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 30, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 40, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 50, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 60, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 70, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 80, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 90, 30, 30);
select fnCalculaDescuento(3001, 30, 9, 99, 30, 30);
select fnCalculaDescuento(3001, 30, 9,100, 30, 30);

SET @diasUso=17;
SET @diasPunta=13;
call prCalculaDescuento(1500, @diasUso, @diasPunta, 100, 30, 30,
@vnDescuento, @vnDescuentoKM, @vnDescDiaSinUso, @vnDescNoHoraPunta, @vnFactorDias);
select @diasUso, @diasPunta, @vnDescuento, @vnDescuentoKM, @vnDescDiaSinUso, @vnDescNoHoraPunta, @vnFactorDias;


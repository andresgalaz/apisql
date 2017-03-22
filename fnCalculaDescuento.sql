DROP function IF EXISTS fnCalculaDescuento;
DELIMITER //
CREATE function fnCalculaDescuento( prmKms integer,  prmDiasUso integer,  prmDiasPunta integer,  prmScore integer,  prmDiasMes integer,  prmDiasVigencia integer ) returns decimal
BEGIN
    declare descuento decimal(5,2);
    call prCalculaDescuento(prmKms, prmDiasUso, prmDiasPunta, prmScore, prmDiasMes, prmDiasVigencia, @vnDescuento, @vnDescuentoKM, @vnDescDiaSinUso, @vnDescNoHoraPunta, @vnFactorDias);
    SET descuento = @vnDescuento;
    return descuento;
END //
DELIMITER ;

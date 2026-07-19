-- =========================================================
--  FUNCIONES (MySQL)
-- =========================================================

DELIMITER //

-- 1. Calcular IVA
CREATE FUNCTION fn_calcular_iva(monto DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(monto * 0.15, 2);
END //

DELIMITER ;    
-- Uso: 
SELECT fn_calcular_iva(100);


-- 2. Calcular Descuento (version A: por porcentaje directo)
DELIMITER //
CREATE FUNCTION fn_calcular_descuento(monto DECIMAL(10,2), porcentaje DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(monto * (porcentaje / 100), 2);
END //

DELIMITER ;    
-- Uso: 
SELECT fn_calcular_descuento(100, 10);


-- 2. Calcular Descuento (version B: segun una promocion existente)
DELIMITER //
CREATE FUNCTION fn_calcular_descuento_promocion(monto DECIMAL(10,2), p_id_promocion INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2);

    SELECT porcentaje_descuento INTO v_porcentaje
    FROM promociones
    WHERE id_promocion = p_id_promocion;

    IF v_porcentaje IS NULL THEN
        RETURN 0;
    END IF;

    RETURN ROUND(monto * (v_porcentaje / 100), 2);
END //

DELIMITER ;    

-- Uso
SELECT fn_calcular_descuento_promocion(100, 3);


-- 3. Calcular Edad
DELIMITER //
CREATE FUNCTION fn_calcular_edad(p_fecha_nacimiento DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    IF p_fecha_nacimiento IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN TIMESTAMPDIFF(YEAR, p_fecha_nacimiento, CURDATE());
END //

DELIMITER ;    
-- Actualizar o colocar fecha de nacimiento a los 5 primeros clientes para comprobar la funcion
UPDATE clientes SET fecha_nacimiento = '1995-03-14' WHERE id_cliente = 1;
UPDATE clientes SET fecha_nacimiento = '1988-11-02' WHERE id_cliente = 2;
UPDATE clientes SET fecha_nacimiento = '2000-07-20' WHERE id_cliente = 3;
UPDATE clientes SET fecha_nacimiento = '1975-05-30' WHERE id_cliente = 4;
UPDATE clientes SET fecha_nacimiento = '1992-09-15' WHERE id_cliente = 5;
-- Uso: 
SELECT nombre_cliente, fn_calcular_edad(fecha_nacimiento) AS edad FROM clientes;


-- 4. Calcular Comisión
DELIMITER // 
CREATE FUNCTION fn_calcular_comision(p_id_empleado INT, p_porcentaje DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_vendido DECIMAL(10,2);

    SELECT SUM(f.total_factura) INTO v_total_vendido
    FROM ventas v
    JOIN facturas f ON f.id_venta = v.id_venta
    WHERE v.id_vendedor = p_id_empleado;

    IF v_total_vendido IS NULL THEN
        SET v_total_vendido = 0;
    END IF;

    RETURN ROUND(v_total_vendido * (p_porcentaje / 100), 2);
END //

DELIMITER ;    

-- Uso: 
SELECT fn_calcular_comision(4, 5);

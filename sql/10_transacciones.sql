
-- TRANSACCIONES 

-- TRANSACCIÓN 1: Registrar una venta completa

START TRANSACTION;
-- Registrar la venta
INSERT INTO ventas (fecha_venta, id_sucursal, id_pago, id_cliente, id_vendedor, id_cajero, id_promocion)
VALUES (CURRENT_DATE(), 1, 1, 1, 4, 11, NULL);

-- Guardar el id de la venta recien insertada
SET @id_venta_nueva = LAST_INSERT_ID();

-- Registrar el detalle de la venta
INSERT INTO detalle_venta (id_venta, id_producto, cantidad_vendida, precio_unitario, subtotal)
VALUES 
    (@id_venta_nueva, 1, 2, 51.98, 103.96),
    (@id_venta_nueva, 6, 1, 10.45, 10.45);


INSERT INTO facturas (numero_factura, id_venta, descuento_aplicado, subtotal_neto, impuesto, total_factura, monto_pagado)
VALUES (CONCAT('FAC-', LPAD(@id_venta_nueva, 6, '0')), @id_venta_nueva, 0.00, 114.41, 17.16, 131.57, 131.57);

COMMIT;

-- Verificar que se registro la venta
SELECT * FROM ventas ORDER BY id_venta DESC LIMIT 1;

-- Verificar el detalle
SELECT * FROM detalle_venta WHERE id_venta = @id_venta_nueva;

-- Verificar la factura
SELECT * FROM facturas WHERE id_venta = @id_venta_nueva;

-- TRANSACCION 2: Procesar una devolucion

START TRANSACTION;

-- Registrar la devolucion
INSERT INTO devoluciones (id_venta, id_producto, fecha_devolucion, cantidad_devuelta, motivo, monto_reembolso)
VALUES (7, 18, CURRENT_DATE(), 1, 'Talla incorrecta', 28.16);

COMMIT;

-- Verificar que se registro la devolucion
SELECT * FROM devoluciones ORDER BY id_devoluciones DESC LIMIT 1;

-- Verificar que el stock subio 
SELECT id_producto, nombre_producto, stock_disponible FROM productos WHERE id_producto = 18;

-- Verificar movimiento en inventario
SELECT * FROM movimientos_inventario ORDER BY id_movimiento DESC LIMIT 1;


-- TRANSACCION 3: Actualizar precio
DELIMITER //
CREATE PROCEDURE sp_actualizar_precio(IN p_id_producto INT, IN p_precio_nuevo DECIMAL(10,2))
BEGIN
    DECLARE precio_actual DECIMAL(10,2);
    
    SELECT precio_unitario INTO precio_actual 
    FROM productos WHERE id_producto = p_id_producto;
    
    IF p_precio_nuevo < 5.00 THEN
        SELECT 'Error: El precio no puede ser menor a $5.00' AS mensaje;
    ELSE
        START TRANSACTION;
        UPDATE productos
        SET precio_unitario = p_precio_nuevo
        WHERE id_producto = p_id_producto;
        COMMIT;
        SELECT CONCAT('Precio actualizado de $', precio_actual, ' a $', p_precio_nuevo) AS mensaje;
    END IF;
END //
DELIMITER ;

CALL sp_actualizar_precio(2, 20.00);

-- Verificacion
SELECT id_producto, nombre_producto, precio_unitario FROM productos WHERE id_producto = 2;

SELECT * FROM auditoria WHERE tabla_afectada = 'productos' AND accion = 'UPDATE_PRECIO' ORDER BY fecha_hora DESC LIMIT 1;


-- TRANSACCION 4: Registrar nuevo empleado

DELIMITER //
CREATE PROCEDURE sp_registrar_empleado(
    IN p_nombre VARCHAR(75),
    IN p_rol VARCHAR(30),
    IN p_id_sucursal INT
)
BEGIN
    DECLARE existe_sucursal INT;
    DECLARE id_empleado_nuevo INT;

    SELECT COUNT(*) INTO existe_sucursal
    FROM sucursales
    WHERE id_sucursal = p_id_sucursal;

    IF existe_sucursal = 0 THEN
        SELECT 'Error: La sucursal no existe' AS mensaje;
    ELSE
        START TRANSACTION;

        INSERT INTO empleados (nombre_empleado, rol_empleado, id_sucursal)
        VALUES (p_nombre, p_rol, p_id_sucursal);

        SET id_empleado_nuevo = LAST_INSERT_ID();

        INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
        VALUES ('empleados', id_empleado_nuevo, 'INSERT', 19, CURRENT_TIMESTAMP());

        COMMIT;
        SELECT CONCAT('Empleado registrado con ID: ', id_empleado_nuevo, ' en sucursal ', p_id_sucursal) AS mensaje;
    END IF;
END //
DELIMITER ;

CALL sp_registrar_empleado('Carlos Mendoza', 'Vendedor', 2);

-- Verificacion

SELECT * FROM empleados WHERE nombre_empleado = 'Carlos Mendoza';
SELECT * FROM auditoria WHERE tabla_afectada = 'empleados' ORDER BY fecha_hora DESC LIMIT 1;

-- TRANSACCION 5: Anular una venta

DELIMITER //
CREATE PROCEDURE sp_anular_venta(
    IN p_id_venta INT
)
BEGIN
    DECLARE existe_venta INT;

    SELECT COUNT(*) INTO existe_venta
    FROM ventas
    WHERE id_venta = p_id_venta;

    IF existe_venta = 0 THEN
        SELECT 'Error: La venta no existe' AS mensaje;
    ELSE
        START TRANSACTION;

        UPDATE productos p
        JOIN detalle_venta dv ON dv.id_producto = p.id_producto
        SET p.stock_disponible = p.stock_disponible + dv.cantidad_vendida
        WHERE dv.id_venta = p_id_venta;

        INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
        SELECT
            dv.id_producto,
            v.id_sucursal,
            'ANULACION',
            dv.cantidad_vendida,
            CURRENT_DATE(),
            CONCAT('Anulación de venta ID: ', p_id_venta)
        FROM detalle_venta dv
        JOIN ventas v ON v.id_venta = dv.id_venta
        WHERE dv.id_venta = p_id_venta;

        INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
        VALUES ('ventas', p_id_venta, 'DELETE', 19, CURRENT_TIMESTAMP());

        DELETE FROM ventas WHERE id_venta = p_id_venta;

        COMMIT;
        SELECT CONCAT('Venta ', p_id_venta, ' anulada correctamente') AS mensaje;
    END IF;
END //
DELIMITER ;

CALL sp_anular_venta(101);

-- Verificacion

SELECT * FROM ventas WHERE id_venta = 101;
SELECT * FROM detalle_venta WHERE id_venta = 101;
SELECT * FROM facturas WHERE id_venta = 101;
SELECT * FROM movimientos_inventario WHERE tipo_movimiento = 'ANULACION' ORDER BY id_movimiento DESC LIMIT 1;
SELECT * FROM auditoria WHERE tabla_afectada = 'ventas' AND accion = 'DELETE' ORDER BY fecha_hora DESC LIMIT 1;
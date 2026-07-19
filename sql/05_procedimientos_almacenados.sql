-- --------------------------
-- Procedimientos Almacenados 
-- --------------------------

DELIMITER //
-- 1. Registrar Cliente
-- Valida que la cedula no este duplicada antes de insertar
CREATE PROCEDURE sp_registrar_cliente(
    IN p_nombre VARCHAR(75), IN p_cedula VARCHAR(15),
    IN p_telefono VARCHAR(15), IN p_correo VARCHAR(50)
)
BEGIN
    IF EXISTS (SELECT 1 FROM clientes WHERE cedula_cliente = p_cedula) THEN
        SELECT CONCAT('Ya existe un cliente con la cedula ', p_cedula) AS mensaje;
    ELSE
        INSERT INTO clientes (nombre_cliente, cedula_cliente, telefono_cliente, correo_cliente)
        VALUES (p_nombre, p_cedula, p_telefono, p_correo);
    END IF;
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_cliente('Maria Perez', '1712345678', '0991234567', 'maria@correo.com');

-- 2. Registrar Producto
DELIMITER //
CREATE PROCEDURE sp_registrar_producto(
    IN p_nombre VARCHAR(50), IN p_id_talla INT, IN p_color VARCHAR(15), IN p_precio DECIMAL(10,2),
    IN p_id_proveedor INT, IN p_stock INT, IN p_id_categoria INT, IN p_origen VARCHAR(20)
)
BEGIN
    INSERT INTO productos (nombre_producto, id_talla, color, precio_unitario,
                            id_proveedor, stock_disponible, id_categoria, origen)
    VALUES (p_nombre, p_id_talla, p_color, p_precio, p_id_proveedor, p_stock, p_id_categoria, p_origen);
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_producto('Chompa', 3, 'Azul', 45.50, 2, 20, 1, 'Importado');


-- 3. Registrar Venta
-- Registra venta + detalle (un producto), actualiza inventario y aplica promocion
DELIMITER //
CREATE PROCEDURE sp_registrar_venta(
    IN p_fecha DATE, IN p_id_sucursal INT, IN p_id_pago INT, IN p_id_cliente INT,
    IN p_id_vendedor INT, IN p_id_cajero INT, IN p_id_promocion INT,
    IN p_id_producto INT, IN p_cantidad INT
)
BEGIN
    DECLARE v_id_venta INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(10,2) DEFAULT 0;
    DECLARE v_iva DECIMAL(10,2);

    INSERT INTO ventas (fecha_venta, id_sucursal, id_pago, id_cliente,
                         id_vendedor, id_cajero, id_promocion)
    VALUES (p_fecha, p_id_sucursal, p_id_pago, p_id_cliente,
            p_id_vendedor, p_id_cajero, p_id_promocion);

    SET v_id_venta = LAST_INSERT_ID();

    SELECT precio_unitario INTO v_precio FROM productos WHERE id_producto = p_id_producto;
    SET v_subtotal = v_precio * p_cantidad;

    INSERT INTO detalle_venta (id_venta, id_producto, cantidad_vendida, precio_unitario, subtotal)
    VALUES (v_id_venta, p_id_producto, p_cantidad, v_precio, v_subtotal);

    UPDATE productos SET stock_disponible = stock_disponible - p_cantidad
    WHERE id_producto = p_id_producto;

    INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
    VALUES (p_id_producto, p_id_sucursal, 'Salida', p_cantidad, p_fecha, 'Venta a cliente');

    IF p_id_promocion IS NOT NULL THEN
        SET v_descuento = fn_calcular_descuento_promocion(v_subtotal, p_id_promocion);
    END IF;

    SET v_iva = fn_calcular_iva(v_subtotal - v_descuento);

    INSERT INTO facturas (numero_factura, id_venta, descuento_aplicado, subtotal_neto, impuesto, total_factura, monto_pagado)
    VALUES (CONCAT('FAC-', v_id_venta), v_id_venta, v_descuento, v_subtotal - v_descuento, v_iva,
            (v_subtotal - v_descuento) + v_iva, (v_subtotal - v_descuento) + v_iva);
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_venta('2026-07-19', 1, 1, 5, 2, 11, NULL, 3, 2);

-- 4. Registrar Devolución
DELIMITER //
CREATE PROCEDURE sp_registrar_devolucion(
    IN p_id_venta INT, IN p_id_producto INT, IN p_cantidad INT,
    IN p_motivo VARCHAR(150), IN p_monto_reembolso DECIMAL(10,2)
)
BEGIN
    DECLARE v_id_sucursal INT;

    INSERT INTO devoluciones (id_venta, id_producto, fecha_devolucion, cantidad_devuelta, motivo, monto_reembolso)
    VALUES (p_id_venta, p_id_producto, CURDATE(), p_cantidad, p_motivo, p_monto_reembolso);

    UPDATE productos SET stock_disponible = stock_disponible + p_cantidad
    WHERE id_producto = p_id_producto;

    SELECT id_sucursal INTO v_id_sucursal FROM ventas WHERE id_venta = p_id_venta;

    INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
    VALUES (p_id_producto, v_id_sucursal, 'Entrada', p_cantidad, CURDATE(), 'Devolucion de cliente');
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_devolucion(22, 20, 1, 'Producto defectuoso', 48.96);

-- 5. Aplicar Promoción
DELIMITER //
CREATE PROCEDURE sp_aplicar_promocion(IN p_id_venta INT, IN p_id_promocion INT)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2);
    DECLARE v_descuento DECIMAL(10,2);
    DECLARE v_iva DECIMAL(10,2);

    IF NOT EXISTS (SELECT 1 FROM promociones WHERE id_promocion = p_id_promocion) THEN
        SELECT CONCAT('La promocion ', p_id_promocion, ' no existe') AS mensaje;
    ELSE
        SELECT SUM(subtotal) INTO v_subtotal FROM detalle_venta WHERE id_venta = p_id_venta;
        SET v_descuento = fn_calcular_descuento_promocion(v_subtotal, p_id_promocion);
        SET v_iva = fn_calcular_iva(v_subtotal - v_descuento);

        UPDATE ventas SET id_promocion = p_id_promocion WHERE id_venta = p_id_venta;

        UPDATE facturas
        SET descuento_aplicado = v_descuento,
            subtotal_neto = v_subtotal - v_descuento,
            impuesto = v_iva,
            total_factura = (v_subtotal - v_descuento) + v_iva
        WHERE id_venta = p_id_venta;
    END IF;
END //
DELIMITER ;
-- Uso: 
CALL sp_aplicar_promocion(10, 3);

-- 6. Calcular Ventas Mensuales
DELIMITER //
CREATE PROCEDURE sp_calcular_ventas_mensuales()
BEGIN
    SELECT DATE_FORMAT(v.fecha_venta, '%Y-%m') AS mes, COUNT(v.id_venta) AS total_ventas
    FROM ventas v
    GROUP BY DATE_FORMAT(v.fecha_venta, '%Y-%m')
    ORDER BY mes;
END //
DELIMITER ;
-- Uso: 
CALL sp_calcular_ventas_mensuales();

-- 7. Registrar Proveedor
DELIMITER //
CREATE PROCEDURE sp_registrar_proveedor(IN p_nombre VARCHAR(50))
BEGIN
    INSERT INTO proveedores (nombre_proveedor) VALUES (p_nombre);
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_proveedor('Textiles del Pacifico');

-- 8. Actualizar Inventario
DELIMITER //
CREATE PROCEDURE sp_actualizar_inventario(
    IN p_id_producto INT, IN p_id_sucursal INT, IN p_tipo_movimiento VARCHAR(20),
    IN p_cantidad INT, IN p_motivo VARCHAR(150)
)
BEGIN
    IF p_tipo_movimiento = 'Entrada' THEN
        UPDATE productos SET stock_disponible = stock_disponible + p_cantidad
        WHERE id_producto = p_id_producto;
    ELSEIF p_tipo_movimiento = 'Salida' THEN
        UPDATE productos SET stock_disponible = stock_disponible - p_cantidad
        WHERE id_producto = p_id_producto;
    END IF;

    INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
    VALUES (p_id_producto, p_id_sucursal, p_tipo_movimiento, p_cantidad, CURDATE(), p_motivo);
END //
DELIMITER ;
-- Uso: 
CALL sp_actualizar_inventario(5, 2, 'Entrada', 30, 'Reposicion de stock');

-- 9. Registrar Queja
DELIMITER //
CREATE PROCEDURE sp_registrar_queja(IN p_id_cliente INT, IN p_descripcion TEXT)
BEGIN
    INSERT INTO quejas (id_cliente, fecha_queja, descripcion, estado)
    VALUES (p_id_cliente, CURDATE(), p_descripcion, 'Pendiente');
END //
DELIMITER ;
-- Uso:
 CALL sp_registrar_queja(14, 'El producto llego con una talla incorrecta');

-- 10. Registrar Auditoría
DELIMITER //
CREATE PROCEDURE sp_registrar_auditoria(
    IN p_tabla_afectada VARCHAR(30), IN p_id_registro_afectado VARCHAR(50),
    IN p_accion VARCHAR(20), IN p_id_empleado INT
)
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (p_tabla_afectada, p_id_registro_afectado, p_accion, p_id_empleado, NOW());
END //
DELIMITER ;
-- Uso: 
CALL sp_registrar_auditoria('Clientes', '14', 'UPDATE', 3);

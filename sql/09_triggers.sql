-- TRIGGERS

-- 1. Trigger para calcular el subtotal automáticamente en detalle_venta
DELIMITER //

CREATE TRIGGER trg_calcular_subtotal
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    SET NEW.subtotal = NEW.cantidad_vendida * NEW.precio_unitario;
END //

DELIMITER ;


INSERT INTO detalle_venta (id_venta, id_producto, cantidad_vendida, precio_unitario, subtotal)
VALUES (1, 2, 3, 17.68, 0);

-- Verificar que subtotal = 53.04
SELECT * FROM detalle_venta WHERE id_venta = 1 AND id_producto = 2;

-- 2. Trigger para controlar el stock negativo

DELIMITER //

CREATE TRIGGER trg_control_stock_negativo
BEFORE INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    DECLARE stock_actual INT;

    -- Consultar el stock actual del producto
    SELECT stock_disponible INTO stock_actual
    FROM productos
    WHERE id_producto = NEW.id_producto;

    -- Validar si la cantidad supera el inventario disponible
    IF stock_actual < NEW.cantidad_vendida THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock insuficiente en la sucursal para completar la venta de este producto.';
    END IF;

END //

DELIMITER ;

INSERT INTO detalle_venta (id_venta, id_producto, cantidad_vendida, precio_unitario, subtotal)
VALUES (1, 11, 9999, 12.92, 0);

-- 3. Trigger para validar que la devolucion de la compra si se lo hace en menos de 30 dias
DELIMITER //

CREATE TRIGGER trg_validar_plazo_devolucion
BEFORE INSERT ON devoluciones
FOR EACH ROW
BEGIN
    DECLARE fecha_venta_original DATE;

    SELECT fecha_venta INTO fecha_venta_original
    FROM ventas
    WHERE id_venta = NEW.id_venta;

    IF DATEDIFF(NEW.fecha_devolucion, fecha_venta_original) > 30 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No se puede devolver un producto después de 30 días de la venta.';
    END IF;
END //

DELIMITER ;

INSERT INTO devoluciones (id_venta, id_producto, fecha_devolucion, cantidad_devuelta, motivo, monto_reembolso)
VALUES (1, 14, '2027-01-01', 1, 'Prueba', 38.73);

-- 4. TRIGGER PARA DESCONTAR EL STOCK DE LOS PRODUCTOS AL REALIZAR UNA VENTA
DELIMITER //

CREATE TRIGGER trg_descontar_stock_venta
AFTER INSERT ON detalle_venta
FOR EACH ROW
BEGIN
    -- Descontar el stock en la tabla productos
    UPDATE productos
    SET stock_disponible = stock_disponible - NEW.cantidad_vendida
    WHERE id_producto = NEW.id_producto;

    -- Registrar el movimiento en la tabla de movimientos de inventario
    INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
    SELECT 
        NEW.id_producto, 
        v.id_sucursal, 
        'VENTA', 
        NEW.cantidad_vendida, 
        CURRENT_DATE(), 
        CONCAT('Venta ID: ', NEW.id_venta)
    FROM ventas v
    WHERE v.id_venta = NEW.id_venta;

END //

DELIMITER ;

-- Ver stock antes
SELECT id_producto, stock_disponible FROM productos WHERE id_producto = 3;

-- Insertar detalle venta
INSERT INTO detalle_venta (id_venta, id_producto, cantidad_vendida, precio_unitario, subtotal)
VALUES (1, 3, 1, 41.14, 0);

-- Ver stock despues 
SELECT id_producto, stock_disponible FROM productos WHERE id_producto = 3;

-- 5. TRIGGER PARA INCREMENTAR EL STOCK DE LA PRENDA AL REALIZAR UNA DEVOLUCION
DELIMITER //

CREATE TRIGGER trg_incrementar_stock_devolucion
AFTER INSERT ON devoluciones
FOR EACH ROW
BEGIN
    
    UPDATE productos
    SET stock_disponible = stock_disponible + NEW.cantidad_devuelta
    WHERE id_producto = NEW.id_producto;

    INSERT INTO movimientos_inventario (id_producto, id_sucursal, tipo_movimiento, cantidad, fecha_movimiento, motivo)
    SELECT 
        NEW.id_producto, 
        v.id_sucursal, 
        'DEVOLUCION', 
        NEW.cantidad_devuelta, 
        NEW.fecha_devolucion, 
        CONCAT('Devolución ID: ', NEW.id_devoluciones, ' - Motivo: ', NEW.motivo)
    FROM ventas v
    WHERE v.id_venta = NEW.id_venta;

END //

DELIMITER ;

-- Ver stock antes
SELECT id_producto, stock_disponible FROM productos WHERE id_producto = 14;

-- Insertar devolucion
INSERT INTO devoluciones (id_venta, id_producto, fecha_devolucion, cantidad_devuelta, motivo, monto_reembolso)
VALUES (1, 14, '2026-02-27', 1, 'Talla incorrecta', 38.73);

-- Ver stock despues 
SELECT id_producto, stock_disponible FROM productos WHERE id_producto = 14;


-- 6. Trigger de auditoria despues de insertar un cliente
DELIMITER //
CREATE TRIGGER trg_auditoria_clientes_insert
AFTER INSERT ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (
        'clientes', 
        NEW.id_cliente, 
        'INSERT', 
        @empleado_actual,  
        CURRENT_TIMESTAMP()
    );
END //
DELIMITER ;

SET @empleado_actual = 19;
INSERT INTO clientes (nombre_cliente, cedula_cliente, telefono_cliente, correo_cliente)
VALUES ('Carla Perez', '1750934510', '0962613456', 'carla.perez@gmail.com');

SELECT * FROM auditoria;

-- 7. Trigger de auditoria despues de cambiar de la informacion de un cliente

DELIMITER //

CREATE TRIGGER trg_auditoria_clientes_update
AFTER UPDATE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (
        'clientes', 
        NEW.id_cliente, 
        'UPDATE', 
        @empleado_actual, 
        CURRENT_TIMESTAMP()
    );
END //

DELIMITER ;

SET @empleado_actual = 19;
UPDATE clientes SET telefono_cliente = '0962616789' WHERE cedula_cliente = '1750934510';
SELECT * FROM auditoria;


-- 8. Trigger de auditoria despues de eliminar un cliente 
DELIMITER //

CREATE TRIGGER trg_auditoria_clientes_delete
AFTER DELETE ON clientes
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (
        'clientes', 
        OLD.id_cliente, 
        'DELETE', 
        @empleado_actual, 
        CURRENT_TIMESTAMP()
    );
END //

DELIMITER ;

SET @empleado_actual = 19;
DELETE FROM clientes WHERE cedula_cliente = '1750134510';
SELECT * FROM auditoria;

-- 9. Trigger de auditoria despues de registrar un nuevo producto

DELIMITER //
CREATE TRIGGER trg_auditoria_productos_insertar
AFTER INSERT ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (
        'productos', 
        NEW.id_producto, 
        'INSERT', 
        @empleado_actual, 
        CURRENT_TIMESTAMP()
    );
END //

DELIMITER ;

INSERT INTO productos (nombre_producto, precio_unitario, stock_disponible, id_talla, id_proveedor, id_categoria)
VALUES ('Producto Prueba', 25.00, 10, 1, 1, 1);
SELECT * FROM auditoria;

-- 10. Trigger de auditoria despues de eliminar producto

DELIMITER //
CREATE TRIGGER trg_auditoria_productos_delete
AFTER DELETE ON productos
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
    VALUES (
        'productos', 
        OLD.id_producto, 
        'DELETE', 
        @empleado_actual, 
        CURRENT_TIMESTAMP()
    );
END //

DELIMITER ;

-- DELETE
DELETE FROM productos WHERE id_producto = '23';
SELECT * FROM auditoria;

-- 11. Trigger para registrar el cambio del precio de un producto
DELIMITER //

CREATE TRIGGER trg_auditoria_cambio_precio
AFTER UPDATE ON productos
FOR EACH ROW
BEGIN
    -- Valida si realmente hubo un cambio en el precio unitario
    IF OLD.precio_unitario <> NEW.precio_unitario THEN
        INSERT INTO auditoria (tabla_afectada, id_registro_afectado, accion, id_empleado, fecha_hora)
        VALUES (
            'productos', 
            NEW.id_producto, 
            'UPDATE_PRECIO', 
            @empleado_actual, 
            CURRENT_TIMESTAMP()
        );
    END IF;
END //

DELIMITER ;

UPDATE productos SET precio_unitario = 99.99 WHERE id_producto = 1;
SELECT * FROM auditoria;

-- 12. Trigger para evitar que una queja resuelta vuelva a Pendiente

DELIMITER //

CREATE TRIGGER trg_validar_estado_queja
BEFORE UPDATE ON quejas
FOR EACH ROW
BEGIN
    IF OLD.estado = 'Resuelta' AND NEW.estado = 'Pendiente' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Una queja resuelta no puede volver a estado Pendiente.';
    END IF;
END //

DELIMITER ;

INSERT INTO quejas (id_cliente, descripcion, estado)
VALUES (1, 'Queja de prueba', 'Resuelta');


UPDATE quejas SET estado = 'Pendiente' WHERE id_cliente = 1;





-- VISTAS 

-- VISTA 1: Clientes mas frecuentes, los que mas compran

CREATE VIEW vw_clientes_frecuentes AS
SELECT
    cl.id_cliente,
    cl.nombre_cliente,
    cl.cedula_cliente,
    cl.telefono_cliente,
    COUNT(v.id_venta)       AS total_compras,
    SUM(f.total_factura)    AS monto_acumulado
FROM clientes cl
JOIN ventas v   ON v.id_cliente = cl.id_cliente
JOIN facturas f ON f.id_venta   = v.id_venta
GROUP BY
    cl.id_cliente,
    cl.nombre_cliente,
    cl.cedula_cliente,
    cl.telefono_cliente
ORDER BY monto_acumulado DESC;

-- VISTA 2: Productos disponibles en la tienda

CREATE VIEW vw_productos_disponibles AS
SELECT p.id_producto, p.nombre_producto, c.nombre_categoria AS tipo_producto,
       p.precio_unitario, p.stock_disponible
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock_disponible > 0;

-- VISTA 3: Ventas Consolidadas

-- Detalle general de cada venta

CREATE VIEW vw_ventas_consolidadas AS
SELECT
    v.id_venta,
    v.fecha_venta,
    cl.nombre_cliente                           AS cliente,
    e.nombre_empleado                           AS vendedor,
    mp.metodo_pago                              AS tipo_pago,
    SUM(dv.subtotal)                            AS subtotal_bruto,
    f.descuento_aplicado,
    f.total_factura                             AS total
FROM ventas v
JOIN clientes cl       ON v.id_cliente  = cl.id_cliente
JOIN empleados e       ON v.id_vendedor = e.id_empleado
JOIN metodos_pago mp   ON v.id_pago     = mp.id_pago
JOIN detalle_venta dv  ON dv.id_venta   = v.id_venta
JOIN facturas f        ON f.id_venta    = v.id_venta
GROUP BY
    v.id_venta,
    v.fecha_venta,
    cl.nombre_cliente,
    e.nombre_empleado,
    mp.metodo_pago,
    f.descuento_aplicado,
    f.total_factura
ORDER BY v.fecha_venta DESC;


-- VISTA 4: Productos mas vendidos

CREATE VIEW vw_productos_mas_vendidos AS
SELECT p.nombre_producto AS producto,
       SUM(dv.cantidad_vendida) AS total_unidades_vendidas
FROM detalle_venta dv
JOIN productos p ON dv.id_producto = p.id_producto
GROUP BY p.nombre_producto;


-- VISTA 5: Productos con Bajo Stock

CREATE VIEW vw_productos_bajo_stock AS
SELECT
    p.id_producto,
    p.nombre_producto,
    c.nombre_categoria  AS categoria,
    p.stock_disponible  AS stock_actual,
    p.stock_minimo
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock_disponible < p.stock_minimo
ORDER BY p.stock_disponible ASC;


-- VISTA 6: Productos que nunca se han vendido

CREATE VIEW vw_productos_nunca_vendidos AS
SELECT p.id_producto, p.nombre_producto, p.stock_disponible
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 
    FROM detalle_venta dv 
    WHERE dv.id_producto = p.id_producto
);

-- VISTA 7: Productos que tienen un precio mayor al promedio

CREATE VIEW vw_productos_precio_mayor_promedio AS
SELECT nombre_producto AS producto, precio_unitario AS precio
FROM productos
WHERE precio_unitario > (SELECT AVG(precio_unitario) FROM productos);

-- VISTA 8: Promociones Aplicadas,analiza el impacto de las promociones en ventas

CREATE VIEW vw_promociones_aplicadas AS
SELECT
    v.id_venta,
    cl.nombre_cliente           AS cliente,
    pr.descripcion_promocion    AS promocion,
    pr.porcentaje_descuento     AS porcentaje,
    f.descuento_aplicado,
    v.fecha_venta
FROM ventas v
JOIN clientes cl    ON v.id_cliente   = cl.id_cliente
JOIN promociones pr ON v.id_promocion = pr.id_promocion
JOIN facturas f     ON f.id_venta     = v.id_venta
ORDER BY f.descuento_aplicado DESC;


-- VISTA 9: Devoluciones
-- Controla las devoluciones realizadas

CREATE VIEW vw_devoluciones AS
SELECT
    d.id_devoluciones,
    d.fecha_devolucion,
    cl.nombre_cliente   AS cliente,
    p.nombre_producto   AS producto,
    d.cantidad_devuelta AS cantidad,
    d.motivo,
    d.monto_reembolso
FROM devoluciones d
JOIN ventas v   ON d.id_venta    = v.id_venta
JOIN clientes cl ON v.id_cliente = cl.id_cliente
JOIN productos p ON d.id_producto = p.id_producto
ORDER BY d.fecha_devolucion DESC;

-- VISTA 10: Empleados por rol
CREATE VIEW vw_empleados_por_rol AS
SELECT id_empleado, nombre_empleado, rol_empleado
FROM empleados;

-- VISTA 11: Desempeño de Vendedores
-- Evalua el desempeño comercial de cada vendedor

CREATE VIEW vw_desempeno_vendedores AS
SELECT
    e.id_empleado,
    e.nombre_empleado,
    COUNT(DISTINCT v.id_venta)      AS total_ventas,
    SUM(f.total_factura)            AS monto_generado,
    COUNT(DISTINCT d.id_devoluciones) AS total_devoluciones
FROM empleados e
LEFT JOIN ventas v        ON v.id_vendedor      = e.id_empleado
LEFT JOIN facturas f      ON f.id_venta         = v.id_venta
LEFT JOIN devoluciones d  ON d.id_venta         = v.id_venta
WHERE e.rol_empleado = 'Vendedor'
GROUP BY
    e.id_empleado,
    e.nombre_empleado
ORDER BY monto_generado DESC;

-- CONSULTAS DE PRUEBA

SELECT * FROM vw_clientes_frecuentes;
SELECT * FROM vw_productos_disponibles;
SELECT * FROM vw_ventas_consolidadas;
SELECT * FROM vw_productos_mas_vendidos;
SELECT * FROM vw_productos_bajo_stock;
SELECT * FROM vw_productos_nunca_vendidos;
SELECT * FROM vw_productos_precio_mayor_promedio;
SELECT * FROM vw_promociones_aplicadas;
SELECT * FROM vw_devoluciones;
SELECT * FROM vw_empleados_por_rol;
SELECT * FROM vw_desempeno_vendedores;

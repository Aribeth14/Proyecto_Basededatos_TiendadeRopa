-----------------
--CONSULTAS SQL 
-----------------
-- 1. Listado de clientes
SELECT id_cliente, nombre_cliente, cedula_cliente, telefono_cliente, correo_cliente
FROM clientes;
-- 2. Productos disponibles
SELECT  p.id_producto,p.nombre_producto,c.nombre_categoria AS tipo_producto,
		p.precio_unitario,p.stock_disponible
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
WHERE p.stock_disponible > 0;

-- 3.Ventas por fecha
SELECT  v.id_venta, v.fecha_venta,
		cl.nombre_cliente AS cliente,
		f.total_factura AS total_venta
FROM ventas v
JOIN clientes cl ON v.id_cliente=cl.id_cliente
JOIN facturas f ON f.id_venta=v.id_venta
ORDER BY v.fecha_venta;

--4. Proveedores registrados
SELECT id_proveedor,nombre_proveedor
FROM proveedores;

--5.Empleados por rol
SELECT id_empleado,nombre_empleado,rol_empleado
FROM empleados
ORDER BY rol_empleado;

--6. Clientes con sus compras JOIN
SELECT  cl.nombre_cliente AS cliente,
		v.fecha_venta,
		f.total_factura AS total_venta,
		mp.metodo_pago AS tipo_venta
FROM ventas v
JOIN clientes cl ON v.id_cliente=cl.id_cliente
JOIN facturas f ON f.id_venta=v.id_venta
JOIN metodos_pago mp ON v.id_pago=mp.id_pago;

--7. Ventas con Vendedor
SELECT  v.id_venta,
		cl.nombre_cliente AS cliente,
		e.nombre_empleado AS vendedor,
		v.fecha_venta,
		f.total_factura AS total_venta
FROM ventas v
JOIN clientes cl ON v.id_cliente =cl.id_cliente
JOIN empleados e ON v.id_vendedor=e.id_empleado
JOIN facturas f ON f.id_venta=v.id_venta;

--8. Detalle de productos vendidos
SELECT  dv.id_venta,
		p.nombre_producto AS producto,
		dv.cantidad_vendida,dv.precio_unitario,dv.subtotal
FROM detalleventa dv 	
JOIN productos p ON dv.id_producto=p.id_producto;

--9. Productos con proveedor 
SELECT  p.nombre_producto AS producto,
		c.nombre_categoria AS tipo_producto,
		pr.nombre_proveedor AS proveedor
FROM productos p
JOIN categorias c ON p.id_categoria = c.id_categoria
JOIN proveedores pr ON p.id_proveedor = pr.id_proveedor;

--10.Devoluciones con cliente y producto
SELECT  cl.nombre_cliente AS cliente,
		p.nombre_producto AS producto,
		d.fecha_devolucion,d.motivo,
		d.cantidad_devuelta AS cantidad
FROM devoluciones d
JOIN ventas v ON d.id_venta = v.id_venta
JOIN clientes cl ON v.id_cliente = cl.id_cliente
JOIN productos p ON d.id_producto =p.id_producto;

--11.Total vendido por vendedor (GROUP BY)
SELECT  e.nombre_empleado AS vendedor,
		COUNT(v.id_venta) AS cantidad_ventas,
		SUM(f.total_factura) AS total_vendido
FROM ventas v
JOIN empleados e ON v.id_vendedor=e.id_empleado
JOIN facturas f ON f.id_venta = v.id_venta
GROUP BY e.nombre_empleado
ORDER BY total_vendido DESC;

--12.Productos mas vendidos (GROUP BY)
SELECT  p.nombre_producto AS producto,
		SUM(dv.cantidad_vendida) AS total_unidades_vendidas
FROM detalleventa dv
JOIN productos p ON dv.id_producto=p.id_producto
GROUP BY p.nombre_producto
ORDER BY total_unidades_vendidas ASC;

--13.Ventas por mes (GROUP BY)
SELECT  TO_CHAR(v.fecha_venta, 'YYYY-MM') AS mes,
		COUNT(v.id_venta) AS total_ventas,
		SUM(f.total_factura) AS monto_total
FROM ventas v
JOIN facturas f ON f.id_venta=v.id_venta
GROUP BY TO_CHAR(v.fecha_venta, 'YYYY-MM')
ORDER BY mes;

--14. Compras por cliente (GROUP BY)
SELECT  cl.nombre_cliente AS cliente,
		COUNT(v.id_venta) AS cantidad_compras,
		SUM(f.total_factura) AS monto_acumulado
FROM ventas v
JOIN clientes cl ON v.id_cliente=cl.id_cliente
JOIN facturas f ON f.id_venta=v.id_venta
GROUP BY cl.nombre_cliente
ORDER BY monto_acumulado ASC;

--15.Devoluciones por vendedor (GROUP BY)
SELECT  e.nombre_empleado AS vendedor,
		COUNT (d.id_devoluciones) AS total_devoluciones
FROM devoluciones d
JOIN ventas v ON d.id_venta = v.id_venta
JOIN empleados e ON v.id_vendedor= e.id_empleado
GROUP BY e.nombre_empleado
ORDER BY total_devoluciones DESC;

-----------------
-- SUBCONSULTAS
-----------------
--16. Clientes con compras superiores al promedio 
SELECT  cl.nombre_cliente AS cliente,
		SUM(f.total_factura) AS total_comprado
FROM ventas v
JOIN clientes cl ON v.id_cliente = cl.id_cliente
JOIN facturas f ON f.id_venta=v.id_venta
GROUP BY cl.nombre_cliente
HAVING SUM(f.total_factura)> (SELECT AVG(total_factura) FROM facturas);

--17.Productos con precio mayor al promedio
SELECT nombre_producto AS producto, precio_unitario AS precio
FROM productos
WHERE precio_unitario > (SELECT AVG(precio_unitario) FROM productos);

--18. Vendedores con ventas superiores al promedio
SELECT nombre_empleado AS vendedor,total_vendido
FROM (
		SELECT e.id_empleado,e.nombre_empleado,
		SUM(f.total_factura) AS total_vendido
		FROM ventas v
		JOIN empleados e ON v.id_vendedor=e.id_empleado
		JOIN facturas f ON f.id_venta=v.id_venta
		GROUP BY e.id_empleado,e.nombre_empleado
)AS ventas_por_vendedor
WHERE total_vendido >(
	SELECT AVG(total_vendido)
	FROM(
		SELECT SUM(f.total_factura) AS total_vendido
		FROM ventas v
		JOIN empleados e ON v.id_vendedor=e.id_empleado
		JOIN facturas f ON f.id_venta=v.id_venta
		GROUP BY e.id_empleado
	)AS sub
);

--19. Productos que nunca se han vendido
SELECT id_producto,nombre_producto,stock_disponible
FROM productos
WHERE id_producto NOT IN(SELECT DISTINCT id_producto FROM detalleventa);

--20.Clientes que no han realizado compras
SELECT id_cliente,nombre_cliente,telefono_cliente
FROM clientes
WHERE id_cliente NOT IN(SELECT DISTINCT id_cliente FROM ventas);








		
		
		

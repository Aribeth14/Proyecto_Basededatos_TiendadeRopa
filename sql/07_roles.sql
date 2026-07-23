-- ROLES DE LA TIENDA

-- ROL ADMINISTRADOR
CREATE ROLE 'rol_administrador';
GRANT ALL PRIVILEGES ON *.* TO 'rol_administrador' WITH GRANT OPTION;
FLUSH PRIVILEGES;

-- ROL GERENTE
CREATE ROLE 'rol_gerente';

-- Otorgar permisos de lectura a las tablas operativas y de negocio
GRANT SELECT ON tienda_ropa.sucursales TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.categorias TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.tallas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.proveedores TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.metodos_pago TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.clientes TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.promociones TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.empleados TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.productos TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.ventas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.detalle_venta TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.facturas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.devoluciones TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.movimientos_inventario TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.quejas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.auditoria TO 'rol_gerente';

-- Otorgar permisos sobre las vistas del negocio 
GRANT SELECT ON tienda_ropa.vw_clientes_frecuentes TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_productos_disponibles TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_ventas_consolidadas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_productos_mas_vendidos TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_productos_bajo_stock TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_productos_nunca_vendidos TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_productos_precio_mayor_promedio TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_promociones_aplicadas TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_devoluciones TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_empleados_por_rol TO 'rol_gerente';
GRANT SELECT ON tienda_ropa.vw_desempeno_vendedores TO 'rol_gerente';

-- Permisos para aprobar promociones
GRANT SELECT, UPDATE ON tienda_ropa.promociones TO 'rol_gerente';
-- Permisos para autorizar devoluciones
GRANT SELECT, UPDATE ON tienda_ropa.devoluciones TO 'rol_gerente';

FLUSH PRIVILEGES;

-- ROL CAJERO

CREATE ROLE 'rol_cajero';

GRANT SELECT, UPDATE ON tienda_ropa.ventas TO 'rol_cajero';

GRANT SELECT, INSERT ON tienda_ropa.facturas TO 'rol_cajero';

-- Permisos de solo lectura para el cobro y la factura
GRANT SELECT ON tienda_ropa.metodos_pago TO 'rol_cajero';  
GRANT SELECT ON tienda_ropa.detalle_venta TO 'rol_cajero';  
GRANT SELECT ON tienda_ropa.productos TO 'rol_cajero';      
GRANT SELECT ON tienda_ropa.clientes TO 'rol_cajero';      
GRANT SELECT ON tienda_ropa.promociones TO 'rol_cajero';

FLUSH PRIVILEGES;

-- ROL VENDEDOR

CREATE ROLE 'rol_vendedor';

-- Permisos de lectura  para consultar el inventario, tallas, categorias y clientes
GRANT SELECT ON tienda_ropa.productos TO 'rol_vendedor';
GRANT SELECT ON tienda_ropa.tallas TO 'rol_vendedor';
GRANT SELECT ON tienda_ropa.categorias TO 'rol_vendedor';
GRANT SELECT ON tienda_ropa.clientes TO 'rol_vendedor';
GRANT SELECT ON tienda_ropa.sucursales TO 'rol_vendedor';
GRANT SELECT ON tienda_ropa.promociones TO 'rol_vendedor';

-- Permisos iniciar la venta, detalle_venta
GRANT SELECT, INSERT ON tienda_ropa.ventas TO 'rol_vendedor';
GRANT SELECT, INSERT ON tienda_ropa.detalle_venta TO 'rol_vendedor';

FLUSH PRIVILEGES;

-- ROL AUDITOR
CREATE ROLE 'rol_auditor';

-- Otorgar permisos exclusivos de solo lectura sobre las tablas de auditoria, ventas y devoluciones
GRANT SELECT ON tienda_ropa.auditoria TO 'rol_auditor';
GRANT SELECT ON tienda_ropa.ventas TO 'rol_auditor';
GRANT SELECT ON tienda_ropa.devoluciones TO 'rol_auditor';

-- Opcional: Tablas complementarias para dar contexto completo a las ventas y auditorias
GRANT SELECT ON tienda_ropa.detalle_venta TO 'rol_auditor';
GRANT SELECT ON tienda_ropa.facturas TO 'rol_auditor';
GRANT SELECT ON tienda_ropa.empleados TO 'rol_auditor';
GRANT SELECT ON tienda_ropa.clientes TO 'rol_auditor';

FLUSH PRIVILEGES;

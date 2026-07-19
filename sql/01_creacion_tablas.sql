--Nombre de la Base de datos: tienda_ropa 
-- Tablas con restricciones CASCADE / RESTRICT / SET NULL

CREATE DATABASE tienda_ropa;
USE tienda_ropa;


CREATE TABLE sucursales(
    id_sucursal        INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sucursal    VARCHAR(50) NOT NULL,
    direccion_sucursal VARCHAR(50)
);

CREATE TABLE categorias(
    id_categoria     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL,
    descripcion      TEXT
);

CREATE TABLE tallas(
    id_talla     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_talla VARCHAR(50) NOT NULL
);

CREATE TABLE proveedores(
    id_proveedor     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_proveedor VARCHAR(50) NOT NULL
);

CREATE TABLE metodos_pago(
    id_pago     INT AUTO_INCREMENT PRIMARY KEY,
    metodo_pago VARCHAR(30) NOT NULL
);

CREATE TABLE clientes(
    id_cliente       INT AUTO_INCREMENT PRIMARY KEY,
    nombre_cliente   VARCHAR(75) NOT NULL,
    cedula_cliente   VARCHAR(15) UNIQUE NOT NULL,
    telefono_cliente VARCHAR(15),
    correo_cliente   VARCHAR(50),
    fecha_nacimiento DATE
);

CREATE TABLE promociones(
    id_promocion          INT AUTO_INCREMENT PRIMARY KEY,
    descripcion_promocion TEXT,
    porcentaje_descuento  DECIMAL(5,2)
);

-- ------------------------------
-- TABLAS CON FK (clave foranea)
-- ------------------------------
-- RESTRICT: no eliminar sucursal si tiene empleados
CREATE TABLE empleados(
    id_empleado     INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empleado VARCHAR(75) NOT NULL,
    rol_empleado    VARCHAR(30) NOT NULL,
    id_sucursal     INT,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
	ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RESTRICT en talla, proveedor, categoria: no eliminar si hay productos asociados
CREATE TABLE productos(
    id_producto      INT AUTO_INCREMENT PRIMARY KEY,
    nombre_producto  VARCHAR(50) NOT NULL,
    id_talla         INT,
    color            VARCHAR(15),
    precio_unitario  DECIMAL(10,2) NOT NULL,
    id_proveedor     INT,
    stock_disponible INT NOT NULL DEFAULT 0,
    id_categoria     INT,
    origen           VARCHAR(20) NOT NULL DEFAULT 'Nacional'
                     CHECK (origen IN ('Nacional','Importado')),
    stock_minimo     INT NOT NULL DEFAULT 5,
    FOREIGN KEY (id_talla) REFERENCES tallas(id_talla)
	ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
	ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
	ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RESTRICT en sucursal, metodo_pago, cliente: no eliminar si tiene ventas
-- SET NULL en promocion: si se elimina la promo, la venta queda sin promo
-- RESTRICT en vendedor/cajero: no eliminar empleado con ventas
CREATE TABLE ventas(
    id_venta     INT AUTO_INCREMENT PRIMARY KEY,
    fecha_venta  DATE NOT NULL,
    id_sucursal  INT,
    id_pago      INT,
    id_cliente   INT,
    id_vendedor  INT,
    id_cajero    INT,
    id_promocion INT,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_pago) REFERENCES metodos_pago(id_pago)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_vendedor) REFERENCES empleados(id_empleado)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_cajero) REFERENCES empleados(id_empleado)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- CASCADE: si se elimina la venta, se elimina el detalle
-- RESTRICT: no eliminar producto con ventas registradas
CREATE TABLE detalle_venta(
    id_venta         INT,
    id_producto      INT,
    cantidad_vendida INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    subtotal         DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_venta, id_producto),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
    ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- CASCADE: si se elimina la venta, se elimina la factura
CREATE TABLE facturas(
    id_factura         INT AUTO_INCREMENT PRIMARY KEY,
    numero_factura     VARCHAR(20) UNIQUE NOT NULL,
    id_venta           INT,
    descuento_aplicado DECIMAL(10,2) NOT NULL DEFAULT 0,
    subtotal_neto      DECIMAL(10,2) NOT NULL,
    impuesto           DECIMAL(10,2) NOT NULL,
    total_factura      DECIMAL(10,2) NOT NULL,
    monto_pagado       DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- RESTRICT: no eliminar venta ni producto si hay devoluciones pendientes
CREATE TABLE devoluciones(
    id_devoluciones   INT AUTO_INCREMENT PRIMARY KEY,
    id_venta          INT,
    id_producto       INT,
    fecha_devolucion  DATE NOT NULL,
    cantidad_devuelta INT NOT NULL,
    motivo            TEXT,
    monto_reembolso   DECIMAL(10,2),
    FOREIGN KEY (id_venta) REFERENCES ventas(id_venta)
	ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
	ON DELETE RESTRICT ON UPDATE CASCADE
);

-- RESTRICT: trazabilidad de inventario
CREATE TABLE movimientos_inventario(
    id_movimiento    INT AUTO_INCREMENT PRIMARY KEY,
    id_producto      INT,
    id_sucursal      INT,
    tipo_movimiento  VARCHAR(20) NOT NULL,
    cantidad         INT NOT NULL,
    fecha_movimiento DATE NOT NULL,
    motivo           TEXT,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
	ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
	ON DELETE RESTRICT ON UPDATE CASCADE
);

-- SET NULL: el registro de auditoria queda aunque se elimine el empleado
CREATE TABLE auditoria(
    id_auditoria         INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada       VARCHAR(30) NOT NULL,
    id_registro_afectado VARCHAR(50),
    accion               VARCHAR(20) NOT NULL,
    id_empleado          INT,
    fecha_hora           TIMESTAMP NOT NULL,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
    ON DELETE SET NULL ON UPDATE CASCADE
);

-- CASCADE: si se elimina el cliente, sus quejas tambien
CREATE TABLE quejas(
    id_queja    INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente  INT,
    fecha_queja DATE NOT NULL DEFAULT (CURRENT_DATE),
    descripcion TEXT NOT NULL,
    estado      VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
                CHECK (estado IN ('Pendiente','En Proceso','Resuelta')),
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
	ON DELETE CASCADE ON UPDATE CASCADE
);

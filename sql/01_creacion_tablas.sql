--Nombre de la Base de datos
CREATE DATABASE tienda_ropa;
----------------------------
--Creacion de las tablas 
----------------------------
--Tabla Sucursal
CREATE TABLE sucursales(
	id_sucursal SERIAL PRIMARY KEY,
	nombre_sucursal VARCHAR(50) NOT NULL,
	direccion_sucursal VARCHAR(50) 
);
--Tabla categorias
CREATE TABLE categorias(
	id_categoria SERIAL PRIMARY KEY,
	nombre_categoria VARCHAR(50) NOT NULL,
	descripcion TEXT
);
--Tabla tallas
CREATE TABLE tallas(
	id_talla SERIAL PRIMARY KEY,
	nombre_talla VARCHAR(50) NOT NULL
);
--Tabla Proveedores
CREATE TABLE proveedores(
	id_proveedor SERIAL PRIMARY KEY,
	nombre_proveedor VARCHAR(50) NOT NULL
);

--Tabla Metodo de pago
CREATE TABLE metodos_pago(
	id_pago SERIAL PRIMARY KEY,
	metodo_pago VARCHAR(30) NOT NULL
);
--Tabla Clientes
CREATE TABLE clientes(
	id_cliente SERIAL PRIMARY KEY,
	nombre_cliente VARCHAR(75) NOT NULL,
	cedula_cliente VARCHAR(15) UNIQUE NOT NULL,
	telefono_cliente VARCHAR(15),
	correo_cliente VARCHAR(50)
);
--Tabla promociones
CREATE TABLE promociones(
	id_promocion SERIAL PRIMARY KEY,
	descripcion_promocion TEXT,
	porcentaje_descuento DECIMAL(5,2)
);
--Tabla empleados
CREATE TABLE empleados (
	id_empleado SERIAL PRIMARY KEY,
	nombre_empleado VARCHAR(75) NOT NULL,
	rol_empleado VARCHAR(30) NOT NULL,
	id_sucursal INT REFERENCES sucursales(id_sucursal)
);
--Tabla producto
CREATE TABLE productos(
	id_producto SERIAL PRIMARY KEY,
	nombre_producto VARCHAR(50) NOT NULL,
	id_talla INT REFERENCES tallas(id_talla),
	color VARCHAR(15),
	precio_unitario DECIMAL(10,2) NOT NULL,
	id_proveedor INT REFERENCES proveedores(id_proveedor),
	stock_disponible INT NOT NULL DEFAULT 0,
	id_categoria INT REFERENCES categorias(id_categoria)
);
--Tabla ventas
CREATE TABLE ventas(
	id_venta SERIAL PRIMARY KEY,
	fecha_venta DATE NOT NULL,
	id_sucursal INT REFERENCES sucursales(id_sucursal),
	id_pago INT REFERENCES metodos_pago(id_pago),
	id_cliente INT REFERENCES clientes(id_cliente),
	id_vendedor INT REFERENCES empleados(id_empleado),
	id_cajero INT REFERENCES empleados(id_empleado),
	id_promocion INT REFERENCES promociones(id_promocion)
);
--Tabla detalle venta
CREATE TABLE detalleventa(
	id_venta INT REFERENCES ventas(id_venta),
	id_producto INT REFERENCES productos(id_producto),
	cantidad_vendida INT NOT NULL, 
	precio_unitario DECIMAL(10,2) NOT NULL,
	subtotal DECIMAL(10,2) NOT NULL,
	PRIMARY KEY(id_venta,id_producto)
);
--Tabla facturas
CREATE TABLE facturas(
	id_factura SERIAL PRIMARY KEY,
	numero_factura VARCHAR(20) UNIQUE NOT NULL,
	id_venta INT REFERENCES ventas(id_venta),
	impuesto DECIMAL(10,2),
	total_factura DECIMAL(10,2)NOT NULL,
	monto_pagado DECIMAL(10,2)	
);
--Tabla devoluciones
CREATE TABLE devoluciones(
	id_devoluciones SERIAL PRIMARY KEY,
	id_venta INT REFERENCES ventas(id_venta),
	id_producto INT REFERENCES productos(id_producto),
	fecha_devolucion DATE NOT NULL,
	cantidad_devuelta INT NOT NULL,
	motivo TEXT,
	monto_reembolso DECIMAL(10,2)
);

--Tabla movimientos inventario
CREATE TABLE movimientos_inventario(
	id_movimiento SERIAL PRIMARY KEY,
	id_producto INT REFERENCES productos(id_producto),
	id_sucursal INT REFERENCES sucursales(id_sucursal),
	tipo_movimiento VARCHAR(20) NOT NULL,
	cantidad INT NOT NULL,
	fecha_movimiento DATE NOT NULL,
	motivo TEXT
);
--Tabla Auditoria
CREATE TABLE auditoria(
	id_auditoria SERIAL PRIMARY KEY,
	tabla_afectada VARCHAR(30) NOT NULL,
	id_registro_afectado INT,
	accion VARCHAR(20) NOT NULL,
	id_empleado  INT REFERENCES empleados(id_empleado),
	fecha_hora TIMESTAMP NOT NULL
);




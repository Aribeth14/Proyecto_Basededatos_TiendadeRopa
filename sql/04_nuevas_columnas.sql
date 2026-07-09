----------------------------------------------
--Agrega columnas y tabla necesarias para las 
--funciones y procedimientos del proyecto
----------------------------------------------
--1. Fecha denacimiento en Clientes
ALTER TABLE clientes 
ADD COLUMN fecha_nacimiento DATE;

--2. Origen del producto (Nacional/Importado)
ALTER TABLE productos 
ADD COLUMN origen VARCHAR(20) NOT NULL DEFAULT 'Nacional'
	CHECK(origen IN ('Nacional','Importado'));

--3. Stock minimo por producto (Bajo Stock)
ALTER TABLE productos 
ADD COLUMN stock_minimo INT NOT NULL DEFAULT 5;

--4. Tabla de Quejas
CREATE TABLE quejas(
	id_queja SERIAL PRIMARY KEY,
	id_cliente INT REFERENCES clientes(id_cliente),
	fecha_queja DATE NOT NULL DEFAULT CURRENT_DATE,
	descripcion TEXT NOT NULL,
	estado VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
		CHECK (estado IN ('Pendiente','En Proceso','Resuelta'))
);
	

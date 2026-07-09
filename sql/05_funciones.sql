---------------
--Funciones
---------------
--1. Calcular IVA
CREATE OR REPLACE FUNCTION fn_calcular_iva(monto NUMERIC)
RETURNS NUMERIC 
AS $$
BEGIN
	RETURN ROUND(monto * 0.15, 2);
END;
$$ LANGUAGE plpgsql;

SELECT fn_calcular_iva(100);

--2.Calcular descuento
--VERSION 1. descuento directo por porcentaje
CREATE OR REPLACE FUNCTION fn_calcular_descuento(monto NUMERIC, porcentaje NUMERIC)
RETURNS NUMERIC 
AS $$
BEGIN
	RETURN ROUND (monto *(porcentaje /100),2);
END;
$$ LANGUAGE plpgsql;
--VERSION 2. descuento segun una promocion existente
CREATE OR REPLACE FUNCTION fn_calcular_descuento_promocion(monto NUMERIC,p_id_promocion INT)
RETURNS NUMERIC 
AS $$
DECLARE v_porcentaje NUMERIC;
BEGIN
	SELECT porcentaje_descuento INTO v_porcentaje
	FROM promociones
	WHERE id_promocion=p_id_promocion;
	IF v_porcentaje IS NULL THEN
		RETURN 0;
	END IF;
	RETURN ROUND(monto*(v_porcentaje/100),2);
END;
$$ LANGUAGE plpgsql;
	
SELECT fn_calcular_descuento(100,1);
SELECT fn_calcular_descuento_promocion(100,3);

--Calcular edad (Apartir de su fecha de nacimiento)
CREATE OR REPLACE FUNCTION fn_calcular_edad(p_fecha_nacimiento DATE)
RETURNS INT 
AS $$
BEGIN
	IF p_fecha_nacimiento IS NULL THEN
		RETURN NULL;
	END IF;
	RETURN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p_fecha_nacimiento));
END;
$$ LANGUAGE plpgsql;

SELECT nombre_cliente,fn_calcular_edad(fecha_nacimiento) AS edad FROM clientes ORDER BY id_cliente;

--4. Calcular Comision 
CREATE OR REPLACE FUNCTION fn_calcular_comision(p_id_empleado INT,p_porcentaje NUMERIC DEFAULT 5)
RETURNS NUMERIC
AS $$
DECLARE v_total_vendido NUMERIC;
BEGIN
	SELECT SUM(f.total_factura) INTO v_total_vendido
	FROM ventas v
	JOIN facturas f ON f.id_venta=v.id_venta
	WHERE v.id_vendedor=p_id_empleado;

	IF v_total_vendido IS NULL THEN
		v_total_vendido:=0;
	END IF;
	RETURN ROUND(v_total_vendido *(p_porcentaje/100),2);
END;
$$ LANGUAGE plpgsql;

SELECT fn_calcular_comision(4);   --Comision al 5% por default
SELECT fn_calcular_comision(4,8); --Comision al 8%

--5. Producto Bajo stock
--Lista de productos con stock menor a lo minimo establecido
CREATE OR REPLACE FUNCTION fn_productos_bajo_stock()
RETURNS TABLE(id_producto INT, nombre_producto VARCHAR,stock_disponible INT,stock_minimo INT)
AS $$
BEGIN
	RETURN QUERY 
	SELECT p.id_producto,p.nombre_producto,p.stock_disponible,p.stock_minimo
	FROM productos p
	WHERE p.stock_disponible < p.stock_minimo;
END;
$$ LANGUAGE plpgsql;

SELECT *FROM fn_productos_bajo_stock();

--6. Clientes Frecuentes
CREATE OR REPLACE  FUNCTION fn_clientes_frecuentes(p_min_compras INT DEFAULT 3)
RETURNS TABLE(id_cliente INT,nombre_cliente VARCHAR,cantidad_compras BIGINT,monto_acumulado NUMERIC)
AS $$
BEGIN
	RETURN QUERY
	SELECT cl.id_cliente,cl.nombre_cliente,
		COUNT(v.id_venta) AS cantidad_compras,
		SUM(f.total_factura) AS monto_acumulado
	FROM ventas v
	JOIN clientes cl ON v.id_cliente=cl.id_cliente
	JOIN facturas f ON f.id_venta=v.id_venta
	GROUP BY cl.id_cliente,cl.nombre_cliente
	HAVING COUNT(v.id_venta) >= p_min_compras
	ORDER BY cantidad_compras DESC;
END;
$$ LANGUAGE plpgsql;

SELECT *FROM  fn_clientes_frecuentes();  -- 3 compras o mas
SELECT *FROM  fn_clientes_frecuentes(5); --5 compras o mas
	

	



-- MER 2: Sistema de Ventas en Línea


CREATE DATABASE Ventas_linea;
USE Ventas_linea;

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100),
    direccion VARCHAR(150)
);

CREATE TABLE producto (
    id_producto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    precio DECIMAL(10,2),
    stock INT
);

CREATE TABLE empleado (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    cargo VARCHAR(50),
    correo VARCHAR(100)
);

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
);

CREATE TABLE pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    fecha DATE,
    total DECIMAL(10,2),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE detalle_pedido (
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    PRIMARY KEY (id_pedido, id_producto),
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE producto_categoria (
    id_producto INT,
    id_categoria INT,
    PRIMARY KEY (id_producto, id_categoria),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);


INSERT INTO cliente (nombre, correo, direccion) VALUES ('Ana Torres', 'ana@correo.com', 'Calle 123');
INSERT INTO producto (nombre, precio, stock) VALUES ('Teclado', 70000, 20);
INSERT INTO empleado (nombre, cargo, correo) VALUES ('Pedro Silva', 'Vendedor', 'pedro@ventas.com');
INSERT INTO categoria (nombre) VALUES ('Electrónica');
INSERT INTO pedido (id_cliente, fecha, total) VALUES (1, '2025-06-27', 140000);

SELECT * FROM cliente;
SELECT nombre FROM producto WHERE stock > 10;
SELECT p.nombre, dp.cantidad FROM detalle_pedido dp JOIN producto p ON dp.id_producto = p.id_producto;
SELECT c.nombre, pe.fecha FROM pedido pe JOIN cliente c ON pe.id_cliente = c.id_cliente;
SELECT nombre FROM producto WHERE id_producto NOT IN (SELECT id_producto FROM detalle_pedido);

DELETE FROM detalle_pedido WHERE id_pedido = 1 AND id_producto = 1;
DELETE FROM pedido WHERE id_pedido = 1;
DELETE FROM producto WHERE id_producto = 1;
DELETE FROM cliente WHERE id_cliente = 1;
DELETE FROM producto_categoria WHERE id_producto = 1 AND id_categoria = 1;

-- 1. Total de pedidos por cliente
CREATE FUNCTION total_pedidos_cliente(cli_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM pedido WHERE id_cliente = cli_id;
  RETURN total;
END;

-- 2. Total vendido de un producto
CREATE FUNCTION total_vendido_producto(prod_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT SUM(cantidad) INTO total FROM detalle_pedido WHERE id_producto = prod_id;
  RETURN total;
END;

-- 3. Nombre de producto por ID
CREATE FUNCTION nombre_producto(prod_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM producto WHERE id_producto = prod_id;
  RETURN nombre;
END;

-- 4. Stock actual de un producto
CREATE FUNCTION stock_producto(prod_id INT) RETURNS INT
BEGIN
  DECLARE stock_actual INT;
  SELECT stock INTO stock_actual FROM producto WHERE id_producto = prod_id;
  RETURN stock_actual;
END;

-- 5. Total productos en categoría
CREATE FUNCTION total_productos_categoria(cat_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM producto_categoria WHERE id_categoria = cat_id;
  RETURN total;
END;

DELIMITER $$
CREATE PROCEDURE registrar_pedido (
  IN p_id_cliente INT,
  IN p_fecha DATE,
  IN p_total DECIMAL(10,2)
)
BEGIN
  INSERT INTO pedido (id_cliente, fecha, total)
  VALUES (p_id_cliente, p_fecha, p_total);
END;
$$
DELIMITER ;

-- Clientes con más de 1 pedido
SELECT nombre FROM cliente
WHERE id_cliente IN (
  SELECT id_cliente FROM pedido GROUP BY id_cliente HAVING COUNT(*) > 1
);

-- Productos sin pedidos
SELECT nombre FROM producto
WHERE id_producto NOT IN (
  SELECT id_producto FROM detalle_pedido
);

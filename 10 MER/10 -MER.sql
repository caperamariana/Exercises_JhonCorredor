-- MER 11: Sistema de Gestión de Cine

CREATE DATABASE Cine;
USE Cine;

CREATE TABLE pelicula (
    id_pelicula INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100),
    duracion INT,
    clasificacion VARCHAR(10)
);

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100)
);

CREATE TABLE sala (
    id_sala INT PRIMARY KEY AUTO_INCREMENT,
    numero INT,
    capacidad INT
);

CREATE TABLE horario (
    id_horario INT PRIMARY KEY AUTO_INCREMENT,
    dia VARCHAR(20),
    hora TIME
);

CREATE TABLE funcion (
    id_funcion INT PRIMARY KEY AUTO_INCREMENT,
    id_pelicula INT,
    id_sala INT,
    id_horario INT,
    fecha DATE,
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula),
    FOREIGN KEY (id_sala) REFERENCES sala(id_sala),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);

CREATE TABLE boleto (
    id_boleto INT PRIMARY KEY AUTO_INCREMENT,
    id_funcion INT,
    id_cliente INT,
    asiento VARCHAR(10),
    FOREIGN KEY (id_funcion) REFERENCES funcion(id_funcion),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE pelicula_horario (
    id_pelicula INT,
    id_horario INT,
    PRIMARY KEY (id_pelicula, id_horario),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula(id_pelicula),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);


INSERT INTO pelicula (titulo, duracion, clasificacion) VALUES ('Matrix', 120, 'PG-13');
INSERT INTO cliente (nombre, correo) VALUES ('Andrés López', 'andres@correo.com');
INSERT INTO sala (numero, capacidad) VALUES (1, 100);
INSERT INTO horario (dia, hora) VALUES ('Viernes', '19:00:00');
INSERT INTO funcion (id_pelicula, id_sala, id_horario, fecha) VALUES (1, 1, 1, '2025-08-05');


SELECT * FROM pelicula;
SELECT nombre FROM cliente WHERE correo LIKE '%@correo.com';
SELECT p.titulo, f.fecha FROM funcion f JOIN pelicula p ON f.id_pelicula = p.id_pelicula;
SELECT c.nombre, b.asiento FROM boleto b JOIN cliente c ON b.id_cliente = c.id_cliente;
SELECT titulo FROM pelicula WHERE id_pelicula NOT IN (SELECT id_pelicula FROM funcion);

DELETE FROM boleto WHERE id_boleto = 1;
DELETE FROM funcion WHERE id_funcion = 1;
DELETE FROM pelicula_horario WHERE id_pelicula = 1 AND id_horario = 1;
DELETE FROM pelicula WHERE id_pelicula = 1;
DELETE FROM cliente WHERE id_cliente = 1;


-- 1. Total funciones por película
CREATE FUNCTION total_funciones_pelicula(p_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM funcion WHERE id_pelicula = p_id;
  RETURN total;
END;

-- 2. Nombre del cliente
CREATE FUNCTION nombre_cliente(c_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM cliente WHERE id_cliente = c_id;
  RETURN nombre;
END;

-- 3. Capacidad de la sala
CREATE FUNCTION capacidad_sala(s_id INT) RETURNS INT
BEGIN
  DECLARE cap INT;
  SELECT capacidad INTO cap FROM sala WHERE id_sala = s_id;
  RETURN cap;
END;

-- 4. Día de la función
CREATE FUNCTION dia_funcion(f_id INT) RETURNS VARCHAR(20)
BEGIN
  DECLARE dia_func VARCHAR(20);
  SELECT h.dia INTO dia_func FROM funcion f JOIN horario h ON f.id_horario = h.id_horario WHERE f.id_funcion = f_id;
  RETURN dia_func;
END;

-- 5. Total boletos vendidos por función
CREATE FUNCTION total_boletos_funcion(f_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM boleto WHERE id_funcion = f_id;
  RETURN total;
END;

DELIMITER $$
CREATE PROCEDURE registrar_boleto (
  IN p_id_funcion INT,
  IN p_id_cliente INT,
  IN p_asiento VARCHAR(10)
)
BEGIN
  INSERT INTO boleto (id_funcion, id_cliente, asiento)
  VALUES (p_id_funcion, p_id_cliente, p_asiento);
END;
$$
DELIMITER ;


-- Clientes sin boletos
SELECT nombre FROM cliente
WHERE id_cliente NOT IN (
  SELECT id_cliente FROM boleto
);

-- Películas sin funciones asignadas
SELECT titulo FROM pelicula
WHERE id_pelicula NOT IN (
  SELECT id_pelicula FROM funcion
);
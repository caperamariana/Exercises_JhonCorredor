-- MER 6: Sistema de Transporte Escolar

CREATE DATABASE Transporte_escolar;
USE Transporte_escolar;

CREATE TABLE estudiante (
    id_estudiante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    grado VARCHAR(10)
);

CREATE TABLE conductor (
    id_conductor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    licencia VARCHAR(20)
);

CREATE TABLE vehiculo (
    id_vehiculo INT PRIMARY KEY AUTO_INCREMENT,
    placa VARCHAR(10),
    capacidad INT
);

CREATE TABLE ruta (
    id_ruta INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    recorrido TEXT
);

CREATE TABLE asignacion (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_estudiante INT,
    id_ruta INT,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
    FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
);

CREATE TABLE vehiculo_ruta (
    id_vehiculo INT,
    id_ruta INT,
    PRIMARY KEY (id_vehiculo, id_ruta),
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo),
    FOREIGN KEY (id_ruta) REFERENCES ruta(id_ruta)
);

CREATE TABLE conductor_vehiculo (
    id_conductor INT,
    id_vehiculo INT,
    PRIMARY KEY (id_conductor, id_vehiculo),
    FOREIGN KEY (id_conductor) REFERENCES conductor(id_conductor),
    FOREIGN KEY (id_vehiculo) REFERENCES vehiculo(id_vehiculo)
);


INSERT INTO estudiante (nombre, grado) VALUES ('Laura Méndez', '7B');
INSERT INTO conductor (nombre, licencia) VALUES ('Carlos Peña', 'ABC123');
INSERT INTO vehiculo (placa, capacidad) VALUES ('XYZ789', 30);
INSERT INTO ruta (nombre, recorrido) VALUES ('Ruta Norte', 'Escuela - Av. Central - Zona 5');
INSERT INTO asignacion (id_estudiante, id_ruta) VALUES (1, 1);


SELECT * FROM vehiculo;
SELECT nombre FROM ruta WHERE nombre LIKE '%Norte%';
SELECT e.nombre, r.nombre FROM asignacion a JOIN estudiante e ON a.id_estudiante = e.id_estudiante JOIN ruta r ON a.id_ruta = r.id_ruta;
SELECT c.nombre, v.placa FROM conductor_vehiculo cv JOIN conductor c ON cv.id_conductor = c.id_conductor JOIN vehiculo v ON cv.id_vehiculo = v.id_vehiculo;
SELECT nombre FROM conductor WHERE id_conductor NOT IN (SELECT id_conductor FROM conductor_vehiculo);


DELETE FROM conductor_vehiculo WHERE id_conductor = 1 AND id_vehiculo = 1;
DELETE FROM vehiculo_ruta WHERE id_vehiculo = 1 AND id_ruta = 1;
DELETE FROM asignacion WHERE id_asignacion = 1;
DELETE FROM vehiculo WHERE id_vehiculo = 1;
DELETE FROM conductor WHERE id_conductor = 1;


-- 1. Total estudiantes por ruta
CREATE FUNCTION total_estudiantes_ruta(r_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM asignacion WHERE id_ruta = r_id;
  RETURN total;
END;

-- 2. Capacidad del vehículo
CREATE FUNCTION capacidad_vehiculo(v_id INT) RETURNS INT
BEGIN
  DECLARE cap INT;
  SELECT capacidad INTO cap FROM vehiculo WHERE id_vehiculo = v_id;
  RETURN cap;
END;

-- 3. Nombre del conductor
CREATE FUNCTION nombre_conductor(c_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM conductor WHERE id_conductor = c_id;
  RETURN nombre;
END;

-- 4. Placa del vehículo
CREATE FUNCTION placa_vehiculo(v_id INT) RETURNS VARCHAR(10)
BEGIN
  DECLARE placa VARCHAR(10);
  SELECT placa INTO placa FROM vehiculo WHERE id_vehiculo = v_id;
  RETURN placa;
END;

-- 5. Total rutas de un vehículo
CREATE FUNCTION total_rutas_vehiculo(v_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM vehiculo_ruta WHERE id_vehiculo = v_id;
  RETURN total;
END;

DELIMITER $$
CREATE PROCEDURE registrar_asignacion (
  IN p_id_estudiante INT,
  IN p_id_ruta INT
)
BEGIN
  INSERT INTO asignacion (id_estudiante, id_ruta)
  VALUES (p_id_estudiante, p_id_ruta);
END;
$$
DELIMITER ;


-- Estudiantes sin asignación
SELECT nombre FROM estudiante
WHERE id_estudiante NOT IN (
  SELECT id_estudiante FROM asignacion
);

-- Vehículos sin rutas asignadas
SELECT placa FROM vehiculo
WHERE id_vehiculo NOT IN (
  SELECT id_vehiculo FROM vehiculo_ruta
);

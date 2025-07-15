-- MER 4: Clínica Veterinaria

CREATE DATABASE Veterinaria;
USE veterinaria;

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE mascota (
    id_mascota INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    especie VARCHAR(50),
    edad INT
);

CREATE TABLE veterinario (
    id_veterinario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    especialidad VARCHAR(100)
);

CREATE TABLE tratamiento (
    id_tratamiento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    descripcion TEXT
);

CREATE TABLE consulta (
    id_consulta INT PRIMARY KEY AUTO_INCREMENT,
    id_mascota INT,
    id_veterinario INT,
    fecha DATE,
    motivo TEXT,
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota),
    FOREIGN KEY (id_veterinario) REFERENCES veterinario(id_veterinario)
);

CREATE TABLE consulta_tratamiento (
    id_consulta INT,
    id_tratamiento INT,
    dosis VARCHAR(100),
    PRIMARY KEY (id_consulta, id_tratamiento),
    FOREIGN KEY (id_consulta) REFERENCES consulta(id_consulta),
    FOREIGN KEY (id_tratamiento) REFERENCES tratamiento(id_tratamiento)
);

CREATE TABLE mascota_cliente (
    id_mascota INT,
    id_cliente INT,
    PRIMARY KEY (id_mascota, id_cliente),
    FOREIGN KEY (id_mascota) REFERENCES mascota(id_mascota),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);


INSERT INTO cliente (nombre, telefono, correo) VALUES ('Juan Morales', '3104567890', 'juan@correo.com');
INSERT INTO mascota (nombre, especie, edad) VALUES ('Toby', 'Perro', 4);
INSERT INTO veterinario (nombre, especialidad) VALUES ('Dra. Andrea Díaz', 'Dermatología');
INSERT INTO tratamiento (nombre, descripcion) VALUES ('Antibiótico', 'Tratamiento para infecciones');
INSERT INTO consulta (id_mascota, id_veterinario, fecha, motivo) VALUES (1, 1, '2025-07-01', 'Infección en la piel');


SELECT * FROM cliente;
SELECT nombre FROM mascota WHERE especie = 'Perro';
SELECT t.nombre, ct.dosis FROM consulta_tratamiento ct JOIN tratamiento t ON ct.id_tratamiento = t.id_tratamiento;
SELECT m.nombre, c.fecha FROM consulta c JOIN mascota m ON c.id_mascota = m.id_mascota;
SELECT nombre FROM tratamiento WHERE id_tratamiento NOT IN (SELECT id_tratamiento FROM consulta_tratamiento);


DELETE FROM consulta_tratamiento WHERE id_consulta = 1 AND id_tratamiento = 1;
DELETE FROM consulta WHERE id_consulta = 1;
DELETE FROM mascota_cliente WHERE id_mascota = 1 AND id_cliente = 1;
DELETE FROM tratamiento WHERE id_tratamiento = 1;
DELETE FROM cliente WHERE id_cliente = 1;


-- 1. Total consultas por mascota
CREATE FUNCTION total_consultas_mascota(m_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM consulta WHERE id_mascota = m_id;
  RETURN total;
END;

-- 2. Total tratamientos en una consulta
CREATE FUNCTION total_tratamientos_consulta(c_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM consulta_tratamiento WHERE id_consulta = c_id;
  RETURN total;
END;

-- 3. Nombre del veterinario
CREATE FUNCTION nombre_veterinario(v_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM veterinario WHERE id_veterinario = v_id;
  RETURN nombre;
END;

-- 4. Edad de la mascota
CREATE FUNCTION edad_mascota(m_id INT) RETURNS INT
BEGIN
  DECLARE edad INT;
  SELECT edad INTO edad FROM mascota WHERE id_mascota = m_id;
  RETURN edad;
END;

-- 5. Total mascotas por cliente
CREATE FUNCTION total_mascotas_cliente(c_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM mascota_cliente WHERE id_cliente = c_id;
  RETURN total;
END;


DELIMITER $$
CREATE PROCEDURE registrar_consulta (
  IN p_id_mascota INT,
  IN p_id_veterinario INT,
  IN p_fecha DATE,
  IN p_motivo TEXT
)
BEGIN
  INSERT INTO consulta (id_mascota, id_veterinario, fecha, motivo)
  VALUES (p_id_mascota, p_id_veterinario, p_fecha, p_motivo);
END;
$$
DELIMITER ;

-- Clientes con más de 1 mascota
SELECT nombre FROM cliente
WHERE id_cliente IN (
  SELECT id_cliente FROM mascota_cliente GROUP BY id_cliente HAVING COUNT(*) > 1
);

-- Mascotas sin consultas
SELECT nombre FROM mascota
WHERE id_mascota NOT IN (
  SELECT id_mascota FROM consulta
);
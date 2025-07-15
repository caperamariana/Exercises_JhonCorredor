-- MER 9: Sistema de Gestión de Eventos

CREATE DATABASE Eventos;
USE Eventos;

CREATE TABLE evento (
    id_evento INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    fecha DATE,
    lugar VARCHAR(100)
);

CREATE TABLE participante (
    id_participante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100)
);

CREATE TABLE organizador (
    id_organizador INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    telefono VARCHAR(20)
);

CREATE TABLE tipo_evento (
    id_tipo INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
);

CREATE TABLE inscripcion (
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    id_evento INT,
    id_participante INT,
    fecha_inscripcion DATE,
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
    FOREIGN KEY (id_participante) REFERENCES participante(id_participante)
);

CREATE TABLE evento_tipo (
    id_evento INT,
    id_tipo INT,
    PRIMARY KEY (id_evento, id_tipo),
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
    FOREIGN KEY (id_tipo) REFERENCES tipo_evento(id_tipo)
);

CREATE TABLE organizador_evento (
    id_organizador INT,
    id_evento INT,
    PRIMARY KEY (id_organizador, id_evento),
    FOREIGN KEY (id_organizador) REFERENCES organizador(id_organizador),
    FOREIGN KEY (id_evento) REFERENCES evento(id_evento)
);


INSERT INTO evento (nombre, fecha, lugar) VALUES ('Conferencia Tech', '2025-08-01', 'Centro Convenciones');
INSERT INTO participante (nombre, correo) VALUES ('Sofía Castaño', 'sofia@correo.com');
INSERT INTO organizador (nombre, telefono) VALUES ('Laura Pérez', '3107894561');
INSERT INTO tipo_evento (nombre) VALUES ('Tecnología');
INSERT INTO inscripcion (id_evento, id_participante, fecha_inscripcion) VALUES (1, 1, '2025-07-10');


SELECT * FROM evento;
SELECT nombre FROM participante WHERE correo LIKE '%@correo.com';
SELECT e.nombre, i.fecha_inscripcion FROM inscripcion i JOIN evento e ON i.id_evento = e.id_evento;
SELECT o.nombre, e.lugar FROM organizador_evento oe JOIN organizador o ON oe.id_organizador = o.id_organizador JOIN evento e ON oe.id_evento = e.id_evento;
SELECT nombre FROM tipo_evento WHERE id_tipo NOT IN (SELECT id_tipo FROM evento_tipo);

DELETE FROM organizador_evento WHERE id_organizador = 1 AND id_evento = 1;
DELETE FROM evento_tipo WHERE id_evento = 1 AND id_tipo = 1;
DELETE FROM inscripcion WHERE id_inscripcion = 1;
DELETE FROM evento WHERE id_evento = 1;
DELETE FROM participante WHERE id_participante = 1;

-- 1. Total inscripciones a un evento
CREATE FUNCTION total_inscripciones_evento(e_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM inscripcion WHERE id_evento = e_id;
  RETURN total;
END;

-- 2. Nombre del participante
CREATE FUNCTION nombre_participante(p_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM participante WHERE id_participante = p_id;
  RETURN nombre;
END;

-- 3. Total eventos de un organizador
CREATE FUNCTION total_eventos_organizador(o_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM organizador_evento WHERE id_organizador = o_id;
  RETURN total;
END;

-- 4. Nombre del tipo de evento
CREATE FUNCTION nombre_tipo_evento(t_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM tipo_evento WHERE id_tipo = t_id;
  RETURN nombre;
END;

-- 5. Lugar del evento
CREATE FUNCTION lugar_evento(e_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE lugar VARCHAR(100);
  SELECT lugar INTO lugar FROM evento WHERE id_evento = e_id;
  RETURN lugar;
END;

DELIMITER $$
CREATE PROCEDURE registrar_inscripcion (
  IN p_id_evento INT,
  IN p_id_participante INT,
  IN p_fecha_inscripcion DATE
)
BEGIN
  INSERT INTO inscripcion (id_evento, id_participante, fecha_inscripcion)
  VALUES (p_id_evento, p_id_participante, p_fecha_inscripcion);
END;
$$
DELIMITER ;


-- Participantes sin inscripciones
SELECT nombre FROM participante
WHERE id_participante NOT IN (
  SELECT id_participante FROM inscripcion
);

-- Eventos sin organizador
SELECT nombre FROM evento
WHERE id_evento NOT IN (
  SELECT id_evento FROM organizador_evento
);

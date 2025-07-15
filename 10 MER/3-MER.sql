
-- MER 3: Gestión de Proyectos

CREATE DATABASE Proyectos;
USE Proyectos;

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100)
);

CREATE TABLE proyecto (
    id_proyecto INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    fecha_inicio DATE,
    fecha_fin DATE
);

CREATE TABLE tarea (
    id_tarea INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100),
    descripcion TEXT,
    estado VARCHAR(50),
    id_proyecto INT,
    FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
);

CREATE TABLE recurso (
    id_recurso INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    tipo VARCHAR(50)
);

CREATE TABLE usuario_proyecto (
    id_usuario INT,
    id_proyecto INT,
    PRIMARY KEY (id_usuario, id_proyecto),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_proyecto) REFERENCES proyecto(id_proyecto)
);

CREATE TABLE tarea_recurso (
    id_tarea INT,
    id_recurso INT,
    PRIMARY KEY (id_tarea, id_recurso),
    FOREIGN KEY (id_tarea) REFERENCES tarea(id_tarea),
    FOREIGN KEY (id_recurso) REFERENCES recurso(id_recurso)
);


INSERT INTO usuario (nombre, correo) VALUES ('Lucía Pérez', 'lucia@correo.com');
INSERT INTO proyecto (nombre, fecha_inicio, fecha_fin) VALUES ('App Móvil', '2025-07-01', '2025-10-01');
INSERT INTO tarea (titulo, descripcion, estado, id_proyecto) VALUES ('Diseño UI', 'Diseñar interfaz', 'En Proceso', 1);
INSERT INTO recurso (nombre, tipo) VALUES ('Figma', 'Software');
INSERT INTO usuario_proyecto (id_usuario, id_proyecto) VALUES (1, 1);


SELECT * FROM proyecto;
SELECT titulo FROM tarea WHERE estado = 'En Proceso';
SELECT r.nombre FROM tarea_recurso tr JOIN recurso r ON tr.id_recurso = r.id_recurso;
SELECT u.nombre, p.nombre FROM usuario u JOIN usuario_proyecto up ON u.id_usuario = up.id_usuario JOIN proyecto p ON up.id_proyecto = p.id_proyecto;
SELECT nombre FROM recurso WHERE id_recurso NOT IN (SELECT id_recurso FROM tarea_recurso);


DELETE FROM tarea_recurso WHERE id_tarea = 1 AND id_recurso = 1;
DELETE FROM tarea WHERE id_tarea = 1;
DELETE FROM usuario_proyecto WHERE id_usuario = 1 AND id_proyecto = 1;
DELETE FROM recurso WHERE id_recurso = 1;
DELETE FROM usuario WHERE id_usuario = 1;


-- 1. Total tareas por proyecto
CREATE FUNCTION total_tareas_proyecto(proj_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM tarea WHERE id_proyecto = proj_id;
  RETURN total;
END;

-- 2. Estado de tarea por ID
CREATE FUNCTION estado_tarea(tarea_id INT) RETURNS VARCHAR(50)
BEGIN
  DECLARE estado VARCHAR(50);
  SELECT estado INTO estado FROM tarea WHERE id_tarea = tarea_id;
  RETURN estado;
END;

-- 3. Nombre del recurso
CREATE FUNCTION nombre_recurso(recurso_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM recurso WHERE id_recurso = recurso_id;
  RETURN nombre;
END;

-- 4. Total usuarios por proyecto
CREATE FUNCTION total_usuarios_proyecto(proj_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM usuario_proyecto WHERE id_proyecto = proj_id;
  RETURN total;
END;

-- 5. Total recursos por tarea
CREATE FUNCTION total_recursos_tarea(tarea_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM tarea_recurso WHERE id_tarea = tarea_id;
  RETURN total;
END;

DELIMITER $$
CREATE PROCEDURE registrar_tarea (
  IN p_titulo VARCHAR(100),
  IN p_descripcion TEXT,
  IN p_estado VARCHAR(50),
  IN p_id_proyecto INT
)
BEGIN
  INSERT INTO tarea (titulo, descripcion, estado, id_proyecto)
  VALUES (p_titulo, p_descripcion, p_estado, p_id_proyecto);
END;
$$
DELIMITER ;

-- Proyectos con más de 2 tareas
SELECT nombre FROM proyecto
WHERE id_proyecto IN (
  SELECT id_proyecto FROM tarea GROUP BY id_proyecto HAVING COUNT(*) > 2
);

-- Recursos no asignados a tareas
SELECT nombre FROM recurso
WHERE id_recurso NOT IN (
  SELECT id_recu
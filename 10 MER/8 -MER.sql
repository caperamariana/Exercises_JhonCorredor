-- MER 13: Sistema de Cursos Virtuales

CREATE DATABASE Cursos_virtuales;
USE Cursos_virtuales;

CREATE TABLE usuario (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    correo VARCHAR(100)
);

CREATE TABLE curso (
    id_curso INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(100),
    descripcion TEXT
);

CREATE TABLE instructor (
    id_instructor INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    especialidad VARCHAR(100)
);

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50)
);

CREATE TABLE inscripcion (
    id_inscripcion INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT,
    id_curso INT,
    fecha DATE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso)
);

CREATE TABLE curso_categoria (
    id_curso INT,
    id_categoria INT,
    PRIMARY KEY (id_curso, id_categoria),
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE curso_instructor (
    id_curso INT,
    id_instructor INT,
    PRIMARY KEY (id_curso, id_instructor),
    FOREIGN KEY (id_curso) REFERENCES curso(id_curso),
    FOREIGN KEY (id_instructor) REFERENCES instructor(id_instructor)
);


INSERT INTO usuario (nombre, correo) VALUES ('Natalia Ramírez', 'natalia@correo.com');
INSERT INTO curso (titulo, descripcion) VALUES ('Python Básico', 'Curso introductorio de programación en Python');
INSERT INTO instructor (nombre, especialidad) VALUES ('Luis Torres', 'Programación');
INSERT INTO categoria (nombre) VALUES ('Tecnología');
INSERT INTO inscripcion (id_usuario, id_curso, fecha) VALUES (1, 1, '2025-07-01');

SELECT * FROM curso;
SELECT nombre FROM usuario WHERE correo LIKE '%@correo.com';
SELECT c.titulo, i.fecha FROM inscripcion i JOIN curso c ON i.id_curso = c.id_curso;
SELECT u.nombre, c.titulo FROM inscripcion i JOIN usuario u ON i.id_usuario = u.id_usuario JOIN curso c ON i.id_curso = c.id_curso;
SELECT titulo FROM curso WHERE id_curso NOT IN (SELECT id_curso FROM curso_categoria);


DELETE FROM curso_categoria WHERE id_curso = 1 AND id_categoria = 1;
DELETE FROM inscripcion WHERE id_inscripcion = 1;
DELETE FROM curso_instructor WHERE id_curso = 1 AND id_instructor = 1;
DELETE FROM curso WHERE id_curso = 1;
DELETE FROM usuario WHERE id_usuario = 1;


-- 1. Total de cursos inscritos por usuario
CREATE FUNCTION total_cursos_usuario(u_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM inscripcion WHERE id_usuario = u_id;
  RETURN total;
END;

-- 2. Nombre del curso
CREATE FUNCTION nombre_curso(c_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT titulo INTO nombre FROM curso WHERE id_curso = c_id;
  RETURN nombre;
END;

-- 3. Nombre del instructor
CREATE FUNCTION nombre_instructor(i_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM instructor WHERE id_instructor = i_id;
  RETURN nombre;
END;

-- 4. Categoría del curso
CREATE FUNCTION categoria_curso(c_id INT) RETURNS VARCHAR(50)
BEGIN
  DECLARE nombre VARCHAR(50);
  SELECT cat.nombre INTO nombre FROM curso_categoria cc JOIN categoria cat ON cc.id_categoria = cat.id_categoria WHERE cc.id_curso = c_id LIMIT 1;
  RETURN nombre;
END;

-- 5. Total usuarios inscritos en un curso
CREATE FUNCTION total_usuarios_curso(c_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM inscripcion WHERE id_curso = c_id;
  RETURN total;
END;


DELIMITER $$
CREATE PROCEDURE registrar_inscripcion (
  IN p_id_usuario INT,
  IN p_id_curso INT,
  IN p_fecha DATE
)
BEGIN
  INSERT INTO inscripcion (id_usuario, id_curso, fecha)
  VALUES (p_id_usuario, p_id_curso, p_fecha);
END;
$$
DELIMITER ;

-- Usuarios sin cursos inscritos
SELECT nombre FROM usuario
WHERE id_usuario NOT IN (
  SELECT id_usuario FROM inscripcion
);

-- Cursos sin instructores asignados
SELECT titulo FROM curso
WHERE id_curso NOT IN (
  SELECT id_curso FROM curso_instructor
);
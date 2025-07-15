-- MER 5: Biblioteca Escolar

CREATE DATBASE Biblioteca_escolar;
USE Biblioteca_escolar;

CREATE TABLE estudiante (
    id_estudiante INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    grado VARCHAR(10)
);

CREATE TABLE libro (
    id_libro INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(150),
    autor VARCHAR(100),
    ejemplares INT
);

CREATE TABLE bibliotecario (
    id_bibliotecario INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    turno VARCHAR(50)
);

CREATE TABLE categoria (
    id_categoria INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100)
);

CREATE TABLE prestamo (
    id_prestamo INT PRIMARY KEY AUTO_INCREMENT,
    id_estudiante INT,
    id_libro INT,
    fecha_prestamo DATE,
    fecha_devolucion DATE,
    FOREIGN KEY (id_estudiante) REFERENCES estudiante(id_estudiante),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
);

CREATE TABLE libro_categoria (
    id_libro INT,
    id_categoria INT,
    PRIMARY KEY (id_libro, id_categoria),
    FOREIGN KEY (id_libro) REFERENCES libro(id_libro),
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE bibliotecario_prestamo (
    id_bibliotecario INT,
    id_prestamo INT,
    PRIMARY KEY (id_bibliotecario, id_prestamo),
    FOREIGN KEY (id_bibliotecario) REFERENCES bibliotecario(id_bibliotecario),
    FOREIGN KEY (id_prestamo) REFERENCES prestamo(id_prestamo)
);

INSERT INTO estudiante (nombre, grado) VALUES ('Carlos Jiménez', '6A');
INSERT INTO libro (titulo, autor, ejemplares) VALUES ('Cien años de soledad', 'Gabriel García Márquez', 3);
INSERT INTO bibliotecario (nombre, turno) VALUES ('Lucía Morales', 'Mañana');
INSERT INTO categoria (nombre) VALUES ('Literatura Clásica');
INSERT INTO prestamo (id_estudiante, id_libro, fecha_prestamo, fecha_devolucion) VALUES (1, 1, '2025-07-05', '2025-07-12');

SELECT * FROM estudiante;
SELECT titulo FROM libro WHERE ejemplares > 1;
SELECT l.titulo, p.fecha_prestamo FROM prestamo p JOIN libro l ON p.id_libro = l.id_libro;
SELECT nombre FROM bibliotecario WHERE turno = 'Mañana';
SELECT nombre FROM categoria WHERE id_categoria NOT IN (SELECT id_categoria FROM libro_categoria);


DELETE FROM bibliotecario_prestamo WHERE id_bibliotecario = 1 AND id_prestamo = 1;
DELETE FROM prestamo WHERE id_prestamo = 1;
DELETE FROM estudiante WHERE id_estudiante = 1;
DELETE FROM libro_categoria WHERE id_libro = 1 AND id_categoria = 1;
DELETE FROM libro WHERE id_libro = 1;


-- 1. Total préstamos por estudiante
CREATE FUNCTION total_prestamos_estudiante(e_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM prestamo WHERE id_estudiante = e_id;
  RETURN total;
END;

-- 2. Ejemplares disponibles de un libro
CREATE FUNCTION ejemplares_libro(lib_id INT) RETURNS INT
BEGIN
  DECLARE ejemplares INT;
  SELECT ejemplares INTO ejemplares FROM libro WHERE id_libro = lib_id;
  RETURN ejemplares;
END;

-- 3. Nombre del bibliotecario
CREATE FUNCTION nombre_bibliotecario(b_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM bibliotecario WHERE id_bibliotecario = b_id;
  RETURN nombre;
END;

-- 4. Nombre del libro
CREATE FUNCTION nombre_libro(lib_id INT) RETURNS VARCHAR(150)
BEGIN
  DECLARE titulo VARCHAR(150);
  SELECT titulo INTO titulo FROM libro WHERE id_libro = lib_id;
  RETURN titulo;
END;

-- 5. Total libros por categoría
CREATE FUNCTION total_libros_categoria(cat_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM libro_categoria WHERE id_categoria = cat_id;
  RETURN total;
END;


DELIMITER $$
CREATE PROCEDURE registrar_prestamo (
  IN p_id_estudiante INT,
  IN p_id_libro INT,
  IN p_fecha_prestamo DATE,
  IN p_fecha_devolucion DATE
)
BEGIN
  INSERT INTO prestamo (id_estudiante, id_libro, fecha_prestamo, fecha_devolucion)
  VALUES (p_id_estudiante, p_id_libro, p_fecha_prestamo, p_fecha_devolucion);
END;
$$
DELIMITER ;

-- Estudiantes con más de 1 préstamo
SELECT nombre FROM estudiante
WHERE id_estudiante IN (
  SELECT id_estudiante FROM prestamo GROUP BY id_estudiante HAVING COUNT(*) > 1
);

-- Libros sin préstamos
SELECT titulo FROM libro
WHERE id_libro NOT IN (
  SELECT id_libro FROM prestamo
);
-- MER 7: Sistema de Gestión de Turnos Médicos

CREATE DATABASE Turnos_medicos;
USE Turnos_medicos;


CREATE TABLE paciente (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    documento VARCHAR(20)
);

CREATE TABLE medico (
    id_medico INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100),
    especialidad VARCHAR(100)
);

CREATE TABLE consultorio (
    id_consultorio INT PRIMARY KEY AUTO_INCREMENT,
    numero INT,
    piso INT
);

CREATE TABLE horario (
    id_horario INT PRIMARY KEY AUTO_INCREMENT,
    dia VARCHAR(20),
    hora_inicio TIME,
    hora_fin TIME
);

CREATE TABLE turno (
    id_turno INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    id_medico INT,
    id_consultorio INT,
    id_horario INT,
    fecha DATE,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_consultorio) REFERENCES consultorio(id_consultorio),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);

CREATE TABLE medico_horario (
    id_medico INT,
    id_horario INT,
    PRIMARY KEY (id_medico, id_horario),
    FOREIGN KEY (id_medico) REFERENCES medico(id_medico),
    FOREIGN KEY (id_horario) REFERENCES horario(id_horario)
);

CREATE TABLE paciente_turno (
    id_paciente INT,
    id_turno INT,
    PRIMARY KEY (id_paciente, id_turno),
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_turno) REFERENCES turno(id_turno)
);


INSERT INTO paciente (nombre, documento) VALUES ('María Ramírez', '123456789');
INSERT INTO medico (nombre, especialidad) VALUES ('Dr. Alfonso Ruiz', 'Cardiología');
INSERT INTO consultorio (numero, piso) VALUES (101, 1);
INSERT INTO horario (dia, hora_inicio, hora_fin) VALUES ('Lunes', '08:00:00', '12:00:00');
INSERT INTO turno (id_paciente, id_medico, id_consultorio, id_horario, fecha) VALUES (1, 1, 1, 1, '2025-07-10');


SELECT * FROM turno;
SELECT nombre FROM medico WHERE especialidad = 'Cardiología';
SELECT p.nombre, t.fecha FROM turno t JOIN paciente p ON t.id_paciente = p.id_paciente;
SELECT m.nombre, h.dia FROM medico_horario mh JOIN medico m ON mh.id_medico = m.id_medico JOIN horario h ON mh.id_horario = h.id_horario;
SELECT nombre FROM paciente WHERE id_paciente NOT IN (SELECT id_paciente FROM turno);


DELETE FROM paciente_turno WHERE id_paciente = 1 AND id_turno = 1;
DELETE FROM turno WHERE id_turno = 1;
DELETE FROM medico_horario WHERE id_medico = 1 AND id_horario = 1;
DELETE FROM horario WHERE id_horario = 1;
DELETE FROM paciente WHERE id_paciente = 1;


-- 1. Total turnos por paciente
CREATE FUNCTION total_turnos_paciente(p_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM turno WHERE id_paciente = p_id;
  RETURN total;
END;

-- 2. Nombre del médico
CREATE FUNCTION nombre_medico(m_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM medico WHERE id_medico = m_id;
  RETURN nombre;
END;

-- 3. Día del turno
CREATE FUNCTION dia_turno(t_id INT) RETURNS VARCHAR(20)
BEGIN
  DECLARE dia_turno VARCHAR(20);
  SELECT h.dia INTO dia_turno FROM turno t JOIN horario h ON t.id_horario = h.id_horario WHERE t.id_turno = t_id;
  RETURN dia_turno;
END;

-- 4. Total horarios de un médico
CREATE FUNCTION total_horarios_medico(m_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM medico_horario WHERE id_medico = m_id;
  RETURN total;
END;

-- 5. Piso del consultorio
CREATE FUNCTION piso_consultorio(c_id INT) RETURNS INT
BEGIN
  DECLARE piso INT;
  SELECT piso INTO piso FROM consultorio WHERE id_consultorio = c_id;
  RETURN piso;
END;


DELIMITER $$
CREATE PROCEDURE registrar_turno (
  IN p_id_paciente INT,
  IN p_id_medico INT,
  IN p_id_consultorio INT,
  IN p_id_horario INT,
  IN p_fecha DATE
)
BEGIN
  INSERT INTO turno (id_paciente, id_medico, id_consultorio, id_horario, fecha)
  VALUES (p_id_paciente, p_id_medico, p_id_consultorio, p_id_horario, p_fecha);
END;
$$
DELIMITER ;

-- Médicos con más de 1 horario asignado
SELECT nombre FROM medico
WHERE id_medico IN (
  SELECT id_medico FROM medico_horario GROUP BY id_medico HAVING COUNT(*) > 1
);

-- Pacientes sin turnos asignados
SELECT nombre FROM paciente
WHERE id_paciente NOT IN (
  SELECT id_paciente FROM turno
);

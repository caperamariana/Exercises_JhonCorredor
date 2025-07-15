
-- Crear la base de datos del sistema de reservas de hotel
CREATE DATABASE Hotel;

-- Usar la base de datos creada
USE Hotel;

-- Crear tabla de clientes
CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,     -- ID único del cliente
    nombre VARCHAR(100),                    
    correo VARCHAR(100),                       
    telefono VARCHAR(20)                          
);

-- Crear tabla de habitaciones del hotel
CREATE TABLE habitacion (
    id_habitacion INT PRIMARY KEY AUTO_INCREMENT, 
    numero INT,                                   
    tipo VARCHAR(50),                             
    precio_noche DECIMAL(10,2)                     
);

-- Crear tabla de empleados del hotel
CREATE TABLE empleado (
    id_empleado INT PRIMARY KEY AUTO_INCREMENT,   
    nombre VARCHAR(100),                         
    cargo VARCHAR(50),                          
    correo VARCHAR(100)                            
);

-- Crear tabla de servicios disponibles
CREATE TABLE servicio (
    id_servicio INT PRIMARY KEY AUTO_INCREMENT,    
    nombre VARCHAR(100),                         
    costo DECIMAL(10,2)                         
);

-- Crear tabla de reservas hechas por los clientes
CREATE TABLE reserva (
    id_reserva INT PRIMARY KEY AUTO_INCREMENT,     
    id_cliente INT,                             
    id_habitacion INT,                             
    fecha_inicio DATE,                           
    fecha_fin DATE,                               
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),      
    FOREIGN KEY (id_habitacion) REFERENCES habitacion(id_habitacion) 
);

-- Crear tabla intermedia entre reservas y servicios contratados
CREATE TABLE reserva_servicio (
    id_reserva INT,                              
    id_servicio INT,                           
    cantidad INT,                               
    PRIMARY KEY (id_reserva, id_servicio),      
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),      
    FOREIGN KEY (id_servicio) REFERENCES servicio(id_servicio)   
);

-- Crear tabla intermedia entre empleados y reservas
CREATE TABLE empleado_reserva (
    id_empleado INT,                               
    id_reserva INT,                               
    PRIMARY KEY (id_empleado, id_reserva),     
    FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),  
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)   
);

-- Insertar datos de prueba
INSERT INTO cliente (nombre, correo, telefono) VALUES ('Carlos Ríos', 'carlos@correo.com', '3111234567');
INSERT INTO habitacion (numero, tipo, precio_noche) VALUES (101, 'Suite', 200000);
INSERT INTO empleado (nombre, cargo, correo) VALUES ('Laura Gómez', 'Recepcionista', 'laura@hotel.com');
INSERT INTO servicio (nombre, costo) VALUES ('Desayuno Buffet', 30000);
INSERT INTO reserva (id_cliente, id_habitacion, fecha_inicio, fecha_fin) VALUES (1, 1, '2025-06-25', '2025-06-27');

-- Mostrar todos los clientes registrados
SELECT * FROM cliente;

-- Mostrar nombre de habitaciones tipo 'Suite'
SELECT nombre FROM habitacion WHERE tipo = 'Suite';

-- Mostrar servicios y cantidades usados en reservas
SELECT s.nombre, rs.cantidad FROM reserva_servicio rs 
JOIN servicio s ON rs.id_servicio = s.id_servicio;

-- Mostrar reservas con fechas y nombre del cliente
SELECT r.fecha_inicio, r.fecha_fin, c.nombre 
FROM reserva r 
JOIN cliente c ON r.id_cliente = c.id_cliente;

-- Mostrar servicios que no han sido usados
SELECT nombre FROM servicio 
WHERE id_servicio NOT IN (SELECT id_servicio FROM reserva_servicio);

-- Eliminar un servicio específico de una reserva
DELETE FROM reserva_servicio WHERE id_reserva = 1 AND id_servicio = 1;

-- Eliminar una reserva específica
DELETE FROM reserva WHERE id_reserva = 1;

-- Eliminar una habitación
DELETE FROM habitacion WHERE id_habitacion = 1;

-- Eliminar asignación de un empleado a una reserva
DELETE FROM empleado_reserva WHERE id_empleado = 1 AND id_reserva = 1;

-- Eliminar un cliente
DELETE FROM cliente WHERE id_cliente = 1;


-- 1. Total de reservas que tiene un cliente
CREATE FUNCTION total_reservas_cliente(cli_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM reserva WHERE id_cliente = cli_id;
  RETURN total;
END;

-- 2. Costo total de los servicios en una reserva específica
CREATE FUNCTION costo_servicios_reserva(res_id INT) RETURNS DECIMAL(10,2)
BEGIN
  DECLARE total DECIMAL(10,2);
  SELECT SUM(rs.cantidad * s.costo) INTO total 
  FROM reserva_servicio rs
  JOIN servicio s ON rs.id_servicio = s.id_servicio
  WHERE rs.id_reserva = res_id;
  RETURN total;
END;

-- 3. Precio total de una habitación según la cantidad de noches
CREATE FUNCTION total_habitacion(res_id INT) RETURNS DECIMAL(10,2)
BEGIN
  DECLARE total DECIMAL(10,2);
  DECLARE dias INT;
  SELECT DATEDIFF(fecha_fin, fecha_inicio) INTO dias FROM reserva WHERE id_reserva = res_id;
  SELECT dias * h.precio_noche INTO total 
  FROM reserva r 
  JOIN habitacion h ON r.id_habitacion = h.id_habitacion
  WHERE r.id_reserva = res_id;
  RETURN total;
END;

-- 4. Devolver el nombre del cliente por ID
CREATE FUNCTION nombre_cliente(cli_id INT) RETURNS VARCHAR(100)
BEGIN
  DECLARE nombre VARCHAR(100);
  SELECT nombre INTO nombre FROM cliente WHERE id_cliente = cli_id;
  RETURN nombre;
END;

-- 5. Total de reservas atendidas por un empleado
CREATE FUNCTION reservas_empleado(emp_id INT) RETURNS INT
BEGIN
  DECLARE total INT;
  SELECT COUNT(*) INTO total FROM empleado_reserva WHERE id_empleado = emp_id;
  RETURN total;
END;

-- Procedimiento almacenado para registrar una nueva reserva
DELIMITER $$
CREATE PROCEDURE registrar_reserva (
  IN p_id_cliente INT,
  IN p_id_habitacion INT,
  IN p_fecha_inicio DATE,
  IN p_fecha_fin DATE
)
BEGIN
  INSERT INTO reserva (id_cliente, id_habitacion, fecha_inicio, fecha_fin)
  VALUES (p_id_cliente, p_id_habitacion, p_fecha_inicio, p_fecha_fin);
END;
$$
DELIMITER ;


-- Mostrar clientes con más de 2 reservas
SELECT nombre FROM cliente
WHERE id_cliente IN (
  SELECT id_cliente FROM reserva GROUP BY id_cliente HAVING COUNT(*) > 2
);

-- Mostrar número de habitaciones que no han sido reservadas
SELECT numero FROM habitacion
WHERE id_habitacion NOT IN (
  SELECT id_habitacion FROM reserva
);

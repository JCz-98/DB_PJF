use gym_db;

-- Reporte con vistas
-- 1. Reporte de las maquinas mas usadas por entrendaores en rutinas de upper body
CREATE VIEW equipos_usados_en rutinas_upper_body
AS
SELECT 
	Equipo.nombre, Equipo.descripcion 
FROM 
	Rutina
INNER JOIN 
	 Localizacion USING (idLocalizacion)
INNER JOIN 
	Equipos USING (idEquipos)
WHERE Localizacion.musculo = "Bicep" OR Localizacion.musculo = "Antebrazo"
	OR Localizacion.musculo = "Tricep" OR Localizacion.musculo = "Espalda"
	OR Localizacion.musculo = "Abdomen" OR Localizacion.musculo = "Hombros"

-- 2. Que rutinas dio un entredor en especifico
CREATE VIEW rutinas_entrenadas_entrenador
AS
SELECT 
	em.nombre, em.especialidad, idLocalizacion, series, repeticiones, fecha 
FROM 
	Rutina
INNER JOIN
	Entrenador as ent using (idEntrenador)
INNER JOIN
	Empleado as em using (idEmpleado)
WHERE
	em.nombre = "Camilo"

-- 3. Que clientes tienen rutinas con especialidad
CREATE VIEW clientes_entrenados_kickboxing
AS
SELECT 
	cl.nombre, em.especialidad, idLocalizacion, series, repeticiones, fecha 
FROM 
	Rutina
INNER JOIN
	Entrenador as ent using (idEntrenador)
INNER JOIN
	Cliente as cl using (idCliente)
WHERE
	ent.especialidad = "KickBoxing"

-- 4. Informacion de clientes que tienen asistencia de nutricionista
CREATE VIEW nutricionista_informacion_cliente
AS
SELECT 
	Cliente.nombre as paciente, Empleado.nombre as tratante, duracion as ultima_dieta, recomendaciones
FROM 
	Dieta
INNER JOIN
	Cliente  using (idCliente)
INNER JOIN
	Empleado using (idEmpleado)

-- 4. Informacion de clientes que tienen asistencia de fisioteriapia

CREATE VIEW fisioterapista_informacion_cliente
AS
SELECT 
	Cliente.nombre as paciente, Empleado.nombre as tratante, fecha as ultima_revision, tratamiento
FROM 
	Fisioterapia
INNER JOIN
	Cliente  using (idCliente)
INNER JOIN
	Empleado using (idEmpleado)

	
-- Store Procedures with transactions

DELIMITER $$

-- 1. Agregar nuevo cliente. valida existencia
CREATE PROCEDURE nuevo_cliente (
	in new_id INT,
    in new_nombre VARCHAR(45),
    in new_fecha DATE,
    out return_val INT
)
BEGIN
	declare id_search int default -1;
    
    START TRANSACTION;
    
		SELECT 
			idCliente
		INTO id_search FROM
			Cliente
		WHERE
			idCliente = new_id;
		
        IF id_search != new_id THEN
			INSERT INTO
				Cliente
			VALUES
				(new_id, new_nombre, new_fecha);
        ELSE
			SET return_val = 1;
            rollback;
            
        END IF;
        
	COMMIT;
    SET return_val = 0;
    
END $$

-- 2. Ingreso de membresia de un cliente si e snuevo cliente o si quiere contratar una nueva memebresia

CREATE PROCEDURE nueva_membresia (
	in new_gym INT,
    in new_cliente INT,
    in new_duracion INT,
    in new_fecha DATE,
    out return_val INT
)
BEGIN
	declare id_1 int default -1;
    
    START TRANSACTION;
    
		SELECT 
			Duracion_mes
		INTO id_1 
        FROM
			Membresia
		WHERE
			idCliente = new_cliente and idGimnasio = new_gym;
		
        IF id_1 != -1 AND id_search != new_duracion THEN
			INSERT INTO
				Membresia (idGimnasio, idCliente, Duracion_mes, fecha_r)
			VALUES
				(new_gym, new_cliente, new_duracion, new_fecha);
        ELSE
			SET return_val = 1;
            rollback;
            
        END IF;
        
	COMMIT;
    SET return_val = 0;

END $$

-- 3. crea Relacion entre cliente y entreador para poder crear rutinas, valida existencia y nueva especialidad

CREATE PROCEDURE relacion_entrenador (
	in new_empleado INT,
    in new_cliente INT,
    in new_especialidad VARCHAR(45),
    out return_val INT
)
BEGIN
	declare id_1 int default -1;
    declare id_2 int default -1;
    
	declare id_rel int default -1;
	declare rel_esp VARCHAR(45);
    
    START TRANSACTION;
		
        SELECT 
			idEntrenador, especialidad
		INTO id_rel, rel_esp
        FROM
			Entrenador
		WHERE
			idCliente = new_cliente and idEmpleado = new_empleado;
        
        IF id_rel = -1 THEN
        
			SELECT 
				idEmpleado
			INTO id_1 
			FROM
				Entrenador
			WHERE
				idEmpleado = new_empleado;
				
			SELECT 
				idCliente
			INTO id_2 
			FROM
				Cliente
			WHERE
				idCliente = new_cliente;
                
			IF id_1 != -1  and id_2 != -1 THEN
				INSERT INTO
					Entreador (idEmpleado, idCliente, especialidad)
				VALUES
					(new_gym, new_cliente, new_duracion, new_fecha);
			ELSE
				SET return_val = 1;
				rollback;
			END IF;
        ELSE
			
            IF rel_esp != new_especialidad THEN
				INSERT INTO
					Entreador (idEmpleado, idCliente, especialidad)
				VALUES
					(new_empleado, new_cliente, new_especialidad);
            ELSE
				SET return_val = 1;
				rollback;
			END IF;
            
        END IF;			

	COMMIT;
    SET return_val = 0;
    
END $$

DELIMITER ;

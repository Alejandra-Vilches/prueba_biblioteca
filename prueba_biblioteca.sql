--creación base de datos
CREATE DATABASE biblioteca;

--entrar con la base de datos
\c biblioteca;

--crear tabla socios
CREATE TABLE socios (RUT VARCHAR(15) PRIMARY KEY, NOMBRE VARCHAR(20), APELLIDO VARCHAR(20), DIRECCIÓN VARCHAR(100), TELÉFONO VARCHAR(15));

--crear tabla libros
CREATE TABLE libros(ISBN VARCHAR(15) PRIMARY KEY, TITULO VARCHAR(100), CANT_PAGINA INT);

--crear tabla historial_prestamos
CREATE TABLE historial_prestamos(FECHA_PRESTAMO DATE,FECHA_ESPERADA_DEV DATE, FECHA_REAL_DEV DATE, RUT_SOCIO VARCHAR(15), ID_HISTORIAL SERIAL, PRIMARY KEY (id_historial), FOREIGN KEY (rut_socio) REFERENCES socios (rut));

--crear tabla autores
CREATE TABLE autores(ID_AUTOR INT PRIMARY KEY, NOMBRE_AUTOR VARCHAR(20), APELLIDO_AUTOR VARCHAR(20), fecha_nacimiento INT,fecha_muerte INT);

--agregar campo tipo_autor a tabla autores_libros
ALTER TABLE autores_libros
ADD tipo_autor VARCHAR(15);

--cargar valores a tabla socios
\copy socios FROM '/Users/ale/Documents/bootcamp/programacion/parte-3/prueba_biblioteca/socios.csv' csv header;

--cargar valores a tabla libros
\copy libros FROM '/Users/ale/Documents/bootcamp/programacion/parte-3/prueba_biblioteca/libros.csv' csv header; 

--cargar valores a tabla autores
\copy autores FROM '/Users/ale/Documents/bootcamp/programacion/parte-3/prueba_biblioteca/autores.csv' csv header; 

--insertar valores a tabla historial_prestamos
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('JUAN SOTO', 'CUENTOS DE TERROR', '2020-01-20', '2020-01-27', '2020-01-27', '1111111-1', 1);

INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('SILVANA MUÑOZ', 'POESÍAS CONTEMPORANEAS', '2020-01-20', '2020-01-30', '2020-01-30', '5555555-5', 2);
	
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('SANDRA AGUILAR', 'HISTORIA DE ASIA', '2020-01-22', '2020-01-30', '2020-01-30', '3333333-3', 3);
	
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('ESTEBAN JEREZ', 'MANUAL DE MECÁNICA', '2020-01-23', '2020-01-30', '2020-01-30', '4444444-4', 4);
	
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('ANA PÉREZ', 'CUENTOS DE TERROR', '2020-01-27', '2020-02-04', '2020-02-04', '2222222-2', 5);
	
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('JUAN SOTO', 'MANUAL DE MECÁNICA', '2020-01-31', '2020-02-12', '2020-02-12', '1111111-1', 6 );
	
INSERT INTO public.historial_prestamos(
	socio, libro, fecha_prestamo, fecha_esperada_dev, fecha_real_dev, rut_socio, id_historial)
	VALUES ('SANDRA AGUILAR', 'POESÍAS CONTEMPORANEAS', '2020-01-31', '2020-02-12', '2020-02-12', '3333333-3', 7);

--cargar valores a tabla historial_prestamos_libros
\copy historial_prestamos_libros FROM '/Users/ale/Documents/bootcamp/programacion/parte-3/prueba_biblioteca/historial_prestamos_libros.csv' csv header;

--cargar valores a tabla autores_libros
\copy autores_libros FROM '/Users/ale/Documents/bootcamp/programacion/parte-3/prueba_biblioteca/autores_libros.csv' csv header; 

--a. Mostrar todos los libros que posean menos de 300 páginas.

SELECT * 
FROM libros 
WHERE cant_paginas < 300;

--b. Mostrar todos los autores que hayan nacido después del 01-01-1970.
--tuve que arreglar la tabla
ALTER TABLE autores
DROP fecha_nac_muerte;

ALTER TABLE autores
ADD fecha_nacimiento INT;

ALTER TABLE autores
ADD fecha_muerte INT;

UPDATE autores SET fecha_nacimiento=1982 WHERE id_autor=1;
UPDATE autores SET fecha_nacimiento=1950 WHERE id_autor=2;
UPDATE autores SET fecha_muerte=2012 WHERE id_autor=2;
UPDATE autores SET fecha_muerte=2020 WHERE id_autor=3;
UPDATE autores SET fecha_nacimiento=1968 WHERE id_autor=3;
UPDATE autores SET fecha_nacimiento=1972 WHERE id_autor=4;
UPDATE autores SET fecha_nacimiento=1976 WHERE id_autor=5;

--aquí está la consulta
SELECT * 
FROM autores
WHERE fecha_nacimiento >1970;

--c. ¿Cuál es el libro más solicitado? 

SELECT COUNT(historial_prestamos_libros.libros_isbn), libros.titulo
FROM historial_prestamos_libros
INNER JOIN libros ON libros.isbn = historial_prestamos_libros.libros_isbn
GROUP BY historial_prestamos_libros.libros_isbn, libros.titulo
ORDER BY COUNT(*)
DESC LIMIT 1 ;

--d. Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto debería pagar cada usuario que entregue el préstamo después de 7 días.

--tuve que cambiar las fechas estimadas de devolución
UPDATE historial_prestamos
SET fecha_esperada_dev='2020-01-27'
WHERE id_historial=2;

UPDATE historial_prestamos
SET fecha_esperada_dev='2020-01-29'
WHERE id_historial=3;

UPDATE historial_prestamos
SET fecha_esperada_dev='2020-02-03'
WHERE id_historial=5;

UPDATE historial_prestamos
SET fecha_esperada_dev='2020-02-07'
WHERE id_historial=6;

UPDATE historial_prestamos
SET fecha_esperada_dev='2020-02-07'
WHERE id_historial=7;

--consulta de deudas de los socios

SELECT (fecha_real_dev - fecha_esperada_dev) * 100 AS deuda, socios.nombre, socios.apellido
FROM historial_prestamos
INNER JOIN socios ON historial_prestamos.rut_socio = socios.rut
WHERE (fecha_real_dev - fecha_esperada_dev) > 0;
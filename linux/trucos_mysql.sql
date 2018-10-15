-- # Arrancar y parar mysql
sudo service mysql status
sudo service mysql stop
sudo service mysql start

-- # Lanzar un script en mysql para crear una base de datos
mysql -u root -p <[PENTAHO_HOME]/biserver-ce/data/mysql5/create_jcr_mysql.sql

-- # Conectarse a una base de datos
mysql -u root -p
use [database]

mysql [database] -u [user] -p

-- # Dar acceso al usuario de una máquina a una BBDD MariaDB:
GRANT ALL ON UDIMADW3.* TO 'obiee'@'10.100.2.%';


-- Consulta de datos de auditoria de cargas:
SELECT * FROM tlog_job_entry
WHERE log_date > '2017-09-03 00:00:00'
ORDER BY log_date DESC

-- Con el campo errors detectamos pasos fallados y con el results vemos si se ha llegado a ejecutar o no

SELECT * FROM tlog_step
WHERE log_date > '2017-09-03 00:00:00'
AND transname = 'TR_CARGA_TFC_HIST_MATRICULA_UPDATE_TODO'
ORDER BY log_date DESC

-- Con el campo errors detectamos el paso fallado, y en el campo log_field aparece el error


SELECT mat.datini, mat.datfin, mat.plan_estudios_sk, pl.plan_estudios_cod, pl.plan_estudios_de,
       mat.exp_numord, mat.alu_dnialu, mat.persona_sk, mat.datalu
FROM tfc_hist_matricula mat
LEFT JOIN tlk_plan_estudios pl ON (mat.plan_estudios_sk = pl.plan_estudios_sk)
WHERE mat.anioacad_sk = 2016
AND mat.plan_estudios_sk = 1142
AND mat.exp_numord = 0


show create database udimadw

ALTER TABLE `UDIMAODS`.`toi_matricalumno_intervalos_reales` 
ADD COLUMN `persona_sk` INT NULL COMMENT 'Clave primaria de la dimensión persona que identifica al alumno de la matrícula' AFTER `alu_dnialu`;

CREATE INDEX idx_tfc_hist_matricula_alumno_persona
USING BTREE
ON tfc_hist_matricula_alumno (persona_sk);


-- Para permitir claves (primarias y únicas, con índices solo es necesario
-- especificar el ROW_FORMAT de la tabla) de tamaño grande en las bases de datos de mysql
-- hay que hacer estos dos cambios a los parámetros generales de la base
-- de datos. El cambio afecta a todas las bases de datos alojadas, no sólo
-- a una de ellas:
SHOW GLOBAL VARIABLES LIKE 'innodb_large%';
SHOW GLOBAL VARIABLES LIKE 'innodb_file%';
SET GLOBAL innodb_large_prefix = ON;
SET GLOBAL innodb_file_format = BARRACUDA;

-- Además, en la creación de cada tabla, hay que especificar su ROW_FORMAT:
CREATE TABLE xxx ()
COMMENT ''
ROW_FORMAT = DYNAMIC;


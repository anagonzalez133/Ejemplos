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

/* La tabla tlog_channels se relaciona con el resto de tablas por el CHANNEL_ID, excepto en el caso de la tlog_job_entry
no ocurre así por un bug https://jira.pentaho.com/browse/PDI-16515  en lugar de
la unión directa usar la siguiente query */
select CHANNEL.CHANNEL_ID CHANNEL_ID_CORRECTED, CHANNEL.OBJECT_NAME channel_object_name
, JOBENTRY.*
from tlog_job_entry JOBENTRY
inner join tlog_job JOB
on JOBENTRY.ID_BATCH = JOB.ID_JOB
/* Las limitaciones por jobname y fecha no funcionan, dan timeout, hay que limitar por channel_id, obteniendo el que nos interese de la consulta de abajo */
/* and JOB.JOBNAME = 'JB_ALL_HIST_MATRICULA'
and JOB.LOGDATE >= STR_TO_DATE('20181001', '%Y%m%d') */
inner join tlog_channels CHANNEL
on JOB.CHANNEL_ID = CHANNEL.PARENT_CHANNEL_ID
 and CHANNEL.OBJECT_NAME = JOBENTRY.STEPNAME
WHERE JOB.CHANNEL_ID = '73a9e95a-5ca1-4393-b04d-89208fc0eaf9'


select JOB.CHANNEL_ID JOB_CHANNEL_ID, JOBENTRY.ID_BATCH, JOBENTRY.CHANNEL_ID WRONG_JOBENTRY_CHANNEL_ID, JOBENTRY.LOG_DATE,
       JOBENTRY.TRANSNAME, JOBENTRY.STEPNAME, JOBENTRY.LINES_READ, JOBENTRY.LINES_WRITTEN,
       JOBENTRY.LINES_UPDATED, JOBENTRY.LINES_INPUT, JOBENTRY.LINES_OUTPUT, JOBENTRY.ERRORS,
       JOBENTRY.RESULT, JOBENTRY.NR_RESULT_ROWS
from tlog_job_entry JOBENTRY
inner join tlog_job JOB
on JOBENTRY.ID_BATCH = JOB.ID_JOB
WHERE JOBENTRY.transname = 'JB_ALL_HIST_MATRICULA'

select JOB.CHANNEL_ID JOB_CHANNEL_ID, JOBENTRY.ID_BATCH, JOBENTRY.CHANNEL_ID WRONG_JOBENTRY_CHANNEL_ID, JOBENTRY.LOG_DATE,
       JOBENTRY.TRANSNAME, JOBENTRY.STEPNAME, JOBENTRY.LINES_READ, JOBENTRY.LINES_WRITTEN,
       JOBENTRY.LINES_UPDATED, JOBENTRY.LINES_INPUT, JOBENTRY.LINES_OUTPUT, JOBENTRY.ERRORS,
       JOBENTRY.RESULT, JOBENTRY.NR_RESULT_ROWS
from tlog_job_entry JOBENTRY
inner join tlog_job JOB
on JOBENTRY.ID_BATCH = JOB.ID_JOB
WHERE JOBENTRY.transname = 'JB_ALL_HIST_MATRICULA'
-- and JOB.LOGDATE >= STR_TO_DATE('20181001', '%Y%m%d')








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



-- Para cambiar el character set de una base de datos:
-- 1) Exportar la base de datos a un fichero sql especificando la orden de borrar la base de datos:
mysqldump -uusername -ppassword -c -e --default-character-set=utf8mb4 --single-transaction --skip-set-charset --add-drop-database -B dbname > dump.sql
-- 2) Editar con vi el fichero sql generado, haciendo el cambio del collate y el character set:
-- Es importante hacer la sustitución primero del COLLATE y luego del CHARSET, para evitar modificar el COLLATE parcialmente
:%s/latin1_spanish_ci/utf8mb4_general_ci/
:%s/latin1/utf8mb4/
-- 3) Volver a crear la base de datos con el fichero modificado:
mysql -uusername -ppassword < dump.sql

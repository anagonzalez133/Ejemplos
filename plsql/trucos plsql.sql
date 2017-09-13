


/**************************************
* Crear un tablespace con su datafile *
***************************************/
CREATE TABLESPACE COSTES_INDX
BLOCKSIZE 8192 DATAFILE '/ldatabase1/l1199/data/costes_indx_l1199_01.dbf'
SIZE 50M AUTOEXTEND ON NEXT 100M MAXSIZE 5000M
NOLOGGING EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

ALTER USER DDS_COSTES QUOTA UNLIMITED ON COSTES_INDX;
ALTER USER ODS_COSTES QUOTA UNLIMITED ON COSTES_INDX;

CREATE TABLESPACE CORE_DAT_128K DATAFILE '/kdatabase2/k1158/sysdata/core_dat_128k_k1158_01.dbf' SIZE 50M
    EXTENT MANAGEMENT LOCAL UNIFORM SIZE 128K;
CREATE TABLESPACE CORE_INX_128K DATAFILE '/kdatabase2/k1158/sysdata/core_inx_128k_k1158_01.dbf' SIZE 50M
    EXTENT MANAGEMENT LOCAL AUTOALLOCATE;

-- Directorios para tablas externas:
select * from v$parameter where name like 'utl_file_dir'

/*****************************************************************
* Generar un script de grants en base a los grants ya existentes *
* en un entorno.                                                 *
******************************************************************/
SELECT 'GRANT '||PRIVILEGE||' ON '||GRANTOR||'.'||TABLE_NAME||' TO '||GRANTEE||';'
FROM ALL_TAB_PRIVS
WHERE GRANTOR = 'USUARIO'
ORDER BY TABLE_NAME;

/********************************************
* Tamaño de tablespaces de la base de datos *
*********************************************/
select df.tablespace_name "Tablespace", totalusedspace "Used MB",
       (df.totalspace - tu.totalusedspace) "Free MB",
       df.totalspace "Total MB", round(100 * ( (df.totalspace - tu.totalusedspace)/ df.totalspace)) "Pct. Free"
from (  select tablespace_name, round(sum(bytes) / 1048576) TotalSpace
        from dba_data_files
        group by tablespace_name
     ) df,
     (  select round(sum(bytes)/(1024*1024)) totalusedspace, tablespace_name
        from dba_segments
        group by tablespace_name
     ) tu
where df.tablespace_name = tu.tablespace_name
order by df.tablespace_name

/*************************************************************
* Búsqueda de tablespaces con menos del 10% de espacio libre *
**************************************************************/

SELECT TSP.TABLESPACE_NAME T_NAME,
       TSP.TOTAL_SPACE TOT_SPACE,
       FREE.TOTAL_FREE,
       ROUND(FREE.TOTAL_FREE /TSP.TOTAL_SPACE*100) PCT_FREE,
       ROUND((TSP.TOTAL_SPACE - FREE.TOTAL_FREE),2) TOT_USED,
       ROUND((TSP.TOTAL_SPACE - FREE.TOTAL_FREE)/TSP.TOTAL_SPACE*100) PCT_USED,
       NEXTEXT.MAX_NEXT_EXTENT
FROM (  SELECT TABLESPACE_NAME, SUM(BYTES)/1024/1024 TOTAL_SPACE FROM DBA_DATA_FILES GROUP BY TABLESPACE_NAME) TSP,
     (  SELECT TABLESPACE_NAME, ROUND(SUM(BYTES)/1024/1024,2) TOTAL_FREE, ROUND(MAX(BYTES)/1024/1024,2) MAX_FREE
	    FROM DBA_FREE_SPACE
		GROUP BY TABLESPACE_NAME
	 ) FREE,
	 (  SELECT TABLESPACE_NAME, ROUND(MAX(NEXT_EXTENT)/1024/1024,2) MAX_NEXT_EXTENT
	    FROM DBA_SEGMENTS
	    GROUP BY TABLESPACE_NAME
	 ) NEXTEXT
WHERE TSP.TABLESPACE_NAME = FREE.TABLESPACE_NAME (+)
AND TSP.TABLESPACE_NAME = NEXTEXT.TABLESPACE_NAME (+)
AND ((ROUND(FREE.TOTAL_FREE/TSP.TOTAL_SPACE*100)) <> FREE.MAX_FREE);

/************************************************************************
* Búsqueda de parámetros de la base de datos como el número de sesiones *
*************************************************************************/
select * from v$parameter
order by name

/********************************************************
* Búsqueda de objetos descompilados de la base de datos *
*********************************************************/
select owner, object_type, object_name, status from dba_objects
where status = 'INVALID'
and owner = 'ODS_UXXIAC'
order by owner, object_type, object_name, status

/*******************************
* Búsqueda de políticas de VPD *
********************************/
select * from dba_policies
where object_owner = 'DDS_UXXIAC'
order by object_name, policy_name

-- Variante para lanzar desde el usuario propietario del objeto sobre el que se aplica la VPD:
select * from user_policies
order by object_name, policy_name

/*********************************************************
* Búsqueda y creación de trabajos programados en la BBDD *
**********************************************************/
SELECT * FROM all_scheduler_jobs

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'TUTORES_ASIGNACION',
   job_type           =>  'PLSQL_BLOCK',
   job_action         =>  'BEGIN pudm$tutores_udima.p_asignacionmasivadetutor; END;',
   repeat_interval    =>  'FREQ=DAILY;BYHOUR=19;BYMINUTE=5',
   comments           =>  'Ejecución diaria del proceso de desasignación/asignación de tutores');
  DBMS_SCHEDULER.ENABLE ('TUTORES_ASIGNACION');
END;

BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (name => 'TUTORES_ASIGNACION', attribute => 'repeat_interval', value => 'FREQ=DAILY;BYHOUR=01');
END;


BEGIN
owbsys.wb_workspace_management.set_workspace('OWB11G', 'OWB11G');
END;

select a.TASK_NAME, a.CREATION_DATE, a.AUDIT_EXECUTION_ID,
			 c.AUDIT_MESSAGE_LINE_ID, c.PLAIN_TEXT
from wb_rt_audit_executions a,
     WB_RT_AUDIT_MESSAGES b,
     WB_RT_AUDIT_MESSAGE_lines c
where a.AUDIT_EXECUTION_ID = b.AUDIT_EXECUTION_ID
and b.AUDIT_MESSAGE_ID = c.AUDIT_MESSAGE_ID
order by a.CREATION_DATE desc, c.AUDIT_MESSAGE_LINE_ID desc


/*********************************************************************
* Datos del Control Center, actualizar CONNECT_SPEC si es necesario. *
**********************************************************************/
select node_id, connect_spec
from WB_RT_SERVICE_NODES

/**********************************************************************
* Para actualizar la localización del Control Center de Análisis tras *
* una importación completa del proyecto utilizar la siguiente consulta *
**********************************************************************/
SELECT b_1 COMPLETED, s1_1 CREATEDBY, d_1 CREATIONTIMESTAMP, b_2 CUSTOMERDELETABLE,
       b_3 CUSTOMERRENAMABLE, b_4 DELETEINOVERRIDE, s3_1 DESCRIPTION, b_5 EDITABLE,
       i_1 ELEMENTID, b_6 IMPORTED, s4_1 LOGICALNAME, s2_2 METADATASIGNATURE,
       s4_2 NAME, s3_2 NOTE, i_2 NOTM, b_7 OVERRIDEATTRIBUTES, b_8 OVERRIDECHILDREN,
       b_9 OVERRIDEROLES, b_10 PERSISTENT, b_11 SEEDED, s2_3 STRONGTYPENAME,
       s1_2 UOID, s1_3 UPDATEDBY, d_2 UPDATETIMESTAMP, r_1 ICONOBJECT, s1_9 APPLICATIONTYPE,
       s1_10 GATEWAYTYPE, s1_11 LOCTYPE, s1_12 LOCTYPEVERSION, b_12 REGISTERED,
       s1_13 TYPE, r_15 PLATFORM, r_16 MIVDEFINITION, r_17 OWNINGPROJECT,
       r_4 ACLCONTAINER, r_5 VALIDATIONRESULT, r_6 OWNINGFOLDER, s2_4 HOST,
       i_7 PORT, s2_5 SCHEMA, s1_14 SID, s1_15 USERNAME
FROM CMPFCOClasses tbl
WHERE s2_1 = 'CMPRuntimeLocation'

-- Para recuperar los datos del service name (y de paso actualizar aquí
-- también host y puerto si es necesario) utilizar la siguiente consulta:
select datos.logicalname prop_cod, datos.value prop_de
from cmpstringpropertyvalue_v datos
where datos.propertyowner = elementid_anterior
order by datos.logicalname
	
-- Con esto ya se pueden realizar las actualizaciones:

update cmpfcoclasses
set s2_4 = 'mihost',
    i_7 = 'mipuerto'
where s2_1 = 'CMPRuntimeLocation'
and i_1 = elementid_anterior

update cmpstringpropertyvalue_v
set value = 'mihost'
where propertyowner = elementid_anterior
and logicalname = 'CMPLocation_Host'

update cmpstringpropertyvalue_v
set value = 'misid'
where propertyowner = elementid_anterior
and logicalname = 'CMPLocation_ServiceName'



/*********************************************************************
* Datos de localizaciones de OWB
*********************************************************************/
select loc.elementid loc_id, loc.name loc_de,
       datos.logicalname prop_cod, datos.value prop_de
from cmpstringpropertyvalue_v datos,
     CMPLogicalLocation_v loc
where datos.propertyowner = loc.elementid
order by loc.name, datos.logicalname

update cmpstringpropertyvalue_v
set value = 'l1104'
where propertyowner = 347550
and logicalname = 'CMPLocation_ServiceName'

-- Búsqueda de la versión del repositorio de runtime: WB_RTV_SERVICE_NODES, WB_RTV_INSTALLED_SERVICES

/********************************************************************
*        Búsqueda de ciertas constantes en el OWB.                  *
* La búsqueda en la vista ALL_IV_XFORM_MAP_PARAMETERS sólo funciona *
* cuando se efectúa por la columna MAP_COMPONENT_ID, por eso está la*
* subquery:                                                         *
*********************************************************************/

select p.* from
ALL_IV_XFORM_MAP_PARAMETERS p
where p.TRANSFORMATION_EXPRESSION = '''TIEMPO COMPLETO'''
and p.map_component_id in (
SELECT distinct c.map_component_id FROM
ALL_IV_XFORM_MAPS M,
ALL_IV_XFORM_MAP_COMPONENTS C
WHERE M.MAP_ID = C.MAP_ID
AND M.INFORMATION_SYSTEM_NAME = 'ANECA_ODS'
AND C.OPERATOR_TYPE = 'Variables')

/*****************************************************************
* Se comprueba en qué procesos se cargan las TOH que intervienen *
* los mapeos de un proceso OI:                                   *
******************************************************************/

SELECT DISTINCT MAPTOH.MAP_TOH, PROC.PROCESS_NAME
FROM (  SELECT DISTINCT MAP_COMPONENT_NAME||'_M' MAP_TOH
        FROM (  SELECT DISTINCT ACTIVITY_NAME FROM ALL_IV_PROCESS_ACTIVITIES
                WHERE PROCESS_NAME = 'INV_PROD_CIENTI_OI_C'
		    AND ACTIVITY_NAME LIKE '%M'
		 ) MAPORI,
		 ALL_IV_XFORM_MAP_COMPONENTS MAP
	  WHERE MAPORI.ACTIVITY_NAME = MAP.MAP_NAME
	  AND MAP.MAP_COMPONENT_NAME LIKE 'TOH%'
     ) MAPTOH,
     ALL_IV_PROCESS_ACTIVITIES PROC
WHERE MAPTOH.MAP_TOH = PROC.ACTIVITY_NAME (+)
ORDER BY 1, 2

-- Consideraciones:
-- No se recuperan datos de los mapeos a los que se haya cambiado
-- el nombre en el process flow, dados por la siguiente query:
SELECT * FROM (
SELECT DISTINCT MAPORI.ACTIVITY_NAME, MAP.MAP_NAME
FROM (  SELECT DISTINCT ACTIVITY_NAME FROM ALL_IV_PROCESS_ACTIVITIES
        WHERE PROCESS_NAME = 'INV_PROD_CIENTI_OI_C'
	  AND ACTIVITY_NAME LIKE '%M'
     ) MAPORI,
     ALL_IV_XFORM_MAP_COMPONENTS MAP
WHERE MAPORI.ACTIVITY_NAME = MAP.MAP_NAME (+)
)
WHERE MAP_NAME IS NULL

-- No se recuperan los mapeos que cargan las TOH para los que
-- el nombre del mapeo se ha acortado respecto al nombre de la TOH:
SELECT * FROM (
SELECT DISTINCT MAPTOH.MAP_TOH, MAP.MAP_NAME
FROM (  SELECT DISTINCT MAP_COMPONENT_NAME||'_M' MAP_TOH
        FROM (  SELECT DISTINCT ACTIVITY_NAME FROM ALL_IV_PROCESS_ACTIVITIES
                WHERE PROCESS_NAME = 'INV_PROD_CIENTI_OI_C'
		    AND ACTIVITY_NAME LIKE '%M'
		 ) MAPORI,
		 ALL_IV_XFORM_MAP_COMPONENTS MAP
	  WHERE MAPORI.ACTIVITY_NAME = MAP.MAP_NAME
	  AND MAP.MAP_COMPONENT_NAME LIKE 'TOH%'
     ) MAPTOH,
     ALL_IV_XFORM_MAP_COMPONENTS MAP
WHERE MAPTOH.MAP_TOH = MAP.MAP_NAME (+)
)
WHERE MAP_NAME IS NULL

/********************************************************
* Búsqueda de mapeos en los que intervienen las tablas, *
* incluyendo el esquema del mapeo:                      *
*********************************************************/
select distinct m.INFORMATION_SYSTEM_NAME, c.MAP_NAME, c.MAP_COMPONENT_NAME
from all_iv_xform_maps m,
     all_iv_xform_map_components c
where m.MAP_ID = c.MAP_ID
and c.MAP_COMPONENT_NAME like '%TFC_PER_PAS%'
order by 1, 3, 2

/**********************************************************
* Búsqueda de los valores de parámetros de procedimientos *
* que participan en los process flow:                     *
***********************************************************/

select a.PROCESS_ID, a.PROCESS_NAME, a.ACTIVITY_ID,
       a.ACTIVITY_NAME, b.PARAMETER_ID, b.PARAMETER_NAME, b.DEFAULT_VALUE
from ALL_IV_PROCESS_ACTIVITIES a,
     ALL_IV_PROCESS_PARAMETERS b
where a.ACTIVITY_ID = b.PARAMETER_OWNER_ID
and a.ACTIVITY_NAME like 'BORRAINDI%'
order by a.PROCESS_NAME, a.ACTIVITY_ID, b.POSITION

/************************************************************
* Búsqueda de los procesos en los que participan los mapeos *
* en los que interviene una tabla:                          *
*************************************************************/

select distinct a.MAP_COMPONENT_NAME, a.MAP_NAME, b.PROCESS_NAME
from ALL_IV_XFORM_MAP_COMPONENTS a,
     ALL_IV_PROCESS_ACTIVITIES b
where a.MAP_NAME = b.ACTIVITY_NAME (+)
and a.MAP_COMPONENT_NAME like '%PROSUBPRO%'
order by 1, 2, 3

/***********************************************************
* Búsqueda del tiempo de ejecución de un determinado mapeo *
************************************************************/

select TASK_NAME, CREATION_DATE,
       TO_DATE(TO_CHAR(CREATION_DATE + FLOOR((TO_NUMBER(TO_CHAR(CREATION_DATE, 'SSSSS')) + ELAPSE)/86399), 'YYYYMMDD') || ' ' || TO_CHAR(TO_NUMBER(TO_CHAR(CREATION_DATE, 'SSSSS')) + ELAPSE  - (FLOOR((TO_NUMBER(TO_CHAR(CREATION_DATE, 'SSSSS')) + ELAPSE)/86399) * 86399)), 'YYYYMMDD SSSSS') FECHA_FIN, 
       ELAPSE,
       TRUNC(ELAPSE/86399) DIAS,
       TO_CHAR(TO_DATE(MOD(ELAPSE,86399), 'SSSSS'), 'HH24:MI') HORAS
from WB_RT_AUDIT_EXECUTIONS
where TASK_NAME LIKE '%RESULT%DS%CREA%'
ORDER BY 2 DESC

/************************************************************************
* Búsqueda de tiempos y cursores de todos los mapeos de un PROCESS FLOW *
*************************************************************************/

select padre.external_audit_id, exec.AUDIT_EXECUTION_ID, exec.EXECUTION_NAME, exec.ELAPSE, exec.CREATION_DATE, exec.LAST_UPDATE_DATE,
       exec.RETURN_RESULT, exec.RETURN_RESULT_NUMBER, exec.RETURN_CODE, exec.AUDIT_STATUS,
       MAP.NUMBER_RECORDS_SELECTED, map.number_records_inserted, map.number_records_updated,
       map.number_records_deleted
from wb_rt_audit_executions exec,
     all_rt_audit_map_runs map,
     wb_rt_audit_executions padre
where exec.TOP_LEVEL_AUDIT_EXECUTION_ID = padre.audit_execution_id
and exec.audit_execution_id = MAP.EXECUTION_AUDIT_ID
and padre.execution_name = 'GENERAL_ALL'
order by exec.creation_date desc

/************************************************************************
* Búsqueda de mensajes de ejecución de una actividad en un process flow *
*************************************************************************/
select a.TASK_NAME, a.CREATION_DATE, a.AUDIT_EXECUTION_ID,
c.AUDIT_MESSAGE_LINE_ID, c.PLAIN_TEXT
from wb_rt_audit_executions a,
     WB_RT_AUDIT_MESSAGES b,
     WB_RT_AUDIT_MESSAGE_lines c
where a.AUDIT_EXECUTION_ID = b.AUDIT_EXECUTION_ID
and b.AUDIT_MESSAGE_ID = c.AUDIT_MESSAGE_ID
order by a.CREATION_DATE desc, c.AUDIT_MESSAGE_LINE_ID desc

-- Versión para 11G:

SELECT map.execution_audit_id, map.external_audit_id, map.execution_name,
       map.object_name, map.object_type, map.execution_audit_status,
       map.elapse_time, map.created_on map_dt_executed_on,
       mes.created_on mes_dt_created_on, mes.message_severity,
       mes.message_text
FROM all_rt_audit_executions map,
     all_rt_audit_exec_messages mes
WHERE map.execution_audit_id = mes.execution_audit_id
ORDER BY mes.created_on desc, map.created_on DESC

/***************************************************************
* Búsqueda de los valores definidos para parámetros durante la *
* ejecución de un process flow:                                *
****************************************************************/
select a.execution_audit_id, c.task_name activity_name,
TO_CHAR(c.created_on, 'YYYYMMDD HH24:MI:SS') start_date,
TO_CHAR(c.updated_on, 'YYYYMMDD HH24:MI:SS') completion_date,
a.parameter_name, a.value, a.parameter_mode, a.parameter_type
from all_rt_audit_execution_params a,
     all_rt_audit_executions c,
     all_rt_audit_executions p
where a.execution_audit_id = c.execution_audit_id
and c.parent_execution_audit_id = p.execution_audit_id
and p.object_name LIKE 'EEX_OH%'
order by a.execution_audit_id desc, c.parameter_audit_id desc

/**********************************************************************
* Consultar los procesos y en qué estado se encuentran, tanto los que *
* están en ejecución como los que han finalizado y en que estado han  *
* finalizado: Vista WF_ITEM_ACTIVITY_STATUSES_V del usuario OWF_MGR,  *
* aquí hay tres campos importantes que luego usaremos, ITEM_TYPE,     *
* ITEM_KEY, ACTIVITY_NAME                                             *
* Para cancelar la ejecución de procesos que se han quedado activos,  *
* ejecutar la siguiente consulta para recuperar los procesos a abortar*
***********************************************************************/
select 'EXECUTE wf_engine.ABORTPROCESS('||''''||i.ITEM_TYPE||''''||','
       ||''''||i.item_key||''''||','||''''||p.instance_label||''''||','
       ||''''||'COMPLETE'||''''||');'
from WF_PROCESS_ACTIVITIES p,
WF_ITEM_ACTIVITY_STATUSES i
where activity_status = 'ACTIVE'
and p.instance_id = i.process_activity
order by i.activity_status,i.activity_result_code

/*********************************************************************
* Para relanzar un proceso que ha dado error se usa el procedimiento *
* handleerror:                                                       *
**********************************************************************/
exec wf_engine.handleerror ('<item_type>','<item_key>','<activity_name>','< RETRY || SKIP >','[<return_status>]);
-- return_status tiene que ser informado cuando el tercer parámetro de
-- la llamada sea SKIP y los valores que admite son: OK, OK_WITH_WARNINGS, FAILURE.
-- Ejemplo:
-- Relanzar el mapping TOI_2_PAS_PORC_CUOT_SS_M, que inicialmente finalizó con errores,
-- ahora se relanzará tras solucionar el problema.
exec wf_engine.handleerror ('UXXIRRHH','WB_IK_2006422_9153_141061','TOI_2_PAS_PORC_CUOT_SS_M','RETRY');

/*********************************************
* Para consultar la url del Workflow Monitor *
**********************************************/
select * from WF_RESOURCES
where name = 'WF_WEB_AGENT'


/*
Para abrir el OWB en modo debug en la versión 11:
•	Navegar al directorio <OWBHOME>\owb\bin\admin
•	Crear en este directorio un fichero llamado owbclient.logging.properties con el siguiente contenido:
console.messageFormat={1,time}: {2}
file.messageFormat=[{3} ({4})] {1,time}: <{0}> {2}
handlers=java.util.logging.FileHandler,java.util.logging.ConsoleHandler
java.util.logging.FileHandler.pattern=/temp/owbclient.log

# Excessive debug, do not use day to day
.level = DEBUG_ALL
java.util.logging.FileHandler.level=ALL
java.util.logging.ConsoleHandler.level=DEBUG_ALL
•	Abrir el OWB del modo habitual.
•	En C:\TEMP se creará el fichero de log
•	Una vez finalizado el modo debug, borrar el fichero (o renombrarlo para poder utilizarlo), ya que los log generados pueden comerse mucho espacio a la larga.

*/


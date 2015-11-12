/*******************************************************************************
*   Proceso de borrado de las tablas de RRHH una vez configuradas las fechas   *
*                                   a borrar.                                  *
*  Revisar el script si se va a lanzar en otro entorno que no sea producción   *
* de la UC3M, porque fallará si no se ejecuta en ese entorno si se ejecuta sin *
*                                  modificar.                                  *
*******************************************************************************/
SET SERVEROUTPUT ON SIZE 1000000
SET PAGESIZE 0
SET VERIFY OFF
SET WRAP ON
SET LINESIZE 1500
/* Elimina el mensaje Procedure PL/SQL sucessfully completed : */
SET FEEDBACK OFF

accept RUTA_LOG    PROMPT 'Introduzca la ruta donde dejar el fichero de log (Formato C:\temp):  '

spool &RUTA_LOG\borrado_rrhh.log

DECLARE
  v_estado VARCHAR2(10);
  v_error  VARCHAR2(400);
  v_error_cod     NUMBER(10);

v_usuario       VARCHAR2(30) := 'SIN_DEFINIR';
v_maquina       VARCHAR2(100) := 'SIN_DEFINIR';
ERROR_USUARIO   EXCEPTION;
ERROR_BD        EXCEPTION;

BEGIN
    
    DBMS_OUTPUT.PUT_LINE('...');
    DBMS_OUTPUT.PUT_LINE('...');
    DBMS_OUTPUT.PUT_LINE('Puede revisar el log de ejecucion en &RUTA_LOG\borrado_rrhh.log');
    DBMS_OUTPUT.PUT_LINE('...');
    DBMS_OUTPUT.PUT_LINE('*****************************************************************');
    DBMS_OUTPUT.PUT_LINE('* Versión del script: 2.0 Fecha Ejecucion: ' || to_char(sysdate, 'dd-mm-yy hh24:mi:ss') || ' Usuario: ' || USER || ' *');
    DBMS_OUTPUT.PUT_LINE('*****************************************************************');
    DBMS_OUTPUT.PUT_LINE('...');

    SELECT USER INTO v_usuario FROM DUAL;
    
    IF v_usuario <> 'ODS_GENERAL' THEN RAISE ERROR_USUARIO; END IF;
    
    DBMS_OUTPUT.PUT_LINE('Usuario correcto');
    DBMS_OUTPUT.PUT_LINE('...');
    
    SELECT host_name INTO v_maquina FROM V$INSTANCE;
    
    IF v_maquina NOT IN ('uxxibd1.uc3m.es', 'uxxibd2.uc3m.es') THEN RAISE ERROR_BD; END IF;

    DBMS_OUTPUT.PUT_LINE('Base de datos correcta');
    DBMS_OUTPUT.PUT_LINE('...');

    ELIMINAR_CARGAS.ELIMINAR_CARGA('1', NULL, v_estado, v_error);
    DBMS_OUTPUT.PUT_LINE(v_estado||':'||v_error);

EXCEPTION
    WHEN ERROR_USUARIO THEN
        DBMS_OUTPUT.PUT_LINE('************************* ERROR *************************');
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('Error: El usuario '|| v_usuario ||' no es correcto. Remitir el log a OCU.');
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('************************* ERROR *************************');
        
    WHEN ERROR_BD THEN
        DBMS_OUTPUT.PUT_LINE('************************* ERROR *************************');
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('Error: El entorno '|| v_maquina ||' no es correcto. Remitir el log a OCU.');
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('************************* ERROR *************************');

    WHEN OTHERS THEN
        v_error_cod := SQLCODE;
        v_error := SUBSTR(SQLERRM, 1, 300);

        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('*****************************************************************');
        DBMS_OUTPUT.PUT_LINE('*********    ERROR     Interrumpa el proceso y remita el log a OCU para su estudio ******');
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        DBMS_OUTPUT.PUT_LINE('...');
        DBMS_OUTPUT.PUT_LINE('************************* ERROR *************************');
        ROLLBACK;
        RAISE_APPLICATION_ERROR(v_error_cod, v_error);
END;
/
spool off

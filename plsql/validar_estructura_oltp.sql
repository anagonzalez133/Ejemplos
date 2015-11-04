/*                                 Versión 1.0                                  */
/*                               Fecha: 20091112                                */
/*                          Instrucciones y posología:                          */
/* 1. Se lanza desde el usuario ODS_XXX del OLTP que queramos validar           */
/* 2. Hay que ajustar las tres primeras variables del apartado del DECLARE:     */
/*    V_MODULO_OWB: Es el nombre del modulo OLTP en el OWB que queremos validar */
/*    V_PROPIETARIO_TABLAS: El usuario propietario de las tablas, no            */
/*                          necesariamente el usuario del DB-Link               */
/*    V_DB_LINK: El nombre del DB-Link en el usuario ODS_XXX.                   */
/********************************************************************************/

SET SERVEROUTPUT ON
DECLARE

v_modulo_owb VARCHAR2(50) := 'SOROLLA_OLTP';
v_propietario_tablas VARCHAR2(50) := 'UXXIEC';
v_db_link VARCHAR2(50) := 'UXXIEC.WORLD@TO_SOROLLA_OLTP';

/* Cursor con todas las tablas y vistas y sus columnas para un módulo del OWB */
CURSOR c_col_tab_owb (p_modulo_owb owb102.all_iv_tables.schema_name%TYPE) IS
SELECT UPPER(c.entity_name) tabla, UPPER(c.column_name) columna, c.data_type, c.length, c.precision, c.scale
FROM owb102.all_iv_tables t,
     owb102.all_iv_columns c
WHERE t.table_id = c.entity_id
AND t.schema_name = p_modulo_owb
UNION
SELECT UPPER(c.entity_name) tabla, UPPER(c.column_name) columna, c.data_type, c.length, c.precision, c.scale
FROM owb102.all_iv_views v,
     owb102.all_iv_columns c
WHERE v.view_id = c.entity_id
AND v.schema_name = p_modulo_owb
ORDER BY tabla, columna;

v_tabla VARCHAR2(30) := 'Inicio';
v_columna VARCHAR2(30) := 'Inicio';
v_tipo_col VARCHAR2(30) := 'Inicio';

v_orden VARCHAR2(500);
r_tab_col_oltp all_tab_columns%ROWTYPE;

BEGIN

    DBMS_OUTPUT.PUT_LINE('Inicio validacion tablas de ' || v_modulo_owb || '-' || v_propietario_tablas || '-' || v_db_link || '. Versión 1.0.');
    
    /* Construyo la orden que se va a lanzar para buscar las columnas */
    v_orden := 'SELECT * FROM all_tab_columns@' || v_db_link || ' WHERE UPPER(table_name) = :v_tab_name AND owner = :v_owner AND UPPER(column_name) = :v_col';
    
    FOR r_col_tab_owb IN c_col_tab_owb (v_modulo_owb) LOOP
        
        /* Inicializo las variables de control */
        v_tabla := r_col_tab_owb.tabla;
        v_columna := r_col_tab_owb.columna;
        v_tipo_col := r_col_tab_owb.data_type;
        
        BEGIN
            EXECUTE IMMEDIATE v_orden INTO r_tab_col_oltp USING v_tabla, v_propietario_tablas, v_columna;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Revisar: No existe columna:' || v_tabla || '-' || v_columna  || '.');
            v_columna := 'NO COLUMNA';
        END;
        
        IF v_columna = 'NO COLUMNA' THEN NULL; /* No validamos más, ya hemos dejado el mensaje de revisión */
        ELSE
            CASE WHEN v_tipo_col <> r_tab_col_oltp.data_type
                     THEN DBMS_OUTPUT.PUT_LINE('Revisar: ' || v_tabla || '-' || v_columna || ' es de tipo distinto:' || v_tipo_col || '<>' || r_tab_col_oltp.data_type || '.');
                 WHEN v_tipo_col IN ('VARCHAR2', 'CHAR') THEN
                     /* Comprobamos que la tabla del owb tenga al menos la misma longitud que la tabla fuente */ 
                     IF r_col_tab_owb.length < r_tab_col_oltp.data_length THEN
                        DBMS_OUTPUT.PUT_LINE('Revisar: ' || v_tabla || '-' || v_columna || ' aumentar longitud.');
                     END IF;
                 WHEN v_tipo_col = 'DATE' THEN NULL; /* En columnas de este tipo no hay que revisar tamaños */
                 WHEN v_tipo_col = 'NUMBER' THEN
                     /* Comprobamos la precisión y escala de las columnas */
                     IF (r_col_tab_owb.precision < r_tab_col_oltp.data_precision OR r_col_tab_owb.scale < r_tab_col_oltp.data_scale) THEN
                         DBMS_OUTPUT.PUT_LINE('Revisar: ' || v_tabla || '-' || v_columna || ' aumentar precision o escala.');
                     END IF;
                 ELSE DBMS_OUTPUT.PUT_LINE('Revisar: ' || v_tabla || '-' || v_columna || ' tipo de columna:' || v_tipo_col || ' no tratado.');
            END CASE; /* CASE Validacion columna */
        END IF; /* v_columna = NO COLUMNA */
    END LOOP; /* Fin del loop que recorre las tablas y vistas del owb */
    DBMS_OUTPUT.PUT_LINE('Fin validacion tablas de ' || v_modulo_owb || '-' || v_propietario_tablas || '-' || v_db_link || '.');
EXCEPTION
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERROR en ' || v_tabla || '-' || v_columna || '-' || v_tipo_col || '. ' || SQLERRM);
END;

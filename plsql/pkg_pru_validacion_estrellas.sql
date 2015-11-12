/******************************************************************************
* Paquete PKG_PRU_VALIDACION_ESTRELLAS
* Versión: 1.0
*******************************************************************************/

CREATE OR REPLACE PACKAGE pkg_pru_validacion_estrellas IS
 
PROCEDURE pr_inicia_ejecucion;
PROCEDURE pr_lanzador_pruebas(p_esquema IN VARCHAR2 DEFAULT NULL,
                              p_tabla IN VARCHAR2 DEFAULT NULL);
PROCEDURE proc_val_metricas(p_esquema IN VARCHAR2, p_tabla IN VARCHAR2);
PROCEDURE proc_val_estrellas(p_usuario IN VARCHAR2, p_tabla IN VARCHAR2);
PROCEDURE proc_num_fallos_cubos(p_usuario IN VARCHAR2, p_tabla IN VARCHAR2,
                                p_metricas_falladas_no OUT NUMBER,
                                p_dim_falladas_no OUT NUMBER,
                                p_texto_correo OUT VARCHAR2);
PROCEDURE proc_val_cubo_dim(p_esquema IN VARCHAR2, p_cubo IN VARCHAR2);
-- Variable global para almacenar el id de ejecución
g_ejecucion NUMBER := NULL;

END pkg_pru_validacion_estrellas;

CREATE OR REPLACE PACKAGE BODY pkg_pru_validacion_estrellas AS 

PROCEDURE pr_inicia_ejecucion IS
BEGIN
    g_ejecucion := ejecucion_seq.NEXTVAL;
END; /* PR_INICIA_EJECUCION */

PROCEDURE pr_lanzador_pruebas(p_esquema IN VARCHAR2 DEFAULT NULL,
                              p_tabla IN VARCHAR2 DEFAULT NULL) IS
    CURSOR c_procedimientos (v_esquema, v_estrella) IS
    SELECT
    FROM toi_man_pruebas_regresion
    WHERE (esquema_de = NVL(v_esquema, esquema_de) OR ESQUEMA_DE = 'TODOS')
    AND (estrella_de = NVL(v_estrella, estrella_de) OR estrella_de = 'TODOS');
BEGIN
END; /* PR_LANZADOR_PRUEBAS */


PROCEDURE proc_val_metricas(p_usuario IN VARCHAR2, p_tabla IN VARCHAR2) IS 
    v_usuario VARCHAR2(30); 
    v_tabla VARCHAR2(30); 
    v_columna VARCHAR2(38); 
    v_cero_uno_fg NUMBER(1); 
    v_orden VARCHAR2(2000);  
    v_num_filas NUMBER;  
    v_error_cod NUMBER(10);  
    v_error_de VARCHAR2(300);  
    v_procedure VARCHAR2(50) := 'PROC_VAL_METRICAS';  
  
      
    CURSOR C_COLUMNAS (V_USUARIO VARCHAR2, V_TABLA VARCHAR2)  
    IS  
        SELECT usuario, tabla, columna, val_cero_uno_fg 
        FROM TOI_MAN_VAL_METRICAS 
        WHERE usuario = NVL(V_USUARIO, usuario) 
        AND tabla = NVL(V_TABLA, tabla);  
        
BEGIN  
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Inicio para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT; 
  
    OPEN C_COLUMNAS (p_usuario, p_tabla);  
    LOOP 
          
        FETCH C_COLUMNAS  INTO v_usuario, v_tabla, v_columna, v_cero_uno_fg;  
        EXIT WHEN C_COLUMNAS%NOTFOUND; 
         
        IF v_cero_uno_fg = 0 THEN 
            v_orden :='SELECT COUNT(1) FROM ' || v_USUARIO || '.' || v_TABLA ||' WHERE ' || v_COLUMNA || ' IS NULL'; 
        ELSE 
            v_orden :='SELECT COUNT(1) FROM ' || v_USUARIO || '.' || v_TABLA ||' WHERE ' || v_COLUMNA || ' IS NULL OR ' || v_columna || ' NOT IN  (0, 1)'; 
        END IF; /* v_cero_uno_fg = 0 */ 
             
        execute immediate v_orden into v_num_filas; 
         
        IF v_num_filas <> 0 THEN 
         
            UPDATE TOI_MAN_VAL_METRICAS 
            SET VAL_FALLADA_FG = 1 
            WHERE USUARIO = v_usuario 
            AND TABLA = v_tabla 
            AND COLUMNA = v_columna; 
         
        ELSE 
 
            UPDATE TOI_MAN_VAL_METRICAS 
            SET VAL_FALLADA_FG = 0 
            WHERE USUARIO = v_usuario 
            AND TABLA = v_tabla 
            AND COLUMNA = v_columna; 
              
        END IF; /* v_num_filas = 0 */  
         
        COMMIT; 
    END LOOP;  
    CLOSE C_COLUMNAS; 
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Fin para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT;  
      
EXCEPTION  
WHEN OTHERS THEN  
    v_error_cod := SQLCODE;  
    v_error_de := SUBSTR(SQLCODE || ': ' || SQLERRM, 1, 300);  
      
    ROLLBACK;  
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, COLUMNA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, v_tabla, v_columna, v_error_de, sysdate);  
      
    COMMIT;  
      
    RAISE_APPLICATION_ERROR(v_error_cod, v_error_de);  
END; /* PROC_VAL_METRICAS */

PROCEDURE proc_val_estrellas(p_usuario IN VARCHAR2, p_tabla IN VARCHAR2) IS 
    v_error_cod NUMBER(10);
    v_error_de VARCHAR2(300);  
    v_procedure VARCHAR2(50) := 'PROC_VAL_ESTRELLAS';  
  
BEGIN  
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Inicio para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT; 
  
    PROC_VAL_METRICAS(p_usuario, p_tabla); 
 
    PROC_VAL_CUBO_DIM(p_usuario, p_tabla); 
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Fin para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT;  
      
EXCEPTION  
WHEN OTHERS THEN  
    v_error_cod := SQLCODE;  
    v_error_de := SUBSTR(SQLCODE || ': ' || SQLERRM, 1, 300);  
      
    ROLLBACK;  
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, v_error_de, sysdate);  
      
    COMMIT;  
      
    RAISE_APPLICATION_ERROR(v_error_cod, v_error_de);  
END; /* PROC_VAL_ESTRELLAS */
 
PROCEDURE proc_num_fallos_cubos(p_usuario IN VARCHAR2, p_tabla IN VARCHAR2,
                                p_metricas_falladas_no OUT NUMBER,
                                p_dim_falladas_no OUT NUMBER,
                                p_texto_correo OUT VARCHAR2) IS 
    v_error_cod NUMBER(10);  
    v_error_de VARCHAR2(300);  
    v_procedure VARCHAR2(50) := 'PROC_NUM_FALLOS_METRICAS';  
  
BEGIN  
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Inicio para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT; 
  
    SELECT COUNT(1) INTO p_metricas_falladas_no 
    FROM TOI_MAN_VAL_METRICAS 
    WHERE USUARIO = NVL(p_usuario, USUARIO) 
    AND TABLA = NVL(p_tabla, TABLA) 
    AND VAL_FALLADA_FG = 1; 
 
    SELECT COUNT(1) INTO p_dim_falladas_no 
    FROM TOI_MAN_VAL_CUBO_DIM 
    WHERE USUARIO_CUBO = NVL(p_usuario, USUARIO_CUBO) 
    AND TABLA_CUBO = NVL(p_tabla, TABLA_CUBO) 
    AND VAL_FALLADA_FG = 1; 
     
    CASE WHEN p_metricas_falladas_no + p_dim_falladas_no = 0 
        THEN p_texto_correo := NULL; 
    ELSE p_texto_correo := 'La validación de cubos para el usuario ' || NVL(p_usuario, 'USUARIO NULO') || ' / tabla ' || NVL(p_tabla, 'TABLA_NULA'); 
         p_texto_correo := p_texto_correo || ' ha fallado para ' || p_metricas_falladas_no || ' métricas y ' || p_dim_falladas_no || ' dimensiones.' ; 
    END CASE; 
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, 'Fin para ' || p_usuario || '.' || p_tabla, sysdate);  
      
    COMMIT;  
      
EXCEPTION  
WHEN OTHERS THEN  
    v_error_cod := SQLCODE;  
    v_error_de := SUBSTR(SQLCODE || ': ' || SQLERRM, 1, 300);  
      
    ROLLBACK;  
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_tabla, v_error_de, sysdate);  
      
    COMMIT;  
      
    RAISE_APPLICATION_ERROR(v_error_cod, v_error_de);  
END; /* PROC_NUM_FALLOS_CUBOS */

PROCEDURE proc_val_cubo_dim(p_usuario IN VARCHAR2, p_cubo IN VARCHAR2) IS 
    v_usuario_cubo VARCHAR2(30);
    v_tabla_cubo VARCHAR2(30); 
    v_columna_cubo VARCHAR2(30); 
    v_usuario_dimension VARCHAR2(30); 
    v_tabla_dimension VARCHAR2(30); 
    v_columna_dimension VARCHAR2(30); 
    v_orden VARCHAR2(2000);  
    v_num_filas NUMBER;  
    v_error_cod NUMBER(10);  
    v_error_de VARCHAR2(300);  
    v_procedure VARCHAR2(50) := 'PROC_VAL_CUBO_DIM';  
  
      
    CURSOR C_DIMENSIONES (V_USUARIO VARCHAR2, V_CUBO VARCHAR2)  
    IS  
        SELECT usuario_cubo, tabla_cubo, columna_cubo, usuario_dimension, tabla_dimension, columna_dimension 
        FROM TOI_MAN_VAL_CUBO_DIM 
        WHERE usuario_cubo = NVL(V_USUARIO, usuario_cubo) 
        AND tabla_cubo = NVL(V_CUBO, tabla_cubo); 
        
BEGIN  
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_cubo, 'Inicio para ' || p_usuario || '.' || p_cubo, sysdate);  
      
    COMMIT; 
  
    OPEN C_DIMENSIONES (p_usuario, p_cubo);  
    LOOP 
          
        FETCH C_DIMENSIONES  INTO v_usuario_cubo, v_tabla_cubo, v_columna_cubo, v_usuario_dimension, v_tabla_dimension, v_columna_dimension;  
        EXIT WHEN C_DIMENSIONES%NOTFOUND; 
         
        v_orden := 'SELECT COUNT(1) FROM (SELECT DISTINCT ' || v_tabla_dimension || '.' || v_columna_dimension; 
        v_orden := v_orden || ' FROM ' || v_usuario_cubo || '.' || v_tabla_cubo || ', ' || v_usuario_dimension || '.' || v_tabla_dimension; 
        v_orden := v_orden || ' WHERE ' || v_tabla_cubo || '.' || v_columna_cubo || ' = ' || v_tabla_dimension || '.' || v_columna_dimension || ' (+)'; 
        v_orden := v_orden || ') WHERE ' || v_columna_dimension || ' IS NULL'; 
         
        execute immediate v_orden into v_num_filas; 
         
        IF v_num_filas <> 0 THEN 
         
            UPDATE TOI_MAN_VAL_CUBO_DIM 
            SET VAL_FALLADA_FG = 1 
            WHERE USUARIO_CUBO = v_usuario_cubo 
            AND TABLA_CUBO = v_tabla_cubo 
            AND COLUMNA_CUBO = v_columna_cubo 
            AND USUARIO_DIMENSION = v_usuario_dimension 
            AND TABLA_DIMENSION = v_tabla_dimension 
            AND COLUMNA_DIMENSION = v_columna_dimension; 
         
        ELSE 
 
            UPDATE TOI_MAN_VAL_CUBO_DIM 
            SET VAL_FALLADA_FG = 0 
            WHERE USUARIO_CUBO = v_usuario_cubo 
            AND TABLA_CUBO = v_tabla_cubo 
            AND COLUMNA_CUBO = v_columna_cubo 
            AND USUARIO_DIMENSION = v_usuario_dimension 
            AND TABLA_DIMENSION = v_tabla_dimension 
            AND COLUMNA_DIMENSION = v_columna_dimension; 
              
        END IF; /* v_num_filas = 0 */  
         
        COMMIT; 
    END LOOP;  
    CLOSE C_DIMENSIONES; 
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, p_cubo, 'Fin para ' || p_usuario || '.' || p_cubo, sysdate);  
      
    COMMIT;  
      
EXCEPTION  
WHEN OTHERS THEN  
    v_error_cod := SQLCODE;  
    v_error_de := SUBSTR(SQLCODE || ': ' || SQLERRM, 1, 300);  
      
    ROLLBACK;  
      
    INSERT INTO TOI_AUDITA_PROCEDIMIENTOS  
    (PROCEDURE_DE, TABLA_DE, COLUMNA_DE, MENSAJE_DE, FECHA_DT)  
    VALUES  
    (v_procedure, v_tabla_cubo, v_columna_cubo, v_error_de, sysdate);  
      
    COMMIT;  
      
    RAISE_APPLICATION_ERROR(v_error_cod, v_error_de);  
END; /* PROC_VAL_CUBO_DIM */
 
END pkg_pru_validacion_estrellas;

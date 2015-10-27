
puts "Establecer la fuente del codigo"
source D:\\owb10g\\procedimientos_omb.tcl
set OMBLOG "D:\\387556\\proc_desplegar_TOH_M.log"
proc_desplegar_TOH_M UXXIDW U21_ODS

# Pruebas para copiar tablas, no es un procedimiento, se lanza directamente desde la ventana del plus
set OMBLOG "D:\\317382\\copia_tabla.log"
copia_tabla TPLA_SUBTIPESTUDI /UXXIDW/UXXIAC_OLTP TOH_U21_TPLA_SUBTIPESTUDI /UXXIDW/UXXIAC_ODS "D:\\317382\\"

# Copiar un objeto de un módulo a otro
OMBCC '/UXXI2_COSTES/INTERFACES_INV_SDS'
OMBCOPY TABLE '/UXXI2_COSTES/INTERFACES_ECO_SDS/TOI_AME_LOGAPR_UPD' \
    TO 'TOI_GIN_LOGAPR_UPD'
# La tabla es creada en el módulo INTERFACES_INV_SDS, luego es conveniente
# cambiar el BUSINESS_NAME de la tabla para que coincida con el físico:
OMBALTER TABLE 'TOI_GIN_LOGAPR_UPD' \
    SET PROPERTIES (BUSINESS_NAME) VALUES ('TOI_GIN_LOGAPR_UPD')

# Cambiar el BUSINESS_NAME de un procedimiento dentro de un paquete:
OMBCC '/UXXIDW/GENERAL_ODS'
OMBALTER PROCEDURE 'PKG_PRUEBAS_REGRESION/PR_VAL_UXXIAC_PLAN' \
    SET PROPERTIES (BUSINESS_NAME) VALUES ('PR_VAL_UXXIAC_PLAN')




# Pendiente de probar para ejecutar un mapping, extraido del foro
set location SRC2 
# or SRC1, I don't know which location you prefer
set mapList { 
Map1
}
foreach mapName $mapList {
   puts '$mapName' ;
   OMBSTART MAPPING '$mapName' AS '$mapName' IN '$location'
   OMBCOMMIT;
}




OMBRECONCILE TABLE 'TOI_CTRL_EJERCICIOS' TO MAPPING 'TOI_INGRESO_MENSUAL_M' \
OPERATOR 'TOI_CTRL_EJERCICIOS' \
USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')

OMBSYNCHRONIZE MAPPING '/MYPROJECT/MY_NEW_LOCATION/MY_MAP' \
    TO PROCESS_FLOW 'MY_FLOW' ACTIVITY 'MY_MAP' \
    USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'ACTIVITY_MATCH_BY_POSITION')

OMBSYNCHRONIZE MAPPING '/MYPROJECT/MY_NEW_LOCATION/MY_MAP' \
    TO PROCESS_FLOW 'MY_FLOW' ACTIVITY 'MY_MAP' \
    USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')




source D:\\owb10g\\scripts_pases.tcl
set OMBLOG "D:\\III000521\\exporta_coleccion.log"
exporta_coleccion UXXIDW III000521 "D:\\III000521\\"

source D:\\owb10g\\scripts_pases.tcl
set OMBLOG "D:\\359589\\log\\importa_coleccion.log"
importacion UXXIDW 359589 "D:\\359589\\pase\\"

source D:\\owb10g\\scripts_pases.tcl
set OMBLOG "D:\\392306\\log\\importa_coleccion.log"
importacion_solo_despliegue UXXIDW "D:\\392306\\pase\\" objetos_coleccion_392306_2


set v_export_mdl "C:\\temp\\Ana\\375670\\TITULOS.MDL"
set v_export_log "C:\\temp\\Ana\\375670\\TITULOS_exp.log"
OMBEXPORT TO MDL_FILE '$v_export_mdl' FROM PROJECT 'UXXIDW' \
    WITH DEPENDEE_DEPTH MAX OUTPUT LOG TO '$v_export_log'

OMBEXPORT TO MDL_FILE '$v_export_mdl' COMPONENTS (TABLE 'UXXIDW/SIGMA_OLTP/TITULOS') \
    OUTPUT LOG TO '$v_export_log'

# proc_conectar owb102/owb102@palme:2485:p1007 'UXXIDW' DEFAULT_CONTROL_CENTER 'OWB102'
# proc_desplegar_correspondencias UXXIDW
# puts "desplegadas correspondencias"
# proc_desplegar_flujos UXXIDW
# puts "desplegados flujos"
# exit

# OMBCONNECT CONTROL_CENTER owb102/owb102@palme:2485:p1007 USE REPOSITORY 'OWB102'

USE REPOSITORY 'OWB102'

owb_set_maxerrors_ansi UXXIDW UXXIEC_DDS


OMBDEPLOY DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN'

OMBCOMMIT


OMBCC '..'
OMBCC 'UXXIRRHH_DDS'
owb_set_max_errors
OMBCOMMIT

-- Reconciliar una tabla dentro de un mapeo.
OMBRECONCILE TABLE 'TOI_EMPLEADO' \
             TO MAPPING 'TOI_EMPLEADO_BIS_M' OPERATOR 'TOI_EMPLEADO_1' \
             USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')
             
-- Si la tabla se encuentra en un esquema diferente del mapeo:
OMBRECONCILE TABLE '/UXXIDW/HOMINIS_DDS/TLK_1_PER_EMPLEADOPDI' \
             TO MAPPING 'TOI_EMPPDI_SK_M' OPERATOR 'TLK_1_PER_EMPLEADOPDI' \
             USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')

OMBCOMMIT


OMBRETRIEVE MAPPING 'TOI_CONCEPTO_M' HAS CONNECTION \
FROM ATTRIBUTE 'CONCEPTOS_STRCODIGOCONCE' OF GROUP 'OUTGRP1' OF OPERATOR 'JOIN' \
TO ATTRIBUTE 'char_' OF GROUP 'INPUTS' OF OPERATOR 'SUBSTR_2'
1 -- Hay conexion
0 -- No hay conexion

OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_op' GROUP '$p_group' GET PROPERTIES (DIRECTION)
# 1 Entrada
# 2 Salida
# 3 Entrada-Salida


# Crear un mapeo TOH:
set p_proyecto UXXIDW
set p_modulo ODS
set p_map MYMAP
set G_SRC_OBJ_TYPE TABLE
set G_TGT_OBJ_TYPE TABLE
set p_tab_oltp EMP
set p_tab_toh TOH
set p_modulo_oltp OLTP
set g_from_group INOUTGRP1
set g_to_group INOUTGRP1

OMBCC '/$p_proyecto/$p_modulo'

OMBCREATE MAPPING '$p_map\$p_modulo'
    ADD $G_SRC_OBJ_TYPE OPERATOR '$p_tab_oltp' \
        BOUND TO $G_SRC_OBJ_TYPE '$p_proyecto/$p_modulo_oltp/$p_tab_oltp' \
    ADD $G_TGT_OBJ_TYPE OPERATOR '$p_tab_toh' \
        BOUND TO $G_TGT_OBJ_TYPE '$p_proyecto/$p_modulo/$p_tab_toh' \
    ADD CONNECTION FROM GROUP '$g_from_group' OF OPERATOR '$p_tab_oltp' \
        TO GROUP '$g_to_group' OF OPERATOR '$p_tab_toh' BY NAME



# Añadir una conexión entre dos elementos de un mapeo.
OMBALTER MAPPING 'TOI_EMPLEADO_M' \
         ADD CONNECTION FROM ATTRIBUTE 'Result' OF GROUP 'RESULT' OF OPERATOR 'NVL_20' \
         TO ATTRIBUTE 'INPUT1' OF GROUP 'INGRP1' OF OPERATOR 'PROC_SORT_LANGUAGES_HOM_11'

# Borrar una conexión entre dos elementos de un mapeo
OMBALTER MAPPING 'TOI_EMPLEADO_M' \
         DELETE CONNECTION FROM ATTRIBUTE 'Result' OF GROUP 'RESULT' OF OPERATOR 'NVL_25' \
         TO ATTRIBUTE 'INPUT3' OF GROUP 'INGRP1' OF OPERATOR 'PROC_SORT_LANGUAGES_HOM_11'


# Añadir una columna a un operador de un mapeo:
OMBALTER MAPPING 'TOI_EMPPDI_SK_M' \
         ADD ATTRIBUTE 'ACREDITACION_ID' OF GROUP 'INOUTGRP1' OF OPERATOR 'FLTR' \
         SET PROPERTIES (DATATYPE, LENGTH) VALUES ('VARCHAR2', 50)


# Borrar un operador de un mapeo:
OMBALTER MAPPING 'TOI_EMPPAS_SK_M' DELETE OPERATOR 'SPLIT'

# Añadir un indice BITMAP a una tabla:
OMBALTER TABLE 'TFC_DOC_CAPACIDAD_DOCENTE' ADD INDEX 'IB_TFC_DOC_CAPACIDAD_DOCEN_09' \
SET PROPERTIES (INDEX_TYPE, LOCAL_INDEX, TABLESPACE) VALUES ('BITMAP', 'true', 'UXXIDW_INDX') \
ADD INDEX_COLUMN 'DEDICACION_ID' OF INDEX 'IB_TFC_DOC_CAPACIDAD_DOCEN_09'

# Cuando una tabla esta particionada, los indices tambien estan particionados y
# hay que especificar el tablespace de los indices para cada particion
OMBCC '/UXXIDW/SIGMA_DDS'
set p_cubo TFC_DOC_RESULT_ACADEMICOS
set indexList [ OMBRETRIEVE TABLE '$p_cubo' GET INDEXES ]
foreach v_index $indexList {
    OMBALTER TABLE '$p_cubo' MODIFY INDEX '$v_index' \
    SET PROPERTIES (TABLESPACE, PARTITION_TABLESPACE_LIST, OVERFLOW) \
    VALUES ('UXXIDW_INDX', 'UXXIDW_INDX', 'UXXIDW_INDX')
}
OMBCOMMIT

# Añadir particiones a una tabla
OMBCC '/UXXIDW/UXXIAC_DDS'
set p_tabla TFC_DOC_MATRICULAS_ALUMNO
set v_Col [ OMBRETRIEVE TABLE '$p_tabla' GET PARTITION_KEYS ]
OMBALTER TABLE '$p_tabla' ADD PARTITION_KEY '$v_Col' SET PROPERTIES (TYPE) VALUES ('RANGE') \
    ADD PARTITION 'P_1998' SET PROPERTIES (VALUES_LESS_THAN) VALUES (1999) \
    ADD PARTITION 'RESTO' SET PROPERTIES (VALUES_LESS_THAN) VALUES ('MAXVALUE')


# Cuando una tabla esta particionada, hay que especificar el tablespace de cada particion
OMBCC '/UXXIDW/HOMINIS_DDS'
set p_cubo TFC_GASTOS_PER_PAS
set partList [ OMBRETRIEVE TABLE '$p_cubo' GET PARTITIONS ]
foreach v_part $partList {
    OMBALTER TABLE '$p_cubo' MODIFY PARTITION '$v_part' \
    SET PROPERTIES (TABLESPACE)  VALUES ('DDS_UXXIAC')
}
OMBCOMMIT


## Añadir un operador de lookup a un mapeo:
set OMBLOG "D:\\339307\\temp.log"
OMBCC '/UXXIDW/HIST_ODS'
set p_map TOI_TFC_HIST_METRICAS_CP_M
set p_tabla_ori TOI_CP_METRICAS_SALEN_TR_AB
set p_lk_table TOI_SK_HIST_PLAN_ESTUDIOS
set p_uk ""
append p_uk $p_lk_table "_UK"
OMBALTER MAPPING '$p_map' ADD KEY_LOOKUP OPERATOR 'LK_$p_lk_table' \
    BOUND TO TABLE '/UXXIDW/HIST_ODS/$p_lk_table'
OMBALTER MAPPING '$p_map' ADD CONNECTION \
    FROM ATTRIBUTE 'FECHA_FOTO_ID' OF GROUP 'INOUTGRP1' OF OPERATOR '$p_tabla_ori' \
    TO GROUP 'INGRP1' OF OPERATOR 'LK_$p_lk_table'
OMBALTER MAPPING '$p_map' ADD CONNECTION \
    FROM ATTRIBUTE 'PLAN_ESTUDIOS_ID' OF GROUP 'INOUTGRP1' OF OPERATOR '$p_tabla_ori' \
    TO GROUP 'INGRP1' OF OPERATOR 'LK_$p_lk_table'

OMBALTER MAPPING '$p_map' MODIFY OPERATOR 'LK_$p_lk_table' SET PROPERTIES(LOOKUP_CONDITION) \
    VALUES('/* KEY_NAME $p_uk */  /* KEY_COLUMN */ OUTGRP1.FECHA_FOTO_ID = INGRP1.FECHA_FOTO_ID /* KEY_COLUMN */  AND OUTGRP1.PLAN_ESTUDIOS_ID = INGRP1.PLAN_ESTUDIOS_ID')




# Deshabilitar Foreing Keys de un cubo
OMBCC '/UXXIDW/MODULO_DDS'
set fkList [OMBRETRIEVE TABLE 'TFC_DOC_CARGA_DOCENTE' GET FOREIGN_KEYS]
foreach fkName $fkList {
OMBALTER TABLE '$tabName' MODIFY FOREIGN_KEY '$fkName' \
SET PROPERTIES (DEPLOYABLE) VALUES ('0')
}

-- Esto no me ha funcionado:
OMBALTER DIMENSION 'TLK_1_DOC_EMPLEADO_DOCENCIA' \
         ADD HIERARCHY 'JURIDICO'

OMBALTER DIMENSION 'TLK_1_DOC_EMPLEADO_DOCENCIA' MODIFY HIERARCHY 'JURIDICO' \
         SET REF LEVELS ('TIPO_REG_JURIDICO','REG_JURIDICO','EMPLEADO')
         



# Modificar en un cubo el nombre del elemento dimension (para que se llame como la FK)
OMBALTER CUBE 'TFC_CUBO' MODIFY DIMENSION_USE 'TLK_DIMENSION' RENAME TO 'FK_TFC_CUBO_DIMENSION_LEVEL'

# Este procedimiento automatiza el renombrado de las DIMENSION_USE
set OMBLOG "D:\\343449\\temp.log"
source D:\\owb10g\\procedimientos_omb.tcl
proc_renombra_dim_cubo UXXIDW UXXIAC_DDS TFC_DOC_ACTIVIDAD_MATRIC


# Obtener propiedades genéricas de objetos del OWB:
# http://forums.oracle.com/forums/thread.jspa?threadID=589638
# OMBDESCRIBE MODEL and OMBDESCRIBE CLASS_DEFINITION
# For example, you can get property list for ATTRIBUTE class with command
OMBDESCRIBE CLASS_DEFINITION 'ATTRIBUTE' GET PROPERTY_DEFINITIONS
OMBDESCRIBE CLASS_DEFINITION 'MAPPING' GET PROPERTY_DEFINITIONS
OMBDESCRIBE CLASS_DEFINITION 'TABLE' GET PROPERTY_DEFINITIONS
OMBDESCRIBE CLASS_DEFINITION 'MATERIALIZED_VIEW' GET PROPERTY_DEFINITIONS
OMBDESCRIBE CLASS_DEFINITION 'KEY_LOOKUP_OPERATOR' GET PROPERTY_DEFINITIONS

# http://blogs.oracle.com/warehousebuilder/2007/06/owb_model_introspection.html
# So if you want to see the core properties of an object (for example TABLE)
# you can perform the following from within OMBPlus (or panel):
OMBDESCRIBE CLASS_DEFINITION 'TABLE' GET  CORE PROPERTY_DEFINITIONS
# You can get just configuration properties by executing:
OMBDESCRIBE CLASS_DEFINITION 'TABLE' GET  CONFIGURATION PROPERTY_DEFINITIONS
# and if you want all properties just omit CORE/CONFIGURATION.











# Despliegue de objetos desde la ventana de comandos
OMUCONTROLCENTERJOBS
set OMBLOG "D:\\288626\\despliegue_tablas_ECONOMICO_DDS_desa.log"
proc_desplegar_tablas UXXIDW ECONOMICO_DDS CREATE

# Despliegue objetos
proc despl_objeto { p_tipo_objeto p_objeto p_accion } {
    set v_dap ""
    append v_dap "DEPLOY_PLAN_" $p_tipo_objeto "_" $p_objeto
    set v_a ""
    append v_a "DEPLOY_" $p_tipo_objeto "_" $p_objeto
    OMBCREATE TRANSIENT DEPLOYMENT_ACTION_PLAN '$v_dap' \
            ADD ACTION '$v_a' SET PROPERTIES (OPERATION) \
            VALUES ('$p_accion') SET REFERENCE $p_tipo_objeto \
            '$p_objeto'
    OMBDEPLOY DEPLOYMENT_ACTION_PLAN '$v_dap'
    OMBDROP DEPLOYMENT_ACTION_PLAN '$v_dap'
    OMBCOMMIT
    puts "Finalizado despliegue"
}

OMBCC '/UXXIDW/ANECA_ODS'
set p_accion DROP
set p_tipo_objeto PROCESS_FLOW_PACKAGE
set p_mapeo UXXIDWAC
despl_objeto $p_tipo_objeto $p_mapeo $p_accion




# Para desplegar objetos tambien se puede invocar:
set OMBLOG "D:\\371307\\temp_351149_DES.log"
source D:\\owb10g\\scripts_pases.tcl
proc_desplegar_objeto PROCESS_FLOW_PACKAGE UXXIDW CARGA C_DOC CREATE


set p_despleg [OMBRETRIEVE TABLE 'TLK_1_DOC_PLAN_ESTUDIOS' GET PROPERTIES (DEPLOYABLE)]
if {$p_despleg == "true"} {
    puts "Tabla desplegable"
} elseif {$p_despleg == "false"} {
    puts "Tabla no desplegable"
}
# end if p_despleg = true

# Pendiente probar, encontrado en forum:
# You can start a mapping LOAD_CHANNELS deployed in location SALES_LOC using something like the following;
OMBSTART MAPPING 'LOAD_CHANNELS' AS 'MyChannelsMap' IN 'SALES_LOC' 


OMBCC '/UXXIDW/CARGA/UXXIAC'
OMBALTER PROCESS_FLOW 'DOC_DOCENCIA_DS_C' ACTIVITY 'BORRAINDICE_1' SET PROPERTIES (DEPLOYED_LOCATION) VALUES ('LOC_UXXIAC_DDS')

OMBCC '/UXXIDW/CARGAS/UXXIRRHH'
set v_direcciones "dir1@xx.es;dir2@xx.es;dir3@xx.es"
OMBALTER PROCESS_FLOW 'XX' MODIFY ACTIVITY 'EMAIL' MODIFY PARAMETER 'TO_ADDRESS' SET PROPERTIES (VALUE) VALUES ('$v_direcciones')

# Procedimiento para repasar todos los process flow de un paquete,
# recoger las actividades de tipo mapping y asegurar que el
# número máximo de errores es cero. Por si acaso en algun mapeo
# en concreto se hubiera dejado un número diferente de cero aposta
# lo que hace es revisar que el número sea 50 y cambiarlo, cualquier
# otro valor no lo modifica.
OMBCC '/UXXIDW/CARGA/UXXIDWAC'
set pfList [ OMBLIST PROCESS_FLOWS ]
foreach pfName $pfList {
    set mapList [ OMBRETRIEVE PROCESS_FLOW '$pfName' GET MAPPING ACTIVITIES ]
    foreach mapName $mapList {
        set v_par [ OMBRETRIEVE PROCESS_FLOW '$pfName' ACTIVITY '$mapName' PARAMETER 'MAX_NO_OF_ERRORS' GET PROPERTIES  (VALUE) ]
        if { $v_par == 50 } {
            OMBALTER PROCESS_FLOW '$pfName' MODIFY ACTIVITY '$mapName' MODIFY PARAMETER 'MAX_NO_OF_ERRORS' \
            SET PROPERTIES (VALUE) VALUES (0)
        }
    }
}
puts "Fin revision"
















# Proceso que copia en el log las descripciones de las columnas de una tabla para asociarlas a otra tabla
set OMBLOG "C:\\Temp\\314132\\columnas_ttit_titol.log"
set colList [ OMBRETRIEVE TABLE '/UXXIDW/UXXIAC_OLTP/TTIT_TITOL' GET COLUMNS ]
foreach colName $colList {
    set v_comment [ OMBRETRIEVE TABLE '/UXXIDW/UXXIAC_OLTP/TTIT_TITOL' COLUMN '$colName' GET PROPERTIES (DESCRIPTION) ]
    if { $v_comment == "{}" } {
        puts "# OMBALTER TABLE 'TOH_U21_TTIT_TITOL' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
    } elseif { [ string match "\{*" "$v_comment" ] } {
        # el comentario contiene espacios en blanco, por lo que viene entre llaves,
        # eliminamos las llaves del comentario a insertar
        set v_comment [ string range $v_comment 1 [expr [ string length $v_comment ] - 2 ] ]
        puts "OMBALTER TABLE 'TOH_U21_TTIT_TITOL' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
    } else {
        # El comentario es una unica palabra por lo que no viene entre llaves
        # se inserta directamente
        puts "OMBALTER TABLE 'TOH_U21_TTIT_TITOL' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
    }
}
puts "# Fin del proceso"






# Para obtener las tablas que carga un mapeo, las devuelve separadas por una ",", habría luego
# que hacer una lista y tratar cada tabla por separado:
OMBRETRIEVE MAPPING '/UXXIDW/HOMINIS_ODS/TOI_TFC_GASTOS_SEG_M' GET PROPERTIES (TARGET_LOAD_ORDER)









# Procedimiento para generar el script de GRANTS sobre las tablas del OLTP
set OMBLOG "D:\\393380\\temp.log"
OMBCC '/UXXIDW/UXXIINV_EVA_ODS'
set MapList [ OMBLIST MAPPINGS 'TOH.*' ]
foreach p_map $MapList {
    set TabList [ OMBRETRIEVE MAPPING '$p_map' GET TABLE OPERATORS ]
    foreach p_table $TabList {
        set v_bound [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_table' GET BOUND_OBJECT ]
        if { $v_bound == "TABLE /UXXIDW/UXXIINV_OLTP/$p_table" } {
            puts "### GRANT SELECT ON UXXIINV.$p_table TO UXXIDW;"
        }
    }
    # foreach p_table
    set ViewList [ OMBRETRIEVE MAPPING '$p_map' GET VIEW OPERATORS ]
    foreach p_table $ViewList {
        set v_bound [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_table' GET BOUND_OBJECT ]
        if { $v_bound == "VIEW /UXXIDW/UXXIINV_OLTP/$p_table" } {
            puts "### GRANT SELECT ON UXXIINV.$p_table TO UXXIDW;"
        }
    }
    # foreach p_table
}
# foreach p_map
puts "Procedimiento finalizado"



# Procedimiento para guardar en el log la política de carga de los atributos de una tabla en un mapeo:
set AttList [ OMBRETRIEVE MAPPING '$p_mapeo' OPERATOR '$p_tabla' GROUP 'INOUTGRP1' GET ATTRIBUTES ]
foreach AttName $AttList {
    OMBRETRIEVE MAPPING '$p_mapeo' OPERATOR '$p_tabla' GROUP 'INOUTGRP1' ATTRIBUTE '$AttName' \
    GET PROPERTIES (LOAD_COLUMN_WHEN_UPDATING_ROW, MATCH_COLUMN_WHEN_UPDATING_ROW, \
                    MATCH_COLUMN_WHEN_DELETING_ROW)
}
# Finaliza foreach AttName
puts "Revision finalizada"





OMBDROP DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_TOA_ECO_CAMPUS_M'
OMBCOMMIT











# Copia de los objetos de una coleccion a otra
OMBCC '/UXXIDW'
puts "Inicio copia coleccion"
set v_objList [ OMBRETRIEVE COLLECTION '/UXXIDW/DOCENCIA_UEX' GET ALL REFERENCES ]
foreach v_objName $v_objList {
    set v_objNameList [ split "$v_objName" " " ]
    set v_objType [ lindex $v_objNameList 0 ]
    set v_objPath [ lindex $v_objNameList 1 ]
    # puts "Lista: $v_objType $v_objPath"
    OMBALTER COLLECTION 'UXXIAC_DOCENCIA' ADD REFERENCE TO $v_objType '$v_objPath'
}
# foreach v_objName
puts "Fin copia coleccion"

# Añadir un procedimiento público a una colección:
OMBALTER COLLECTION '345189' ADD REFERENCE TO PROCEDURE '/UXXIDW/WB_CUSTOM_TRANS/ANALYZE_OH_MATRICULADOS'


# Borrar las referencias de una colección
set p_coll II000268
set p_map_his TOH_HIS
OMBCC '/UXXI2_COSTES'
puts "Inicio borra historicos"
set v_objList [ OMBRETRIEVE COLLECTION '$p_coll' GET ALL REFERENCES ]
foreach v_objName $v_objList {
    set v_objNameList [ split "$v_objName" " " ]
    set v_objType [ lindex $v_objNameList 0 ]
    set v_objPath [ lindex $v_objNameList 1 ]
    # puts "Lista: $v_objType $v_objPath"
    if { [ string match "*$p_map_his*" "$v_objPath" ] } {
        OMBALTER COLLECTION '$p_coll' REMOVE REFERENCE TO $v_objType '$v_objPath'
    }
}
# foreach v_objName
puts "Fin borra historicos"


# Verificar si con esto se puede implementar algo automático para el despliegue de
# colecciones: (de nuevo problemas para el despliegue de process flows)

OMBRETRIEVE COLLECTION 'P283314' GET TABLE REFERENCES


















OMBRETRIEVE MAPPING 'MAP' OPERATOR 'TABLE_OPERATOR' GET BOUND_OBJECT



# Procedimiento para reconciliar la tabla del sistema OLTP.
# Como al reconciliar la tabla se borran las conexiones, tambien
# general los ALTER para crearlas de nuevo.
proc reconcilia_oltp_ingres {map fromOperator targetOperator targetGroup salida } {
    # Nombre:          reconcilia_oltp_ingres.
    # Parametros:      map: Mapeo donde se encuentra la tabla del OLTP, ej, TOH_SIG_PLAN_M.
    #                  fromOperator: Tabla del OLTP, ej, plan
    #                  targetOperator: Tabla TOH o TOA destino, ej, TOH_SIG_PLAN
    #                  targetGroup: Nombre del grupo de las columnas de la tabla destino,
    #                               normalmente, INOUTGRP1
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.log", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    # Descripcion: Trabaja bajo el supuesto de que la tabla fuente se mapea directamente
    #              a la tabla destino, si no las conexiones fallaran. Escribe en un fichero
    #              de salida las ordenes para reconciliar la tabla y generar de nuevo
    #              las conexiones a la tabla destino (estas conexiones se borran a veces
    #              al reconciliar la tabla del OLTP) Si no se han borrado, fallara tambien.
    #              Repasar el script cada vez que haya que lanzar, porque hay muchas cosas a
    #              HARDCODE.
    puts "Inicio reconcilia_oltp_ingres $map $fromOperator $targetOperator $targetGroup $salida"
    set outfile [open "$salida" a+ ]
    set v_from_lower [ string tolower $fromOperator ]
    set v_from_upper [ string toupper $fromOperator ]
    set v_orden "OMBRECONCILE TABLE '/UXXIDW/SIGMA_OLTP/$v_from_lower'"
    set v_orden "$v_orden TO MAPPING '$map' OPERATOR '$v_from_upper'"
    set v_orden "$v_orden USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')"
    puts $outfile $v_orden
    set targetColumns [ OMBRETRIEVE MAPPING '$map' OPERATOR '$targetOperator' GROUP '$targetGroup' GET ATTRIBUTES ]
    foreach targetAttribute $targetColumns {
        set opList [ OMBRETRIEVE MAPPING '$map' GET OPERATORS CONNECTED TO ATTRIBUTE '$targetAttribute' OF GROUP '$targetGroup' OF OPERATOR '$targetOperator']
        foreach op $opList {
            set grpList [OMBRETRIEVE MAPPING '$map' OPERATOR '$op' GET GROUPS CONNECTED TO ATTRIBUTE '$targetAttribute' OF GROUP '$targetGroup' OF OPERATOR '$targetOperator']
            foreach grp $grpList {
                set attrList [OMBRETRIEVE MAPPING '$map' OPERATOR '$op' GROUP '$grp' GET ATTRIBUTES CONNECTED TO ATTRIBUTE '$targetAttribute' OF GROUP '$targetGroup' OF OPERATOR '$targetOperator']
                foreach attr $attrList {
                    # puts "$op.$grp.$attr"
                    set v_orden "OMBALTER MAPPING '$map'"
                    set v_orden "$v_orden  ADD CONNECTION FROM ATTRIBUTE '$attr' OF GROUP '$grp' OF OPERATOR '$op'"
                    set v_orden "$v_orden TO ATTRIBUTE '$targetAttribute' OF GROUP '$targetGroup'"
                    set v_orden "$v_orden OF OPERATOR '$targetOperator'"
                    puts $outfile $v_orden
                }
            }
            # foreach grp
        }
        # foreach op
    }
    # foreach targetOperator
    close $outfile
    puts "."
    puts "."
    puts "-----------------------------------------------"
}
# Fin reconcilia_oltp_ingres





























# Este procedimiento no he conseguido que funcione. Me importa la tabla, pero no importa las columnas.

proc proc_importar_tabla_fuente {p_proyecto p_modulo p_prop p_tabla} {

    # Nombre:          proc_importar_tabla_fuente.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo asociado a la location del sistema fuente
    #                  p_prop: Usuario propietario de la tabla a importar
    #                  p_tabla: Nombre de la tabla a importar
    # Descripcion:
    #                  Importa al modulo los metadatos que definen la tabla del sistema fuente

    OMBCC '/$p_proyecto/$p_modulo'
    # Creo la sentencia de importacion
    # set v_source_table '\"$p_prop\".\"$p_tabla\"'
    # puts $v_source_table
    set v_tab_upper [ string toupper $p_tabla ]
    set p_tabla [ string tolower $p_tabla ]
    set p_prop [ string tolower $p_prop ]
    set TabList [ OMBLIST TABLES ]
    foreach TabName $TabList {
        if { [ string compare $v_tab_upper $TabName ] == 0 } {
            # La tabla existe en mayusculas, la borramos,
            # ya que las tablas de SIGMA se importan en minusculas
            OMBDROP TABLE '$v_tab_upper'
        }
    }
    # foreach TabName
    OMBCC '/$p_proyecto'
    # OMBCREATE TRANSIENT IMPORT_ACTION_PLAN 'PLAN_IMPORT_$v_tab_upper' \
    # ADD ACTION 'IMPORTA_$v_tab_upper' \
    # SET PROPERTIES (LEVEL, IMPORT_DESCRIPTIONS) ('None', 'true') \
    # SET REF SOURCE TABLE '\"$p_prop\".\"$p_tabla\"' \
    # SET REF TARGET NON_ORACLE_MODULE '$p_modulo'
    OMBCREATE TRANSIENT IMPORT_ACTION_PLAN 'PLAN_IMPORT_$v_tab_upper' \
    ADD ACTION 'IMPORTA_$v_tab_upper' \
    SET REF SOURCE TABLE '\"$p_prop\".\"$p_tabla\"' \
    SET REF TARGET GATEWAY_MODULE '$p_modulo'
    puts "Creado plan"
    OMBIMPORT FROM METADATA_LOCATION FOR IMPORT_ACTION_PLAN 'PLAN_IMPORT_$v_tab_upper' USE 'REPLACE_MODE'
    OMBDROP IMPORT_ACTION_PLAN 'PLAN_IMPORT_$v_tab_upper'
    OMBCC '/$p_proyecto/$p_modulo'
    OMBALTER TABLE '\"$p_prop\".\"$p_tabla\"' SET PROPERTIES (BUSINESS_NAME) VALUES ('$p_table')
    OMBALTER TABLE '\"$p_prop\".\"$p_tabla\"' RENAME TO '$p_tabla'
    # OMBCOMMIT
    # puts "-----------------------------------------------"
    puts "Tabla $p_tabla importada"
    # puts "Fin proc_importar_tabla_fuente $p_proyecto $p_modulo $p_prop $p_tabla"
}
# proc_importar_tabla_fuente










-- Orden de una transición:
OMBRETRIEVE PROCESS_FLOW 'P' TRANSITION 'T1' GET PROPERTIES (TRANSITION_ORDER)

OMBCC '/UXXIDW/CARGA/UXXIAC'
OMBALTER PROCESS_FLOW 'DOC_MATRICULADOS_OH_C' MODIFY TRANSITION 'TRANSITION_77' \
SET PROPERTIES (TRANSITION_ORDER) VALUES (2)

-- Buscar propiedades no standard en OMBPlus:
The first I tried to get property list for transition with OMBDESCRIBE CLASS_DEFINITION command.
But without success - OMBDESCRIBE returned only three "standard" properties
(business_name/description/uoid).
Then I looked through public public views and found column TRANSITION_ORDER.
After that I tried TRANSITION_ORDER property name in OMBRETRIEVE



# Para crear la tabla asociada a la dimensión:
OMBALTER DIMENSION 'YOURDIMENSION' IMPLEMENTED BY SYSTEM STAR























-- Ordenar las transiciones en los process flow
declare
    v_trans_ant number;
    v_proc_ant  varchar2(255);
    v_fork_ant  varchar2(255);
    v_trans     varchar2(255);
    v_orden     varchar2(1000);
    
    CURSOR c_trans IS
        SELECT process_name proc, source_activity_name fork, transition_name trans_de, transition_order trans
        FROM all_iv_process_transitions
        order by process_name, source_activity_name, transition_order, transition_name;

begin

    DBMS_OUTPUT.PUT_LINE('Inicio de proceso');
    
    v_trans_ant := 0;
    v_proc_ant := 'inicio';
    v_fork_ant := 'inicio';
    
    FOR r_dedic IN c_trans LOOP
    
        IF (v_proc_ant <> r_dedic.proc OR v_fork_ant <> r_dedic.fork) THEN
            -- Cambia el proceso o la actividad, inicializamos y comprobamos que la primera transición es la 0 
            v_proc_ant  := r_dedic.proc;
            v_fork_ant  := r_dedic.fork;
            v_trans_ant := 0;
            IF r_dedic.trans <> v_trans_ant THEN
                v_orden := 'OMBALTER PROCESS_FLOW ''' || v_proc_ant || ''' MODIFY TRANSITION ''' || r_dedic.trans_de;
                v_orden := v_orden || ''' SET PROPERTIES (TRANSITION_ORDER) VALUES (' || v_trans_ant || ')';
                DBMS_OUTPUT.PUT_LINE(v_orden);
            END IF;
            
        ELSE
            -- Comparamos la transicion con la transicion anterior
            
            IF v_trans_ant + 1 <> r_dedic.trans THEN
                
                    v_orden := 'OMBALTER PROCESS_FLOW ''' || v_proc_ant || ''' MODIFY TRANSITION ''' || r_dedic.trans_de;
                    v_orden := v_orden || ''' SET PROPERTIES (TRANSITION_ORDER) VALUES (' ||to_char(v_trans_ant + 1) || ')';

                    DBMS_OUTPUT.PUT_LINE(v_orden);
            END IF;
            v_trans_ant := v_trans_ant + 1;
        END IF;
        
    END LOOP;
    
    dbms_output.put_line('Proceso terminado correctamente');

exception
when others then
    dbms_output.put_line(SQLCODE || ' ' || SQLERRM);
    dbms_output.put_line('Error en ' || v_proc_ant || ' del ' || v_fork_ant);
end;





































#    Procedimiento de copia de operadores en un mapeo
set OMBLOG "D:\\339307\\temp.log"
source D:\\owb10g\\procedimientos_omb.tcl
set p_map TOI_CP_TRASLADOS_ENTRADA_2_M
set p_join JOINER
set p_join_new JN
copia_ingrp_join $p_map $p_join $p_join_new D:\\339307\\temp1.tcl


# Se revisan los OMBALTER del temp1.tcl:
source D:\\339307\\temp1.tcl

# Se copian los grupos origen a los destino en el nuevo p_join_new (Si es que se llaman
# igual por lo que se pueden mapear):
puts "OMBALTER MAPPING '$p_map' ADD CONNECTION FROM GROUP 'INOUTGRP1' OF OPERATOR 'TOH_SIG_AC_SOLICITUD' \\"
puts "  TO GROUP 'SOL' OF OPERATOR '$p_join_new' BY NAME"

# Si los atributos no se llaman igual, lo mismo hay que utilizar lo siguiente:
source D:\\owb10g\\scripts_migracion.tcl
conexiones_operador $p_map $p_join "D:\\339307\\temp2.tcl"


# Copiamos la WHERE de un join a otro
set l_expr [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET PROPERTIES (JOIN_CONDITION)]
if {[string first "'" $l_expr] != -1} {
    set l_expr [string map {"'" "''"} $l_expr]
}
if { $l_expr == "{}" } {
    puts "La JOIN origen no tiene datos en la condición WHERE"
} elseif { [ string match "\{*" "$l_expr" ] } {
    # La expresión en el WHERE contiene espacios en blanco, por lo que viene entre llaves,
    # eliminamos las llaves de la expresión a insertar
    set l_expr [ string range $l_expr 1 [expr [ string length $l_expr ] - 2 ] ]
    OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
        SET PROPERTIES (JOIN_CONDITION) VALUES ('$l_expr')
} else {
    # Posiblemente no entre por aquí, pero por si acaso. La WHERE está formada por una expresión
    # sin espacios en blanco, por lo que no hay que eliminar las llaves
    OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
        SET PROPERTIES (JOIN_CONDITION) VALUES ('$l_expr')
}

# Copiamos la Descripcion de un join a otro
set l_expr [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET PROPERTIES (DESCRIPTION)]
if { $l_expr == "{}" } {
    puts "La Descripcion origen no tiene datos en la condición WHERE"
} elseif { [ string match "\{*" "$l_expr" ] } {
    # La expresión en la descripción contiene espacios en blanco, por lo que viene entre llaves,
    # eliminamos las llaves de la expresión a insertar
    set l_expr [ string range $l_expr 1 [expr [ string length $l_expr ] - 2 ] ]
    OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
        SET PROPERTIES (DESCRIPTION) VALUES ('$l_expr')
} else {
    # La descripción está formada por una única palabra,
    # sin espacios en blanco, por lo que no hay que eliminar las llaves
    OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
        SET PROPERTIES (DESCRIPTION) VALUES ('$l_expr')
}



# Cambiamos los nombres de columnas de salida, lanzar una vez creado la nueva join en las ordenes anteriores:
renombra_atributos_outgrp_join $p_map $p_join_new D:\\339307\\temp3.tcl

# El temp.log generado se limpia y se copia en el temp3.tcl
source D:\\339307\\temp3.tcl



# Podemos querer cambiar los nombres de los atributos a los que va la salida del operador JOIN
renombra_atributos_outcon_join $p_map $p_join_new D:\\339307\\temp4.tcl

source D:\\339307\\temp4.tcl








































#
# Clone an Expression Operator in a map.
#
# Usage:
#   OMBCC '/YOUR_PROJECT/YOUR_MODULE'
#   source <this_file>
#   clone_ex SOURCE_MAP_NAME SOURCE_EXPRESSION_OP_NAME TARGET_OP_NAME
#
#
#
proc clone_ex {source_map expression_oper target_oper} {

 set l_groups [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GET OUTPUT GROUPS]

 # Para cada uno de los grupos de salida
 foreach g $l_groups {
   
   set l_atts [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' GET ATTRIBUTES]
   foreach a $l_atts {
     set l_adty [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (DATATYPE)]
     set l_alen [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (LENGTH)]
     set l_apre [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (PRECISION)]
     set l_asca [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (SCALE)]

     # Add attribute
     OMBALTER MAPPING '$source_map' ADD ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper'

     OMBALTER MAPPING '$source_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper' \
      SET PROPERTIES (DATATYPE) VALUES ('$l_adty')
     if {[regexp ".*NUM.*" $l_adty] > 0} {
      OMBALTER MAPPING '$source_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper' \
       SET PROPERTIES (PRECISION) VALUES ('$l_apre')
      OMBALTER MAPPING '$source_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper' \
       SET PROPERTIES (SCALE) VALUES ('$l_asca')
     }
     if {[regexp ".*CHAR.*" $l_adty] > 0} {
      OMBALTER MAPPING '$source_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper' \
       SET PROPERTIES (LENGTH) VALUES ('$l_alen')
     }

     # If it is an OUTPUT group, set the expression. Need to escape single quotes...
       set l_expr [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (EXPRESSION)]
       if {[string first "'" $l_expr] != -1} {
         set l_expr [string map {"'" "''"} $l_expr]
       }
       set v ""
       if {[llength $l_expr] == 1} {
         set v [lindex $l_expr 0]
       } else {
         for each t $l_expr {
           append v $t
         }
       }
       OMBALTER MAPPING '$source_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$target_oper' \
        SET PROPERTIES (EXPRESSION) VALUES ('$v')
     
   }
   # foreach a l_atts
 }
 # foreach g l_groups
}
# proc clone_ex






















































# Para copiar un operador AGGREGATOR. Si hay que eliminar atributos del operador, eliminar la conexión
# de los de entrada, para evitar que los copie de entrada, y eliminar los de salida para evitar que los
# clone ya que borrar los de salida no corrompen el operador:

set OMBLOG "D:\\II000010\\temp.log"
set p_map TFC_DOC_MATRICULAS_ALUMNO_M
set p_join AGG
set p_join_new AGG2

source D:\\owb10g\\scripts_migracion.tcl
conexiones_operador $p_map $p_join "D:\\339307\\temp2.tcl"

# Se edita el temp2 cambiando el nombre del operador y eliminando las conexiones de salida (las
# de salida, si se van a necesitar, se pueden copiar a otro fichero)
source D:\\339307\\temp2.tcl

# Se copia el group by, con eso, al editarlo en el mapeo, se crean automáticamente los atributos de salida
set l_expr [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET PROPERTIES (GROUP_BY_CLAUSE)]
if {[string first "'" $l_expr] != -1} {
    set l_expr [string map {"'" "''"} $l_expr]
}
if { $l_expr == "{}" } {
        puts "La Descripcion origen no tiene datos en la condición GROUP BY"
    } elseif { [ string match "\{*" "$l_expr" ] } {
        # La expresión en la descripción contiene espacios en blanco, por lo que viene entre llaves,
        # eliminamos las llaves de la expresión a insertar
        set l_expr [ string range $l_expr 1 [expr [ string length $l_expr ] - 2 ] ]
        OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
            SET PROPERTIES (GROUP_BY_CLAUSE) VALUES ('$l_expr')
    } else {
        # La descripción está formada por una única palabra,
        # sin espacios en blanco, por lo que no hay que eliminar las llaves
        OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
            SET PROPERTIES (GROUP_BY_CLAUSE) VALUES ('$l_expr')
    }

# Se copia la descripcion de un AGG a otro
set l_expr [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET PROPERTIES (DESCRIPTION)]
if {[string first "'" $l_expr] != -1} {
    set l_expr [string map {"'" "''"} $l_expr]
}
if { $l_expr == "{}" } {
        puts "La Descripcion origen no tiene datos en la condición WHERE"
    } elseif { [ string match "\{*" "$l_expr" ] } {
        # La expresión en la descripción contiene espacios en blanco, por lo que viene entre llaves,
        # eliminamos las llaves de la expresión a insertar
        set l_expr [ string range $l_expr 1 [expr [ string length $l_expr ] - 2 ] ]
        OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
            SET PROPERTIES (DESCRIPTION) VALUES ('$l_expr')
    } else {
        # La descripción está formada por una única palabra,
        # sin espacios en blanco, por lo que no hay que eliminar las llaves
        OMBALTER MAPPING '$p_map' MODIFY OPERATOR '$p_join_new' \
            SET PROPERTIES (DESCRIPTION) VALUES ('$l_expr')
    }


# Se carga en memoria el procedimiento que copia los atributos de salida que faltan
proc copia_agg {p_map p_agg p_agg_new} {

    set v_grupo [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GET OUTPUT GROUPS]
    set v_grupo_new [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg_new' GET OUTPUT GROUPS]
    
    # Recupero los atributos de salida
    set l_atts [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' GET ATTRIBUTES]
    set l_atts_new [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg_new' GROUP '$v_grupo_new' GET ATTRIBUTES]
    foreach v_att $l_atts {
        # Inicializo la variable donde calcula si el atributo existe ya en el grupo nuevo o no
        set v_existe 0
        foreach v_att_new $l_atts_new {
            if { $v_att == $v_att_new } { set v_existe 1 }
        }
        
        if { $v_existe == 0 } {
            # No se ha encontrado atributo en el operador nuevo, se añade y se copia la expresion
            set l_adty [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' ATTRIBUTE '$v_att' GET PROPERTIES (DATATYPE)]
            set l_alen [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' ATTRIBUTE '$v_att' GET PROPERTIES (LENGTH)]
            set l_apre [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' ATTRIBUTE '$v_att' GET PROPERTIES (PRECISION)]
            set l_asca [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' ATTRIBUTE '$v_att' GET PROPERTIES (SCALE)]
            
            # Se añade el atributo
            OMBALTER MAPPING '$p_map' ADD ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new'
            
            OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new' \
                SET PROPERTIES (DATATYPE) VALUES ('$l_adty')
            if { $l_apre != 0 } {
                OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new' \
                    SET PROPERTIES (PRECISION) VALUES ($l_apre)
            }
            if { $l_asca != 0 } {
                OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new' \
                    SET PROPERTIES (SCALE) VALUES ('$l_asca')
            }
            if { $l_alen != 0 } {
                OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new' \
                    SET PROPERTIES (LENGTH) VALUES ('$l_alen')
            }
            
            # Ahora recuperamos la expresion del atributo
            set l_expr [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_agg' GROUP '$v_grupo' ATTRIBUTE '$v_att' GET PROPERTIES (EXPRESSION)]
            if {[string first "'" $l_expr] != -1} {
                set l_expr [string map {"'" "''"} $l_expr]
            }
            set v ""
            if {[llength $l_expr] == 1} {
                set v [lindex $l_expr 0]
            } else {
                for each t $l_expr {
                    append v $t
                }
            }
            
            OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$v_att' OF GROUP '$v_grupo_new' OF OPERATOR '$p_agg_new' \
                SET PROPERTIES (EXPRESSION) VALUES ('$v')
        }
        # if v_existe = 0
     
   }
   # foreach v_att l_atts
}
# proc copia_agg

copia_agg $p_map $p_join $p_join_new

# Si se han copiado los enlaces de los atributos de salida, se puede lanzar ahora

























proc verifica_mapeo { p_proyecto p_ruta p_fichero } {
    # Nombre:          verifica_mapeo.
    
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder, ej UXXIDW.
    #                  p_ruta: Ruta en la que dejar el log de la ejecución, ej, "D:\\3\\"
    #                          las dobles comillas son importantes cuando la ruta contiene
    #                          espacios en blanco.
    #                  p_fichero: Fichero con el listado de mapeos a modificar,
    #                             por ejemplo, verifica_UC3M.log
    
    # Descripcion: Procedimiento para buscar operadores SET_OPERATION en todos los mapeos de un
    #              proyecto y comprobar que ninguno tiene como nombre la palabra reservada SET.
    #              El procedimiento genera un fichero con el listado de mapeos que tienen un
    #              operador con ese nombre, para que se modifiquen.
    
    #Creamos la ruta para el log si no existe
    file mkdir $p_ruta
    # Se especifica el fichero de log
    append v_fichero $p_ruta $p_fichero
    
    puts "Comienzo verifica_mapeo versión 1.0 $p_proyecto $p_ruta $p_fichero"
    puts [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
    
    # Se crea el fichero de log y si ya existe, lo reescribimos
    set v_outfile [ open "$v_fichero" w ]
    puts $v_outfile "Comienzo verifica_mapeo versión 1.0 $p_proyecto $p_ruta $p_fichero"
    puts $v_outfile [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
    
    OMBCC '/$p_proyecto'
    puts "Listado de modulos del proyecto : $p_proyecto"
    set ListMod [ OMBLIST ORACLE_MODULES ]
    foreach ModName $ListMod {
        puts "Listado de mapeos de: $ModName"
            OMBCC '/$p_proyecto/$ModName'
            set mapList [ OMBLIST MAPPINGS ]
            foreach mapName $mapList {
                puts "Revisando mapping $mapName"
                set opList [ OMBRETRIEVE MAPPING '$mapName' GET SET_OPERATION OPERATORS ]
                foreach opName $opList {
                    if { $opName == "SET" } {
                        # El mapeo tiene un operador que nos puede dar problemas,
                        # se copia en el fichero para revisarlo y cambiarle el nombre
                        puts $v_outfile "Revisar mapeo $p_proyecto/$ModName/$mapName"
                    }
                }
                # foreach opName
            }
            # foreach mapName
            puts "."
            puts "."
            puts "-----------------------------------------------"
    }
    # foreach ModName
    
    puts $v_outfile "Finaliza verifica_mapeo versión 1.0 $p_proyecto $p_ruta $p_fichero"
    puts $v_outfile [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
    close $v_outfile
    
    puts "Finaliza verifica_mapeo versión 1.0 $p_proyecto $p_ruta $p_fichero"
    puts [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
    
}
# Fin proc verifica_mapeo





# Revisar la política de todos los mapeos de un módulo
OMBCC '/UXXIDW/UXXIRRHH_ODS'
set ListMaps [ OMBLIST MAPPINGS 'TOI.*' ]
foreach p_Map $ListMaps {
    set p_desplegable [ OMBRETRIEVE MAPPING '$p_Map' GET PROPERTIES (DEPLOYABLE) ]
    if { $p_desplegable == "true" } {
        set ListTabs [ OMBRETRIEVE MAPPING '$p_Map' GET PROPERTIES (TARGET_LOAD_ORDER) ]
        foreach p_Tab [ split $ListTabs "," ] {
            set p_PolCarga [ OMBRETRIEVE MAPPING '$p_Map' OPERATOR '$p_Tab' GET PROPERTIES (LOADING_TYPE) ]
            if { $p_PolCarga != "TRUNCATE_INSERT" } {
                puts "Revisar tabla $p_Tab en mapeo $p_Map"
            }
            # if p_PolCarga
        }
        # foreach p_Tab
    }
    # p_desplegable true
}
# foreach p_Map
puts "Fin revision"

























# Pendiente de probar. Puesto en un hilo en el foro de OWB
# Como comparar si un objeto está incluido en una lista de valores
# Build up a list of the names from the config file ...
set namesToExclude {nm1 nm2 nm3}

# using your objName variable - I will just set it some value to illustrate ...
set objName "someName"

# Then process the objName to see if it is to be excluded....
if {[lsearch $namesToExclude $objName] == -1 } {
puts "include"
} else {
puts "exclude"
}

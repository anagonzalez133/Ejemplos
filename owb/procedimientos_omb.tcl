####### Modulo para despliegue de objetos  #######


####### Componentes                        #######

# proc_conectar
# owb_set_maxerrors_ansi
# modif_tablespace
# revisa_indices
# revisa_process_flows
# genera_alter_process_flows
# reconciles_automaticos            Pendiente de revisión, copiado del foro owb de oracle
# copia_tabla
# proc_desplegar_TOH_M
# renombra_atributos_outgrp_join
# renombra_atributos_outcon_join
# copia_ingrp_join
# proc_borra_referencias_coleccion
# proc_renombra_dim_cubo

# escribir: source 'ruta_fichero\\nombre_fichero', p.e.: source c:\\scripts_tcl\\despligue_mappings.tcl
# para ejecutar el procedimiento: deploy_mappings


proc proc_conectar {p_cadena_repo_dis p_proyecto p_conex_runtime p_contra_runtime} {

    # Nombre:          proc_conectar.

    # Parametros:
    #                  p_cadena_repo_dis, cadena de conexion, p.e: owb9i/owb9i@ensor:1521:CURSOS
    #                  p_proyecto, nombre del proyecto del que se va a hacer el despliegue. p.e.: VENTAS_CMG
    #                  p_conex_runtime, nombre de la conexion desde el repositorio de disenio al runtime, p.e: CONEXION_CMG
    #                  p_contra_runtime, contrasenia del usuario del runtime

    # Precondiciones:
    #                  1.- Ya estan creadas todas las localizaciones a los repositorios.
    #                  2.- Esta creada la conexion al Runtime.

    # Postcondiciones:
    #                  1.- Se conecta al repositorio de disenio owb9i/owb9i@ensor:1521:CURSOS.
    #                  2.- Se abre el proyecto VENTAS_CMG.
    #                  3.- Se conecta con el runtime de la conexion CONEXION_CMG.

    # Ejemplo llamada :
    # OMB+> proc_conectar owb9i/owb9i@ensor:1521:cursos 'VENTAS_CMG' 'CONEXION_CMG' 'OWBRUN9I'

    # OMBCONNECT $p_cadena_repo_dis
    OMBCC $p_proyecto
    OMBCONNECT CONTROL_CENTER $p_cadena_repo_dis USE REPOSITORY 'OWB102'
    OMBDCC
    puts "Conectado a $p_cadena_repo_dis"
    puts "Proyecto $p_proyecto"
    puts "Runtime $p_conex_runtime"
}

proc owb_set_maxerrors_ansi {p_proyecto p_modulo} {
    puts "Comienzo proc_desplegar_tablas $p_proyecto"
    OMBCC '/$p_proyecto'
    set Listmod1 [ OMBLIST ORACLE_MODULES '$p_modulo.*']
    puts "Conectado al proyecto : $p_proyecto"
    set i 1
    foreach mod1 $Listmod1 {
        puts "Listando de tablas de (conectando) de : $mod1"
        OMBCC '$mod1'
      set mapList [ OMBLIST MAPPINGS ]
          set j 1
      foreach mapName $mapList {
        puts "Modificando mapping $mapName"
        OMBALTER MAPPING '$mapName' SET PROPERTIES (MAXIMUM_NUMBER_OF_ERRORS) VALUES (0)
        OMBALTER MAPPING '$mapName' SET PROPERTIES (ANSI_SQL_SYNTAX) VALUES (0)
          incr j
       }
           OMBCC '/$p_proyecto'
       incr i
    }
    puts "Fin owb_set_maxerrors_ansi $p_modulo"
}



proc modif_tablespace {p_proyecto p_modulo p_tablespace} {

    # Nombre:          modif_tablespace
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran las tablas, ej: UXXIRRHH_ODS
    #                  p_tablespace: Tablespace al que cambiar la tabla, ej, UXXIRRHH
    # Descripcion:
    #                  Revisa todas las tablas TOA y TOH del modulo, cambiando el.
    #                  tablespace de despliegue a OA_p_tablespace y OH_p_tablespace
    #                  respectivamente.

    OMBCC '/$p_proyecto/$p_modulo'
    
    puts "Comienzo modif_tablespace $p_proyecto $p_modulo $p_tablespace"
    set v_tablespace "OA_$p_tablespace"
    set Listtab1 [ OMBLIST TABLES 'TOA.*' ]
    foreach tabName $Listtab1 {
        # Se comprueba el tablespace definido para la tabla
        set v_tab [ OMBRETRIEVE TABLE '$tabName' GET PROPERTIES (TABLESPACE) ]
        if { $v_tab == $v_tablespace } {
            puts "$tabName revisada"
        } else {
            OMBALTER TABLE '$tabName' SET PROPERTIES (TABLESPACE) VALUES ('$v_tablespace')
            puts "$tabName modificada"
        }
        # Fin if v_tab = v_tablespace
    }
    set v_tablespace "OH_$p_tablespace"
    set Listtab1 [ OMBLIST TABLES 'TOH.*' ]
    foreach tabName $Listtab1 {
        # Se comprueba el tablespace definido para la tabla
        set v_tab [ OMBRETRIEVE TABLE '$tabName' GET PROPERTIES (TABLESPACE) ]
        if { $v_tab == $v_tablespace } {
            puts "$tabName revisada"
        } else {
            OMBALTER TABLE '$tabName' SET PROPERTIES (TABLESPACE) VALUES ('$v_tablespace')
            puts "$tabName modificada"
        }
        # Fin if v_tab = v_tablespace
    }
    OMBCOMMIT
    
    puts "Fin modif_tablespace $p_proyecto $p_modulo $p_tablespace"
}
# Fin modif_tablespace

proc revisa_indices {p_proyecto p_modulo p_tablespace} {
    # Nombre:          revisa_indices.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran las tablas, ej: UXXIRRHH_DDS
    #                  p_tablespace: Tablespace para ubicar los indices (UXXIDW_INDX)
    # Descripcion: Recoge todas las tablas del modulo y si la tabla es desplegable,
    #              repasa los indices: en las Primary Key, Unique Key y los indices
    #              normales revisa que el tablespace sea el dado y comprueba que las
    #              Foreign Key estan como NO DESPLEGABLES.

    puts "Comienzo revisa_indices $p_proyecto $p_modulo $p_tablespace"
    OMBCC '/$p_proyecto/$p_modulo'
    puts "Listado de tablas de: $p_modulo"
    set tabList [ OMBLIST TABLES ]
    foreach tabName $tabList {
        set p_despleg [OMBRETRIEVE TABLE '$tabName' GET PROPERTIES (DEPLOYABLE)]
        if {$p_despleg == "true"} {
            puts "-----------------------------------------------"
            puts "."
            puts "Modificando tabla $tabName"
            # Las PK, UK e Indices normales nos aseguramos que se
            # despliegan en el tablespace adecuado
            set pkList [OMBRETRIEVE TABLE '$tabName' GET PRIMARY_KEY]
            foreach pkName $pkList {
                puts "Modificando PK $pkName"
                OMBALTER TABLE '$tabName' MODIFY PRIMARY_KEY '$pkName' \
                    SET PROPERTIES (INDEX_TABLESPACE) VALUES ('$p_tablespace')
            }
            # foreach pkName
            
            set idxList [OMBRETRIEVE TABLE '$tabName' GET INDEXES]
            foreach idxName $idxList {
                puts "Modificando IDX $idxName"
                OMBALTER TABLE '$tabName' MODIFY INDEX '$idxName' \
                    SET PROPERTIES (TABLESPACE) VALUES ('$p_tablespace')
            }
            # foreach idxName
            
            set ukList [OMBRETRIEVE TABLE '$tabName' GET UNIQUE_KEYS]
            foreach ukName $ukList {
                puts "Modificando UK $ukName"
                OMBALTER TABLE '$tabName' MODIFY PRIMARY_KEY '$ukName' \
                     SET PROPERTIES (INDEX_TABLESPACE) VALUES ('$p_tablespace')
            }
            # foreach ukName
            
            # Las FK nos aseguramos que estan como no desplegables
            set fkList [OMBRETRIEVE TABLE '$tabName' GET FOREIGN_KEYS]
            foreach fkName $fkList {
                puts "Revisa FK $fkName"
                OMBALTER TABLE '$tabName' MODIFY FOREIGN_KEY '$fkName' \
                    SET PROPERTIES (DEPLOYABLE) VALUES ('false')
            }
            # foreach fkName
        } else {
            puts "Tabla $tabName no desplegable"
        }
        # end if p_despleg = true
        puts "."
        puts "."
    }
    # foreach tabName
    OMBCC '/$p_proyecto'
    OMBCOMMIT
    puts "Fin revisa_indices $p_proyecto $p_modulo $p_tablespace"
}
# Fin revisa_indices


proc revisa_process_flows {p_proyecto p_proc_module p_proc_package} {
    # Nombre:          revisa_process_flows.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_proc_module: Modulo que agrupa los paquetes de process_flow, ej, CARGA
    #                  p_proc_package: Paquete que agrupa los process_flow a revisar, ej, GENERAL
    # Descripcion: Recoge todos los process flows del paquete pasado por parametros y revisa
    #              las transiciones de salida de los objetos tipo START, FORK y AND.
    #              Si la transicion tiene una condicion, la borra y la vuelve a crear
    #              sin condicion.
    puts "Comienzo revisa_proces_flows $p_proyecto $p_proc_module $p_proc_package"
    OMBCC '/$p_proyecto/$p_proc_module/$p_proc_package'
    puts "Listado de procesos: $p_proc_package"
    set procList [ OMBLIST PROCESS_FLOWS ]
    foreach procName $procList {
        puts "-----------------------------------------------"
        puts "Revision de $procName"
        set v_transicion ""
        # Si falla esto es que la actividad START se llama de otra forma
        set v_transicion [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY 'START' \
            GET OUTGOING_TRANSITIONS ]
        set v_condicion [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_transicion' \
            GET PROPERTIES (TRANSITION_CONDITION) ]
        if { $v_condicion == "{}" } {
            puts "Transicion de start $v_transicion correcta"
        } else {
            puts "Transicion de start $v_transicion corregida"
            # OMBALTER PROCESS_FLOW '$procName' MODIFY TRANSITION '$v_transicion' \
            #    SET PROPERTIES (TRANSITION_CONDITION) VALUES ('')
            # Por alguna razon el OMBALTER falla y hay que borrarla y volverla a crear
            set v_ini [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_transicion' \
                GET SOURCE_ACTIVITY ]
            set v_fin [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_transicion' \
                GET DESTINATION_ACTIVITY ]
            OMBALTER PROCESS_FLOW '$procName' DELETE TRANSITION '$v_transicion'
            OMBALTER PROCESS_FLOW '$procName' ADD TRANSITION '$v_transicion' \
                FROM ACTIVITY '$v_ini' TO '$v_fin'
        }
        # if v_condicion
        # Ahora revisamos las transiciones de los FORK
        set forkList [ OMBRETRIEVE PROCESS_FLOW '$procName' GET FORK ACTIVITIES ]
        foreach forkName $forkList {
            set transList [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$forkName' \
                GET OUTGOING_TRANSITIONS ]
            foreach transName $transList {
                set v_condicion [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$transName' \
                    GET PROPERTIES (TRANSITION_CONDITION) ]
                if { $v_condicion == "{}" } {
                    puts "Transicion de $forkName $transName correcta"
                } else {
                    puts "Transicion de $forkName $transName corregida"
                    # OMBALTER PROCESS_FLOW '$procName' MODIFY TRANSITION '$transName' \
                    #    SET PROPERTIES (TRANSITION_CONDITION) VALUES ('')
                    # Por alguna razon el OMBALTER falla justo en las que tenemos que
                    # corregir, por lo que hay que borrar la transicion y volverla a crear
                    # sin condicion
                    set v_ini [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$transName' \
                        GET SOURCE_ACTIVITY ]
                    set v_fin [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$transName' \
                        GET DESTINATION_ACTIVITY ]
                    OMBALTER PROCESS_FLOW '$procName' DELETE TRANSITION '$transName'
                    OMBALTER PROCESS_FLOW '$procName' ADD TRANSITION '$transName' \
                        FROM ACTIVITY '$v_ini' TO '$v_fin'
                }
                # if v_condicion
            }
            # foreach transName
        }
        # foreach forkName
        # Ahora revisamos las transiciones de los AND
        set andList [ OMBRETRIEVE PROCESS_FLOW '$procName' GET AND ACTIVITIES ]
        foreach andName $andList {
            set transList [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$andName' \
                GET OUTGOING_TRANSITIONS ]
            foreach transName $transList {
                set v_condicion [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$transName' \
                    GET PROPERTIES (TRANSITION_CONDITION) ]
                if { $v_condicion == "{}" } {
                    puts "Transicion de $andName $transName correcta"
                } else {
                    puts "Transicion de $andName $transName corregida"
                    OMBALTER PROCESS_FLOW '$procName' MODIFY TRANSITION '$transName' \
                        SET PROPERTIES (TRANSITION_CONDITION) VALUES ('')
                }
                # if v_condicion
            }
            # foreach transName
        }
        # foreach andName
        puts "."
        puts "."
    }
    # foreach procName
    OMBCC '/$p_proyecto'
    OMBCOMMIT
    puts "Fin revisa_process_flows $p_proyecto $p_proc_module $p_proc_package"
    puts "-----------------------------------------------"
}
# Fin revisa_process_flows

proc genera_alter_process_flows {p_proyecto p_proc_module p_proc_package p_fichero} {
    # Nombre:          genera_alter_process_flows.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_proc_module: Modulo que agrupa los paquetes de process_flow, ej, CARGA
    #                  p_proc_package: Paquete que agrupa los process_flow a revisar, ej, GENERAL
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.log", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    # Descripcion: Recoge todos los process flows del paquete pasado por parametros y revisa
    #              si hay un procedimiento publico. Si es asi, escribe en el fichero una
    #              orden para cambiar su ubicacion de despliegue segun el valor de una
    #              variable, v_location, que habra que definir cuando se lance el alter.
    #              v_location NO HA SIDO DEFINIDA para que si dentro del mismo paquete
    #              hay process flow con diferentes localizaciones de despliegue, EDITEMOS
    #              el fichero de salida añadiendo el valor de v_location adecuado y ordenemos
    #              los alter segun ese valor (primero todos los de DDS_SIGMA_LOC,
    #              luego los DDS_SOROLLA_LOC, etc).
    OMBCC '/$p_proyecto/$p_proc_module/$p_proc_package'
    set v_public_path "/$p_proyecto/WB_CUSTOM_TRANS"
    puts "Listado de procesos: $p_proc_package"
    set v_outfile [ open "$p_fichero" a+ ]
    set procList [ OMBLIST PROCESS_FLOWS ]
    foreach procName $procList {
        puts "-----------------------------------------------"
        puts "Revision de $procName"
        set funcList [ OMBRETRIEVE PROCESS_FLOW '$procName' GET TRANSFORMATION ACTIVITIES ]
        foreach funcName $funcList {
            set v_func_ref [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$funcName' GET REF ]
            if { [ string match "$v_public_path*" "$v_func_ref" ] } {
                set v_alter "OMBALTER PROCESS_FLOW '$procName' MODIFY ACTIVITY '$funcName'"
                set v_alter "$v_alter SET PROPERTIES (DEPLOYED_LOCATION) VALUES ('\$v_location')"
                puts $v_outfile $v_alter
            }
            puts "."
            puts "."
        }
        # foreach funcName
    }
    # foreach procName
    close $v_outfile
    puts "Fin genera_alter_process_flows"
}
# fin genera_alter_process_flows





# reconciles_automaticos            Pendiente de probar
# ==========================================================
# set testProj "TEST_DEMO_PROJ"
# set recModule "DWH"

# OMBCC '/$testProj/$recModule'

# foreach recMapping [OMBLIST MAPPINGS] {
# set tabList [ OMBRETRIEVE MAPPING '$recMapping' GET TABLE OPERATORS ]
# foreach TabOpName $tabList {
# set tabPath [split [lindex [OMBRETRIEVE MAPPING '$recMapping' OPERATOR '$TabOpName' GET BOUND_OBJECT] 1] '/']
# set tabProjName [lindex $tabPath 1]
# set tabModuleName [lindex $tabPath 2]
# set tabName [lindex $tabPath 3]
# OMBRECONCILE TABLE '/$testProj/$tabModuleName/$tabName' TO MAPPING '$recMapping' OPERATOR '$TabOpName' USE (RECONCILE_STRATEGY 'REPLACE', MATCHING_STRATEGY 'MATCH_BY_OBJECT_NAME')
# }
# }
# OMBCOMMIT
# ==========================================================

# If you use views in mapping add additinal loop for view operator:
# set viewList [ OMBRETRIEVE MAPPING '$recMapping' GET VIEW OPERATORS ]
# foreach TabOpName $viewList
# reconciles_automaticos            Pendiente de probar

proc copia_tabla {p_tabla_ori p_ruta_ori p_tabla_des p_ruta_des p_ruta} {
    # Nombre:          copia_tabla.
    
    # Parametros:      p_tabla_ori: Nombre de la tabla de la que se toman los datos, ej, TACA_PLAZA.
    #                  p_ruta_ori: Ruta completa del modulo donde se ubica la tabla origen, ej, $p_ruta_ori
    #                  p_tabla_des: Nombre de la tabla que se crea como copia
    #                  p_ruta_des: Ruta completa del modulo donde se ubica la tabla copiada, ej, /UXXIDW/UXXIAC_ODS
    #                  p_ruta: Ruta en la que dejar los objetos exportados, ej, "D:\\3\\"
    #                          las dobles comillas son importantes cuando la ruta contiene
    #                          espacios en blanco.
    
    # Descripcion: Recoge las columnas y descripciones de la tabla origen y copia en un fichero las ordenes
    #              de creacion de la tabla copia, con las mismas columnas y descripciones de la tabla origen.
    #              A continuación crea un mapeo con el mismo nombre donde se mapea la tabla origen
    #              directamente a la destino, e incluye la tabla y el mapeo en una coleccion.
    #              No se copian los indices, particiones ni tablespace de la tabla origen.
    #              Luego se puede copiar el fichero generado y lanzarlo en la ventana del OMBPLUS.
    #
    
    # Archivo de log de la exportacion general
    puts "Comienzo copia_tabla $p_tabla_ori $p_ruta_ori $p_tabla_des $p_ruta_des $p_ruta"
    
    append v_fichero $p_ruta "copia_tabla_$p_tabla_des.log"
    # Crea el fichero, si ya existe, lo sobreescribe
    set v_outfile [ open "$v_fichero" w ]
    
    # Nos situamos en la ruta de la tabla destino
    OMBCC '$p_ruta_des'
    puts $v_outfile "OMBCC '$p_ruta_des'"
    
    puts $v_outfile "OMBCREATE TABLE '$p_tabla_des' \\"
    set v_comment [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' GET PROPERTIES (DESCRIPTION) ]
    if { $v_comment == "{}" } {
        puts "# OMBALTER TABLE '$p_tabla_des' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
    } elseif { [ string match "\{*" "$v_comment" ] } {
        # el comentario contiene espacios en blanco, por lo que viene entre llaves,
        # eliminamos las llaves del comentario a insertar
        set v_comment [ string range $v_comment 1 [expr [ string length $v_comment ] - 2 ] ]
        # puts $v_outfile "OMBALTER TABLE '$p_tabla_des' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
        puts $v_outfile "SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment') \\"
    } else {
        # El comentario es una unica palabra por lo que no viene entre llaves
        # se inserta directamente
        # puts $v_outfile "OMBALTER TABLE '$p_tabla_des' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
        puts $v_outfile "SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment') \\"
    }
    set colList [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' GET COLUMNS ]
    foreach colName $colList {
        set v_tip_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (DATATYPE) ]
        if { $v_tip_col == "VARCHAR2" } {
            set v_long_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (LENGTH) ]
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE, LENGTH) VALUES ('$v_tip_col',$v_long_col) \\"
        } elseif { $v_tip_col == "CHAR" } {
            set $v_tip_col == "VARCHAR2"
            set v_long_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (LENGTH) ]
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE, LENGTH) VALUES ('$v_tip_col',$v_long_col) \\"
        } elseif { $v_tip_col == "NUMBER" } {
            set v_prec_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (PRECISION) ]
            set v_scale_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (SCALE) ]
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE, PRECISION, SCALE) VALUES ('$v_tip_col',$v_prec_col,$v_scale_col) \\"
        } elseif { $v_tip_col == "FLOAT" } {
            set v_prec_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (PRECISION) ]
            set v_scale_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (SCALE) ]
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE, PRECISION, SCALE) VALUES ('$v_tip_col',$v_prec_col,$v_scale_col) \\"
        } elseif { $v_tip_col == "INTEGER" } {
            set v_prec_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (PRECISION) ]
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE, PRECISION) VALUES ('$v_tip_col',$v_prec_col) \\"
        } else {
            puts $v_outfile "# Revisar si este tipo de dato es correcto crearlo asi o hay que hacer mas elseif y quitar este comentario al lanzar el script de creacion"
            puts $v_outfile "ADD COLUMN '$colName' SET PROPERTIES (DATATYPE) VALUES ('$v_tip_col') \\"
        }
    }
    # foreach colName
    
    puts $v_outfile "# Eliminar el \\ final del ultimo ADD COLUMN"
    puts $v_outfile " "
    
    # Si las columnas tienen comentarios les añadimos, no se ha hecho al crear la tabla para
    # no complicar el ADD COLUMN con mas if, por lo que ahora tenemos que recorrer las columnas de nuevo
    # buscando comentarios.
    foreach colName $colList {
        set v_comment [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (DESCRIPTION) ]
        if { $v_comment == "{}" } {
            puts "# OMBALTER TABLE '$p_tabla_des' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
        } elseif { [ string match "\{*" "$v_comment" ] } {
            # el comentario contiene espacios en blanco, por lo que viene entre llaves,
            # eliminamos las llaves del comentario a insertar
            set v_comment [ string range $v_comment 1 [expr [ string length $v_comment ] - 2 ] ]
            puts $v_outfile "OMBALTER TABLE '$p_tabla_des' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
        } else {
            # El comentario es una unica palabra por lo que no viene entre llaves
            # se inserta directamente
            puts $v_outfile "OMBALTER TABLE '$p_tabla_des' MODIFY COLUMN '$colName' SET PROPERTIES (DESCRIPTION) VALUES ('$v_comment')"
        }
    }
    # foreach colName
    
    # Una vez creada la tabla, se crea el mapeo
    puts $v_outfile " "
    append v_mapeo $p_tabla_des "_M"
    puts $v_outfile "# Repasar que el nombre del mapeo no exceda los 30 caracteres"
    puts $v_outfile "OMBCREATE MAPPING '$v_mapeo' \\"
    puts $v_outfile "ADD TABLE OPERATOR '$p_tabla_ori' \\"
    puts $v_outfile "BOUND TO TABLE '$p_ruta_ori/$p_tabla_ori' \\"
    puts $v_outfile "ADD TABLE OPERATOR '$p_tabla_des' SET PROPERTIES (LOADING_TYPE) VALUES ('TRUNCATE_INSERT') \\"
    puts $v_outfile "BOUND TO TABLE '$p_ruta_des/$p_tabla_des' \\"
    puts $v_outfile "ADD CONNECTION FROM GROUP 'INOUTGRP1' OF OPERATOR '$p_tabla_ori' TO GROUP 'INOUTGRP1' OF OPERATOR '$p_tabla_des' BY NAME"
    
    # Ahora se insertan la tabla y el mapeo en la coleccion
    puts $v_outfile " "
    puts $v_outfile "OMBCC '/UXXIDW'"
    puts $v_outfile "# Repasar el nombre de la coleccion, esta metido a HARDCODE"
    puts $v_outfile "OMBALTER COLLECTION 'P317245_ACCESO' ADD REFERENCE TO TABLE '$p_ruta_des/$p_tabla_des'"
    puts $v_outfile "OMBALTER COLLECTION 'P317245_ACCESO' ADD REFERENCE TO MAPPING '$p_ruta_des/$v_mapeo'"

    # Estas propiedades no existen hasta que no se graba el mapeo creado.
    puts $v_outfile " "
    puts $v_outfile "OMBCC '$p_ruta_des'"
    puts $v_outfile "OMBCOMMIT"
    puts $v_outfile "OMBALTER MAPPING '$v_mapeo' SET PROPERTIES (MAXIMUM_NUMBER_OF_ERRORS,ANSI_SQL_SYNTAX) VALUES (0,0)"
    
    close $v_outfile
    
    puts "Fin copia_tabla $p_tabla_ori $p_ruta_ori $p_tabla_des $p_ruta_des $p_ruta"
    
}
# Fin copia_tabla

proc proc_desplegar_TOH_M {p_proyecto p_modulo} {

    # Nombre:          proc_desplegar_TOH_M.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran los mapeos, ej: UXXIRRHH_ODS
    # Precondiciones:
    #                  1.- Todos los objetos estan validados.
    #                  2.- Las conexiones al runtime y repositorio de disenio han sido establecidas.
    #                  3.- Esta abierto el proyecto correspondiente.
    #                  4.- Se han desplegado correctamente las tablas y db-link
    # Postcondiciones:
    #                  1.- Se despliegan con accion REPLACE los mappings TOA y TOH
    #                      correspondientes al proyecto en el modulo indicado por los parametros.

    puts "Comienzo proc_desplegar_TOH_M $p_proyecto $p_modulo"
    OMBCC '/$p_proyecto/$p_modulo'
    set Listmap1 [ OMBLIST MAPPINGS ]
    foreach map1 $Listmap1 {
        if { [ string match "TOA*" "$map1" ] } {
            # Se comprueba si es desplegable
            puts "-----------------------------------------------"
            set p_despleg [OMBRETRIEVE MAPPING '$map1' GET PROPERTIES (DEPLOYABLE)]
            if {$p_despleg == "true"} {
                puts " Desplegando: $map1"
                OMBCREATE TRANSIENT DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1' \
                    ADD ACTION 'DEPLOY_MAPPING_$map1' SET PROPERTIES (OPERATION) \
                    VALUES ('REPLACE') SET REFERENCE MAPPING \
                    '$map1'
                OMBDEPLOY DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1'
                OMBDROP DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1'
                OMBCOMMIT
            } else {
                puts "$map1 no desplegable"
            }
            # Fin if p_despleg = true
            # Se pone una linea en blanco
            puts "."
            puts "."
        } elseif { [ string match "TOH*" "$map1" ] } {
            # Se comprueba si es desplegable
            puts "-----------------------------------------------"
            set p_despleg [OMBRETRIEVE MAPPING '$map1' GET PROPERTIES (DEPLOYABLE)]
            if {$p_despleg == "true"} {
                puts " Desplegando: $map1"
                OMBCREATE TRANSIENT DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1' \
                    ADD ACTION 'DEPLOY_MAPPING_$map1' SET PROPERTIES (OPERATION) \
                    VALUES ('REPLACE') SET REFERENCE MAPPING \
                    '$map1'
                OMBDEPLOY DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1'
                OMBDROP DEPLOYMENT_ACTION_PLAN 'DEPLOY_PLAN_MAPPING_$map1'
                OMBCOMMIT
            } else {
                puts "$map1 no desplegable"
            }
            # Fin if p_despleg = true
            # Se pone una linea en blanco
            puts "."
            puts "."
        } else {
            puts "$map1 no desplegable"
            puts "."
            puts "."
        }
    }
    
    puts "-----------------------------------------------"
    puts "Fin proc_desplegar_TOH_M $p_proyecto $p_modulo"
}
# Fin proc_desplegar_TOH_M


proc renombra_atributos_outgrp_join {p_map p_join p_fichero} {
    # Nombre:          renombra_atributos_outgrp_join.
    
    # Parametros:      p_map: Nombre del mapeo, ej, TOH_U21_TACA_PLAZA_M.
    #                  p_join: Nombre de la join cuyos grupos de salida queremos formatear, ej, JN_OUTER_SK
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.log", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    
    # Descripcion: El contexto tiene que estar situado donde el mapeo, es decir,
    #              antes de ejecutar el script hay que haber ejecutado OMBCC '/UXXIDW/XXX_XDS'.
    #              Este procedimiento copia en el fichero indicado las sentencias
    #              ALTER a lanzar desde la ventana de comandos para cambiar
    #              los nombres de los atributos de salida de un mapeo con la notacion:
    #              GRP_ATRIBUTO. Luego hay que repasarlo para comprobar que las columnas
    #              no exceden el tamaño y si tiene sentido cambiar el nombre a las columnas
    #              antes de lanzar los alter: Si una columna pasa por varias JOIN, no es necesario
    #              poner el grupo de entrada de cada JOIN, con el de la primera para saber de
    #              qué tabla procede es suficiente.
    #
    
    # Archivo de log de la exportacion general
    puts "Comienzo renombra_atributos_outgrp_join $p_map $p_join $p_fichero"
    
    # Se abre un nuevo fichero para escribir, borrando el que ya existiera
    set v_outfile [ open "$p_fichero" w ]
    
    # Modificar si el operador tiene mas de un grupo de salida
    set groupName [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET OUTPUT GROUPS ]
    
    # Cambiamos los nombres de columnas de salida, lanzar una vez creado la nueva join en las ordenes anteriores:
    set colList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' GET ATTRIBUTES ]
    foreach colName $colList {
        set v_ref_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (EXPRESSION) ]
        # Se construye el nuevo nombre de la columna como GRUPO_ATRIBUTO al que hace referencia
        regsub -all {\.} $v_ref_col _ v_new_colName
        
        # Comprobamos que el nuevo nombre de la columna no exceda el tamaño de 30 caracteres máximo
        if { [ string length $v_new_colName ] > 30 } {
            puts $v_outfile "# Revisar la columna $v_ref_col, el nombre $v_new_colName excede el tamaño"
        } else {
            puts $v_outfile "OMBALTER MAPPING '$p_map' MODIFY \\"
            puts $v_outfile "  ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join' \\"
            puts $v_outfile "  RENAME TO '$v_new_colName'"
        }
    }
    # foreach colName para los atributos de salida
    puts $v_outfile "puts Proceso_terminado"
    
    close $v_outfile
    
    puts "Fin renombra_atributos_outgrp_join $p_map $p_join $p_fichero"
    
}
# Fin renombra_atributos_outgrp_join

proc renombra_atributos_outcon_join {p_map p_join p_fichero} {
    # Nombre:          renombra_atributos_outcon_join.
    
    # Parametros:      p_map: Nombre del mapeo, ej, TOH_U21_TACA_PLAZA_M.
    #                  p_join: Nombre de la join cuyos grupos de salida queremos formatear, ej, JN_OUTER_SK
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.log", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    
    # Descripcion: El contexto tiene que estar situado donde el mapeo, es decir,
    #              antes de ejecutar el script hay que haber ejecutado OMBCC '/UXXIDW/XXX_XDS'.
    #              Este procedimiento copia en el fichero indicado las sentencias
    #              ALTER a lanzar desde la ventana de comandos para cambiar
    #              los nombres de los atributos conectados a los atributos de salida
    #              del join, para ponerles el mismo nombre. Luego hay que repasarlo
    #              para comprobar que tiene sentido cambiar el nombre a las columnas
    #              antes de lanzar los alter: Si el atributo del JOIN está conectado
    #              a la tabla que se carga no tiene sentido cambiar el nombre de la
    #              columna de la tabla.
    #
    
    # Archivo de log de la exportacion general
    puts "Comienzo renombra_atributos_outcon_join $p_map $p_join $p_fichero"
    
    # Se abre un nuevo fichero para escribir, borrando el que ya existiera
    set v_outfile [ open "$p_fichero" w ]
    
    # Modificar si el operador tiene mas de un grupo de salida
    set groupList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET OUTPUT GROUPS ]
    
    foreach groupName $groupList {
    # Cambiamos los nombres de columnas de salida, lanzar una vez creado la nueva join en las ordenes anteriores:
    set colList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' GET ATTRIBUTES ]
    foreach colName $colList {

        set opList [ OMBRETRIEVE MAPPING '$p_map' GET OPERATORS CONNECTED FROM ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join']
        foreach op $opList {
            set grpList [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GET GROUPS CONNECTED FROM ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join']
            foreach grp $grpList {
                set attrList [OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GROUP '$grp' GET ATTRIBUTES CONNECTED FROM ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join']
                foreach attr $attrList {
                    # puts "$op.$grp.$attr"
                    puts $v_outfile "OMBALTER MAPPING '$p_map' MODIFY ATTRIBUTE '$attr' \\"
                    puts $v_outfile "  OF GROUP '$grp' OF OPERATOR '$op' RENAME TO '$colName'"
                }
            }
            # foreach grp
        }
        # foreach op
    }
    # foreach colName para los atributos de salida
    }
    # foreach groupName
    
    puts $v_outfile "puts Proceso_terminado"
    
    close $v_outfile
    
    puts "Fin renombra_atributos_outcon_join $p_map $p_join $p_fichero"
    
}
# Fin renombra_atributos_outcon_join

proc copia_ingrp_join {p_map p_join p_join_new p_fichero} {
    # Nombre:          copia_ingrp_join.
    
    # Parametros:      p_map: Nombre del mapeo, ej, TOH_U21_TACA_PLAZA_M.
    #                  p_join: Nombre de la join cuyos grupos de entrada queremos copiar, ej, JN_OLD
    #                  p_join_new: Nombre de la join que vamos a crear copiando la de entrada, ej, JN_NEW
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.tcl", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    
    # Descripcion: El contexto tiene que estar situado donde el mapeo, es decir,
    #              antes de ejecutar el script hay que haber ejecutado OMBCC '/UXXIDW/XXX_XDS'.
    #              Este procedimiento copia en el fichero indicado las sentencias
    #              ALTER a lanzar desde la ventana de comandos para copiar
    #              todos los grupos de entrada de un operador tipo JOIN. Se puede personalizar
    #              para otros tipos de operadores.
    #              Como por defecto al crear el JN se crean dos grupos, INGRP1 e INGRP2,
    #              cuando acaba de crearlos los borra. Si se utiliza para otro tipo de operador
    #          habrá que repasar esto.
    #              Está personalizado para no incluir atributos de entrada que no estén conectados, se
    #              puede eliminar esto.
    #
    
    # Archivo de log de la exportacion general
    puts "Comienzo copia_ingrp_join $p_map $p_join $p_join_new $p_fichero"
    
    # Se abre un nuevo fichero para escribir, borrando el que ya existiera
    set v_outfile [ open "$p_fichero" w ]
    
    puts $v_outfile "OMBALTER MAPPING '$p_map' ADD JOINER OPERATOR '$p_join_new'"
    set groupList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GET INPUT GROUPS ]
    foreach groupName $groupList {
        puts $v_outfile "OMBALTER MAPPING '$p_map'  ADD INPUT GROUP '$groupName' OF OPERATOR '$p_join_new'"
        set colList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' GET ATTRIBUTES ]
        foreach colName $colList {
            set v_conectado [ OMBRETRIEVE MAPPING '$p_map' GET OPERATORS CONNECTED TO ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join' ]
            # Si queremos copiar todos los atributos de entrada, aunque no estén conectados, descomentar
            # la siguiente linea
            # set v_conectado P
            if { $v_conectado == "" } {
                # No sacamos el atributo
                puts $v_outfile "# Atributo $colName del grupo $groupName no conectado"
            } else {
            
                set v_tip_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (DATATYPE) ]
        if { $v_tip_col == "VARCHAR2" } {
            set v_long_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (LENGTH) ]
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new' \\"
            puts $v_outfile "  SET PROPERTIES (DATATYPE, LENGTH) VALUES ('$v_tip_col',$v_long_col)"
        } elseif { $v_tip_col == "CHAR" } {
            set v_long_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (LENGTH) ]
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new' \\"
            puts $v_outfile "  SET PROPERTIES (DATATYPE, LENGTH) VALUES ('$v_tip_col',$v_long_col)"
        } elseif { $v_tip_col == "NUMBER" } {
            set v_prec_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (PRECISION) ]
            set v_scale_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (SCALE) ]
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new' \\"
            puts $v_outfile "  SET PROPERTIES (DATATYPE, PRECISION, SCALE) VALUES ('$v_tip_col',$v_prec_col,$v_scale_col)"
        } elseif { $v_tip_col == "FLOAT" } {
            set v_prec_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (PRECISION) ]
            set v_scale_col [ OMBRETRIEVE TABLE '$p_ruta_ori/$p_tabla_ori' COLUMN '$colName' GET PROPERTIES (SCALE) ]
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new'"
            puts $v_outfile "  SET PROPERTIES (DATATYPE, PRECISION, SCALE) VALUES ('$v_tip_col',$v_prec_col,$v_scale_col)"
        } elseif { $v_tip_col == "INTEGER" } {
            set v_prec_col [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_join' GROUP '$groupName' ATTRIBUTE '$colName' GET PROPERTIES (PRECISION) ]
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new' \\"
            puts $v_outfile "  SET PROPERTIES (DATATYPE, PRECISION) VALUES ('$v_tip_col',$v_prec_col)"
        } else {
            puts $v_outfile "# Revisar si este tipo de dato es correcto crearlo asi o hay que hacer mas elseif y quitar este comentario al lanzar el script de creacion"
            puts $v_outfile "OMBALTER MAPPING '$p_map' \\"
            puts $v_outfile "  ADD ATTRIBUTE '$colName' OF GROUP '$groupName' OF OPERATOR '$p_join_new' \\"
            puts $v_outfile "  SET PROPERTIES (DATATYPE) VALUES ('$v_tip_col')"
        }
        # if v_tip_col tipo de dato
            }
            # if v_conectado
        }
        # foreach colName
    }
    # foreach groupName
    
    puts $v_outfile "OMBALTER MAPPING '$p_map' DELETE GROUP 'INGRP1' OF OPERATOR '$p_join_new'"
    puts $v_outfile "OMBALTER MAPPING '$p_map' DELETE GROUP 'INGRP2' OF OPERATOR '$p_join_new'"
    
    puts $v_outfile "puts Proceso_terminado"
    
    close $v_outfile
    
    puts "Fin copia_ingrp_join $p_map $p_join $p_join_new $p_fichero"
    
}
# Fin copia_ingrp_join


proc borra_referencias_coleccion {p_proyecto p_coleccion} {
    # Nombre:          borra_referencias_coleccion.
    
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_coleccion: Nombre de la coleccion a exportar, ej, I308562_becas
    
    # Descripcion: Obtiene el listado de objetos que conforman la coleccion
    #              borrando todas las referencias.
    #
    
    # Archivo de log de la exportacion general
    puts "Comienzo borra_referencias_coleccion $p_proyecto $p_coleccion"
    
    OMBCC '/'
    
    # Obtengo la lista de objetos de la coleccion
    set objList [ OMBRETRIEVE COLLECTION '/$p_proyecto/$p_coleccion' GET ALL REFERENCES ]
    
    OMBCC '/$p_proyecto'
    
    foreach objTN $objList {
        
        # El listado anterior devuelve un string con el formato: TIPO /ruta/OBJETO,
        # en primer lugar lo descompongo en una lista en vez de string:
        set objPar [ split "$objTN" ]
        # El primer elemento de la lista, es el tipo de objeto
        set v_objTipo [ lindex $objPar 0 ]
        set v_objRuta [ lindex $objPar 1 ]
        
        puts "Se borra $v_objTipo $v_objRuta"
        
        OMBALTER COLLECTION '$p_coleccion' REMOVE REFERENCE TO $v_objTipo '$v_objRuta'
        
        
        puts "."
        puts "."
        puts "-----------------------------------------------"
    }
    # foreach objTN
    
    OMBCOMMIT
    
    puts "Fin borra_referencias_coleccion $p_proyecto $p_coleccion"

}
# proc_borra_referencias_coleccion

proc proc_renombra_dim_cubo { p_proyecto p_modulo p_cubo } {
    # Nombre:          proc_renombra_dim_cubo.
    
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentra el cubo
    #                  p_cubo: Nombre del cubo. Supone que la tabla asociada
    #                          al cubo se llama igual.
    
    # Descripcion: Obtiene el listado de dimensiones asociadas al cubo,
    #              busca el nombre de la columna asociada y busca su FK.
    #              Si existe la FK sobre la columna, renombra la DIMENSION_USE
    #              como la FK.
    #
    
    puts "Se inicia proc_renombra_dim_cubo $p_proyecto $p_modulo $p_cubo"
    OMBCC '/$p_proyecto/$p_modulo'
    # Se obtiene el listado de dimensiones utilizadas en el cubo, con el nombre asociado
    set dimList [ OMBRETRIEVE CUBE '$p_cubo' GET DIMENSION_USES ]
    # Se obtiene el listado de FK de la tabla asociada al cubo
    set FKList [ OMBRETRIEVE TABLE '$p_cubo' GET FOREIGN_KEYS ]
    # Mejora pendiente: construir aqui una lista con las columnas asociadas a la FK
    # en el mismo orden que FKList, para no repetir el OMBRETRIEVE TABLE por DIMENSION_USE
    
    foreach v_dimCubo $dimList {
        # Se busca el nombre de la columna asociada a la dimension
        set v_dim_col [ OMBRETRIEVE CUBE '$p_cubo' DIMENSION_USE '$v_dimCubo' GET IMPLEMENTED_OBJECT ]
        # Vamos al listado de FK y buscamos si hay una sobre esa columna
        set v_control 0
        foreach v_FK $FKList {
            set v_FK_col [ OMBRETRIEVE TABLE '$p_cubo' FOREIGN_KEY '$v_FK' GET COLUMNS ]
            if { $v_FK_col == $v_dim_col } {
                # Si la columna tiene una FK, comprobamos si la FK se nombra diferente que la DIMENSION_USE del cubo
                if { $v_dimCubo != $v_FK } {
                    set v_control 1
                    set v_dimCubo_new $v_FK
                }
            }
        }
        # foreach v_FK
        
        # Si hemos encontrado la FK asociada, cambiamos el nombre de la DIMENSION_USE para que se llame igual
        if { $v_control > 0 } {
            OMBALTER CUBE '$p_cubo' MODIFY DIMENSION_USE '$v_dimCubo' RENAME TO '$v_dimCubo_new'
        }
    }
    # foreach v_dimCubo
    
    puts "Finaliza proc_renombra_dim_cubo $p_proyecto $p_modulo $p_cubo"
}
# proc_renombra_dim_cubo


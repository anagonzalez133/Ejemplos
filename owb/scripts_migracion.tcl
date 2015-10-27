####### Modulo con los procedimientos a lanzar en la migracion de 9.2 a 10gR2  #######
####### Autor:   AnaGH                                                         #######
####### Version: 2.0                                                           #######
####### Fecha:   2030522                                                       #######

####### Cometido                           #######
#
# Proporciona procedimientos que formatean los objetos
# para la version 10gR2
#
# Los procedimientos estan hechos para ejecutarse
# desde el nodo del arbol de proyectos donde
# comienza el proyecto que queremos desplegar

####### Componentes                        #######

# revisa_jerarquias             Version 1.0
# revisa_indices                Version 1.0
# revisa_indices_tablespaces    Version 2.0
# owb_set_maxerrors_ansi        Version 1.0
# modif_tablespace              Version 1.0
# conexiones_operador           Version 1.0
# genera_alter_process_flows    Version 1.0
# proc_cambia_location          Version 1.0
# revisa_secuencias             Version 2.0



proc revisa_jerarquias { p_proyecto p_modulo } {
    # Nombre:          revisa_jerarquias.
    
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder, ej: UXXIDW.
    #                  p_modulo: Modulo donde se encuentran las dimensiones, ej: UXXIRRHH_DDS
    
    # Descripcion: Recoge todas las dimensiones del modulo y repasa las jerarquias.
    #              Si la jerarquia tiene un unico nivel, la borra.
    
    
    puts "Comienzo revisa_jerarquias $p_proyecto $p_modulo "
    OMBCC '/$p_proyecto/$p_modulo'
    puts "Listado de dimensiones de: $p_modulo"
    set dimList [ OMBLIST DIMENSIONS ]
    foreach dimName $dimList {
        puts "."
        puts "Modificando dimension $dimName"
        # Obtenemos el listado de jerarquias
        set jerarqList [ OMBRETRIEVE DIMENSION '$dimName' GET HIERARCHIES ]
        foreach jerarqName $jerarqList {
            puts "Revisando jerarquia $jerarqName"
            set v_lev_num 0
            # Obtenemos los niveles que forman la jerarquia
            set nivelList [ OMBRETRIEVE DIMENSION '$dimName' HIERARCHY '$jerarqName' GET REF LEVELS ]
            foreach nivelName $nivelList {
                incr v_lev_num
            }
            # foreach nivelName
            if { $v_lev_num < 2 } {
                # Jerarquia de un nivel, la borramos
                OMBALTER DIMENSION '$dimName' DELETE HIERARCHY '$jerarqName'
            }
            # if v_lev_num = 1
        }
        # foreach jerarqName
        puts "Dimension $dimName revisada"
        puts "."
        puts "."
        puts "-----------------------------------------------"
    }
    # foreach dimName
    OMBCC '/$p_proyecto'
    puts "Fin revisa_jerarquias $p_proyecto $p_modulo"
    puts "Revisar el log y hacer commit"
}
# Fin revisa_jerarquias

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
            puts "."
            puts "Modificando tabla $tabName"
            # Las PK e Indices normales nos aseguramos que se
            # despliegan en el tablespace adecuado
            set pkList [OMBRETRIEVE TABLE '$tabName' GET PRIMARY_KEY]
            foreach pkName $pkList {
                puts "Modificando PK $pkName"
                OMBALTER TABLE '$tabName' MODIFY PRIMARY_KEY '$pkName' \
                    SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablespace', 'true')
            }
            # foreach pkName
            set idxList [OMBRETRIEVE TABLE '$tabName' GET INDEXES]
            foreach idxName $idxList {
                puts "Modificando IDX $idxName"
                OMBALTER TABLE '$tabName' MODIFY INDEX '$idxName' \
                    SET PROPERTIES (TABLESPACE) VALUES ('$p_tablespace')
            }
            # foreach idxName
            
            # Los indices de tipo UK los cambiamos por PK
            # Finalmente no se cambian porque al borrar el UK se pierden
            # las referencias en las tablas asociadas a cubos, hay
            # que cambiarlo a mano.
            set ukList [OMBRETRIEVE TABLE '$tabName' GET UNIQUE_KEYS]
            foreach ukName $ukList {
                # puts "Cambia UK por PK $ukName"
                # Obtenemos las columnas que forman la UK
                # set idx_col_List [OMBRETRIEVE TABLE '$tabName' UNIQUE_KEY \
                #    '$ukName' GET COLUMNS]
                # Almacenamos en una variable las columnas con el formato
                # adecuado para la sentencia de creacion de la PRIMARY_KEY
                # set v_i 1
                # foreach idx_col_Name $idx_col_List {
                #     if {$v_i == 1} {
                #        set v_cols '$idx_col_Name'
                #     } else {
                #        set v_cols "$v_cols, '$idx_col_Name'"
                #     }
                    # if v_i = 1
                #     incr v_i
                # }
                # foreach idx_col_Name
                # OMBALTER TABLE '$tabName' DELETE UNIQUE_KEY '$ukName'
                # OMBALTER TABLE '$tabName' ADD PRIMARY_KEY '$ukName' \
                #     SET REF COLUMNS ($v_cols)
                # OMBALTER TABLE '$tabName' MODIFY PRIMARY_KEY '$ukName' \
                #     SET PROPERTIES (DEPLOYABLE, INDEX_TABLESPACE) \
                #    VALUES ('true', '$p_tablespace')
                puts "Modificando UK $ukName"
                OMBALTER TABLE '$tabName' MODIFY UNIQUE_KEY '$ukName' \
                     SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablespace', 'true')
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
        puts "-----------------------------------------------"

    }
    # foreach tabName
    OMBCC '/$p_proyecto'
    OMBCOMMIT
    puts "Fin revisa_indices $p_proyecto $p_modulo $p_tablespace"
}
# Fin revisa_indices

proc revisa_indices_tablespaces {p_proyecto p_modulo p_tablesp_tab p_tablesp_idx} {
    # Nombre:          revisa_indices_tablespaces.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran las tablas, ej: UXXIRRHH_DDS
    #                  p_tablesp_tab: Tablespace para ubicar las tablas (DDS_UXXIRRHH)
    #                  p_tablesp_idx: Tablespace para ubicar los indices (UXXIDW_INDX)
    # Descripcion: Recoge todas las tablas y vistas materializadas del modulo, y si la
    #              tabla es desplegable:
    #              1 - Actualiza el tablespace de la tabla
    #              2 - Comprueba si la tabla está particionada, en caso afirmativo, actualiza
    #                  el tablespace de las particiones
    #              3 - Comprueba si la tabla tiene Primary Key definida, en caso afirmativo
    #                  comprueba que el check de Using Index está marcado y el tablespace para
    #                  el índice.
    #              4 - Comprueba si la tabla tiene Unique Key definida, en caso afirmativo
    #                  comprueba que el check de Using Index está marcado y el tablespace para
    #                  el índice.
    #              5 - Comprueba los indices normales (serán los tipos bitmap) y les asigna el
    #                  el tablespace correcto.
    #              6 - Comprueba que las Foreign Key estén como NO DESPLEGABLES.

    puts "Comienzo revisa_indices_tablespaces $p_proyecto $p_modulo $p_tablesp_tab $p_tablesp_idx"
    OMBCC '/$p_proyecto/$p_modulo'
    
    # Calculamos el alias del módulo para obtener el nombre de los tablespaces OA_ALIAS y OH_ALIAS
    set v_alias [ string range $p_modulo 0 [ expr { [ string first _ $p_modulo ] - 1 } ] ]
    set v_oa "OA_$v_alias"
    set v_oh "OH_$v_alias"
    
    puts "Listado de tablas de: $p_modulo"
    
    set tabList [ OMBLIST TABLES ]
    foreach tabName $tabList {
        set p_despleg [OMBRETRIEVE TABLE '$tabName' GET PROPERTIES (DEPLOYABLE)]
        if {$p_despleg == "true"} {
            puts "."
            puts "Modificando tabla $tabName"
            # Comprobamos si se trata de una TOA o una TOH
            if { [ string match TOA* $tabName ] == 1 } {
                set v_tablesp_tab $v_oa
            } elseif { [ string match TOH* $tabName ] == 1 } {
                set v_tablesp_tab $v_oh
            } else {
                set v_tablesp_tab $p_tablesp_tab
            }
            # if TOA o TOH
            OMBALTER TABLE '$tabName' SET PROPERTIES (TABLESPACE) VALUES ('$v_tablesp_tab')
            set v_PartList [ OMBRETRIEVE TABLE '$tabName' GET PARTITIONS ]
            foreach v_Part $v_PartList {
                OMBALTER TABLE '$tabName' MODIFY PARTITION '$v_Part' SET PROPERTIES (TABLESPACE) VALUES ('$v_tablesp_tab')
            }
            
            if { [ llength $v_PartList ] != 0 } {
                OMBALTER TABLE '$tabName' SET PROPERTIES (PARTITION_TABLESPACE_LIST, OVERFLOW) VALUES ('', '')
            }
            # Nos aseguramos que la Primary Key se despliegue en el tablespace adecuado
            set pkList [OMBRETRIEVE TABLE '$tabName' GET PRIMARY_KEY]
            foreach pkName $pkList {
                puts "Modificando PK $pkName"
                OMBALTER TABLE '$tabName' MODIFY PRIMARY_KEY '$pkName' \
                    SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablesp_idx', 'true')
            }
            # foreach pkName
            
            # Nos aseguramos que los Unique Key se desplieguen en el tablespace adecuado
            set ukList [ OMBRETRIEVE TABLE '$tabName' GET UNIQUE_KEYS ]
            foreach ukName $ukList {
                puts "Modificando UK $ukName"
                OMBALTER TABLE '$tabName' MODIFY UNIQUE_KEY '$ukName' \
                     SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablesp_idx', 'true')
            }
            # foreach ukName

            # A continuación revisamos los índices normales. Si la tabla
            # está particionada hay que definir el tablespace de cada partición
            set idxList [OMBRETRIEVE TABLE '$tabName' GET INDEXES]
            foreach idxName $idxList {
                puts "Modificando IDX $idxName"
                if { [ llength $v_PartList ] == 0 } {
                    OMBALTER TABLE '$tabName' MODIFY INDEX '$idxName' \
                        SET PROPERTIES (TABLESPACE) VALUES ('$p_idx_tablespace')
                } else {
                    OMBALTER TABLE '$tabName' MODIFY INDEX '$idxName' \
                        SET PROPERTIES (TABLESPACE, PARTITION_TABLESPACE_LIST, OVERFLOW) \
                        VALUES ('$p_tablesp_idx', '$p_tablesp_idx', '$p_tablesp_idx')
                }
                # [ llength $v_partList ] == 0
            }
            # foreach idxName
            
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
        puts "-----------------------------------------------"

    }
    # foreach tabName
    
    # Repetimos el proceso para vistas materializadas
    set mvList [ OMBLIST MATERIALIZED_VIEWS ]
        foreach mvName $mvList {
            set p_despleg [OMBRETRIEVE MATERIALIZED_VIEW '$mvName' GET PROPERTIES (DEPLOYABLE)]
            if {$p_despleg == "true"} {
                puts "."
                puts "Modificando vista materializada $mvName"
                OMBALTER MATERIALIZED_VIEW '$mvName' SET PROPERTIES (TABLESPACE) VALUES ('$p_tablesp_tab')
                set v_PartList [ OMBRETRIEVE MATERIALIZED_VIEW '$mvName' GET PARTITIONS ]
                foreach v_Part $v_PartList {
                    OMBALTER MATERIALIZED_VIEW '$mvName'  MODIFY PARTITION '$v_Part' SET PROPERTIES (TABLESPACE) VALUES ('$p_tablesp_tab')
                }
                # Nos aseguramos que la Primary Key se despliegue en el tablespace adecuado
                set pkList [OMBRETRIEVE MATERIALIZED_VIEW '$mvName' GET PRIMARY_KEY]
                foreach pkName $pkList {
                    puts "Modificando PK $pkName"
                    OMBALTER MATERIALIZED_VIEW '$mvName' MODIFY PRIMARY_KEY '$pkName' \
                        SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablesp_idx', 'true')
                }
                # foreach pkName
                
                # Nos aseguramos que los Unique Key se desplieguen en el tablespace adecuado
                set ukList [ OMBRETRIEVE MATERIALIZED_VIEW '$mvName' GET UNIQUE_KEYS ]
                foreach ukName $ukList {
                    puts "Modificando UK $ukName"
                    OMBALTER MATERIALIZED_VIEW '$mvName' MODIFY UNIQUE_KEY '$ukName' \
                         SET PROPERTIES (INDEX_TABLESPACE, USING_INDEX) VALUES ('$p_tablesp_idx', 'true')
                }
                # foreach ukName
    
                # A continuación revisamos los índices normales. Si la tabla
                # está particionada hay que definir el tablespace de cada partición
                set idxList [OMBRETRIEVE MATERIALIZED_VIEW '$mvName' GET INDEXES]
                foreach idxName $idxList {
                    puts "Modificando IDX $idxName"
                    if { [ llength $v_PartList ] == 0 } {
                        OMBALTER MATERIALIZED_VIEW '$mvName' MODIFY INDEX '$idxName' \
                            SET PROPERTIES (TABLESPACE) VALUES ('$p_tablesp_idx')
                    } else {
                        OMBALTER MATERIALIZED_VIEW '$mvName' MODIFY INDEX '$idxName' \
                            SET PROPERTIES (TABLESPACE, PARTITION_TABLESPACE_LIST, OVERFLOW) \
                            VALUES ('$p_tablesp_idx', '$p_tablesp_idx', '$p_tablesp_idx')
                    }
                    # [ llength $v_partList ] == 0
                }
                # foreach idxName
                
            } else {
                puts "Vista materializada $mvName no desplegable"
            }
            # end if p_despleg = true
            puts "."
            puts "."
            puts "-----------------------------------------------"
    
        }
    # foreach mvName
    
    OMBCOMMIT
    puts "Fin revisa_indices_tablespaces $p_proyecto $p_modulo $p_tablesp_tab $p_tablesp_idx"
}
# Fin revisa_indices_tablespaces

proc owb_set_maxerrors_ansi {p_proyecto} {

    # Nombre:          owb_set_maxerrors_ansi.

    # Parametros:
    #                  p_proyecto, nombre del proyecto que se va a reconfigurar. p.e.: UXXIDW

    # Descripcion: Recorre todos los modulos del proyecto y repasa los mapeos
    #              poniendo a 0 el numero maximo de errores y desmarcando el check de ANSI_SQL.


    puts "Comienzo owb_set_maxerrors_ansi $p_proyecto"
    OMBCC '/$p_proyecto'
    set Listmod1 [ OMBLIST ORACLE_MODULES ]
    puts "Conectado al proyecto : $p_proyecto"
    foreach mod1 $Listmod1 {
        puts "Listado de mapeos de: $mod1"
        OMBCC '$mod1'
      set mapList [ OMBLIST MAPPINGS ]
      foreach mapName $mapList {
        puts "Modificando mapping $mapName"
        OMBALTER MAPPING '$mapName' SET PROPERTIES (MAXIMUM_NUMBER_OF_ERRORS, ANSI_SQL_SYNTAX) VALUES (0, 0)
       }
           OMBCC '/$p_proyecto'
        puts "."
        puts "."
        puts "-----------------------------------------------"
    }
    OMBCOMMIT
    puts "Fin owb_set_maxerrors_ansi $p_proyecto"
}
# Fin owb_set_maxerrors_ansi


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

proc conexiones_operador { p_map p_op p_fichero } {

    # Nombre:          conexiones_operador
    # Parametros:      p_map: Mapeo con la funcion a sustituir, ej TOI_CONCEPTO_M.
    #                  p_op: Operador a reconciliar, ej SUBSTR_2
    #                  p_fichero: Fichero donde guardar las ordenes de alter,
    #                             ej, "C:\\temp\\prueba.log", las dobles comillas al invocar
    #                             son importantes si la ruta del fichero tiene espacios en blanco
    # Descripcion:
    #                  El contexto (OMBCC) ya esta situado donde el mapeo.
    #                  Este proceso lista en un fichero todas las conexiones del operador para
    #                  que una vez reconciliado, si se pierden conexiones, se puedan restablecer
    #                  editando el fichero y actualizando el nombre de grupos/atributos del
    #                  operador reconciliado.

    # Se abre el fichero para escribir, creandolo si no existe, y truncando el que habia si existe
    set v_outfile [ open "$p_fichero" w ]
    
    # Obtengo cada uno de los grupos/atributos del operador.
    set fungrpList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_op' GET GROUPS ]
    foreach fungrpName $fungrpList {
        set funattList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$p_op' GROUP '$fungrpName' GET ATTRIBUTES ]
        foreach funattName $funattList {

            # Para cada atributo, busco el operador, grupo y atributo conectado como entrada al atributo
            set opList [ OMBRETRIEVE MAPPING '$p_map' GET OPERATORS CONNECTED \
                         TO ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op' ]
            foreach op $opList {
            
                # A un atributo de un operador solo puede entrar una conexion,
                # pero para mostrar el OMBALTER solo cuando haya conexion de entrada,
                # se ha metido la orden dentro de un foreach al que entrara solo si hay datos
                # en opList.
                set grp [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GET GROUPS CONNECTED \
                          TO ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op' ]
                set attr [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GROUP '$grp' \
                           GET ATTRIBUTES CONNECTED TO ATTRIBUTE '$funattName' OF GROUP '$fungrpName' \
                           OF OPERATOR '$p_op' ]

                # Si es copiar el operador, se utiliza esta orden
                # set v_orden "OMBALTER MAPPING '$p_map'"
                # set v_orden "$v_orden ADD CONNECTION FROM ATTRIBUTE '$attr' OF GROUP '$grp' OF OPERATOR '$op'"
                # set v_orden "$v_orden TO ATTRIBUTE '$funattName' OF GROUP '$fungrpName'"
                # set v_orden "$v_orden OF OPERATOR '$p_op'"
                
                # Si es crear un operador nuevo a partir del existente, vamos agregando atributos
                set v_orden "OMBALTER MAPPING '$p_map'"
                set v_orden "$v_orden ADD CONNECTION FROM ATTRIBUTE '$attr' OF GROUP '$grp' OF OPERATOR '$op'"
                set v_orden "$v_orden TO ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op'"
                # Se añade el atributo como atributo nuevo al grupo, si se quiere tener ya el atributo
                # en el grupo, descomentar la línea de arriba y comentar esta:
                # set v_orden "$v_orden TO GROUP '$fungrpName' OF OPERATOR '$p_op'"
                puts $v_outfile $v_orden
            }
            # foreach op entrada

            # Busco el operador, grupo y atributo salida del atributo de la funcion
            set opList [ OMBRETRIEVE MAPPING '$p_map' GET OPERATORS CONNECTED \
                         FROM ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op' ]
            foreach op $opList {
                set grpList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GET GROUPS CONNECTED \
                              FROM ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op' ]
                foreach grp $grpList {
                    set attrList [ OMBRETRIEVE MAPPING '$p_map' OPERATOR '$op' GROUP '$grp' \
                                   GET ATTRIBUTES CONNECTED FROM ATTRIBUTE '$funattName' \
                                   OF GROUP '$fungrpName' OF OPERATOR '$p_op' ]
                    foreach attr $attrList {
                        # Ya tenemos uno de los atributos conectados al atributo de salida
                        set v_orden "OMBALTER MAPPING '$p_map'"
                        set v_orden "$v_orden ADD CONNECTION FROM ATTRIBUTE '$funattName' OF GROUP '$fungrpName' OF OPERATOR '$p_op'"
                        set v_orden "$v_orden TO ATTRIBUTE '$attr' OF GROUP '$grp'"
                        set v_orden "$v_orden OF OPERATOR '$op'"
                        puts $v_outfile $v_orden
                    }
                    # foreach attr
                }
                # foreach grp
            }
            # foreach op salida

        }
        # foreach funattName

    }
    # foreach fungrpName
    puts $v_outfile "puts Proceso_terminado"
    close $v_outfile
    puts "Fin conexiones_operador $p_map $p_op $p_fichero"
}
# conexiones_operador

proc genera_alter_process_flows {p_proyecto p_proc_module p_proc_package p_fichero} {
    # Nombre:          genera_alter_process_flows.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_proc_module: Modulo que agrupa los paquetes de process_flow, ej, CARGA
    #                  p_proc_package: Paquete que agrupa los process_flow a revisar, ej, GENERAL
    # Descripcion: Recoge todos los process flows del paquete pasado por parametros y revisa
    #              las transiciones de salida de los objetos tipo START, FORK y AND.
    #              Si la transicion tiene una condicion, la borra y la vuelve a crear
    #              sin condicion. Tambien revisa si hay algun procedimiento en el process.
    #              Si es asi, escribe en el fichero de salida una orden para cambiar su
    #              ubicacion de despliegue segun el valor de una variable, v_location,
    #              que habra que definir cuando se lance el alter.
    #              v_location NO HA SIDO DEFINIDA para que si dentro del mismo paquete
    #              hay process flow con diferentes localizaciones de despliegue, EDITEMOS
    #              el fichero de salida añadiendo el valor de v_location adecuado y ordenemos
    #              los alter segun ese valor (primero todos los de DDS_SIGMA_LOC,
    #              luego los DDS_SOROLLA_LOC, etc).
    puts "Comienzo revisa_proces_flows $p_proyecto $p_proc_module $p_proc_package $p_fichero"
    OMBCC '/$p_proyecto/$p_proc_module/$p_proc_package'
    set v_public_path "/$p_proyecto/WB_CUSTOM_TRANS"
    set v_outfile [ open "$p_fichero" a+ ]
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
        
        # Se revisan los procedimientos en el process flow para borrarlos y volver a incluirlos
        set funcList [ OMBRETRIEVE PROCESS_FLOW '$procName' GET TRANSFORMATION ACTIVITIES ]
        foreach funcName $funcList {
            set v_func_ref [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$funcName' GET REF ]
            # Se genera la sentencia de DELETE
            set v_alter "OMBALTER PROCESS_FLOW '$procName' DELETE ACTIVITY '$funcName'"
            puts $v_outfile $v_alter

            # Se genera la sentencia para volver a incluirla
            set v_alter "OMBALTER PROCESS_FLOW '$procName'"
            set v_alter "$v_alter ADD TRANSFORMATION ACTIVITY '$funcName'"
            set v_alter "$v_alter SET REF TRANSFORMATION '$v_func_ref'"
            puts $v_outfile $v_alter
            
            if { [ string match "$v_public_path*" "$v_func_ref" ] } {
                # Genera el alter de la localizacion de despliegue
                set v_alter "OMBALTER PROCESS_FLOW '$procName' MODIFY ACTIVITY '$funcName'"
                set v_alter "$v_alter SET PROPERTIES (DEPLOYED_LOCATION) VALUES ('\$v_location')"
                puts $v_outfile $v_alter
            }
                
            # Se dan los valores iniciales a los parametros
            set parList [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$funcName' \
                GET PARAMETERS ]
            foreach parName $parList {
                set v_parValue [ OMBRETRIEVE PROCESS_FLOW '$procName' ACTIVITY '$funcName' \
                    PARAMETER '$parName' GET PROPERTIES (VALUE) ]
                set v_alter "OMBALTER PROCESS_FLOW '$procName'"
                set v_alter "$v_alter MODIFY TRANSFORMATION ACTIVITY '$funcName'"
                set v_alter "$v_alter MODIFY PARAMETER '$parName'"
                set v_alter "$v_alter SET PROPERTIES (VALUE) VALUES ('$v_parValue')"
                puts $v_outfile $v_alter
            }
            # foreach parName

            # Se crea la conexion de entrada
            set v_in_trans [ OMBRETRIEVE PROCESS_FLOW '$procName' \
                ACTIVITY '$funcName' GET INCOMING_TRANSITIONS ]
            set v_condicion [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_in_trans' \
                GET PROPERTIES (TRANSITION_CONDITION) ]
            set v_in_act [OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_in_trans' \
                GET SOURCE_ACTIVITY]
            if { $v_condicion == "{}" } {
                set v_alter "OMBALTER PROCESS_FLOW '$procName' ADD TRANSITION '$v_in_trans'"
                set v_alter "$v_alter FROM ACTIVITY '$v_in_act' TO '$funcName'"
            } else {
                set v_alter "OMBALTER PROCESS_FLOW '$procName' ADD TRANSITION '$v_in_trans'"
                set v_alter "$v_alter FROM ACTIVITY '$v_in_act' TO '$funcName'"
                set v_alter "$v_alter SET PROPERTIES (TRANSITION_CONDITION) VALUES ('$v_condicion')"
            }
            # if v_condicion nula
            puts $v_outfile $v_alter

            # Se crea la conexion de salida
            set v_out_trans [ OMBRETRIEVE PROCESS_FLOW '$procName' \
                ACTIVITY '$funcName' GET OUTGOING_TRANSITIONS ]
            set v_condicion [ OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_out_trans' \
                GET PROPERTIES (TRANSITION_CONDITION) ]
            set v_out_act [OMBRETRIEVE PROCESS_FLOW '$procName' TRANSITION '$v_out_trans' \
                GET DESTINATION_ACTIVITY]
            set v_alter "OMBALTER PROCESS_FLOW '$procName' ADD TRANSITION '$v_out_trans'"
            set v_alter "$v_alter FROM ACTIVITY '$funcName' TO '$v_out_act'"
            set v_alter "$v_alter SET PROPERTIES (TRANSITION_CONDITION) VALUES ('$v_condicion')"
            puts $v_outfile $v_alter

            puts "."
            puts "."
        }
        # foreach funcName
        
        puts "."
        puts "."
    }
    # foreach procName
    OMBCC '/$p_proyecto'
    OMBCOMMIT
    close $v_outfile
    puts "Fin genera_alter_process_flows $p_proyecto $p_proc_module $p_proc_package $p_fichero"
    puts "-----------------------------------------------"
}
# Fin genera_alter_process_flows

proc proc_cambia_location {p_proyecto p_modulo p_loc_old p_loc_new} {
    # Nombre:          proc_cambia_location.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran los mapeos, ej: UXXIRRHH_ODS
    #                  p_loc_old: LOC_UXXIAC_OLD
    #              p_loc_new: LOC_UXXIAC_NEW
    # Descripcion: Para todos los mapeos TOA y TOH del modulo, busca la propiedad LOCATION
    #          de los operadores de tipo tabla que lo componen y si es igual a la
    #          proporcionada como parametro OLD, se cambia por la proporcionada como NEW.
    #              Si se quiere usar para tablas que se usan como otro tipo de operador
    #          diferente del TABLE (Tablas externas, vistas, operadores de Look - up, etc.)
    #          sera necesario modificar el proceso.
    #
    
    puts "Comienzo proc_cambia_location $p_proyecto $p_modulo $p_loc_old $p_loc_new"
    
    OMBCC '/$p_proyecto/$p_modulo'
    
    set mapList [ OMBLIST MAPPINGS 'TOA.*' ]
    foreach mapName $mapList {
        
        puts "Se revisan los operadores del mapeo $mapName"
        # Obtenemos la lista de operadores tabla del mapeo
        set opList [ OMBRETRIEVE MAPPING '$mapName' GET TABLE OPERATORS ]
        foreach opName $opList {
            set v_op_loc [ OMBRETRIEVE MAPPING '$mapName' OPERATOR '$opName' GET PROPERTIES (DB_LOCATION) ]
            if { "$v_op_loc" == "$p_loc_old" } {
                puts "Hay que cambiar la location para $opName"
                OMBALTER MAPPING '$mapName' MODIFY OPERATOR '$opName' \
                SET PROPERTIES (DB_LOCATION) VALUES ('$p_loc_new')
            }
        }
        # foreach opName
        
        # Se pone una linea en blanco
        puts "."
        puts "."
    }
    # foreach mapName TOA
    
    set mapList [ OMBLIST MAPPINGS 'TOH.*' ]
    foreach mapName $mapList {
        
        puts "Se revisan los operadores del mapeo $mapName"
        # Obtenemos la lista de operadores tabla del mapeo
        set opList [ OMBRETRIEVE MAPPING '$mapName' GET TABLE OPERATORS ]
        foreach opName $opList {
            set v_op_loc [ OMBRETRIEVE MAPPING '$mapName' OPERATOR '$opName' GET PROPERTIES (DB_LOCATION) ]
            if { "$v_op_loc" == "$p_loc_old" } {
                puts "Hay que cambiar la location para $opName"
                OMBALTER MAPPING '$mapName' MODIFY OPERATOR '$opName' \
                SET PROPERTIES (DB_LOCATION) VALUES ('$p_loc_new')
            }
        }
        # foreach opName
        
        # Se pone una linea en blanco
        puts "."
        puts "."
    }
    # foreach mapName TOH
    
    OMBCOMMIT
    
    puts "-----------------------------------------------"
    puts "Fin proc_cambia_location $p_proyecto $p_modulo $p_loc_old $p_loc_new"
}
# proc_cambia_location

proc revisa_secuencias {p_proyecto p_modulo} {
    # Nombre:          revisa_secuencias.
    # Parametros:      p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran las secuencias a revisar, ej: UXXIRRHH_DDS
    # Descripcion: Recoge todas las secuencias del modulo y si la secuencia es
    #              desplegable, fuerza que se inicie en el 1000.

    puts "Comienzo revisa_secuencias $p_proyecto $p_modulo"
    OMBCC '/$p_proyecto/$p_modulo'
    puts "Listado de secuencias de: $p_modulo"
    set seqList [ OMBLIST SEQUENCES ]
    foreach seqName $seqList {
        set p_despleg [OMBRETRIEVE SEQUENCE '$seqName' GET PROPERTIES (DEPLOYABLE)]
        if {$p_despleg == "true"} {
            OMBALTER SEQUENCE '$seqName' SET PROPERTIES (START_WITH) VALUES (1000)
        } else {
            puts "Secuencia $seqName no desplegable"
        }
        # end if p_despleg = true

    }
    # foreach seqName
    OMBCOMMIT
    puts "Fin revisa_secuencias $p_proyecto $p_modulo"
}
# Fin revisa_secuencias

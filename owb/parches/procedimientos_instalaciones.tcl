################################### Componentes ###################################
# pr_crea_coleccion {p_proyecto p_coleccion p_fichero}
# pr_fichero_coleccion {p_proyecto p_coleccion p_ruta}
# pr_obj_desplegable { p_TipoObjeto p_RutaObjeto p_fichero_objetos }
# pr_borra_operadores {p_fichero p_tipo_objeto}
# pr_despliega_objeto {p_tipo_objeto p_ruta_objeto p_accion}
# pr_desplegar_objeto {p_tipo_objeto p_proyecto p_modulo p_objeto p_accion}
# pr_exporta_proyecto {p_proyecto p_ruta}
# pr_exporta_coleccion {p_proyecto p_coleccion p_ruta}
# pr_instala_parche {p_proyecto p_coleccion p_ruta}
# Precondiciones: Para poder ejecutar los procedimientos de este script
#                 tienen que estar cargadas las variables globales que definen
#                 los datos de conexión, rutas locales, etc, así como los
#                 procedimientos base de tratamiento de errores, logs y conexión.
################################### Componentes ###################################

proc pr_crea_coleccion {p_proyecto p_coleccion p_fichero} {
	# Nombre:      pr_crea_coleccion.
	
  # Parametros:  p_proyecto: Proyecto del WarehouseBuilder, ej, UXXIDW.
  #              p_coleccion: Nombre de la coleccion a crear, ej, I308562_BECAS
  #              p_fichero: Fichero en que se encuentran los objetos a incluir en
  #                         la coleccion, con su ruta completa, ej, "D:\\3\\UXXIDW_listado_coleccion_III000XXX.lst"
  #                         las dobles comillas son importantes cuando la ruta contiene
  #                         espacios en blanco.
  
  # Descripcion: Crea la coleccion con los objetos que se indican en el fichero.
  #              Si la coleccion a crear ya existe finaliza con error.
  #
  
  # Archivo de log de la ejecucion de este procedimiento
  pr_crear_fichero_log
  global k_fichero_log
  puts "Log de la creacion de la coleccion: $k_fichero_log"
  pr_escribir_log "Comienza pr_crea_coleccion $p_proyecto $p_coleccion $p_fichero"
  
  # Nos conectamos al OWB
  set v_ejecucion [ pr_conectar ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_crea_coleccion: Al conectar al OWB"
	}
  # Nos situamos en el contexto del proyecto
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_crea_coleccion: Al poner el contexto en el proyecto"
	}
	
	# Comprobamos si la colección existe
	pr_escribir_log "pr_crea_coleccion: Comprobamos si la coleccion a crear ya existe"
	set v_ejecucion [ pr_ejecutar_omb OMBCREATE COLLECTION '$p_coleccion' ]
  if { [ string match "ERROR API0408*" "$v_ejecucion" ] } {
  	pr_finalizar_error "pr_crea_coleccion: La coleccion $p_coleccion ya existe"
  } elseif { [ pr_tratar_error $v_ejecucion ] } {
  	pr_finalizar_error "pr_crea_coleccion: Al comprobar si existe la colección $p_coleccion"
  }
	
	pr_escribir_log "pr_crea_coleccion: Leemos el fichero con objetos a incluir en la coleccion"
	set v_ejecucion [ pr_ejecutar_omb open "$p_fichero" ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_crea_coleccion: Al abrir el fichero $p_fichero"
	}
  set v_outfile $v_ejecucion
	set v_ejecucion [ pr_ejecutar_omb read -nonewline $v_outfile ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_crea_coleccion: Al leer el fichero $p_fichero"
	}
  set v_data_fichero $v_ejecucion
  close $v_outfile
  
  # Con los datos del fichero en v_data_fichero, vamos leyendo el fichero línea por línea
  set v_ejecucion [ pr_ejecutar_omb split $v_data_fichero \n ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_crea_coleccion: Al dividir el fichero en una lista"
	}
  set v_lista_objetos $v_ejecucion
  foreach v_objeto $v_lista_objetos {
  	# Compruebo que el numero de parametros para invocar creación de la colección es correcta
  	if { [ llength $v_objeto ] == 2 } {
    	# Obtengo los parametros para invocarlo, v_tipo_objeto y v_ruta_objeto:
    	set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto ] 0 ]
    	if [ pr_tratar_error $v_ejecucion ] {
    		pr_finalizar_error "pr_crea_coleccion: Al obtener el tipo de objeto en $v_objeto"
    	}
    	set v_tipo_objeto $v_ejecucion
    	set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto ] 1 ]
    	if [ pr_tratar_error $v_ejecucion ] {
    		pr_finalizar_error "pr_crea_coleccion: Al obtener el tipo de objeto en $v_objeto"
    	}
    	set v_ruta_objeto $v_ejecucion
    	
    	set v_ejecucion [ pr_ejecutar_omb OMBALTER COLLECTION '$p_coleccion' ADD REFERENCE TO $v_tipo_objeto '$v_ruta_objeto' ]
    	if [ pr_tratar_error $v_ejecucion ] {
    		pr_finalizar_error "pr_crea_coleccion: Al añadir el objeto $v_objeto a la coleccion $p_coleccion"
    	}
    	
    } else {
    	# llength $v_objeto != 2
    	pr_escribir_log "ERROR pr_crea_coleccion: No se puede incluir en la coleccion: $v_objeto"
    }
    # Numero parametros en $v_objeto
  }
  # foreach v_objeto
	OMBCOMMIT
	pr_ejecutar_omb OMBDISCONNECT
	pr_escribir_log ""
	pr_escribir_log ""
	pr_escribir_log "pr_crea_coleccion: Comprobar el log $k_fichero_log"
  pr_escribir_log "Finaliza pr_crea_coleccion $p_proyecto $p_coleccion $p_fichero"
}
# pr_crea_coleccion

proc pr_fichero_coleccion {p_proyecto p_coleccion p_ruta} {
	# Nombre:      pr_fichero_coleccion.
	
  # Parametros:  p_proyecto: Proyecto del WarehouseBuilder, ej, UXXIDW.
  #              p_coleccion: Nombre de la coleccion, ej, I308562_BECAS
  #              p_ruta: Ruta en la que dejar el fichero, ej, "D:\\3\\"
  #                      las dobles comillas son importantes cuando la ruta contiene
  #                      espacios en blanco.
  
  # Descripcion: Crea un fichero con un listado de los objetos de la colección
  #
  
  # Archivo de log de la exportacion general
  pr_crear_fichero_log
  global k_fichero_log
  puts "Log de la exportación: $k_fichero_log"
  pr_escribir_log "Comienza pr_fichero_coleccion $p_proyecto $p_coleccion $p_ruta"
  
  # Comprobamos que la ruta en que dejar el fichero existe
  set v_ejecucion [ file mkdir $p_ruta ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_fichero_coleccion: Al comprobar la ruta donde dejar el fichero"
	}
  append v_fichero_objetos $p_ruta $p_proyecto "_listado_coleccion_" $p_coleccion ".lst"
  # Creamos el fichero y si ya existe, lo sobreescribimos, a continuación lo cerramos
  # para que si se produce un error no se quede el fichero bloqueado.
  set v_ejecucion [ open "$v_fichero_objetos" w ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_fichero_coleccion: Al abrir el fichero $v_fichero_objetos"
	}
  set v_outfile_objetos $v_ejecucion
  close $v_outfile_objetos
  
  pr_escribir_log "pr_fichero_coleccion: Nos conectamos al OWB"
  
  set v_ejecucion [ pr_conectar ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_fichero_coleccion: Al conectar a base de datos"
	}
  
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_fichero_coleccion: Al poner el contexto en el proyecto"
	}
  
  # Obtengo la lista de objetos de la coleccion.
  set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE COLLECTION '/$p_proyecto/$p_coleccion' GET ALL REFERENCES ]
  if [ pr_tratar_error $v_ejecucion ] {
  	pr_finalizar_error "pr_fichero_coleccion: Al obtener los objetos de la colección $p_coleccion"
  }
  set objList $v_ejecucion
  
  foreach v_objeto $objList {
  	set v_ejecucion [ pr_ejecutar_omb open "$v_fichero_objetos" a+ ]
  	if [ pr_tratar_error $v_ejecucion ] {
  		pr_finalizar_error "pr_fichero_coleccion: Al abrir el fichero de objetos $v_fichero_objetos para $v_objeto"
  	}
		set v_outfile_objetos $v_ejecucion
		puts $v_outfile_objetos "$v_objeto"
		close $v_outfile_objetos
	}
	# foreach v_objRuta
  pr_ejecutar_omb OMBDISCONNECT
	pr_escribir_log ""
	pr_escribir_log ""
	pr_escribir_log "pr_fichero_coleccion: Comprobar el log $k_fichero_log"
  pr_escribir_log "Finaliza pr_fichero_coleccion $p_proyecto $p_coleccion $p_ruta"
}
# Fin pr_fichero_coleccion

proc pr_obj_desplegable { p_TipoObjeto p_RutaObjeto p_fichero_objetos } {
    # Nombre:          pr_obj_desplegable
    
    # Parametros:      p_TipoObjeto: Tipo de objeto del OWB
    #                  p_RutaObjeto: Objeto con la ruta completa de acceso, por ejemplo,
    #                                /UXXI2_COSTES/INTERFACES_ACA_ODS/TOH_ACA_ASIGNATURAS.
    #                  p_fichero_objetos: Fichero donde se graban los objetos desplegables,
    #                                     con su ruta completa, ej, D:\\temp\\fichero.lst
    
    # Descripcion: Determina si el objeto es desplegable, y si lo es, lo graba en el fichero
    #              de objetos a desplegar que se crea al exportar la colección.
    #              La casuística para determinar si un objeto es desplegable es la siguiente:
    #              1 - Si el objeto pertenece a un módulo que contiene el nombre OLTP, no es
    #                  desplegable.
    #              2 - Si la ruta del objeto no tiene la forma: /proyecto/modulo/objeto, se 
    #                  mira lo siguiente:
    #                  a - Si el objeto pertenece a un paquete de base de datos, lo que se
    #                      mira si es desplegable es el paquete completo, no el objeto solo.
    #                  b - Si el objeto es un process flow, lo que se mira si se despliega
    #                      es el paquete de process flow.
    #                  c - Si no es uno de los casos anteriores, se deja un mensaje de error
    #                      en el log avisando que hay que revisar ese objeto, pero no se
    #                      para el proceso.
    #              3 - Para el resto de casos, se mira la propiedad desplegable del objeto.
    #
	pr_escribir_log "Inicio de pr_obj_desplegable $p_TipoObjeto $p_RutaObjeto $p_fichero_objetos"
	
	# Determinamos el nombre del módulo
	set v_ejecucion [ pr_ejecutar_omb lindex [ split $p_RutaObjeto "/" ] 2 ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_obj_desplegable: al dividir $p_RutaObjeto"
	}
	set v_modName $v_ejecucion
	set v_desplegable 0
	# Por si acaso cambiamos el tipo de objeto porque se despliega el de nivel superior (un
	# paquete en vez de un procedimiento, el paquete de process flow en vez del process flow,
	# etc), guardamos el tipo del objeto a desplegar en una variable:
	set v_TipoObjetoFinal $p_TipoObjeto
	
	# Empezamos a determinar si el objeto es desplegable
	if { [ string match "*OLTP*" "$v_modName" ] } {
				pr_escribir_log "No hay que desplegar $p_TipoObjeto $p_RutaObjeto"
				set v_desplegable 1
	} elseif { [ llength [ split $p_RutaObjeto "/" ] ] == 5 } {
		# La ruta con el objeto es de tipo /proyecto/modulo/paquete/objeto, comprobamos
		# el tipo de objeto que es para saber qué es lo que hay que desplegar
		switch $p_TipoObjeto {
			"FUNCTION" - "PROCEDURE" - "TABLE_FUNCTION" {
				# La ruta tiene el formato /proyecto/modulo/paquete/procedimiento_funcion_table-funcion,
				# cambio el tipo de objeto a desplegar, que es el paquete de base de datos
				# que lo contiene.
				set v_TipoObjetoFinal "PACKAGE"
				set v_proyecto [ lindex [ split $p_RutaObjeto "/" ] 1 ]
				set v_modName [ lindex [ split $p_RutaObjeto "/" ] 2 ]
				set v_objName [ lindex [ split $p_RutaObjeto "/" ] 3 ]
				set p_RutaObjeto ""
				append p_RutaObjeto "/" $v_proyecto "/" $v_modName "/" $v_objName
				
				# A continuación comprobamos si el PACKAGE es deplegable
				set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $v_TipoObjetoFinal '$p_RutaObjeto' GET PROPERTIES (DEPLOYABLE) ]
				if [ pr_tratar_error $v_ejecucion ] {
					pr_finalizar_error "pr_obj_desplegable: al comprobar si $v_TipoObjetoFinal $p_RutaObjeto es desplegable"
	    	}
	    	
	    	if { $v_ejecucion } {
	    		set v_desplegable 0
	    	} else {
	    		set v_desplegable 1
	    	}
	    }
	    "PROCESS_FLOW" {
	    	# La ruta tiene el formato /proyecto/modulo_process/paquete_process/process,
	    	# cambio el tipo de objeto a desplegar, que es el paquete de process flows
	    	# que lo contiene.
	    	set v_TipoObjetoFinal "PROCESS_FLOW_PACKAGE"
	    	set v_proyecto [ lindex [ split $p_RutaObjeto "/" ] 1 ]
	    	set v_modName [ lindex [ split $p_RutaObjeto "/" ] 2 ]
	    	set v_objName [ lindex [ split $p_RutaObjeto "/" ] 3 ]
	    	set p_RutaObjeto ""
	    	append p_RutaObjeto "/" $v_proyecto "/" $v_modName "/" $v_objName
	    	
	    	# A continuación comprobamos si el PROCESS_FLOW_PACKAGE es deplegable.
	    	# Esta propiedad sólo se puede consultar en el contexto del módulo de
	    	# PROCESS_FLOW, por lo que situamos el contexto allí y luego lo ponemos
	    	# otra vez a nivel de proyecto.
	    	OMBCC '/$v_proyecto/$v_modName'
	    	set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $v_TipoObjetoFinal '$v_objName' GET PROPERTIES (DEPLOYABLE) ]
	    	if [ pr_tratar_error $v_ejecucion ] {
	    		pr_finalizar_error "pr_obj_desplegable: Al comprobar si $v_TipoObjetoFinal $p_RutaObjeto es desplegable"
	    	}
	    	if { $v_ejecucion } {
	    		set v_desplegable 0
	    	} else {
	    		set v_desplegable 1
	    	}
	    	OMBCC '/$v_proyecto'
	    	
	    }
	    default {
	    	# Es algo que no tengo catalogado, lo dejo como no desplegable y pongo el aviso
	    	# en el log para revisarlo
	    	pr_escribir_log "ERROR pr_obj_desplegable: no se puede desplegar el $p_TipoObjeto $p_RutaObjeto, revisar el objeto"
	    	set v_desplegable 1
	    }
	  }
	  # Fin switch p_TipoObjeto
	} elseif { [ llength [ split $p_RutaObjeto "/" ] ] == 4 } {
		# No es un objeto del OLTP y la ruta del objeto tiene la forma /proyecto/modulo/objeto,
		# compruebo si el objeto es desplegable
		switch $p_TipoObjeto {
			"CUBE" - "DIMENSION" {
				# Los cubos y dimensiones no voy a desplegarlos
				set v_desplegable 1
			}
			default {
				set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $p_TipoObjeto '$p_RutaObjeto' GET PROPERTIES (DEPLOYABLE) ]
				if [ pr_tratar_error $v_ejecucion ] {
					pr_finalizar_error "pr_obj_desplegable: Al comprobar si $p_TipoObjeto $p_RutaObjeto es desplegable"
				}
				if { $v_ejecucion } {
					set v_desplegable 0
				} else {
					set v_desplegable 1
				}
			}
		}
		# switch $p_TipoObjeto
	} else {
		# Es algo que no tengo catalogado, lo dejo como no desplegable y pongo el aviso
		# en el log para revisarlo
		pr_escribir_log "ERROR pr_obj_desplegable: no se puede desplegar el $p_TipoObjeto $p_RutaObjeto, revisar el objeto"
		set v_desplegable 1
	}
	# Fin comprobacion si el objeto es desplegable
	pr_escribir_log "pr_obj_desplegable: El $v_TipoObjetoFinal $p_RutaObjeto es desplegable: $v_desplegable"
	
	# Si el objeto es desplegable, lo incluimos en el fichero de objetos
	if { $v_desplegable == 0 } {
		set v_outfile_objetos [ open "$p_fichero_objetos" a+ ]
		puts $v_outfile_objetos "$v_TipoObjetoFinal $p_RutaObjeto"
		close $v_outfile_objetos
	}
	# Fin if v_desplegable
	
	pr_escribir_log "Fin de pr_obj_desplegable $p_TipoObjeto $p_RutaObjeto $p_fichero_objetos"
	pr_escribir_log "---------------------------------------------------------------------------------"
	pr_escribir_log ""

}
# proc pr_obj_desplegable

proc pr_borra_operadores {p_fichero p_tipo_objeto} {
    # Nombre:      pr_borra_operadores
    
    # Parametros:  p_fichero:     Nombre del fichero a leer, con su ruta completa, por ej,
    #                             D:\\temp\\fichero.lst
    #              p_tipo_objeto: Tipo de objetos que tiene el fichero: MAPPING o PROCESS_FLOW
    
    # Descripcion: Abre el fichero leyendo su contenido y borrando los operadores de los mapeos
    #              o process flow que se indican en el fichero.
    #
	pr_escribir_log "Inicia pr_borra_operadores $p_fichero $p_tipo_objeto"
	set v_ejecucion [ pr_ejecutar_omb open "$p_fichero" ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_borra_operadores: No se ha podido abrir el fichero $p_fichero"
	}
	set v_outfile $v_ejecucion
	
	set v_ejecucion [ pr_ejecutar_omb read -nonewline $v_outfile ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_borra_operadores: No se puede leer el fichero $p_fichero"
	}
	set v_data_fichero $v_ejecucion
	close $v_outfile
	
	# Obtengo la lista de mapeos o process flow
	set v_lista_objetos [ split $v_data_fichero \n ]
	foreach v_objeto $v_lista_objetos {
		switch $p_tipo_objeto {
			"MAPPING" {
				pr_escribir_log "pr_borra_operadores: Borrando operadores del mapeo $v_objeto"
				# Para borrar objetos del mapeo tengo que situar el contexto en el modulo donde
        # está el mapeo. Si considero el objeto una lista utilizando el separador /, el
        # proyecto es el segundo elemento de la lista, el modulo el tercero y el cuarto es el mapeo
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 1 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el proyecto"
        }
        set v_proyName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 2 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el módulo"
        }
        set v_modName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 3 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el mapeo"
        }
        set v_objName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb OMBCC '/$v_proyName/$v_modName' ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido situar el contexto en el módulo"
        }
        
        set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $p_tipo_objeto '$v_objName' GET OPERATORS ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar los operadores del mapeo"
        }
        set v_opList $v_ejecucion
        
        foreach v_opName $v_opList {
        	set v_ejecucion [ pr_ejecutar_omb OMBALTER $p_tipo_objeto '$v_objName' DELETE OPERATOR '$v_opName' ]
        	if [ pr_tratar_error $v_ejecucion ] {
        		pr_finalizar_error "pr_borra_operadores, no se ha podido borrar el operador $v_objeto -> $v_opName"
        	}
        }
        # foreach v_opName
        pr_escribir_log "."
        pr_escribir_log "."
        pr_escribir_log "-----------------------------------------------"
			}
			"PROCESS_FLOW" {
				pr_escribir_log "pr_borra_operadores: Borrando actividades del process_flow $v_objeto"
				# Para borrar objetos del process flow tengo que situar el contexto en el
        # paquete de process flow. Si considero el objeto una lista utilizando el
        # separador /, el proyecto es el segundo elemento de la lista, el módulo de process flow
        # el tercero, el cuarto es el paquete de process flow y el quinto el process.
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 1 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el proyecto"
        }
        set v_proyName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 2 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el módulo"
        }
        set v_modName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 3 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el mapeo"
        }
        set v_packName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb lindex [ split $v_objeto "/" ] 4 ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar el mapeo"
        }
        set v_pfName $v_ejecucion
        
        set v_ejecucion [ pr_ejecutar_omb OMBCC '/$v_proyName/$v_modName/$v_packName' ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido situar el contexto en el módulo"
        }
        
        set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $p_tipo_objeto '$v_pfName' GET ACTIVITIES ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_borra_operadores, no se ha podido recuperar las actividades del process flow"
        }
        set v_actList $v_ejecucion
        foreach v_actName $v_actList {
            # Las actividades START no se pueden borrar, dan error, el resto se borran
            if { [ string match "START*" "$v_actName" ] == 0 } {
            	# La actividad no es START
            	set v_ejecucion [ pr_ejecutar_omb OMBALTER $p_tipo_objeto '$v_pfName' DELETE ACTIVITY '$v_actName' ]
            	if [ pr_tratar_error $v_ejecucion ] {
            		pr_finalizar_error "pr_borra_operadores, no se ha podido borrar la actividad $v_objeto -> $v_actName"
            	}
            }
        }
        # foreach v_actName
        pr_escribir_log "."
        pr_escribir_log "."
        pr_escribir_log "-----------------------------------------------"
			}
			default {
				pr_finalizar_error "pr_borra_operadores: El tipo de objeto a tratar $p_tipo_objeto no está configurado"
			}
		}
		# switch p_tipo_objeto
	}
	# foreach v_mapeo
	pr_escribir_log "Finaliza pr_borra_operadores $p_fichero $p_tipo_objeto"
}
# pr_borra_operadores

proc pr_despliega_objeto {p_tipo_objeto p_ruta_objeto p_accion} {

    # Nombre:      pr_despliega_objeto
    # Parametros:  p_tipo_objeto: Indica el tipo de objeto a desplegar.
    #              p_ruta_objeto: Objeto a desplegar, con la ruta completa para el despliegue
    #              p_accion: CREATE, REPLACE, DROP, UPGRADE

    # Descripcion: Segun el tipo de objeto separa la ruta del nombre del objeto
    #              para invocar al procedimiento adecuado, con la opción de
    #              despliegue indicada.
    #
    
    pr_escribir_log "Se inicia pr_despliega_objeto $p_tipo_objeto $p_ruta_objeto $p_accion"

    # Si considero la ruta del objeto una lista utilizando el separador /, el proyecto
    # donde se ubica el objeto es el primer elemento de la lista, el modulo
    # el segundo y el tercero el nombre del objeto a desplegar
    set v_ejecucion [ pr_ejecutar_omb llength [ split $p_ruta_objeto "/" ] ]
		if [ pr_tratar_error $v_ejecucion ] {
			pr_finalizar_error "pr_despliega_objeto: al comprobar nº elementos en $p_ruta_objeto"
		}
		set v_num_elementos $v_ejecucion
		if { $v_num_elementos != 4 } {
			pr_finalizar_error "pr_despliega_objeto: el objeto a desplegar no tiene el formato /proyecto/modulo/objeto: $p_ruta_objeto"
		}
    set v_proyecto [ lindex [ split $p_ruta_objeto "/" ] 1 ]
    set v_modName [ lindex [ split $p_ruta_objeto "/" ] 2 ]
    set v_objName [ lindex [ split $p_ruta_objeto "/" ] 3 ]
    
    pr_desplegar_objeto $p_tipo_objeto $v_proyecto $v_modName $v_objName $p_accion
    
    pr_escribir_log "Finaliza pr_despliega_objeto $p_tipo_objeto $p_ruta_objeto $p_accion"
}
# Fin pr_despliega_objeto

proc pr_desplegar_objeto {p_tipo_objeto p_proyecto p_modulo p_objeto p_accion} {

    # Nombre:          pr_desplegar_objeto
    # Parametros:      p_tipo_objeto: Tipo de objeto a desplegar, ej, TABLE
    #                  p_proyecto: Proyecto del WarehouseBuilder.
    #                  p_modulo: Modulo donde se encuentran las tablas, ej: UXXIRRHH_ODS
    #                  p_objeto: Nombre del objeto a desplegar, ej, TOH_HOM_PERSONA
    #                  p_accion: CREATE, REPLACE, UPGRADE, DROP
    # Precondiciones:
    #                  1.- Todos los objetos estan validados.
    #                  2.- Las conexiones al runtime y repositorio de disenio han sido establecidas.
    #                  3.- Se ha invocado al ControlCenter
    # Postcondiciones:
    #                  1.- Se despliega el objeto indicado.

    
    pr_escribir_log "Inicia pr_desplegar_objeto $p_tipo_objeto /$p_proyecto/$p_modulo/$p_objeto $p_accion"
    set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto/$p_modulo' ]
		if [ pr_tratar_error $v_ejecucion ] {
			pr_finalizar_error "pr_desplegar_objeto: al establecer el contexto"
		}
    # Se comprueba si el objeto es desplegable
    set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE $p_tipo_objeto '$p_objeto' GET PROPERTIES (DEPLOYABLE) ]
		if [ pr_tratar_error $v_ejecucion ] {
			pr_finalizar_error "pr_desplegar_objeto: al recuperar la propiedad desplegable del objeto"
		}
		set v_despleg $v_ejecucion
    if { $v_despleg == "true" } {
        pr_escribir_log "pr_desplegar_objeto: Desplegando ($p_accion): $p_objeto"
        set v_dap ""
        append v_dap "DEPLOY_PLAN_" $p_tipo_objeto "_" $p_objeto
        set v_a ""
        append v_a "DEPLOY_" $p_tipo_objeto "_" $p_objeto
        set v_ejecucion [ pr_ejecutar_omb OMBCREATE TRANSIENT DEPLOYMENT_ACTION_PLAN '$v_dap' \
                ADD ACTION '$v_a' SET PROPERTIES (OPERATION) \
                VALUES ('$p_accion') SET REFERENCE $p_tipo_objeto \
                '$p_objeto' ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_desplegar_objeto: al crear la acción de despliegue"
        }

        set v_ejecucion [ pr_ejecutar_omb OMBDEPLOY DEPLOYMENT_ACTION_PLAN '$v_dap' ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_desplegar_objeto: al desplegar la acción"
        }
        set v_ejecucion [ pr_ejecutar_omb OMBDROP DEPLOYMENT_ACTION_PLAN '$v_dap' ]
        if [ pr_tratar_error $v_ejecucion ] {
        	pr_finalizar_error "pr_desplegar_objeto: al borrar la acción de despliegue"
        }
        OMBCOMMIT
    } else {
        pr_escribir_log "pr_desplegar_objeto: $p_objeto no desplegable"
    }
    # Fin if v_despleg = true
    # Se pone una linea en blanco
    
    pr_escribir_log "Fin pr_desplegar_objeto $p_tipo_objeto $p_proyecto $p_modulo $p_objeto $p_accion"
    pr_escribir_log "."
    pr_escribir_log "."
    pr_escribir_log "-----------------------------------------------"
}
# Fin pr_desplegar_objeto

proc pr_exporta_proyecto {p_proyecto p_ruta} {
	# Nombre:      pr_exporta_proyecto.
	
  # Parametros:  p_proyecto: Proyecto del WarehouseBuilder, ej, UXXIDW.
  #              p_ruta: Ruta en la que dejar los objetos exportados, ej, "D:\\3\\"
  #                      las dobles comillas son importantes cuando la ruta contiene
  #                      espacios en blanco.
  # Descripcion: Exporta el proyecto completo con todas sus dependencias en un fichero
  #              llamado PROYECTO_EXP_YYMMDD.MDL. El log de la exportación se almacena
  #              en un fichero llamado PROYECTO_EXP_YYMMDD_HHMISS.log
  #              Se conecta al iniciar la exportación y se desconecta al finalizar.
  #
  pr_crear_fichero_log
  global k_fichero_log
  puts "Log de la exportación: $k_fichero_log"
  pr_escribir_log "Comienza pr_exporta_proyecto $p_proyecto $p_ruta"
  # Nos conectamos al OWB
  set v_ejecucion [ pr_conectar ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_proyecto: Al conectar al OWB"
	}
  
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_proyecto: Al poner el contexto en el proyecto"
	}
	
	# Nos aseguramos que la ruta donde dejar el fichero de exportación existe:
	set v_ejecucion [ pr_ejecutar_omb file mkdir $p_ruta ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_proyecto: Al comprobar que exista la ruta $p_ruta"
	}
	pr_escribir_log "$v_ejecucion"
	
	append v_export_mdl $p_ruta $p_proyecto _EXP_ [ clock format [ clock seconds ] -format "%y%m%d" ] ".MDL"
	append v_export_log $p_ruta $p_proyecto _EXP_ [ clock format [ clock seconds ] -format "%y%m%d_%H%M%S" ] ".log"
	
	pr_escribir_log "pr_exporta_proyecto: Comienzo exportacion del proyecto $p_proyecto"
	
	set v_ejecucion [ OMBEXPORT TO MDL_FILE '$v_export_mdl' FROM PROJECT '$p_proyecto' \
    WITH DEPENDEE_DEPTH MAX OUTPUT LOG TO '$v_export_log' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_proyecto: Al exportar el proyecto"
	}
  
	# Nos desconectamos del OWB
	pr_ejecutar_omb OMBDISCONNECT
	pr_escribir_log ""
	pr_escribir_log ""
	pr_escribir_log "pr_exporta_proyecto: Comprobar el log $k_fichero_log"
  pr_escribir_log "Finaliza pr_exporta_proyecto $p_proyecto $p_ruta"
}
# pr_exporta_proyecto

proc pr_exporta_coleccion {p_proyecto p_coleccion p_ruta} {
	# Nombre:          pr_exporta_coleccion.
	
  # Parametros:      p_proyecto: Proyecto del WarehouseBuilder, ej, UXXIDW.
  #                  p_coleccion: Nombre de la coleccion a exportar, ej, I308562_BECAS
  #                  p_ruta: Ruta en la que dejar los objetos exportados, ej, "D:\\3\\"
  #                          las dobles comillas son importantes cuando la ruta contiene
  #                          espacios en blanco.
  
  # Descripcion: Crea los ficheros necesarios para realizar un pase a produccion.
  #              Exporta la coleccion completa en un unico fichero para realizar el pase
  #              y genera los ficheros con listados de objetos a tratar: mapeos cuyos
  #              operadores hay que borrar, process flow para borrar las actividades
  #              y el de objetos que conforman la colección.
  #              Dentro de la ruta de exportacion se crea (si no existe ya) la carpeta
  #              pase, donde se dejaran los ficheros para el pase a produccion
  #
  
  # Archivo de log de la exportacion general
  pr_crear_fichero_log
  global k_fichero_log
  puts "Log de la exportación: $k_fichero_log"
  pr_escribir_log "Comienza pr_exporta_coleccion $p_proyecto $p_coleccion $p_ruta"
  
  append v_ruta_pase $p_ruta pase\\
  file mkdir $v_ruta_pase
  append v_fichero_objetos $v_ruta_pase $p_proyecto "_objetos_coleccion_" $p_coleccion ".lst"
  append v_fichero_mapeos $v_ruta_pase $p_proyecto "_mapeos_coleccion_" $p_coleccion ".lst"
  append v_fichero_pflow $v_ruta_pase $p_proyecto "_pflow_coleccion_" $p_coleccion ".lst"
  # Creamos los ficheros y si ya existen, los sobreescribimos, a continuación los cerramos
  # para que si se produce un error no se queden los ficheros bloqueados.
  set v_outfile_objetos [ open "$v_fichero_objetos" w ]
  set v_outfile_mapeos [ open "$v_fichero_mapeos" w ]
  set v_outfile_pflow [ open "$v_fichero_pflow" w ]
  close $v_outfile_objetos
  close $v_outfile_mapeos
  close $v_outfile_pflow
  
  pr_escribir_log "pr_exporta_coleccion -> Nos conectamos al OWB"
  
  set v_ejecucion [ pr_conectar ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_coleccion: Al conectar a base de datos"
	}
  
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_exporta_coleccion: Al poner el contexto en el proyecto"
	}
  
  # Obtengo la lista de objetos de la coleccion. Podría obtener todos los objetos
  # de una vez, pero para asegurarme que los grabo en el fichero de despliegue en
  # el orden que me interesa, voy a ir recuperando listas según el tipo de objeto.
  
  # Creo la lista de tipos de objeto
  set v_tipoList [ list SEQUENCE TABLE EXTERNAL_TABLE VIEW MATERIALIZED_VIEW FUNCTION PROCEDURE TABLE_FUNCTION PACKAGE DIMENSION CUBE MAPPING PROCESS_FLOW PROCESS_FLOW_PACKAGE ]
	
	# Para cada tipo de objeto que podemos tener en una colección, vamos recuperando
	# la lista de objetos de ese tipo que tenemos en nuestra colección, para irlo incluyendo
	# en el orden más correcto de despliegue en nuestro fichero de objetos a desplegar
	foreach v_objTipo $v_tipoList {
		# Generamos la lista de objetos de ese tipo que tiene la colección:
		set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE COLLECTION '/$p_proyecto/$p_coleccion' GET $v_objTipo REFERENCES ]
		if [ pr_tratar_error $v_ejecucion ] {
			pr_finalizar_error "pr_exporta_coleccion: Al obtener los $v_objTipo de la colección"
		}
		# Copiamos la lista de objetos devuelta por el OMBRETRIEVE COLLECTION
		set objList $v_ejecucion
		
		foreach v_objRuta $objList {
			pr_escribir_log "pr_exporta_coleccion: Tratamos el $v_objTipo $v_objRuta"
			
			# Grabamos el objeto, si procede, en la lista de mapeos o la de Process flow
			switch $v_objTipo {
				"MAPPING" {
					set v_outfile_mapeos [ open "$v_fichero_mapeos" a+ ]
					puts $v_outfile_mapeos $v_objRuta
					close $v_outfile_mapeos
			  }
			  "PROCESS_FLOW" {
			  	set v_outfile_pflow [ open "$v_fichero_pflow" a+ ]
			  	puts $v_outfile_pflow $v_objRuta
			  	close $v_outfile_pflow
			  }
			}
			# switch $v_objTipo
			
			pr_escribir_log "pr_exporta_coleccion: Determinamos si $v_objTipo $v_objRuta es desplegable"
			# Toda la lógica que determina si un objeto es desplegable y si se incluye en el fichero
			# de objetos está encapsulada en el procedimiento pr_obj_desplegable.
			pr_obj_desplegable $v_objTipo $v_objRuta $v_fichero_objetos
		}
		# foreach v_objRuta
	}
	# foreach v_objTipo $v_tipoList
	
	pr_escribir_log "pr_exporta_coleccion: Ahora exportamos la coleccion completa"
	set v_mdlfile ""
	set v_logfile ""
	append v_mdlfile $v_ruta_pase $p_proyecto "_" $p_coleccion ".mdl"
	append v_logfile $p_ruta $p_proyecto "_" $p_coleccion "_exp.log"
  set v_ejecucion [ pr_ejecutar_omb OMBEXPORT TO MDL_FILE '$v_mdlfile' COMPONENTS (COLLECTION '/$p_proyecto/$p_coleccion') \
        OUTPUT LOG TO '$v_logfile' ]
  if [ pr_tratar_error $v_ejecucion ] {
  	pr_finalizar_error "pr_exporta_coleccion: Al exportar la coleccion"
	}
	
	pr_escribir_log "ATENCION: Recuerda que hay que formatear manualmente el fichero de objetos para el pase $v_fichero_objetos"
  pr_escribir_log "ATENCION: Recuerda que hay que eliminar los objetos nuevos del fichero de mapeos $v_fichero_mapeos"
  pr_escribir_log "ATENCION: Recuerda que hay que eliminar los objetos nuevos del fichero de process flow $v_fichero_pflow"
	
  pr_ejecutar_omb OMBDISCONNECT
	pr_escribir_log ""
	pr_escribir_log ""
	pr_escribir_log "pr_exporta_coleccion: Comprobar el log $k_fichero_log"
  pr_escribir_log "Finaliza pr_exporta_coleccion $p_proyecto $p_coleccion $p_ruta"
}
# Fin pr_exporta_coleccion

proc pr_instala_parche {p_proyecto p_coleccion p_ruta} {
    # Nombre:     pr_instala_parche.
    
    # Parametros: p_proyecto: Proyecto del WarehouseBuilder, ej UXXIDW.
    #             p_coleccion: Nombre de la coleccion a importar, ej, I308562_BECAS
    #             p_ruta: Ruta en la que están los ficheros necesarios para la
    #                     instalación, ej, "D:\\3\\". Las dobles comillas para la ruta
    #                     son necesarias cuando la ruta contiene espacios en blanco.
    #                     Son cuatro ficheros: El mdl de la coleccion, el listado de mapeos,
    #                     el listado de process flow y el listado de objetos a desplegar.
    
    # Descripcion: Lee el listado de mapeos que conforman la coleccion y los repasa uno a uno,
    #              borrando los operadores. IMPORTANTE: Hay que excluir de este listado de mapeos
    #              los mapeos nuevos, porque antes de importarlos todavía no existen, por tanto
    #              el borrado de sus operadores daría error.
    #              Lee el listado de process flow que conforman la coleccion y los repasa uno a uno,
    #              borrando las actividades. De nuevo tener en cuenta los process flow nuevos.
    #              Cuando acaba de borrar hace COMMIT e importa la coleccion.
    #              Una vez importada la coleccion, se comprueba si todos los modulos de
    #              process flow tienen asociada una localizacion de workflow (al importar
    #              process flow a veces se pierde) y si sólo existe una y el modulo no la
    #              tiene asociada, le asocia esa existente, si hay más de una, para la
    #              importación.
    #              Una vez hecha la validacion, procede a leer el fichero de objetos
    #              y despliega los objetos especificados en dicho fichero.
    #              Dentro de la ruta donde estan los ficheros a tratar se crea
    #              (si no existe ya) la carpeta log, donde se dejarán todos los log.
    #
	pr_crear_fichero_log
  global k_fichero_log
  puts "Fichero de log de la instalación: $k_fichero_log"
	pr_escribir_log "Inicia pr_instala_parche $p_proyecto $p_coleccion $p_ruta"
	
	#Creamos las rutas de los diferentes ficheros
	append v_fichero_mapeos $p_ruta $p_proyecto "_mapeos_coleccion_" $p_coleccion ".lst"
  append v_fichero_pflow $p_ruta $p_proyecto "_pflow_coleccion_" $p_coleccion ".lst"
  append v_fichero_objetos $p_ruta $p_proyecto "_objetos_coleccion_" $p_coleccion ".lst"
  append v_mdlfile $p_ruta $p_proyecto "_" $p_coleccion ".mdl"
  append v_logfile $p_ruta $p_proyecto "_" $p_coleccion "_imp_" [ clock format [ clock seconds ] -format "%y%m%d_%H%M%S" ] ".log"
	
  # Compruebo si el fichero de mapeos existe, si no existe, acabo con error
  if { [ file exists $v_fichero_mapeos ] } {
  	pr_escribir_log "pr_instala_parche: El fichero de mapeos: $v_fichero_mapeos existe"
  } else {
  	pr_finalizar_error "pr_instala_parche: no existe el fichero de mapeos: $v_fichero_mapeos"
  }
  
  # Compruebo si el fichero de process flow existe, si no existe, acabo con error
  if { [ file exists $v_fichero_pflow ] } {
  	pr_escribir_log "pr_instala_parche: El fichero de process flow: $v_fichero_pflow existe"
  } else {
  	pr_finalizar_error "pr_instala_parche: no existe el fichero de process flow: $v_fichero_pflow"
  }
  
  # Compruebo si el fichero del pase existe, si no existe, acabo con error
  if { [ file exists $v_mdlfile ] } {
  	pr_escribir_log "pr_instala_parche: El fichero mdl: $v_mdlfile existe"
  } else {
  	pr_finalizar_error "pr_instala_parche: no existe el fichero mdl: $v_mdlfile"
  }
	
	# Compruebo si el fichero de objetos a desplegar existe, si no existe, acabo con error
  if { [ file exists $v_fichero_objetos ] } {
  	pr_escribir_log "pr_instala_parche: El fichero de objetos a desplegar: $v_fichero_objetos existe"
  } else {
  	pr_finalizar_error "pr_instala_parche: no existe el fichero de objetos a desplegar: $v_fichero_objetos"
  }
	
	pr_escribir_log "pr_instala_parche -> Nos conectamos al OWB"
  
  set v_ejecucion [ pr_conectar ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Al conectar a base de datos"
	}
  
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Al poner el contexto en el proyecto"
	}
  
  pr_borra_operadores $v_fichero_mapeos MAPPING
  pr_borra_operadores $v_fichero_pflow PROCESS_FLOW
  
  # Devuelvo el contexto al nivel del proyecto
  set v_ejecucion [ pr_ejecutar_omb OMBCC '/$p_proyecto' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "Fin de pr_instala_parche, desconectando..."
	}
  
  # Una vez borrados todos los operadores de los mapeos tratados y las actividades
  # de los process flow, se graba antes de importar la coleccion
  pr_ejecutar_omb OMBCOMMIT
  
	pr_escribir_log "pr_instala_parche: Ahora importamos la coleccion completa"
	
	set v_ejecucion [ pr_ejecutar_omb OMBIMPORT FROM MDL_FILE '$v_mdlfile' USE UPDATE_MODE MATCH_BY NAMES \
        OUTPUT LOG TO '$v_logfile' ]
	if { [ string match "OMB05105*" "$v_ejecucion" ] } {
  	pr_escribir_log "pr_instala_parche: $v_ejecucion"
  } elseif [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Al importar la colección"
	}
  
  pr_escribir_log "pr_instala_parche: Finalizada la importación"
	
  # Se revisa si al importar un workflow ha perdido la localización del workflow y no se puede desplegar
  set v_ejecucion [ pr_ejecutar_omb OMBLIST ORACLE_WORKFLOW_LOCATIONS ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al recuperar la lista de localizaciones de workflow"
	}
  set v_wf_loc_list $v_ejecucion
  
  set v_ejecucion [ pr_ejecutar_omb llength $v_wf_loc_list ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al recuperar el número de localizaciones de workflow"
	}
  set v_num_wf_loc $v_ejecucion
  
  set v_ejecucion [ pr_ejecutar_omb OMBLIST PROCESS_FLOW_MODULES ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al recuperar los módulos de workflow"
	}
  set v_pf_mod_list $v_ejecucion
  
  foreach v_pf_module $v_pf_mod_list {
  	set v_ejecucion [ pr_ejecutar_omb OMBRETRIEVE PROCESS_FLOW_MODULE '$v_pf_module' GET PROPERTIES (DB_LOCATION) ]
  	if [ pr_tratar_error $v_ejecucion ] {
  		pr_finalizar_error "pr_instala_parche: Error al recuperar la localización del $v_pf_module"
  	}
  	set v_db_location $v_ejecucion
  	if { $v_db_location == "{Unknown value}" } {
  		if { $v_num_wf_loc == 1 } {
  			# Si solo hay una localizacion de workflow, se le asocia esa al modulo que la ha perdido
  			set v_ejecucion [ pr_ejecutar_omb OMBALTER PROCESS_FLOW_MODULE '$v_pf_module' SET PROPERTIES (DB_LOCATION) VALUES ('$v_wf_loc_list') ]
  			if [ pr_tratar_error $v_ejecucion ] {
  				pr_finalizar_error "pr_instala_parche: Error al asignar la localización $v_wf_loc_list al proceso $v_pf_module"
  			}
        OMBCOMMIT
      } else {
      	# Hay mas de una localizacion de workflow, paramos el proceso para revisar cual hay que asociar
      	pr_finalizar_error "pr_instala_parche: El workflow $v_pf_module, no tiene localizacion asociada, contactar con equipo técnico"
      }
      # if v_num_wf_loc = 1
    }
    # if v_db_location desconocida
  }
  # foreach v_pf_mod_list

  pr_escribir_log "pr_instala_parche: Se procede a desplegar los objetos de la coleccion"
  
  # Abro el fichero de objetos para leerlo
	set v_ejecucion [ pr_ejecutar_omb open "$v_fichero_objetos" ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al abrir el fichero de objetos $v_fichero_objetos"
	}
  set v_outfile_objetos $v_ejecucion
	set v_ejecucion [ pr_ejecutar_omb read -nonewline $v_outfile_objetos ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al leer el fichero de objetos $v_fichero_objetos"
	}
  set data_objetos $v_ejecucion
  close $v_outfile_objetos
  
  # Abro la ventana de despliegue desde el OMBPLUS
  pr_escribir_log "pr_instala_parche: Abriendo ventana despliegue"
  set v_ejecucion [ pr_ejecutar_omb OMUCONTROLCENTERJOBS ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al abrir la ventana de despliegue"
	}
  
  # Obtengo la lista de objetos
	set v_ejecucion [ pr_ejecutar_omb split $data_objetos \n ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_finalizar_error "pr_instala_parche: Error al generar una lista con el contenido del fichero de objetos"
	}
  set v_lista_objetos $v_ejecucion
  foreach v_objeto $v_lista_objetos {
  	pr_escribir_log "pr_instala_parche: Desplegando objeto $v_objeto"
  	
  	# Compruebo que el numero de parametros para desplegar el objeto es correcta
  	if { [ llength $v_objeto ] != 3 } {
  		pr_finalizar_error "pr_instala_parche: No se puede desplegar $v_objeto, el numero de parametros es incorrecto"
  	}
  	# if v_objeto formado por tres parametros
  	
  	# Obtengo los parametros para invocarlo:
  	set v_tipo_objeto [ lindex [ split $v_objeto ] 0 ]
  	set v_ruta_objeto [ lindex [ split $v_objeto ] 1 ]
  	set v_accion [ lindex [ split $v_objeto ] 2 ]
  	
  	pr_despliega_objeto $v_tipo_objeto $v_ruta_objeto $v_accion
  	
  }
  # foreach v_lista_objetos
  
	pr_ejecutar_omb OMBDISCONNECT
	pr_escribir_log ""
	pr_escribir_log ""
	pr_escribir_log "pr_instala_parche: Comprobar el log $k_fichero_log"
  pr_escribir_log "Finaliza pr_instala_parche $p_proyecto $p_coleccion $p_ruta"
}
# Fin pr_instala_parche

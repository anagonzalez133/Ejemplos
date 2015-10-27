####### Componentes #######
# pr_crear_fichero_log
# pr_tratar_error { p_mensaje }
# pr_escribir_log { p_mensaje}
# pr_ejecutar_omb { p_args }
# pr_finalizar_error { p_mensaje }
# pr_conectar {} { p_owb_user p_owb_pass p_owb_host p_owb_port p_owb_sid }
# Precondiciones: Para poder ejecutar los procedimientos de este script
#                 tienen que estar cargadas las variables globales que definen
#                 los datos de conexión, rutas locales, etc.
####### Componentes #######

package require java

##################################################################################
# Nombre: pr_crear_fichero_log
# Descripción: Crea el directorio donde dejar los ficheros si no existe.
#              Carga la variable global de nombre del fichero de log con un nombre
#              en el que figura la hora de ejecución del procedimiento.
##################################################################################
proc pr_crear_fichero_log {} {
	global k_ruta
	global k_fichero_log
	# Creamos el directorio si no existe, si existe esta orden no devuelve error
	file mkdir $k_ruta
	# Ponemos un nombre por defecto al fichero donde almacenaremos los log
	# aunque este nombre debería renombrarse cada vez que se ejecuta el fichero
	set k_fichero_log ""
	append k_fichero_log $k_ruta ejecucion_ [ clock format [ clock seconds ] -format "%y%m%d_%H%M%S" ] ".log"
}
# proc pr_crear_fichero_log

##################################################################################
# Nombre: pr_tratar_error
# Parametros:		p_mensaje: mensaje a analizar
# Descripción: Se le pasa un mensaje para analizar. Si el inicio coincide con uno
#              de los patrones utilizados por el OMB, JAVA O SQLPLUS, se devuelve
#              error (1), si no, se considera un mensaje informativo y se devuelve
#              ejecución correcta.
##################################################################################
proc pr_tratar_error { p_mensaje } {
	# Se lee el comienzo del mensaje y si coincide con alguno de los patrones,
  # error OMB, error ORA, error JAVA o error personalizado (un mensaje que 
  # empiece por el literal ERROR), se levanta un error, si no se considera
  # informativo.
  if [ string match OMB0* $p_mensaje ] {
  	return 1
  } elseif [ string match ORA-* $p_mensaje ] {
  	return 1
  } elseif [ string match java.* $p_mensaje ] {
  	return 1
  } elseif [ string match ERROR* $p_mensaje ] {
  	return 1
  } else {
  	return 0
  }
}
# proc pr_tratar_error

##################################################################################
# Nombre: pr_escribir_log
# Parametros:		p_mensaje: mensaje a escribir en el log
# Descripción: Se le pasa un mensaje para escribir. Lee la variable global k_fichero_log
#              con el nombre del fichero donde grabar los mensajes. Antepone al mensaje
#              la hora en que se graba. Escribe el mismo mensaje por pantalla
##################################################################################
proc pr_escribir_log { p_mensaje} {
	global k_fichero_log
  if [ info exists k_fichero_log ] {
  	set v_fichero [ open "$k_fichero_log" a+ ]
  	set v_hora [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
  	puts $v_fichero "$v_hora:-> $p_mensaje"
    puts "$v_hora:-> $p_mensaje"
    close $v_fichero
  } else {
   	# info exists k_fichero_log es falso
   	set v_hora [ clock format [ clock seconds ] -format "%y%m%d %H:%M:%S" ]
   	puts "$v_hora:-> $p_mensaje"
   	puts "ERROR: No está definida la variable k_fichero_log"
   	return "ERROR pr_escribir_log $v_hora:-> No está definida la variable k_fichero_log"
  }
  # if [ info exists k_fichero_log ]
}
# proc pr_escribir_log

##################################################################################
# Nombre: pr_ejecutar_omb
# Parametros:		args: orden OMB Plus a ejecutar con todos sus argumentos
# Descripción: Se le pasa una sentencia OMBPLUS para ejecutar. La evalua y devuelve
#              el resultado. Si devuelve error, graba el mensaje de error,
#              si devuelve un mensaje de ejecución correcta, se ejecuta.
##################################################################################
proc pr_ejecutar_omb args {
	# Escribimos la orden a ejecutar
  pr_escribir_log "pr_ejecutar_omb: $args"
  
  if [ catch { set v_salida [ eval $args ] } v_errmsg ] {
  	pr_escribir_log "OMB_ERROR $v_errmsg"
  	return "ERROR $v_errmsg"
  } else {
    pr_escribir_log "$v_salida"
    return $v_salida
  }
}
# pr_ejecutar_omb

##################################################################################
# Nombre: pr_finalizar_error
# Parametros:		p_mensaje: mensaje a escribir en el log
# Descripción: Se le pasa un mensaje final para escribir en el log. Lee la variable global k_fichero_log
#              con el nombre del fichero donde grabar los mensajes. Antepone al mensaje
#              la hora en que se graba. Escribe el mismo mensaje por pantalla
# Default rollbabk and exit with error code function.
##################################################################################
proc pr_finalizar_error { p_mensaje } {

   pr_escribir_log "ERROR $p_mensaje"
   pr_escribir_log "pr_finalizar_error: Rollback..."

   OMBROLLBACK

   pr_escribir_log "pr_finalizar_error: Salimos..."
   OMBDISCONNECT
   global k_fichero_log
   pr_escribir log ""
   pr_escribir_log ""
   pr_escribir_log "Revisar el log $k_fichero_log"

   # return and also bail from calling function
   return -code 2
}
# proc pr_finalizar_error

##################################################################################
# Nombre: pr_conectar
# Parametros:		Los parámetros son opcionales, si no se pasan, recoge los valores
#               de las variables globales de conexión. Si se pasan, a de ser en este
#               orden.
#               p_owb_user: Usuario del repositorio de diseño.
#               p_owb_pass: Contraseña del usuario.
#               p_owb_host: Máquina de la base de datos donde está el OWB.
#               p_owb_port: Puerto de la base de datos.
#               p_owb_sid:  Service name de la base de datos.
# Descripción: Procedimiento de conexión al OWB.
##################################################################################
proc pr_conectar args {
	# Comprobamos si nos han pasado los datos de conexión o si hay que leerlos
	# de las variables globales
	pr_escribir_log "Inicio de pr_conectar"
	if { [ llength $args ] == 5 } {
  	pr_escribir_log "pr_conectar: Usamos las variables de la llamada: $args"
  	set v_owb_user [ lindex $args {0} ]
  	set v_owb_pass [ lindex $args {1} ]
  	set v_owb_host [ lindex $args {2} ]
		set v_owb_port [ lindex $args {3} ]
		set v_owb_sid [ lindex $args {4} ]
	} elseif { [ llength $args ] == 0 } {
		pr_escribir_log "pr_conectar: Usamos las variables globales"
		global k_owb_user
		global k_owb_pass
		global k_owb_host
		global k_owb_port
		global k_owb_sid
		set v_owb_user $k_owb_user
		set v_owb_pass $k_owb_pass
		set v_owb_host $k_owb_host
		set v_owb_port $k_owb_port
		set v_owb_sid $k_owb_sid
	} else {
		pr_tratar_error "ERROR pr_conectar Nº argumentos incorrecto: $args"
		pr_finalizar_error "Fin de pr_conectar, desconectando..."
	}
	
	pr_escribir_log "pr_conectar: Nos conectamos: $v_owb_user/$v_owb_pass@$v_owb_host:$v_owb_port:$v_owb_sid"
	set v_ejecucion [ pr_ejecutar_omb OMBCONNECT $v_owb_user/$v_owb_pass@$v_owb_host:$v_owb_port:$v_owb_sid USE REPOSITORY '$v_owb_user' ]
	if [ pr_tratar_error $v_ejecucion ] {
		pr_escribir_log "ERROR pr_conectar: Conexión con $v_owb_user $v_owb_pass $v_owb_host $v_owb_port $v_owb_sid"
		pr_escribir_log $v_ejecucion
		pr_finalizar_error "Fin de pr_conectar, desconectando..."
	}
	pr_escribir_log "Fin de pr_conectar"
}
# proc pr_conectar

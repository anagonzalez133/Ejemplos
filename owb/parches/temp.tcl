set ORACLE_HOME=C:\oracle\product\OWB11203
call C:\oracle\product\OWB11203\owb\bin\win32\OMBPlus.bat
OMBCONNECT owb11g/owb11g@uh15597:2486:u1105
set OMBLOG "D:\\OMBPLUS\\temp.log"

source D:\\OMBPLUS\\carga_constantes.tcl
source D:\\OMBPLUS\\procedimientos_base.tcl

OMBCONNECT $k_owb_user/$k_owb_pass@$k_owb_host:$k_owb_port:$k_owb_sid USE REPOSITORY '$k_owb_user'

set p_coleccion VERSION_8_0
set p_ruta_export ""
append p_ruta_export $k_ruta temp\\

source D:\\OMBPLUS\\prueba.tcl
proc_fichero_coleccion $k_proy_uxxiec $p_coleccion $k_ruta

proc pr_prueba { $p_coleccion } {
	set v_ejecucion [ proc_ejecutar_omb OMBCREATE COLLECTION '$p_coleccion' ]
  if [ proc_tratar_error $v_ejecucion ] {
  	proc_finalizar_error "pr_prueba: Al obtener los objetos de la colección $p_coleccion"
  }
  if { string match "API0408:*" "$v_ejecucion" } {
  	puts "La coleccion ya existe"
  } else {
  	puts "La coleccion no existe"
  }
}
# pr_prueba

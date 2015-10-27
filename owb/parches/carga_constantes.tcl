# Variables globales utilizadas en los scripts
# El valor de estas variables hay que ajustarlo para ejecución de
# los scripts en cada PC.
global k_ruta
global k_fichero_log
global k_owb_host
global k_owb_port
global k_owb_sid
global k_owb_user
global k_owb_pass
global k_owb_reparto
global k_proy_uxxiec
global k_proy_reparto

# Ruta donde se encuentran los scripts y ficheros de log utilizados durante la ejecución
set k_ruta "D:\\IEC025007\\pase\\"
# Creamos el directorio si no existe, si existe esta orden no devuelve error
file mkdir $k_ruta
# Ponemos un nombre por defecto al fichero donde almacenaremos los log
# aunque se debería crear un fichero de log nuevo cada vez que se ejecute un procedimiento
set k_fichero_log ""
append k_fichero_log $k_ruta ejecucion_ [ clock format [ clock seconds ] -format "%y%m%d_%H%M%S" ] ".log"

# Datos de conexión
set k_owb_host uh15597
set k_owb_port 2486
set k_owb_sid u1105
set k_owb_user OWB11G
set k_owb_pass OWB11G
set k_owb_reparto OWB11G_COSTES
set k_proy_uxxiec UXXI2_COSTES
set k_proy_reparto UXXI2_COSTES_ANALISIS

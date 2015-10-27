# Uso de los scripts de automatización de la instalación de parches de OWB BORRADOR
En este documento:
1 Introducción
2 Scripts necesarios
3 Cómo utilizar los scripts

# Introducción
Guía para el uso de los scripts desarrollados para automatizar en lo posible la instalación de parches de Oracle Warehouse Builder. Son scripts en el lenguaje OMB Plus (una mezcla del lenguaje TCL de scripting junto con comandos propios del OWB) para comunicarse con el OWB y hacer modificaciones desde una ventana de comandos.
Los scripts NO son totalmente automáticos, siempre hay que revisar los logs generados tras la instalación buscando mensajes de error, pero automatizan muchas de las tareas implicadas en la instalación. Contienen procedimientos para la conexión al OWB, exportación de colecciones y proyectos enteros, y para la importación de colecciones de OWB y su despliegue.
Hasta ahora estos scripts sólo han sido probados en Windows, habría que comprobar su funcionamiento en Unix.
 
# Scripts necesarios
A continuación se adjuntan los scripts necesarios para la automatización de las instalaciones:
carga_constantes.tcl
procedimientos_base.tcl
procedimientos_instalaciones.tcl
El procedimiento carga_constantes.tcl contiene constantes que facilitan la invocación de procedimientos y scripts. Será necesario personalizarlo para cada instalación, indicando los datos de conexión a la base de datos del OWB donde realizar la importación o exportación de la colección, la ruta donde dejar el fichero de log (conviene que sea la misma ruta donde se encuentran los ficheros necesarios para la instalación o donde se van a dejar dichos ficheros), y, si es necesario se pueden añadir constantes que faciliten el invocar de forma automática los procedimientos. Por ejemplo, la mayoría de los procedimientos solicitan como parámetro de entrada el proyecto de OWB donde trabajar, y en el fichero adjunto están declaradas dos constantes con el nombre de los dos proyectos de OWB que tienen las instalaciones de costes, en instalaciones de UXXI2, sólo será necesaria una constante proyecto.

# Cómo utilizar los scripts
Como prerequisito, es necesario tener instalado el OWB en la máquina donde se van a lanzar estos scripts. Localizar el directorio donde está instalado, para personalizar las rutas dadas en las siguientes instrucciones:
1. En primer lugar, abrir una ventana de comandos.
2. A continuación establecer la variable de entorno ORACLE_HOME con la ruta donde tengamos instalado el OWB:
   set ORACLE_HOME=C:\oracle\product\OWB11203
3. A continuación invocar el OMB Plus:
   call C:\oracle\product\OWB11203\owb\bin\win32\OMBPlus.bat
Al cabo de unos segundos cambiará el prompt de nuestra ventana de comandos por el del OMB Plus, indicando que estamos ejecutándolo:

4. A continuación cargar las constantes globales invocando el script de carga de constantes. En este ejemplo el script se encuentra en el mismo directorio que se indica en la constante k_ruta del ejemplo:
   source D:\\OMBPLUS\\carga_constantes.tcl
   Si la ruta contiene espacios en blanco hay que hacer la llamada poniendo dobles comillas al indicar el fichero a cargar:
   source "D:\\Mi ruta\\carga_constantes.tcl"
   La doble barra \\ en la ruta es necesaria porque el carácter \ es un carácter de escape en TCL.

   Al cargar las constantes ya se define por defecto el nombre de un fichero donde escribir los mensajes de log, aunque luego al ejecutar los procedimientos se suele redefinir el fichero. Si la ruta indicada por la constante k_ruta contiene algún error (el script la crea si no existe) se producirá un error en la ejecución de este comando.
5. A continuación cargar los procedimientos base:
   source D:\\OMBPLUS\\procedimientos_base.tcl
6. Y por último cargar los procedimientos propios de la instalación de parches de OWB:
   source D:\\OMBPLUS\\procedimientos_instalaciones.tcl
7. Para captar mensajes que salen por pantalla pero que no quedan grabados en el log conviene invocar un segundo log adicional:
   append p_ruta_omblog $k_ruta temp.log
   set OMBLOG $p_ruta_omblog
   Esto grabará en el fichero temp.log ubicado en la ruta indicada por la constante k_ruta información de comandos que se van ejecutando. Este log puede complementar la información del log generado por los procedimientos.

# Uso de los scripts:
Procedimiento de exportación de una colección
Procedimiento de instalación de parches

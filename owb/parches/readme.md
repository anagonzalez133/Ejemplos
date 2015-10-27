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

# Uso de los scripts. Procedimiento de exportación de una colección
## Introducción
Para la instalación de los parches es necesario generar una serie de ficheros con nombres determinados por el proyecto de OWB y el nombre de la colección exportada, por lo que conviene utilizar el procedimiento de exportación de la colección incluido en los procedimientos de instalación.
## Uso del procedimiento
Ajustar las constantes en carga_constantes.tcl, abrir la ventana de comandos, lanzar el OMB Plus y cargar los scripts según el procedimiento descrito en Cómo utilizar los scripts:

set ORACLE_HOME=C:\oracle\product\OWB11203

call C:\oracle\product\OWB11203\owb\bin\win32\OMBPlus.bat

source D:\\OMBPLUS\\carga_constantes.tcl

source D:\\OMBPLUS\\procedimientos_base.tcl

source D:\\OMBPLUS\\procedimientos_instalaciones.tcl

append p_ruta_omblog $k_ruta temp.log

set OMBLOG $p_ruta_omblog

A continuación llamar al procedimiento de exportación de una colección:

pr_exporta_coleccion PROYECTO COLECCION "RUTA"

Donde PROYECTO hace referencia al proyecto de OWB donde se ubica la colección, COLECCION es el nombre de la colección a exportar, que debe existir ya en el OWB, el procedimiento no la crea, y RUTA hace referencia a la ruta donde dejar los log y los ficheros generados por el procedimiento de exportación, y debe tener el formato D:\\mi_directorio\\. Si la ruta no contiene espacios en blanco, las dobles comillas no son necesarias.

Si en el fichero de carga_constantes tenemos guardada la constante k_proyecto con el nombre del proyecto de nuestro entorno y utilizamos la constante k_ruta del fichero de carga_constantes para dejar los ficheros de la exportación, la forma de invocar a este procedimiento es:

pr_exporta_coleccion $k_proyecto mi_coleccion "$k_ruta"
## Descripción del procedimiento
En primer lugar, este procedimiento define un nuevo fichero de log para la exportación con el formato $k_ruta/ejecucion_YYMMDD_HHMISS.log (se utiliza la constante k_ruta definida en procedimientos_base.tcl para el fichero, aunque al procedimiento se le haya invocado con otra ruta).

A continuación crea (si no existía ya) el subdirectorio pase en el directorio RUTA con que se ha invocado el procedimiento. Dentro de este directorio es donde va a situar los ficheros resultado de la exportación:

PROYECTO_mapeos_coleccion_COLECCION.lst

PROYECTO_pflow_coleccion_COLECCION.lst

PROYECTO_objetos_coleccion_COLECCION.lst

PROYECTO_COLECCION.mdl

Cada vez que se ejecuta este procedimiento estos ficheros se borran si ya existían y se vuelven a crear vacíos, rellenándolos el procedimiento durante su ejecución.
El procedimiento se conecta al OWB (con los datos de conexión definidos en carga_constantes.tcl) y recupera los objetos que forman parte de la colección indicada al invocarlo.

Va analizando objeto por objeto el tipo de objeto de que se trata y si es desplegable o no:
Si se trata de un mapeo, lo graba en el fichero PROYECTO_mapeos_coleccion_COLECCION.lst
Si se trata de un process flow, lo graba en el fichero PROYECTO_pflow_coleccion_COLECCION.lst
Si el objeto es desplegable, lo graba en fichero PROYECTO_objetos_coleccion_COLECCION.lst con el listado de objetos a desplegar cuando se instala el parche

La casuística para determinar si un objeto es desplegable es la siguiente:
1. Si el objeto pertenece a un módulo cuyo nombre incluye el literal OLTP -> No es desplegable
2. Si el objeto es un procedimiento, función o TABLE_FUNCTION que pertenece a un paquete de base de datos, lo que hay que determinar si es desplegable o no es el paquete de base de datos, si el paquete es desplegable, es el que se graba en el fichero de objetos a desplegar.

Si el objeto es un process flow, lo que se despliega es el paquete de process flow, por tanto es el paquete lo que hay que determinar si es desplegable o no y lo que se graba en el fichero de objetos
Para el resto de objetos, se mira directamente la propiedad desplegable del objeto.

Una vez realizado el tratamiento del contenido de la colección se procede a exportar la colección. La orden de exportación genera un log específico, RUTA/PROYECTO_COLECCION_exp.log

Si todo ha ido bien, se procedimiento termina desconectándose del OWB, así como en cualquier momento que se produzca un error controlado durante el proceso.
Si se produce un error no controlado, es posible que el procedimiento termine sin realizar la desconexión del repositorio del OWB, con lo que si se intenta volver a lanzar este procedimiento u otro  se producirá un error al intentar conectarse a un repositorio de OWB estando ya conectado. Las órdenes a lanzar para salir del repositorio de OWB sin grabar cambios realizados son:

OMBROLLBACK

OMBDISCONNECT

Aunque nos hayamos desconectado del repositorio de OWB, seguiremos ejecutando OMB Plus. Si además queremos salir de OMB Plus el siguiente comando a lanzar es:

exit

## Tratamiento de los ficheros tras la exportación
Una vez finalizada la exportación de la colección y generados los ficheros, es necesario, aparte de revisar los logs para comprobar si se ha producido un error, revisar los ficheros .lst generados durante la exportación:
1. El fichero de listado de mapeos será necesario retocarlo eliminando los mapeos que se crean nuevos en el parche. Este fichero se utiliza durante la importación para, antes de importar, borrar los operadores de los mapeos para evitar algunos bugs del OWB producidos al importar mapeos que ya existen, al no realizar correctamente la actualización de operadores (especialmente sensibles son los operadores tipo JOINER cuando se han modificado añadiendo un nuevo grupo o atributo). También hay que eliminar la última línea vacía del fichero, o bien el fichero está vacío, o bien la última línea contiene información.
2. Las mismas consideraciones hay que tener con el fichero de process flow. Eliminar los process flow nuevos y la línea vacía al final del fichero.
3. El fichero de objetos hay que repasarlo, este fichero se utiliza para desplegar objetos tras la importación de la colección, por lo que hay que asegurar:
a) Los objetos se despliegan en el orden correcto. Por defecto se genera el listado de objetos a desplegar con el siguiente orden: secuencias, tablas, tablas externas, vistas materializadas, vistas, funciones, procedimientos, table functions, paquetes, mapeos y process flow, sin embargo hay que revisar este orden por si acaso en un parche concreto hay que alterar algun orden determinado por dependencias concretas entre objetos.
b) Se eliminan duplicados de objetos, para no desplegar el mismo objeto más de una vez. Normalmente en una colección se incluyen process flow individuales, pero lo que se despliega es el paquete de process flow completo, por lo que el mismo paquete puede aparecer listado más de una vez.
c) Se añaden las acciones de despliegue a realizar con cada objeto: CREATE, UPGRADE, REPLACE o DELETE. El listado de objetos se genera como una lista de objetos con la siguiente estructura: "TIPO_OBJETO /PROYECTO/MODULO/OBJETO", hay que ir objeto por objeto añadiendo la acción de despliegue a realizar, de forma que el listado de objetos tenga la estructura "TIPO_OBJETO /PROYECTO/MODULO/OBJETO ACCION".
d) Al igual que en los casos anteriores, hay que eliminar la línea vacía al final del fichero.
# Uso de los scripts. Procedimiento de instalación de parches
## Introducción
Para la instalación de los parches es necesario disponer de una serie de ficheros con nombres determinados por el proyecto de OWB y el nombre de la colección exportada, por lo que conviene haber generado estos ficheros con el procedimiento de exportación de la colección incluido en los procedimientos de instalación. Los ficheros necesarios para la instalación del parche son:

PROYECTO_mapeos_coleccion_COLECCION.lst

PROYECTO_pflow_coleccion_COLECCION.lst

PROYECTO_objetos_coleccion_COLECCION.lst

PROYECTO_COLECCION.mdl

Los ficheros .lst son necesarios aunque estén vacíos.
## Uso del procedimiento
Ajustar las constantes en carga_constantes.tcl, abrir la ventana de comandos, lanzar el OMB Plus y cargar los scripts según el procedimiento descrito en Cómo utilizar los scripts:

set ORACLE_HOME=C:\oracle\product\OWB11203

call C:\oracle\product\OWB11203\owb\bin\win32\OMBPlus.bat

source D:\\OMBPLUS\\carga_constantes.tcl

source D:\\OMBPLUS\\procedimientos_base.tcl

source D:\\OMBPLUS\\procedimientos_instalaciones.tcl

append p_ruta_omblog $k_ruta temp.log

set OMBLOG $p_ruta_omblog

El procedimiento de instalación del parche no realiza una exportación completa del proyecto antes de realizar la instalación. Si es necesario hacer un backup completo del proyecto antes de instalar, consultar el anexo...

A continuación llamar al procedimiento de instalación de una colección:

pr_instala_parche PROYECTO COLECCION "RUTA"

Donde PROYECTO hace referencia al proyecto de OWB donde se ubica la colección, COLECCION es el nombre de la colección a instalar y RUTA hace referencia a la ruta donde se encuentran los ficheros necesarios para la instalación, y debe tener el formato D:\\mi_directorio\\. Si la ruta no contiene espacios en blanco, las dobles comillas no son necesarias.

Si en el fichero de carga_constantes tenemos guardada la constante k_proyecto con el nombre del proyecto y dejamos los los ficheros necesarios para la instalación en el mismo directorio que el indicado por la constante k_ruta del fichero de carga_constantes, la forma de invocar a este procedimiento es:

pr_exporta_coleccion $k_proyecto mi_coleccion "$k_ruta"

## Descripción del procedimiento
En primer lugar, este procedimiento define un nuevo fichero de log para la instalación con el formato $k_ruta/ejecucion_YYMMDD_HHMISS.log (se utiliza la constante k_ruta definida en procedimientos_base.tcl para el fichero, aunque al procedimiento se le haya invocado con otra ruta).

A continuación comprueba que los ficheros necesarios para la instalación existen, se conecta al OWB, y procede a borrar el contenido de los mapeos y luego de los process flow indicados en los correspondientes ficheros .lst.

Una vez ha terminado de borrar el contenido de mapeos y process flow, hace COMMIT, es importante tenerlo en cuenta si se produce algún error a continuación, pues los mapeos y process flow implicados van a estar vacíos hasta que se importen correctamente.

A continuación se procede a la importación de la colección, cuando finaliza la importación, comprueba que los módulos de workflow tienen definida una localización de workflow (es posible que el bug ya no se esté dando en 11.2.0.3, pero en OWB 10, en algunas ocasiones, al importar procesos de workflow se perdía la localización de workflow) Si hay módulos de workflow sin localización se para el proceso para corregirlo manualmente. Luego habrá que realizar el despliegue en un proceso aparte.

Una vez finalizada la comprobación de los workflow, se procede al despliegue del parche, se abrirá una ventana con los datos de conexión al Control Center.
Y a continuación se mostrará una ventana con los últimos trabajos de despliegue realizados.
Cerrar la ventana con los trabajos de despliegue y el procedimiento de instalación continuará con el despliegue indicado por el fichero de objetos.

Cuando termina de desplegar todos los objetos se desconecta del OWB y vuelve a indicar dónde está el fichero de log para que lo revisemos a fin de comprobar que todo ha ido correctamente.

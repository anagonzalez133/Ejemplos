#!/bin/bash
# Con este script puedo programar un cron para automáticamente copiarme carpetas que desee a un disco duro
# cada cierto tiempo. Hay que proporcionar el identificador del disco duro al que queramos hacer la copia,
# y el script se encarga de comprobar si está conectado, y si es así, lanza la sincronizacion.

# Para obtener el identificador del disco duro, con sudo blkid (o con /sbin/blkid si se lanza con root,
# para ejecutar el blkid con root hay que indicar la ruta completa de la librería),
# el campo UUID corresponde al identificador, sustituirlo en este script cuando lo queramos ejecutar
identificador="XXXXXXXXXXXXXXXX"
existe=`/sbin/blkid |grep -i "$identificador"|wc -l`
label=`/sbin/blkid |grep -i "$identificador" |awk '{print$2}'|cut -d '"' -f 2`

# Cuando se hace el rsync, si la ruta origen acaba en barra no crea el directorio en la carpeta destino
# Si no acaba en /, lo crea 
if [ "$existe" == "1" ]
then
	rsync -av /home/user/Documentación /media/user/$label/Trabajo/
	# Para directorios grandes, hacemos una copia comparativa de ficheros, se comparan bloques de fichero,
  # modificando sólo los bloques que hayan variado, no el fichero entero.
	rsync -av --no-whole-file /home/User/VirtualBox\ VMs /media/user/$label/Trabajo/
fi

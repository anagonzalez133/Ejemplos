# Este fichero no es un ejecutable, sólo son comandos sueltos con apuntes de cosas utilizadas

# Arrancar y parar mysql
sudo service mysql status
sudo service mysql stop
sudo service mysql start

# Ejecución de postgres:
sudo -u postgres -i

# Lanzar un script en mysql para crear una base de datos
mysql -u root -p /path/script.sql

# Conectarse a una base de datos
mysql -u root -p
use [database]

mysql [database] -u [user] -p

# Dar acceso a un usuario a una BBDD MariaDB:
GRANT ALL ON DATABASE.* TO 'user'@'x.x.x.%';

cp -a .jitsi_copia .jitsi

# Recuperar el calendario en la barra de sistema:
sudo killall unity-panel-service

# Instalación de diferentes versiones de java: http://www.ubuntu-guia.com/2012/04/instalar-oracle-java-7-en-ubuntu-1204.html#

# version del entorno runtime (JRE):
java -version
# version del entorno de compilación (JDK):
javac -version

# Deberían ser de la misma versión

# Seleccionar la versión de java a usar por defecto:
sudo update-alternatives --config java

# Arranque local del servidor de Pentaho:
cd bin/Pentaho_6_1/biserver-ce/
./start-pentaho.sh
tail -f tomcat/logs/catalina.out | grep "Catalina.start Server startup"

# Lanzar el proceso de autodocumentación de Pentaho
cd bin/Pentaho_6_1/data-integration
sh kitchen.sh -file:/path/document-folder.kjb -param:"INPUT_DIR"=/repositorio_path/pdi/ -param:"OUTPUT_DIR"=/repositorio_path/autodocumentacion

# The df command stand for “disk filesystem“, it is used to get full summary of available and used disk space usage of file system on Linux system
df -h # The df command provides an option to display sizes in Human Readable formats by using ‘-h’ (prints the results in human readable format (e.g., 1K 2M 3G)).

# Espacio ocupado por un directorio, con el listado del espacio ocupado por los subdirectorios
du -kh
# Tamaño de un directorio y sus subdirectorios:
du -sh directorio


# Búsqueda de un texto en un fichero
grep -Rl "text-to-find-here" /path
# i stands for ignore case (optional in your case), it makes it slow search.
# R stands for recursive.
# l stands for "show the file name, not the result itself".
# n stands for show the line number
# / stands for starting at the root of your machine.

# Ejemplo búsqueda uso de tabla en transformaciones y jobs
cd repositorio/pdi/ac
grep -Ril "TFC_HIST_MATRICULA"

# Compresión y descompresión
 tar -zcf archive-name.tar.gz directory-name

# z : Compress archive using gzip program
# c: Create archive
# v: Verbose i.e display progress while creating archive
# f: Archive File name
# x: Uncompress

tar zxf archive-name.tar.gz directory-name

# Listar el contenido de un tar
tar -ztf my-data.tar.gz 'search-pattern (*.log o lo que sea)'

# Syntax for zipping a file or folder.
zip -r archivename.zip file1 file2 folder1
# -r es para añadir al zip todo el contenido dentro del directorio

# Zip individual files to a zip archive
zip abc.zip file1 file2 file3

# How to exclude a file in a folder when compressing it.
zip -r abc.zip 1/ -x 1/bash-support.zip

# List all the files stored in a zip file. Cualquiera de las 3 órdenes
unzip -l abc.zip
less abc.zip
zipinfo -1 abc.zip

# Delete a file in an archive with out extracting entire zip file.
zip -d abc.zip path/file
# Ej. zip -d abc.zip 1/bash-support.zip

# Extract your files from a zip folder
unzip abc.zip

# To extract to a specific directory use -d option
unzip abc.zip -d /tmp

# Borrar directorio y su contenido
rm -r directorio
# Si además no queremos confirmación
rm -rf directorio

# Copiar directorio:
cp -ar /home/vivek/letters /usb/backup

# Crea el directorio letters dentro de /usb/backup
# -a : Preserve the specified attributes such as directory an file mode, ownership, timestamps, if possible additional attributes: context, links, xattr, all.
# -v : Explain what is being done.
# -r : Copy directories recursively.

# Lanzar en el servidor un trabajo:
cd data-integration
nohup sh kitchen.sh -file=/path/JB_XXX.kjb -logfile=ana_prueba.log &
nohup sh pan.sh -file=/path/TR_XXX.ktr -logfile=ana_prueba.log -param:P_FECHA_DESDE=01/01/1900 -param:P_FECHA_HASTA=31/12/2100 &

nohup sh pan.sh -file=/path/TR_XXX.ktr -logfile=ana_prueba.log -param:"P_DB_ORIGEN"=MYDB -param:"P_TABLA_ORIGEN"=my_table &

# Programar un trabajo:
crontab -e
# Visualizar los trabajos programados:
crontab -l

# Instalar un paquete deb:
sudo dpkg -i *.deb

# Partir un fichero por líneas
split -l 811878 catalina.out catalina.out
# Parte el fichero catalina.out en ficheros de 811.878 líneas (o las que sobren en el último fichero) generando como salida ficheros catalina.outaa, catalina.outab, etc
# El fichero catalina.out sigue existiendo, luego podemos hacer un mv para dejar sólo el último fichero o lo que necesitemos.


# Backup de los logs del servidor
# 1: Extraer a local el catalina.out y revisar el número de fila a partir del cual hacer el split
cd biserver-ce/tomcat/logs
split -l xxx catalina.out catalina.out
mv catalina.outaa catalina.out_2017-01
# Revisar que no se haya modificado el catalina.out mientras hemos hecho el split antes de hacer el mv
mv catalina.outab catalina.out
# 2: Ahora ya movemos todos los logs a un fichero comprimido
ls *2017-01*
tar -zcf logs_pentaho_201701.tgz *2017-01*
# Comprobar que en el tgz están todos los ficheros que queremos incluir antes de borrar
tar -ztf logs_pentaho_201701.tgz
rm *2017-01*
mv logs_pentaho_201701.tgz backup/

# Acceder a un comando del histórico
cat /home/usuario/.bash_history | grep export


# Cambiar propietario de un fichero
chown usuario:grupo

# Búsqueda de un archivo
find . -name "*.db"

# Para sacar los 20 ficheros de mayor tamaño
find . -xdev -type f -ls | sort +6nr -7 | head -20







# Para que el virtual box salga a internet
sudo -i
# password root, la ip es la de la máquina virtual
iptables -t nat -I POSTROUTING -s X.X.X.X -j MASQUERADE
echo 1 > /proc/sys/net/ipv4/ip_forward



# Arrancar la base de datos de virtual box
sqlplus / as sysdba
startup
alter pluggable database all open;
select name, open_mode from v$pdbs;


# A partir de la versión 12.1.0.2 se permite salvar el estado de arranque para que se autoarranque cuando arranquemos la base de datos:
alter pluggable database pdb_name save state;

# A continuación arrancar el listener:
cd /opt/oradb/app/oracle/product/12.2.0/dbhome_12_2/bin
lsnrctl status
lsnrctl start




# Para conectarme a las distintas máquinas sin meter clave.
# Para copiar la clave pública a una máquina nueva ejecutar:
ssh-copy-id usuario@maquina
# Me pedirá la clave del usuario y copiará entonces la clave pública. La siguiente vez que me conecte ya no me pedirá la clave (tan sólo la passphrase el primer inicio de sesión)

# Para generar la clave:
ssh-keygen
# , esto genera los ficheros de claves en ~home/.ssh

# Pruebas para revisar el characterset de las conexiones Oracle
# Documentación en Oracle Support que se ha utilizado:
# https://support.oracle.com/epmos/faces/SearchDocDisplay?&id=265090.1 How to check Unix terminal Environments fro the capability to display extended characters
# https://support.oracle.com/epmos/faces/SearchDocDisplay?&id=264157.1 The correct NLS_LANG setting in Unix Environments
# https://support.oracle.com/epmos/faces/SearchDocDisplay?&id=115001.1 NLS_LANG CLient Settings and JDBC Drivers
# https://support.oracle.com/epmos/faces/SearchDocDisplay?&id=265090.1 How to check Unix terminal Environments for the capability to display extended characters
# https://docs.oracle.com/cd/E11882_01/server.112/e10729/applocaledata.htm#NLSPG601 Oracle Database Globalizations Support Guide: Locale Data

# Tras diferentes pruebas, en la conexión debe coincidir el NLS_CHARACTERSET de la tabla de catálogo NLS_DATABASE_PARAMETERS
# Y el del parámetro NLS_LANG que hay que definir en el sistema operativo antes de hacer la conexión por SQL Plus.
# Así, si el NLS_CHARACTERSET es WE8ISO8859P15, haciendo:
# export NLS_LANG=SPANISH_SPAIN.WE8ISO8859P15
# funcionan las querys:
SELECT 'Master’s' texto FROM DUAL;
SELECT '😀' texto FROM DUAL;

# Si el NLS_CHARACTERSET de la base de datos es AL32UTF8, lo suyo sería:
# export NLS_LANG=SPANISH_SPAIN.AL32UTF8
# Aunque parece que con la configuración anterior también funciona.


/******************************************************************************
* Script para corregir/prevenir los problemas derivados de crear usuarios sin *
* cambiar el perfil por defecto para que expiren sus passwords.               *
*******************************************************************************/

/* Si estamos creando el usuario, lo mejor es generar un perfil diferente del *
* DEFAULT con las opciones para que no expire la contraseña y que se pueda    *
* volver a usar la misma contraseña un número ilimitado de veces. En entornos *
* de desarrollo, lo aplicaremos directamente al perfil DEFAULT.               *
*******************************************************************************/

ALTER PROFILE DEFAULT LIMIT PASSWORD_REUSE_TIME UNLIMITED;
ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;

/* Si ya tenemos usuarios bloqueados con la password caducada, lanzar estos   *
* scripts con el usuario SYS */

SELECT username, account_status, expiry_date FROM dba_users
ORDER BY username;

/* Podemos tener usuarios en estado EXPIRED & LOCKED, EXPIRED (GRACE) o LOCKED *
* También hay usuarios que se crean por defecto ya bloqueados, estos usuarios  *
* vamos a dejarlos como están, los identificamos porque la fecha de caducidad  *
* es anterior a la creación de la base de datos. */

SELECT 'ALTER USER '|| name ||' IDENTIFIED BY VALUES '''|| spare4 ||';'|| password ||''';'
       || CHR(13) || 'ALTER USER ' || name || 'ACCOUNT UNLOCKED;' orden
FROM sys.user$
WHERE name IN (SELECT username FROM dba_users WHERE ACCOUNT_STATUS LIKE 'EXPIRED%' AND EXPIRY_DATE > TO_DATE('2016', 'YYYY'));

/* Lanzando el resultado de esta query, que primero restablece la contraseña del *
* usuario (utilizando la password encriptada) y luego desbloqueando su cuenta. */

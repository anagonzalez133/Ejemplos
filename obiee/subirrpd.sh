#!/bin/bash
. ${ORACLE_INSTANCE}/bifoundation/OracleBIApplication/coreapplication/setup/bi-init.sh
biserverxmlexec -I jerarquias_centro.xml -B uxxiec_sin_jerarquia.rpd -P ora10gas -O UXXIEC.rpd
biserverxmlexec -I jerarquias_actividad.xml -B UXXIEC.rpd -P ora10gas -O UXXIEC.rpd
biserverxmlexec -I jerarquias_elemento_coste.xml -B UXXIEC.rpd -P ora10gas -O UXXIEC.rpd
biserverxmlexec -I jerarquias_elemento_ingreso.xml -B UXXIEC.rpd -P ora10gas -O UXXIEC.rpd
biserverxmlexec -I connection_pools.xml -B UXXIEC.rpd -P ora10gas -O UXXIEC.rpd

export JAVA_HOME=${ORACLE_HOME}/jdk
. ${MW_HOME}/wlserver_10.3/server/bin/setWLSEnv.sh

MODULEA="${MW_HOME}/modules/com.oracle.jps-mbeans_1.0.0.0.jar"
MODULEB="${MW_HOME}/modules/com.oracle.jps-api_1.0.0.0.jar"
MODULES="${MODULEA}${CLASSPATHSEP}${MODULEB}"
export MODULES
echo MODULES=${MODULES}

CLASSPATH="${MODULES}${CLASSPATHSEP}${CLASSPATH}"
export CLASSPATH

${JAVA_HOME}/bin/java weblogic.WLST subirrpd.py

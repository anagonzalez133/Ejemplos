#!/bin/bash
export JAVA_HOME=${ORACLE_HOME}/jdk
. ${MW_HOME}/wlserver_10.3/server/bin/setWLSEnv.sh

MODULEA="${MW_HOME}/modules/com.oracle.jps-mbeans_1.0.0.0.jar"
MODULEB="${MW_HOME}/modules/com.oracle.jps-api_1.0.0.0.jar"
MODULES="${MODULEA}${CLASSPATHSEP}${MODULEB}"
export MODULES
echo MODULES=${MODULES}

CLASSPATH="${MODULES}${CLASSPATHSEP}${CLASSPATH}"
export CLASSPATH

${JAVA_HOME}/bin/java weblogic.WLST roles.py

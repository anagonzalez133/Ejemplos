# Pedasso script OMB Plus posteado en el foro, para revisar como solicitar variables y controlar errores.
# http://forums.oracle.com/forums/thread.jspa?threadID=678072


package require java

##################################################################################
#
# Basic Connection Details
#
##################################################################################

# OWB Repository Connection
set OWB_DEG_USER    my_username
set OWB_DEG_PASS    my_password
set OWB_DEG_HOST    my.host.net
set OWB_DEG_PORT    1628
set OWB_DEG_SRVC    orcl
set OWB_DEG_REPOS   owb_mgr

set ORA_MODULE_NAME    ERS_ETL_APP

global VERBOSE_LOG
set VERBOSE_LOG "1"
set SPOOLFILE "c:/omb/logfile.txt"


##################################################################################
#
# Procedures from our standard OWB library
#
##################################################################################

##################################################################################
# Default logging function.
#  Accepts inputs: LOGMSG - a text string to output
#                  FORCELOG - if "1" then output regardless of VERBOSE_LOG setting
##################################################################################
proc log_msg {LOGTYPE LOGMSG {FORCELOG "0"}} {
   global VERBOSE_LOG
   global SPOOLFILE

   if [info exists SPOOLFILE] {
      set fout [open "$SPOOLFILE" a+]      
      if { $VERBOSE_LOG == "1"} {
        puts $fout "$LOGTYPE:-> $LOGMSG"
        puts "$LOGTYPE:-> $LOGMSG"
      } else {
          if { $FORCELOG == "1"} {
             puts $fout "$LOGTYPE:-> $LOGMSG"
             puts "$LOGTYPE:-> $LOGMSG"
          }  
      }
      close $fout
   } else {
      if { $VERBOSE_LOG == "1"} {
        puts "$LOGTYPE:-> $LOGMSG"
      } else {
          if { $FORCELOG == "1"} {
             puts "$LOGTYPE:-> $LOGMSG"
          }  
      }
   }
}


##################################################################################
# Default rollbabk and exit with error code function.
##################################################################################
proc exit_failure { msg } {

   log_msg ERROR "$msg"
   log_msg ERROR "Rolling Back....."

   exec_omb OMBROLLBACK

   log_msg ERROR "Exiting....."

   # return and also bail from calling function
   return -code 2
}

##################################################################################
# Generic wrapper for OMB+ calls
##################################################################################
proc exec_omb { args } {

   # log_msg OMBCMD "$args"

   # the point of this is simply to return errorMsg or return string, whichever is applicable,
   # to simplify error checking using omb_error{}

   if [catch { set retstr [eval $args] } errmsg] {
      log_msg OMBCMD "$args"
      log_msg OMB_ERROR "$errmsg"
      log_msg "" ""
      return $errmsg
   } else {
   #   log_msg OMB_SUCCESS "$retstr"
   #   log_msg "" ""
      return $retstr
   }

}


##################################################################################
# Generic test for errors returned from OMB+ calls
##################################################################################
proc omb_error { retstr } {
   # OMB, Oracle, or java errors may have caused a failure.
   if [string match OMB0* $retstr] {
      return 1
   } elseif [string match ORA-* $retstr] {
      return 1
   } elseif [string match java.* $retstr] {
      return 1
   } else {
      return 0
   }
}



##################################################################################
#
# Procedures from our standard OWB/SQL library
#
##################################################################################

proc oracleConnect { serverName databaseName portNumber username password } {

   # import required classes 
   java::import java.sql.Connection
   java::import java.sql.DriverManager
   java::import java.sql.ResultSet
   java::import java.sql.SQLWarning
   java::import java.sql.Statement
   java::import java.sql.CallableStatement
   java::import java.sql.ResultSetMetaData 
   java::import java.sql.DatabaseMetaData 
   java::import java.sql.Types
   java::import oracle.jdbc.OracleDatabaseMetaData

   # load database driver .
   java::call Class forName oracle.jdbc.OracleDriver 

   # set the connection url.
   append url jdbc:oracle:thin
   append url :
   append url $username
   append url /
   append url $password
   append url "@"
   append url $serverName
   append url :
   append url $portNumber
   append url :
   append url $databaseName

   set oraConnection [ java::call DriverManager getConnection $url ] 
   set oraDatabaseMetaData [ $oraConnection getMetaData ]
   set oraDatabaseVersion [ $oraDatabaseMetaData getDatabaseProductVersion ]

   puts "Connected to: $url"
   puts "$oraDatabaseVersion"
   
   return $oraConnection 
}


proc oracleDisconnect { oraConnect } {
  $oraConnect close
}

proc oraJDBCType { oraType } {
  #translation of JDBC types as defined in XOPEN interface
  set rv "NUMBER"
  switch $oraType {
     "0" {set rv "NULL"}
     "1" {set rv "CHAR"}
     "2" {set rv "NUMBER"}
     "3" {set rv "DECIMAL"}
     "4" {set rv "INTEGER"}
     "5" {set rv "SMALLINT"}
     "6" {set rv "FLOAT"}
     "7" {set rv "REAL"}
     "8" {set rv "DOUBLE"}
     "12" {set rv "VARCHAR"}
     "16" {set rv "BOOLEAN"}
     "91" {set rv "DATE"}
     "92" {set rv "TIME"}
     "93" {set rv "TIMESTAMP"}
     default {set rv "OBJECT"}
  }
  return $rv
}

proc oracleQuery { oraConnect oraQuery } {

   set oraStatement [ $oraConnect createStatement ]
   set oraResults [ $oraStatement executeQuery $oraQuery ]

   # The following metadata dump is not required, but will be a helpfull sort of thing
   # if ever want to really build an abstraction layer
   set oraResultsMetaData [ $oraResults getMetaData ] 
   set columnCount        [ $oraResultsMetaData getColumnCount ]
   set i 1

   #puts "ResultSet Metadata:"
   while { $i <= $columnCount} {
      set fname [ $oraResultsMetaData getColumnName $i]
      set ftype [oraJDBCType [ $oraResultsMetaData getColumnType $i]]
      #puts "Output Field $i Name: $fname Type: $ftype"
      incr i
   }
   # end of metadata dump

   return $oraResults
}


##################################################################################
#
#                MAIN SCRIPT BODY
#
##################################################################################



##################################################################################
#  Connect to repos
##################################################################################

set print [exec_omb OMBCONNECT $OWB_DEG_USER/$OWB_DEG_PASS@$OWB_DEG_HOST:$OWB_DEG_PORT:$OWB_DEG_SRVC USE REPOSITORY '$OWB_DEG_REPOS']

if [omb_error $print] {
    log_msg ERROR "Unable to connect to repository."
    log_msg ERROR "Exiting Script.............."
    return 
} else {
    log_msg LOG "Connected to Repository"    
}

##################################################################################
# Connect to project
##################################################################################

puts -nonewline "Which project do you want to validate? "
set CHK_PROJECT_NAME [gets stdin]

set print [exec_omb OMBCC '$CHK_PROJECT_NAME']

if [omb_error $print] {

   log_msg LOG "Project $CHK_PROJECT_NAME does not exist. No Validation Required...."
   exec_omb OMBDISCONNECT
   return
  
} else {
   log_msg LOG "Verified project $CHK_PROJECT_NAME exists"
}    

set CURRENT_DEPLOYED_LOCATION [exec_omb OMBRETRIEVE ORACLE_MODULE '$ORA_MODULE_NAME' GET REFERENCE LOCATION]
if [omb_error $print] {
   log_msg LOG "Unable to retrieve location . Exiting...."
   exec_omb OMBDISCONNECT
   return
  
} else {
   log_msg LOG "Retrieved location $CURRENT_DEPLOYED_LOCATION"
}    

 log_msg LOG "Project deployed to CURRENT_DEPLOYED_LOCATION ..."   
 set CHK_PASSWORD [OMBRETRIEVE LOCATION '$CURRENT_DEPLOYED_LOCATION' GET PROPERTIES (SCHEMA)]
 set CHK_HOST [OMBRETRIEVE LOCATION '$CURRENT_DEPLOYED_LOCATION' GET PROPERTIES (HOST)]
 set CHK_PORT [OMBRETRIEVE LOCATION '$CURRENT_DEPLOYED_LOCATION' GET PROPERTIES (PORT)]
 set CHK_SERVICE [OMBRETRIEVE LOCATION '$CURRENT_DEPLOYED_LOCATION' GET PROPERTIES (SERVICE)]

 set CHK_SCHEMA   $CHK_PASSWORD
 set CHK_LOCATION $CURRENT_DEPLOYED_LOCATION

##################################################################################
# Validate to Control Center 
##################################################################################

   log_msg LOG "Connecting to Control Center " 
set print [exec_omb OMBCONNECT CONTROL_CENTER USE '$CHK_PASSWORD' ]
if [omb_error $print] {
    exec_omb OMBROLLBACK
    log_msg ERROR "Unable to connect to Control Center "
    log_msg ERROR "$print" 
    exit_failure "Exiting Script.............."
}
exec_omb OMBCOMMIT


log_msg LOG "Checking existing MetaData." 
set print [exec_omb OMBALTER LOCATION '$CHK_LOCATION' SET PROPERTIES (PASSWORD) VALUES ('$CHK_PASSWORD')]
exec_omb OMBCOMMIT

exec_omb OMBCC '$ORA_MODULE_NAME'

log_msg LOG "Checking Tables...." 

set tabList [ OMBLIST TABLES ]

set oraConn [oracleConnect $CHK_HOST $CHK_SERVICE $CHK_PORT $CHK_SCHEMA $CHK_PASSWORD ]

foreach tabname $tabList {

     #get list of columns and data types from OWB
     set owb_column_lst [ OMBRETRIEVE TABLE '$tabname' GET COLUMNS ]
     
     #get list of datatypes
     set owb_type_list {}

     foreach tcol $owb_column_lst {
          set ctyp [exec_omb OMBRETRIEVE TABLE '$tabname' COLUMN '$tcol' GET PROPERTIES (DATATYPE) ]
          lappend owb_type_list $ctyp
     }
     set owb_column_string [join $owb_column_lst ","]
     set owb_type_string [join $owb_type_list ","]     
          
     #get list of columns and data types from data dictionary
     set sql_column_lst {}
     set sql_type_lst {}
     
     set sqlStr "select  alt.column_name, alt.data_type from all_Tab_columns alt, user_synonyms us where alt.owner = us.TABLE_OWNER and   alt.TABLE_NAME = us.table_name and us.synonym_name = upper('$tabname') order by column_id"
     set oraRs [oracleQuery $oraConn $sqlStr]
     while {[$oraRs next]} {
        set colName [$oraRs getString column_name]
        lappend sql_column_lst $colName
        set colType [$oraRs getString data_type]
        lappend sql_type_lst $colType
     }  
     $oraRs close
     
     set sql_column_string [join $sql_column_lst ","]
     set sql_type_string [join $sql_type_lst ","]     
     
     if [string match $sql_column_string $owb_column_string] {
        #do nothing
        set sql_column_string {}
     } else {
        log_msg LOG "TABLE $tabname DATABASE AND METADATA DO NOT MATCH - column name change!!!!!!!!!!!!"
        log_msg LOG "OWB:-> $owb_column_string"
        log_msg LOG "SQL:-> $sql_column_string"
     }
     if [string match $sql_type_string $owb_type_string] {
        #do nothing
        set sql_type_string {}
     } else {
        log_msg LOG "TABLE $tabname DATABASE AND METADATA DO NOT MATCH - column data type change!!!!!!!!!!!!"
        log_msg LOG "OWB:-> $owb_type_string"
        log_msg LOG "SQL:-> $sql_type_string"
     }
}


$oraConn close

exec_omb OMBDISCONNECT










# -------------------------------------------------------------------------------
# Manejo de los argumentos con que se llama a un procedimiento tcl
# -------------------------------------------------------------------------------
# Use $argv to get the list of arguments. Use $argc to get the count of arguments.

# So, I created a file called "arg.tcl" in owb\bin\admin that looks like this:

puts $argc
puts $argv

# Then, from owb\bin\win32, I start OMBPlus..

OMBPlus arg.tcl hello
1
hello



OMBPlus arg.tcl hello1 hello2
2
hello1 hello2



OMBPlus arg.tcl "hello1 hello2"
1
{hello1 hello2}



# Google "tcl command line arguments" for more info 

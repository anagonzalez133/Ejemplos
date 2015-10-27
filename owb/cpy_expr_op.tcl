#
# Clone an Expression Operator in a map.
#
# Usage:
#   OMBCC '/YOUR_PROJECT/YOUR_MODULE'
#   source <this_file>
#   clone_ex SOURCE_MAP_NAME SOURCE_EXPRESSION_OP_NAME TARGET_MAP_NAME
#
#
#
proc clone_ex {source_map expression_oper target_map} {

 # Add the expression operator
 OMBALTER MAPPING '$target_map' ADD EXPRESSION OPERATOR '$expression_oper'

 set l_groups [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GET GROUPS]

 # Rename the groups...
 foreach g $l_groups {
   if {[OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' GET PROPERTIES (DIRECTION)] == 1} {
     OMBALTER MAPPING '$target_map' MODIFY GROUP 'INGRP1' OF OPERATOR '$expression_oper' SET PROPERTIES (PHYSICAL_NAME) VALUES ('$g')
   } else {
     OMBALTER MAPPING '$target_map' MODIFY GROUP 'OUTGRP1' OF OPERATOR '$expression_oper' SET PROPERTIES (PHYSICAL_NAME) VALUES ('$g')
   }

   set l_atts [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' GET ATTRIBUTES]
   foreach a $l_atts {
     set l_adty [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (DATATYPE)]
     set l_alen [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (LENGTH)]
     set l_apre [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (PRECISION)]
     set l_asca [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (SCALE)]

     # Add attribute
     OMBALTER MAPPING '$target_map' ADD ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper'

     OMBALTER MAPPING '$target_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper' \
      SET PROPERTIES (DATATYPE) VALUES ('$l_adty')
     if {[regexp ".*NUM.*" $l_adty] > 0} {
      OMBALTER MAPPING '$target_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper' \
       SET PROPERTIES (PRECISION) VALUES ('$l_apre')
      OMBALTER MAPPING '$target_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper' \
       SET PROPERTIES (SCALE) VALUES ('$l_asca')
     }
     if {[regexp ".*CHAR.*" $l_adty] > 0} {
      OMBALTER MAPPING '$target_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper' \
       SET PROPERTIES (LENGTH) VALUES ('$l_alen')
     }

     # If it is an OUTPUT group, set the expression. Need to escape single quotes...
     if {[OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' GET PROPERTIES (DIRECTION)] == 2} {
       set l_expr [OMBRETRIEVE MAPPING '$source_map' OPERATOR '$expression_oper' GROUP '$g' ATTRIBUTE '$a' GET PROPERTIES (EXPRESSION)]
       if {[string first "'" $l_expr] != -1} {
         set l_expr [string map {"'" "''"} $l_expr]
       }
       set v ""
       if {[llength $l_expr] == 1} {
         set v [lindex $l_expr 0]
       } else {
         for each t $l_expr {
           append v $t
         }
       }
       OMBALTER MAPPING '$target_map' MODIFY ATTRIBUTE '$a' OF GROUP '$g' OF OPERATOR '$expression_oper' \
        SET PROPERTIES (EXPRESSION) VALUES ('$v')
     }
   }
 }
}

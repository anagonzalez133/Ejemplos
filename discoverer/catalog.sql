/***************************************************************
* Búsqueda de las últimas ejecuciones de los libros de trabajo *
****************************************************************/
SELECT DISTINCT DOCS.DOC_CREATED_BY DOC_OWNER,
                DOCS.DOC_NAME DOC_NAME,
		    (  SELECT TRUNC(MAX(DM.QS_CREATED_DATE))
		       FROM EUL5_QPP_STATS DM
		       WHERE DM.QS_DOC_NAME = STATS.QS_DOC_NAME
		    ) LAST_RUN
FROM EUL5_QPP_STATS STATS,
     EUL5_DOCUMENTS DOCS
WHERE DOCS.DOC_NAME NOT LIKE 'Workbook%'
AND STATS.QS_CREATED_DATE(+) > :Fecha_minima
AND DOCS.DOC_CREATED_DATE DOCS.DOC_NAME = STATS.QS_DOC_NAME(+)
HAVING :Maxima_ejecucion >= NVL((  SELECT TRUNC(MAX(DM.QS_CREATED_DATE))
                                   FROM EUL5_QPP_STATS DM
					     WHERE DM.QS_DOC_NAME = STATS.QS_DOC_NAME),
					   '01-JAN-2000')
GROUP BY DOCS.DOC_CREATED_BY, DOCS.DOC_NAME, STATS.QS_DOC_NAME
ORDER BY LAST_RUN DESC, DOCS.DOC_CREATED_BY, DOCS.DOC_NAME;

/***********************************************************
* Búsqueda de dónde se usan elementos en libros de trabajo *
************************************************************/
SELECT DISTINCT o100270.i104288 AS e104288, o100273.i104596 AS e104596,
                o100273.i104600 AS e104600, o100273.i104625 AS e104625,
                o100270.i104646 AS e104646, o100273.i104724 AS e104724,
                o100273.i104732 AS e104732, o100273.i104748 AS e104748
FROM (  SELECT o100113.ba_name AS i104288, o100144.obj_id AS i104602,
                        DECODE (o100144.obj_type,
                                'COBJ', 'Complex',
                                'SOBJ', 'Simple',
                                'CUO', 'Custom',
                                'Unknown'
                               ) AS i104646
        FROM eul5_bas o100113,
             eul5_objs o100144,
             eul5_ba_obj_links o100112
        WHERE (o100113.ba_id(+) = o100112.bol_ba_id)
        AND (o100144.obj_id = o100112.bol_obj_id)
     ) o100270,
     (  SELECT o100144.obj_developer_key AS i104596,
               DECODE (o100144.obj_hidden, 1, 'Hidden', 'Visible') AS i104600,
               o100144.obj_id AS i104615,
               o100144.obj_name AS i104625,
               o100128.exp_developer_key AS i104724,
               DECODE (o100128.it_hidden, 1, 'Yes', 0, 'No', TO_CHAR (o100128.it_hidden)) AS i104732,
               o100128.exp_name AS i104748
        FROM eul5_expressions o100128,
             eul5_objs o100144
        WHERE (o100144.obj_id = o100128.it_obj_id)
     ) o100273
WHERE ((o100270.i104602(+) = o100273.i104615))
and o100273.i104748 like 'Tipo%conva%'
ORDER BY o100273.i104625 ASC, o100270.i104646 ASC, o100273.i104600 ASC

/*********************************************************************
* Búsqueda de dónde se usa una determinada JOIN en libros de trabajo *
**********************************************************************/
SELECT o100232.doc_developer_key workbook_cod, o100232.doc_name workbook_de,
       o100234.ex_to_devkey join_cod, o100234.ex_to_name join_de,
       o100234.ex_to_par_devkey, o100234.ex_to_par_name
FROM uxxidw_es.eul5_documents o100232,
     uxxidw_es.eul5_elem_xrefs o100234
WHERE TO_NUMBER(o100234.ex_from_id) = o100232.doc_id
AND (o100232.doc_content_type = 'application/vnd.oracle-disco.wb')
AND o100234.ex_to_type = 'JOI'
AND o100234.ex_to_name like '%Tipo%Acceso%'
ORDER BY o100232.doc_name ASC, o100234.ex_to_devkey ASC
•	Búsqueda de estadísticas de uso de Discoverer por los usuarios no propietarios de la EUL:
SELECT DECODE (docs_tb.doc_id, NULL, 'Ad-hoc', 'Pre-Defined') AS tipo,
       to_char(estadis_tb.qs_created_date, 'MM') mes_consulta,
       TO_CHAR(estadis_tb.qs_created_date, 'YYYY') anio_consulta,
       DECODE(eul5_get_isitapps_eul, 1, eul5_get_apps_userresp(estadis_tb.qs_created_by), estadis_tb.qs_created_by) usuario,
       NVL(estadis_tb.qs_doc_name, '*** Unknown ***') libro,
       COUNT(DISTINCT(TRUNC(estadis_tb.qs_created_date, 'dd') || NVL(qs_doc_details, '*** Unknown ***'))) AS consultas_no,
       /* NVL(qs_doc_details, '*** Unknown ***') informe, */
       MAX(estadis_tb.qs_created_date) AS max_fecha
FROM eul5_qpp_stats estadis_tb,
     eul5_documents docs_tb
WHERE docs_tb.doc_name(+) = NVL(estadis_tb.qs_doc_name, '*** Unknown ***')
AND DECODE(eul5_get_isitapps_eul, 1, eul5_get_apps_userresp(estadis_tb.qs_created_by), estadis_tb.qs_created_by) NOT IN ('UXXIDW_ES', 'PICASSO_ES')
and docs_tb.doc_content_type (+) = 'application/vnd.oracle-disco.wb'
AND docs_tb.doc_content_type (+) = 'application/vnd.oracle-disco.wb'
GROUP BY DECODE (docs_tb.doc_id, NULL, 'Ad-hoc', 'Pre-Defined'), to_char(estadis_tb.qs_created_date, 'MM'),
         TO_CHAR(estadis_tb.qs_created_date, 'YYYY'), NVL(estadis_tb.qs_doc_name, '*** Unknown ***'),
         DECODE(eul5_get_isitapps_eul, 1, eul5_get_apps_userresp(estadis_tb.qs_created_by), estadis_tb.qs_created_by)
ORDER BY TO_CHAR(estadis_tb.qs_created_date, 'YYYY') desc, to_char(estadis_tb.qs_created_date, 'MM') desc,
         DECODE(eul5_get_isitapps_eul, 1, eul5_get_apps_userresp(estadis_tb.qs_created_by), estadis_tb.qs_created_by) ASC,
         DECODE (docs_tb.doc_id, NULL, 'Ad-hoc', 'Pre-Defined') DESC,
         NVL(estadis_tb.qs_doc_name, '*** Unknown ***') ASC

/*************************************************************
* Actualización de descripciones de elementos en Discoverer: *
* Este procedimiento ha sido usado en COSTES para actualizar *
* las descripciones de los campos libres a lo largo de los 15*
* niveles de una jerarquía. Asociado a un trigger de actuali-*
* zación en la tabla CORE.TCOR_TABLALIBRE, se ejecuta lo si- *
* guiente:                                                   *
**************************************************************/
CREATE OR REPLACE TRIGGER "CORE"."DCOR_TABLIB_ARU" 
  AFTER UPDATE
  ON CORE.TCOR_TABLALIBRE   --
  /* CHK VERSION: '6.0.0.3' */
  --
  -- FECHA      VERSIÓN  USR. QXXI    DESCRIPCIÓN DEL CAMBIO
  -- ========== ======== ==== ======= ====================================
  -- 14-01-2010 6.0.0.3  FCA  365391  Modificados las descripciones de los 
  --                                  15 niveles en vez de solo los niveles activos. 
  -- 26-11-2009 6.0.0.2  FCA  349915  Cambio en las actualizaciones de 
  --                                  clasificaciones en DWH
  -- 26-11-2009 6.0.0.1  MMM  361558  Se modifica para su compilación condicional
  --                                  en función de si existe o no DWH
  -- 29-07-2009 6.0.0.0  FCA  349915  Creación inicial
  --
  -----------------------------------------------------------------------------
  -- Propósito: actualización del metadato de tablas de discoverer
  -----------------------------------------------------------------------------
  REFERENCING NEW AS NEW OLD AS OLD
  FOR EACH ROW
BEGIN
  null;
  $if costes.pkg_cst_opc.enabledOWB $then
  DECLARE
     CURSOR c_clasificaciones
     IS
        SELECT 'N' || nivel.profundidad || '_CL' || cps.codigodwh || '_COD' key_exp_id, --key campo id tabla expresiones 
               'N' || nivel.profundidad || '_CL' || cps.codigodwh || '_DES' key_exp_de, --key campo descrip tabla expresiones
               'N' || DECODE (nivel.profundidad, 1, 'Min', 15, 'Max', nivel.profundidad) || ' Código de ' || initcap (tablib.descrip) descrip_exp_id, --Nombre para el metadato expresiones id
               'N' || DECODE (nivel.profundidad, 1, 'Min', 15, 'Max', nivel.profundidad) || ' '           || initcap (tablib.descrip) descrip_exp_de, --Nombre para el metadato expresiones descrip
               obj.obj_id obj_id  --Id del tipo de clasificacion libre
          FROM (SELECT :NEW.ID ID, 
                       :NEW.descrip1 descrip
                  FROM DUAL) tablib,
               TCOR_CPSTIPENTTABLIB cps,
               (select level profundidad--Genera 15 registros numerados del 1 al 15(Numero total de niveles)
                  from dual
               connect by level < = 15) nivel,
               eul5_objs@uxxidw obj
         WHERE cps.id_tablib = tablib.ID
           AND 
             (   (cps.id_tipent = 10000001 AND obj.obj_developer_key in ('TLK_1_ACTIVIDADES', 'TLK_1_ACTIVIDADES1', 'TLK_1_ACTIVIDADES_SEGU'))
              OR (cps.id_tipent = 10000002 AND obj.obj_developer_key in ('TLK_1_CENTROS', 'TLK_1_CENTROS1', 'TLK_1_CENTROS_SEGU'))
              OR (cps.id_tipent = 10000004 AND obj.obj_developer_key = 'TLK_1_ELEMENTOS_C')
              OR (cps.id_tipent = 10000005 AND obj.obj_developer_key = 'TLK_1_ELEMENTOS_I')
             );
                         
     v_c_key_exp_id           VARCHAR2(100);
     v_c_key_exp_de           VARCHAR2(100);
     v_c_descrip_exp_id       VARCHAR2(100);
     v_c_descrip_exp_de       VARCHAR2(100);
     v_c_obj_id               NUMBER(10);
  BEGIN
    IF UPDATING 
    THEN
      OPEN c_clasificaciones;
      LOOP
        FETCH c_clasificaciones
         INTO v_c_key_exp_id, 
              v_c_key_exp_de,
              v_c_descrip_exp_id,
              v_c_descrip_exp_de,
              v_c_obj_id;
        EXIT WHEN c_clasificaciones%NOTFOUND;
        --Se actualiza el metadato de las expresiones id
        UPDATE eul5_expressions@uxxidw
           SET exp_name   = v_c_descrip_exp_id,
               it_heading = v_c_descrip_exp_id,
               it_hidden  = '0'                --clasificación libre activa
         WHERE exp_developer_key = v_c_key_exp_id
           AND it_obj_id         = v_c_obj_id;
        --Se actualiza el metadato de las expresiones descrip
        UPDATE eul5_expressions@uxxidw
           SET exp_name   = v_c_descrip_exp_de,
               it_heading = v_c_descrip_exp_de,
               it_hidden  = '0'                --clasificación libre activa
         WHERE exp_developer_key = v_c_key_exp_de
           AND it_obj_id         = v_c_obj_id;
      END LOOP;
      CLOSE c_clasificaciones;
      
    END IF;
  END;
  
  $end  
  
END;

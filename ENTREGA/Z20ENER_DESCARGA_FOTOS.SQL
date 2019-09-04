create or replace PROCEDURE  Z20ENER_DESCARGA_FOTOS(fini        in  VARCHAR2,
                             ffin        in  VARCHAR2
                                                    )
/* 4 sept 2019
Guarda dentro de tabla ZZARCHIVOS_DESCARGADOS_TABLA -> el historial de los registros, 
y tambien guarda todas las tranasacciones que se operarom a
LQ_PROCESS_LOG
*/

IS
/*  |||||||||||||||||||||||||||||||||||    VARIABLES    |||||||||||||||||||||||||||||||||||     */
/*  |||||||||||||||||||||||||||||||||||    VARIABLES    |||||||||||||||||||||||||||||||||||     */

---VARIABLE QUE CAPTURA LA CONSTRUCCION DE LA FOTO
    NUERROR             NUMBER;
    SBERROR             VARCHAR2(4000);
    NUINDCOMS           NUMBER := -1;

--VARIABLE PARA LA CREACIN DE CARPETAS
    TIPOORDER          VARCHAR2(4000);       
    IDORDER            VARCHAR2(4000);         
    LEGALORDER         VARCHAR2(4000);       
    NOMBREORDER        VARCHAR2(4000);

---OBTENER EL ID
    FILEID             NUMBER;      

-- CREA LA RUTA DEL ARCHIVO
    NOMBRE_ARCHIVO      VARCHAR2(4000); 

--- PARA CREAR LA RUTAA
        NOMBRECONCATENA     VARCHAR2(4000);
        RUTAFINAL            VARCHAR2(4000);
        LIMPIANOMBRE        VARCHAR2(4000); -- NO USADO
        flag_               BOOLEAN := false; -- NO USADO

 ---FILE TO WRITE
     CONTENIDO_SAV          VARCHAR2(4000);   
     FECHACREACION_ARCHIVO  VARCHAR2(20);          

-- VERIFICA LA CONCAT DE LAS RUTAS
     STRING_RUTAF          VARCHAR2(4000);
     STRING_ARCHIVOF          VARCHAR2(4000);

---VERIFICA SI CREO EL ARCHIVO
    NUMOPERATORIO             NUMBER;    
    
    
v_file UTL_FILE.FILE_TYPE;
d_directory1 varchar2(4000);

/*  |||||||||||||||||||||||||||||||||||           |||||||||||||||||||||||||||||||||||     */
/*  |||||||||||||||||||||||||||||||||||           |||||||||||||||||||||||||||||||||||     */

--NIS-Orden-Nombre_archivo-Fecha_Legalizacion
  CURSOR CUCOMPSESU IS

SELECT *
  FROM (  SELECT CC.*,
                 GS.IDENTIFICATION NIS,
                 NVL (PAO.EXTERNAL_ID, '0') SGC_ORDEN,
                 TO_CHAR (OO.LEGALIZATION_DATE, 'DDMMYYYY') LEGALIZATION_DATE,
                 "FILE_NAME" V_LOB_IMAGE_NAME,                    ---NOMBRE DEL
                 LENGTH (CC.FILE_SRC) AFILE_SRC,
                 LENGTH (CC.FILE_NAME) BNOMBRE,
                 LENGTH (LEGALIZATION_DATE) CFECHA,
                 LENGTH (CC.FILE_SYS_LOCATION) DLOCACION
            FROM OR_ORDER OO
                 INNER JOIN CC_FILE CC ON OO.ORDER_ID = CC.OBJECT_ID
                 LEFT JOIN GE_SUBSCRIBER GS
                    ON OO.SUBSCRIBER_ID = GS.SUBSCRIBER_ID
                 LEFT JOIN PE_AUTONOMOUS_ORDER PAO
                    ON OO.ORDER_ID = PAO.ORDER_ID
           WHERE 
                  --OO.LEGALIZATION_DATE BETWEEN '01012019' AND '29082019' 
                 OO.LEGALIZATION_DATE  between fini and ffin
                 AND LEGALIZATION_DATE = LEGALIZATION_DATE
        ORDER BY OBJECT_ID ASC) B
 WHERE B.AFILE_SRC IS NOT NULL                 
   AND B.BNOMBRE IS NOT NULL;

-----CURSOR--
    SUBTYPE STYCOMPSE  IS  CUCOMPSESU%ROWTYPE;
    TYPE TYTBCOMS IS TABLE OF STYCOMPSE INDEX BY BINARY_INTEGER;
    TBCOMS           TYTBCOMS;

BEGIN
        TIPOORDER   :=''; 
        IDORDER     :=''; 
        LEGALORDER  :=''; 
        NOMBREORDER :='';         
        NOMBRECONCATENA :='';
        RUTAFINAL :='';

--ASIGNA CERP AL ID DE LA TABLA
NUMOPERATORIO:=0;

/*LOG*/
zzCargaMensLog('DescargaFotosAServidor','Inicia Proceso Extraer Datos Liquidacion');

------ SE ESCRIBE DENTRO DE LA TABLA DE LOGS 
          FECHACREACION_ARCHIVO := CURRENT_DATE;

-----Se valida que el CURSOR este cerrado
        IF CUCOMPSESU%ISOPEN THEN
            CLOSE CUCOMPSESU;
        END IF;

-----Se ejecuta el cursor con las ordenes cuyos archivos serán descargados
          OPEN   CUCOMPSESU;
            FETCH  CUCOMPSESU BULK COLLECT INTO TBCOMS;
          CLOSE  CUCOMPSESU;

    NUINDCOMS := TBCOMS.FIRST;

/*LOG*/
    --CargaMensLog('FOTOS_OSF','Inicia procesos Fotos'||' Fecha Ini : '||to_char(fini)||' Fecha Fin: '||to_char(ffin));    
 zzCargaMensLog('FOTOS_OSF','Inicia procesos Fotos'||' Fecha Ini : '||to_char(fini)||' Fecha Fin: '||to_char(ffin));    
 
 
--CONTIENEN DATOS 
    WHILE NUINDCOMS IS NOT NULL 
    LOOP
    flag_ :=true;

    --ASIGNAR PUNTEROS
        TIPOORDER   :=(TBCOMS(NUINDCOMS).OBJECT_LEVEL);
        IDORDER     :=(TBCOMS(NUINDCOMS).OBJECT_ID); 
        LEGALORDER  :=(TBCOMS(NUINDCOMS).LEGALIZATION_DATE);
        NOMBREORDER :=(TBCOMS(NUINDCOMS).V_LOB_IMAGE_NAME);
        
    --OBTENER EL FILE_ID        
        FILEID:=(TBCOMS(NUINDCOMS).FILE_ID); 

/*LOG*/
   ---CargaMensLog('FOTOS_OSF','Orden : '||to_char(IDORDER));  
   zzCargaMensLog('FOTOS_OSF','Orden : '||to_char(IDORDER)); 

/*  |||||||||||||||||||||||||||||||||||     CREAR CARPETAS       |||||||||||||||||||||||||||||||||||     */               
/*  |||||||||||||||||||||||||||||||||||     CREAR CARPETAS       |||||||||||||||||||||||||||||||||||     */               
                                    /*                              */

      mkfile('/imagenes/sfoa0708/10033/nive28'); ---Crea la carpeta base 

--1- CREA LA PRIMER CARPETA               
    IF(TIPOORDER IS NULL)
        -- so OBJECT_LEVEL IS NULL
           THEN   
           dbms_output.put_line('? SE ENCONTRO UN REGISTRO QUE NO CONTIENE DESCRIPOR O ES NULO '||IDORDER );
           dbms_output.put_line('? LINE 98 '|| 'XD ' );
           TIPOORDER:='OR_ORDER'; --SE ESTABLECE POR DEFECTO YA QUE NO EXISTE DENTRO DE LA TABLA OR_ORDER
           NOMBRECONCATENA := '/';      

           NOMBRECONCATENA := NOMBRECONCATENA || TIPOORDER;              
           -- >>>> / OR
           mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA);   -- >>>> / OR

---2-CREA LA SEGUNDA CARPETA  
            -- >>>> / OR / LEG
             NOMBRECONCATENA := NOMBRECONCATENA || '/' || LEGALORDER ;     
             mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA); -- >>>> / OR / LEG


----3-CREA LA SIGUENTES CARPETAS RECURSIVO   
            -- >>>> / OR / LEG / OR_FECHA
                NOMBRECONCATENA := NOMBRECONCATENA || '/' || TIPOORDER || '_' || IDORDER ;     
                mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA);  -- >>>> / OR / LEG / OR_FECHA

        /*-  - -- - - - Se usa el metodo que descargará el archivo - - - - - - - - - -*/ 
        /*-      - -- - - -                                        - - - - - - - - - -*/
            
---ASIGNAR EN NOMBRE DE LA VARIABLE FINAL 
                 ---CUNADO ENCUENTRA UN NULL -> REEMPLAZA EL VALOR
     ELSE
      NOMBRECONCATENA := '/';   -- >>>> / OR    
         NOMBRECONCATENA := NOMBRECONCATENA || TIPOORDER;              -- >>>> / OR         
           mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA);      

--2-CREA LA SEGUNDA CARPETA -- >>>> / OR / LEG
             NOMBRECONCATENA := NOMBRECONCATENA || '/' || LEGALORDER ;     
             mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA); -- >>>> / OR / LEG

---3-CREA LAS SIGUIENTES CARPETAS RECURSIVO  -- >>>> / OR / LEG / OR_FECHA  
                NOMBRECONCATENA := NOMBRECONCATENA || '/' || TIPOORDER || '_' || IDORDER ;     
                mkfile('/imagenes/sfoa0708/10033/nive28'||NOMBRECONCATENA);  -- >>>> / OR / LEG / OR_FECHA  
   END IF;

 ---PARA CREAR LA RUTA     
RUTAFINAL:= NOMBRECONCATENA;

                                 /* --------DESCARGA FOTOS A CARPETA         */    
                                 /* --------DESCARGA FOTOS A CARPETA         */  
                                 
   ENER_DESCARGA_ARCHIVO(TBCOMS(NUINDCOMS).FILE_SRC,   --Archivo a descargar
       '/imagenes/sfoa0708/10033/nive28'||RUTAFINAL, --Ruta donde quedará el archivoz
                 --'T_'||TBCOMS(NUINDCOMS).LEGALIZATION_DATE||'-'||TBCOMS(NUINDCOMS).NIS||'-'||TBCOMS(NUINDCOMS).SGC_ORDEN||'-'||TBCOMS(NUINDCOMS).OBJECT_ID||'-'||TBCOMS(NUINDCOMS).FILE_NAME); --Nombre del archivo
       TBCOMS(NUINDCOMS).LEGALIZATION_DATE||'-'||TBCOMS(NUINDCOMS).NIS||'-'||TBCOMS(NUINDCOMS).SGC_ORDEN||'-'||TBCOMS(NUINDCOMS).OBJECT_ID||'-'||TBCOMS(NUINDCOMS).FILE_NAME); --Nombre del archivo
       

/*--PARA GUARDAR EL NOMBRE      */
    NOMBRE_ARCHIVO:=(CONCAT(NOMBREORDER,'.txt'));

    
/*INDICA SI LA CARPETA Y EL ARCHIVO FUERON CREADOS */
    STRING_RUTAF :=('/imagenes/sfoa0708/10033/nive28'||RUTAFINAL||'/');
    STRING_ARCHIVOF :=(TBCOMS(NUINDCOMS).LEGALIZATION_DATE||'-'||TBCOMS(NUINDCOMS).NIS||'-'||TBCOMS(NUINDCOMS).SGC_ORDEN||'-'||TBCOMS(NUINDCOMS).OBJECT_ID||'-'||TBCOMS(NUINDCOMS).FILE_NAME);


/*VERIFICA QUE EL ARCHIVO Y LA RUTA EXISTA. EN CASO CONTRARIO ESCRIBE EN LOGS*/

        
        --ZZZ_REVISA_EXISTENCIA_ARCHIVO2(STRING_RUTAF,STRING_ARCHIVOF);
        ZZZ_REVISA_EXISTENCIA_ARCHIVO3(STRING_RUTAF,STRING_ARCHIVOF,FILEID);
      
--ESCRITURA DE ARCHIVOS
     CONTENIDO_SAV :=('   ' || LEGALORDER ||'    '|| TIPOORDER  ||'   '||IDORDER ||'    '||NOMBREORDER);

/*LOG*/      
       zzCargaMensLog('FOTOS_OSF','NOMBRE_ARCHIVO'||'  : '||to_char(NOMBRE_ARCHIVO)||' RUTA: '||to_char(RUTAFINAL));      
 

  /*  ||||||||||||||||||||||||||||||||||| USING LQ_PROCESS_LOG 2   |||||||||||||||||||||||||||||||||||     */
  BEGIN

        INSERT INTO OPEN.ZZARCHIVOS_DESCARGADOS_TABLA 
                        (id_unk, id_ccfile, nombre_file, direccion)     
                  VALUES (SEQ_DESCARGADOS.NEXTVAL,                    
                            FILEID,
                            NOMBRE_ARCHIVO,
                            RUTAFINAL);               
END ;

      /*  |||||||||||||||||||||||||||||||||||              |||||||||||||||||||||||||||||||||||     */


--CONTINUA CON LA SIGUIENTE TUPLA 
    NUINDCOMS := TBCOMS.NEXT(NUINDCOMS);

---- LIMPIA LA VARIABLES DE LOS PUNTEROS CUANDO TERMINA UN CILO DEL LOOP
        TIPOORDER   :='';
        IDORDER     :=''; 
        LEGALORDER  :=''; 
        NOMBREORDER :='';         
        NOMBRECONCATENA :='';
        RUTAFINAL:='';

    END LOOP;
    
    commit; 
    
EXCEPTION
    WHEN ex.CONTROLLED_ERROR THEN
        Errors.GETERROR(NUERROR, SBERROR);
        dbms_output.put_line('ERROR CONTROLLED ');
        dbms_output.put_line('error onuErrorCode: '||NUERROR);
        dbms_output.put_line('error osbErrorMess: '||SBERROR);
    IF CUCOMPSESU%ISOPEN THEN
        CLOSE CUCOMPSESU;
    END IF;

ROLLBACK;

    WHEN OTHERS THEN
            Errors.SETERROR;
            Errors.GETERROR(NUERROR, SBERROR);
            dbms_output.put_line('ERROR CONTROLLED ');
            dbms_output.put_line('error onuErrorCode: '||NUERROR);
            dbms_output.put_line('error osbErrorMess: '||SBERROR);
    
    IF CUCOMPSESU%ISOPEN THEN
        CLOSE CUCOMPSESU;
    END IF;
    ROLLBACK;

END;
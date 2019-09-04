create or replace PROCEDURE ZZZ_REVISA_EXISTENCIA_ARCHIVO3 
(
  FPATH IN VARCHAR2 
, 
FFILE IN VARCHAR2 
, 
ID_CCFILE IN NUMBER 
) AS 
BB int;
h_fd utl_file.file_type; 
e_fatal exception; 


    RUTA_Y_ARCHIVO             VARCHAR2(5000);
Begin 
  BEGIN 
   h_fd := utl_file.fopen(fpath, ffile, 'r');   EXCEPTION

   WHEN utl_file.invalid_path THEN
    RAISE e_fatal;

   WHEN utl_file.invalid_mode THEN
     RAISE e_fatal;

   WHEN utl_file.invalid_operation THEN
     RAISE e_fatal;

   WHEN OTHERS THEN
     RAISE e_fatal;

  END; 
  utl_file.fclose( h_fd ); 
  BB:=0;
  
  RUTA_Y_ARCHIVO:=( FPATH || FFILE);
  
  DBMS_OUTPUT.PUT_LINE('29 ->'||1);
   DBMS_OUTPUT.PUT_LINE('Existe el archivo indicado ');
    DBMS_OUTPUT.PUT_LINE('Existe:  ' || FPATH || ' junto el archivo:  ' || FFILE);

 BEGIN    
 
 ---UPDATE 
    UPDATE CC_FILE
    SET 
        FILE_SYS_LOCATION  = RUTA_Y_ARCHIVO -- VA A LLENAR EL FILE_SYS CON LA NUEVA RUTA DE LA IMAGEN EN DISCO
        --,
        --FILE_SRC= 
		
        WHERE 
            FILE_ID = ID_CCFILE;-- ES LA REFERENCIA QUE HACE UNICA EL VAL DE ESTA TRANSACCION 
            
             zzCargaMensLog('UPDATE BEGIN CC_FILE','<: ');
             zzCargaMensLog(' ID_FILE: ',ID_CCFILE);
             zzCargaMensLog(' CONTENIDO: ',FPATH);
            zzCargaMensLog(' : ', RUTA_Y_ARCHIVO);
              zzCargaMensLog('END UPDATE CC_FILE',' :>');
 END;   



/*LOG*/  
    zzCargaMensLog('Existe y ruta:  ' , FPATH || ' ' || FFILE);
    

exception 
  when e_fatal then 
    BB:=1; 
    DBMS_OUTPUT.PUT_LINE('39-> '||0);
      DBMS_OUTPUT.PUT_LINE('No Existe la ruta indicada:  ' || FPATH || 'junto el archivo:  ' || FFILE);
      

/*LOG*/  
      zzCargaMensLog('No Existe la ruta indicada:  ', FPATH || ' ' || FFILE);

  when others then 
    raise_application_error( -20000, ' OTRO TIPO DE ERROR NO MANEJADO ' );
     zzCargaMensLog('OTRO TIPO DE ERROR NO MANEJADO :  ', FPATH || ' ' || FFILE);
      --    BOUT:=1;
    BEGIN

/*LOG*/      
   zzCargaMensLog('ERROR AL MANEJAR:  ',FPATH || '' || FFILE);
   END; 
    BB:=0;
      --   BOUT:=1;
    DBMS_OUTPUT.PUT_LINE('53 -> '||0);
--  NULL;
END ZZZ_REVISA_EXISTENCIA_ARCHIVO3;
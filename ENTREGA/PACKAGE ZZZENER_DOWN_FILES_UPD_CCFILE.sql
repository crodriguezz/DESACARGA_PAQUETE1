create or replace PACKAGE ZZZENER_DOWN_FILES_UPD_CCFILE AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
PROCEDURE ZZZ_REVISA_EXISTENCIA_ARCHIVO3 ( FPATH IN VARCHAR2 , FFILE IN VARCHAR2 , ID_CCFILE IN NUMBER );
PROCEDURE  Z20ENER_DESCARGA_FOTOS(fini in  VARCHAR2, ffin in  VARCHAR2);
PROCEDURE zzCargaMensLog(v_process in VARCHAR2, v_desc_process in VARCHAR2 );
END ZZZENER_DOWN_FILES_UPD_CCFILE;
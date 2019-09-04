create or replace PROCEDURE zzCargaMensLog(v_process in VARCHAR2, v_desc_process in VARCHAR2 ) IS
BEGIN
   INSERT INTO OPEN.LQ_PROCESS_LOG
                 (PROCESS_USER, PROCESS_DATE, PROCESS_ID, PROCESS, PROCESS_DESC)
          VALUES (USER, 
                  SYSDATE, 
                  OPEN.SEQ_LQ_PROCESS_LOG.NEXTVAL, 
                  v_process , 
                   v_desc_process );   
END zzCargaMensLog;

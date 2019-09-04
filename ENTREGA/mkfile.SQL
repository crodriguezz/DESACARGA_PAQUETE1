--host mkdir '/imagenes/sfoa0708/10033/javab/1'

--host('mkdir'||/imagenes/sfoa0708/10033/javac/1/2/3)

create or replace and compile java source named "Dir"
as
  import java.io.*;
public class Dir extends Object {
  public static void Create(String dir) {
   File f = new File(dir);
   f.mkdir();
  }
}

create or replace procedure mkfile(p in varchar2)
as
language java
name 'Dir.Create(java.lang.String)';
/

execute mkfile('/imagenes/sfoa0708/10033/javae');
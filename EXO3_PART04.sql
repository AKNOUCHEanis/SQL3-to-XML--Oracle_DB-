--EXO3

--REQUETE 4 ) 

-- Rivers
drop type Rivers force;

create or replace type Rivers as object (
  name VARCHAR(20 Byte),
  member function toXML return XMLType
);
/
drop table Les_Rivers force;
create table Les_Rivers of Rivers;

-- T_geoSource
drop type T_geoSource force;

create or replace type T_geoSource as object (
  river   VARCHAR(35 Byte),
  country  VARCHAR(35 Byte),
  province  VARCHAR(35 Byte),
  member function toXML return XMLType 
);
/

drop table LesGeoSources force;
create table LesGeoSources of T_geoSource;

drop type T_ensGeoSource force;
create or replace type T_ensGeoSource as table of T_geoSource;
/

--***************** TYPE BODY

----T_geoSource
create or replace type body T_geoSource as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<river name="'||river||'"  country="'||country||'" province="'||province||'"  ></river>');
    return output;
  end;
  
end;
/

-- Rivers
create or replace type body Rivers as
  member function toXML return XMLType is
  output XMLType;
  tmpSource T_ensGeoSource;
  begin
    output := XMLType.createxml('<rivers></rivers>');
    
    select value(s) bulk collect into tmpSource
    from LesGeoSources s;
    
    for indx IN 1..tmpSource.COUNT
    loop
      output := XMLType.appendchildxml(output, 'rivers', tmpSource(indx).toXML());
      end loop;
      
      return output;
  end;
  
end;
/

-- INSERTIONS

insert into Les_Rivers values(Rivers('Rivers'));

insert into LesGeoSources
  select T_geoSource(gs.river,gs.country,gs.province)
  from GEO_SOURCE gs;
  

  
WbExport -type=text
         -file='EXO3_PART04.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select r.toXML().getClobVal()
from Les_Rivers r;


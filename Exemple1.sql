--Exo1

--CREATION DE TYPES ET TABLES

-- MONTAGNES

drop type T_Montagne force;

create or replace type T_montagne as object (
  NAME VARCHAR(35 Byte),
  MOUNTAINS VARCHAR(35 Byte),
  HEIGHT NUMBER,
  TYPE VARCHAR(10 Byte),
  CODEPAYS VARCHAR(4),
  --COORDINATES GEOCOORD
  member function toXML return XMLType
 )
 /
 
create or replace type body T_Montagne as
 member function toXML return XMLType is
    output XMLType;
    begin
        output := XMLType.createxml('<montagne/>');
        output := XMLType.appendchildxml(output,'montagne', XMLType('<nom>'||name||'</nom>'));
        return output;
    end;
 end;
/     

drop table LesMontagnes;

create table LesMontagnes of T_Montagne;


--PAYS
drop table LesPays;

create or replace type T_Pays as object(
  NAME    VARCHAR(35 Byte),
  CODE    VARCHAR(4 Byte),
  CAPITAL VARCHAR(35 Byte),
  PROVINE VARCHAR(35 Byte),
  AREA    NUMBER,
  POPULATION  NUMBER,
  member function toXML return XMLType
)
/

create or replace type T_ensMontagne as table of T_Montagne;
/

create or replace type body T_Pays as
  member function toXML return XMLType is 
  output XMLType;
  -- V-montagnes T_ensXML
  tmpMontagne T_ensMontagne;
  begin
      output := XMLType.createxml('<pays/>');
      output := XMLType.appendchildxml(output,'pays', XMLType('<nom>'||name||'</nom>'));
      output := XMLType.appendchildxml(output,'pays', XMLType('<code>'||code||'</code>'));
      select value(m) bulk collect into tmpMontagne
      from LesMontagnes m
      where code=m.codepays ;
      for indx IN 1..tmpMontagne.COUNT
      loop
        output := XMLType.appendchildxml(output,'pays',tmpMontagne(indx).toXML());
      end loop;
      return output;
   end;
end;
/

drop table LesPays;
/
create table LesPays of T_Pays;
/

-- Insertions

insert into LesPays
  select T_Pays(c.name, c.code, c.capital, c.province, c.area, c.population)
  from COUNTRY c;
  
insert into LesMontagnes
  select T_Montagne(m.name, m.mountains, m.height, m.type, g.country)
  from MOUNTAIN m, GEO_MOUNTAIN g
  where g.MOUNTAIN=m.NAME;
  
-- affichage du résultat
-- @wbOptimizeRowHeight Lines=100
select p.toXML().getClobVal()
from LesPays p;

--exporter le resultat dans un fichier 
WbExport -type=text
         -file='pays.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
        
/

select p.toXML().getClobVal()
from LesPays p;

--exporter le résultat dans un fichier
WbExport -type=text
         -file='montagnes.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
         
/
select m.toXML().getClobVal()
from LesMontagnes m;
































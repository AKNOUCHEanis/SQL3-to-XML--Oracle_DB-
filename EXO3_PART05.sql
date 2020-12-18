--EXO3

--REQUETE 5 )
--Countries  Racince du fichier xml
drop type Countries force;

create or replace type Countries as object(
  name varchar(15 Byte),
  member function toXML return XMLType
);
/

drop table LesCountries force;
create table LesCountries of Countries;


--T_Country
drop type T_Country force;

create or replace type T_Country as object (
  name VARCHAR(35 Byte),
  code VARCHAR(35 Byte),
  member function toXML return XMLType,
  member function getContinent return varchar2,
  member function getBlength return number
);
/
drop table LesCountry force;
create table LesCountry of T_Country;
 
drop type T_ensCountry force;
create or replace type T_ensCountry as table of T_Country;
/

--Encompasses
drop type T_Encompasses force;

create or replace type T_Encompasses as object(
  COUNTRY   VARCHAR(35 Byte),
  CONTINENT VARCHAR(35 Byte),
  PERCENT   NUMBER,
  member function toXML return XMLType
);
/

drop table LesEncompasses force;

create table LesEncompasses of T_Encompasses;

 --Continent
drop type T_Continent force;

create or replace type T_Continent as object(
  NAME  VARCHAR(35 Byte),
  AREA  NUMBER,
  member function toXML return XMLType
);
/

drop type T_ensContinent;

create or replace type T_ensContinent as table of T_Continent; 
/
drop table LesContinents force;

create table LesContinents of T_Continent;

--Border
drop type T_Border force;

create or replace type T_Border as object(
  COUNTRY1 VARCHAR(35 Byte),
  COUNTRY2 VARCHAR(35 Byte),
  LENGTH  VARCHAR(20 Byte),
  member function toXML return XMLType
);
/
drop table LesBorders force;

create table LesBorders of T_Border;

drop type T_ensBorder force;

create or replace type T_ensBorder as table of T_Border;
/


--TYPE BODY

--T_Country
create or replace type body T_Country as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<country name="'||name||'" code="'||code||'" blength="'||self.getBlength()||'"></country>');
    return output;
  end;
  
  member function getContinent return varchar2 is
  nameContinent VARCHAR(20 Byte);
  begin
    -- recherche du continent principal du pays
  select e.continent into nameContinent
  from LesEncompasses e, LesContinents c
  where e.country=self.code and c.name=e.continent 
  and e.percent in ( select max(e1.percent)  
                     from LesEncompasses e1 
                     where e1.country=self.code);
  
  return nameContinent;
  end;
  
  member function getBlength return number is
  blength number;
  begin
     -- calcul de la longueur de la frontiere du pays
   select sum(b.length)    into blength
   from LesBorders b
   where (b.country1= self.code )
       or (b.country2= self.code );
  
   if blength is null
   then
     blength:=0;
   end if; 
   return blength;
  end;
  
end;
/

--Countries
create or replace type body Countries as
  member function toXML return XMLType is
  output XMLType;
  tmpCountry T_ensCountry;
  begin
    output := XMLType.createxml('<countries></countries>');
    
    select value(c) bulk collect into tmpCountry
    from LesCountry c;
    
    for indx IN 1..tmpCountry.COUNT
    loop
      output := XMLType.appendchildxml(output, 'countries', tmpCountry(indx).toXML());
     end loop;
     
    return output;
  end;
  
end;
/

--******** INSERTIONS
insert into LesCountries values(Countries('Countries'));

insert into LesBorders
  select T_Border(b.country1, b.country2, b.length)
  from BORDERS b;

insert into LesContinents
  select T_Continent(c.name, c.area)
  from CONTINENT c;
  
insert into LesEncompasses
  select T_Encompasses(e.country,e.continent,e.percentage)
  from ENCOMPASSES e;
  
insert into LesCountry
  select T_Country(c.name,c.code)
  from COUNTRY c;
  
WbExport -type=text
         -file='EXO3_PART05.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/


select c.toXML().getClobVal()
from LesCountries c;

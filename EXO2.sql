--EXO2

-- type
--T_EXO2
drop type T_Exo2 force;

create or replace type T_Exo2 as object(
  name varchar(10 Byte),
  member function toXML return XMLType
);
/
drop table Exo2 force;
create table Exo2 of T_Exo2;

--T_Country
drop type T_Country force;

create or replace type T_Country as object(
  CODE VARCHAR(35 Byte),
  NAME VARCHAR(35 Byte),
  member function toXML return XMLType,
  member function getPeak return number,
  member function getContinent return varchar2,
  member function getBlength return number
);
/

drop table LesCountry force;

create table LesCountry of T_Country; 

drop type T_ensCountry force;

create or replace type T_ensCountry as table of T_Country;
/
-- GEOCOORD
drop type GEOCOORD force;

create or replace type GEOCOORD as object(
  LATITUDE  NUMBER,
  LONGITUDE NUMBER,
  member function toXML return XMLType
);
/

-- Mountain
drop type T_Mountain force;

create or replace type T_Mountain as object (
    NAME  VARCHAR(35 Byte),
    MOUNTAINS VARCHAR(35 Byte),
    HEIGHT    NUMBER,
    TYPE      VARCHAR(10 Byte),
    COORDINATES GEOCOORD,
    member function toXML return XMLType
);
/

drop table LesMountains force;

create table LesMountains of T_Mountain;

drop type T_ensMountain force;

create or replace type T_ensMountain as table of T_Mountain;
/

--desert
drop type T_Desert force;

create or replace type T_Desert as object (
    NAME    VARCHAR(35 Byte),
    AREA    NUMBER,
    COORDINATES GEOCOORD,
    member function toXML return XMLType
);
/

drop table LesDeserts force;

create table LesDeserts of T_Desert;

drop type T_ensDesert force;

create or replace type T_ensDesert as table of T_Desert;
/

--island
drop type T_Island force;

create or replace type T_Island as object(
  NAME  VARCHAR(35 Byte),
  COORDINATES GEOCOORD,
  member function toXML return XMLType
);
/

drop table LesIslands force;
create table LesIslands of T_Island;

drop type T_ensIsland force;

create or replace type T_ensIsland as table of T_Island;
/
--GeoMountain
drop type T_GeoMountain force;

create or replace type T_GeoMountain as object (
  MOUNTAIN  VARCHAR(35 Byte),
  COUNTRY   VARCHAR(4 Byte),
  PROVINCE  VARCHAR(35 Byte)
);
/
drop table LesGeoMountains;

create table LesGeoMountains of T_GeoMountain;

--GeoDesert
drop type T_GeoDesert force;

create or replace type T_GeoDesert as object (
  DESERT  VARCHAR(35 Byte),
  COUNTRY   VARCHAR(4 Byte),
  PROVINCE  VARCHAR(35 Byte)
);
/
drop table LesGeoDeserts force;

create table LesGeoDeserts of T_GeoDesert;

--GeoIsland
drop type T_GeoIsland force;

create or replace type T_GeoIsland as object (
  ISLAND  VARCHAR(35 Byte),
  COUNTRY VARCHAR(4 Byte),
  PROVINCE  VARCHAR(35 Byte)
);
/

drop table LesGeoIslands force;

create table LesGeoIslands of T_GeoIsland;

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

drop type T_ensEncompasses force;
/
create or replace type T_ensEncompasses as table of T_Encompasses;
/

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


--***************************************************
--body type

--T_Exo2
create or replace type body T_Exo2 as
  member function toXML return XMLType is
  output XMLType;
  tmpCountries T_ensCountry;
  begin
  
  output:=XMLType.createxml('<exo2 ></exo2>');
  
  select value(c) bulk collect into tmpCountries
  from LesCountry c;
  
  for indx IN 1..tmpCountries.COUNT
  loop
    output:=XMLType.appendchildxml(output,'exo2',tmpCountries(indx).toXML());
  end loop;
  
  return output;
  end;
end;
/



--Country
create or replace type body T_Country as
  member function toXML return XMLType is
  output XMLType;
  tmpMountain T_ensMountain;
  tmpDesert   T_ensDesert;
  tmpIsland   T_ensIsland;
  tmpBorders  T_ensBorder;
  nameContinent VARCHAR(30 Byte);
  blength number;
  
  begin
  
                     
   nameContinent:= self.getContinent();
   blength := self.getBlength();                
  
  
  output := XMLType.createxml('<country name="'||name||'" continent="'||nameContinent||'" blength="'||blength||'"  ></country>');
  output := XMLType.appendchildxml(output,'country',XMLType.createxml('<geo></geo>'));
  output := XMLType.appendchildxml(output,'country',XMLType.createxml('<countCountries></countCountries>'));
  
  select value(m) bulk collect into tmpMountain
  from LesMountains m, LesGeoMountains gm
  where gm.country=self.code and gm.mountain=m.name;
  
  for indx IN 1..tmpMountain.COUNT
  loop
    output:= XMLType.appendchildxml(output, 'country/geo', tmpMountain(indx).toXML());
  end loop;
  
  select value(d) bulk collect into tmpDesert
  from LesDeserts d, LesGeoDeserts gd
  where gd.country=self.code and gd.desert=d.name;

  for indx IN 1..tmpDesert.COUNT
  loop
    output:= XMLType.appendchildxml(output, 'country/geo', tmpDesert(indx).toXML());
  end loop;
  
  select value(i) bulk collect into tmpIsland
  from LesIslands i, LesGeoIslands gi
  where gi.country=self.code and gi.island=i.name;

  for indx IN 1..tmpIsland.COUNT
  loop
    output:= XMLType.appendchildxml(output, 'country/geo', tmpIsland(indx).toXML());
  end loop;
  
    output:=XMLType.appendchildxml(output, 'country', XMLType.createxml('<peak height="'|| self.getPeak()||'"></peak>'));
  
  select value(b)    bulk collect into tmpBorders
  from LesBorders b, LesEncompasses e
  where b.country1= self.code and e.continent=nameContinent and e.country=b.country2;

  for indx IN 1..tmpBorders.COUNT
  loop
    output := XMLType.appendchildxml(output,'country/countCountries', tmpBorders(indx).toXML());
  end loop;
  
  select value(b)    bulk collect into tmpBorders
  from LesBorders b, LesEncompasses e
  where b.country2= self.code and e.continent=nameContinent and e.country=b.country1;
  
  for indx IN 1..tmpBorders.COUNT
  loop
    output := XMLType.appendchildxml(output,'country/countCountries', tmpBorders(indx).toXML());
  end loop;

  
  return output;
  end;
  
  member function getPeak return number is 
  result number;
  begin
      result:=0;
      
      select max(m.height) into result
      from LesMountains m, LesGeoMountains gm
      where m.name=gm.mountain and self.code=gm.country;
      
      if result is null
      then
        result:=0 ;
      end if;
      return result;
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
   from LesBorders b, LesEncompasses e
   where (b.country1= self.code and e.continent=self.getContinent() and e.country=b.country2)
       or (b.country2= self.code and e.continent=self.getContinent() and e.country=b.country1);
  
   if blength is null
   then
     blength:=0;
   end if; 
   return blength;
  end;
end;
/

create or replace type body T_Mountain as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<mountain name="'||name||'"  height="'||height||'" ></mountain>');
    return output;
  end;
end;
/

--Desert

create or replace type body T_Desert as
  member function toXML return XMLType is
  output XMLType;
  begin
  output := XMLType.createxml('<desert name="'||name||'" area="'||area||'" ></desert>');
  return output;
  end;
  
end;
/

--Island

create or replace type body T_Island as
  member function toXML return XMLType is
  output XMLType;
  tmpCoordinates GEOCOORD;--T_ensGeocoord;
  begin
    output := XMLType.createxml('<island name="'||name||'" ></island>');
    

    
    select GEOCOORD(i.coordinates.latitude, i.coordinates.longitude) into tmpCoordinates
    from LesIslands i
    where i.name=self.name;
    
    output := XMLType.appendchildxml(output, 'island',tmpCoordinates.toXML());
    
    return output;
  end;
  
end;
/

--Geocoord

create or replace type body GEOCOORD as
  member function toXML return XMLType is
  output XMLType;
  begin
  output := XMLType.createxml('<coordinates latitude="'||latitude||'" longitude="'||longitude||'"></coordinates>');
  return output;
  end;
  
end;
/

--Encompasses

create or replace type body T_Encompasses as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<continent name="'||continent||'" percent="'||percent||'"></continent>');
    return output;
  end;
end;
/
--T_Continent

create or replace type body T_Continent as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<continent name="'||name||'" percent="'||0||'"></continent>');
    return output;
  end;
end;
/

--Border

create or replace type body T_Border as
  member function toXML return XMLType is
  output XMLType;
  begin
  
  output := XMLType.createxml('<border countryCode="'||country2||'" length="'||length||'"></border>');
  return output;
  end;
  
end;
/

--Insertions 
insert into Exo2 values(T_Exo2('Exo2'));
  

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
  select T_Country(c.code,c.name)
  from COUNTRY c;

insert into LesIslands
  select T_Island(i.name,GEOCOORD(i.coordinates.latitude,i.coordinates.longitude))
  from ISLAND i;
  
insert into LesGeoIslands
  select T_GeoIsland(gi.island, gi.country, gi.province)
  from GEO_ISLAND gi;
  
insert into LesMountains
  select T_Mountain(m.name, m.mountains, m.height, m.type, GEOCOORD(m.coordinates.latitude,m.coordinates.longitude))
  from MOUNTAIN m;
  
insert into LesGeoMountains
  select T_GeoMountain(gm.mountain, gm.country, gm.province)
  from GEO_MOUNTAIN gm;
  
insert into LesDeserts
  select T_Desert(d.name, d.area, GEOCOORD(d.coordinates.latitude,d.coordinates.longitude))
  from DESERT d;
  
insert into LesGeoDeserts
  select T_GeoDesert(gd.desert, gd.country, gd.province)
  from GEO_DESERT gd;

WbExport -type=text
         -file='EXO2_PART3.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select e.toXML().getClobVal()
from Exo2 e;


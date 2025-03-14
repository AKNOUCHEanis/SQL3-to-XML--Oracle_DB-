--EXO 1 PART1

--Creation des Types

--Mondial
drop type T_Mondial force;

create or replace type T_Mondial as object(
  NAME  VARCHAR(10 Byte),  --le nom du monde
  member function toXML return XMLType
);
/

drop table Les_Mondes force;

create table Les_Mondes of T_Mondial;

--Country
drop type T_Country force;

create or replace type T_Country as object(
  NAME    VARCHAR(35 Byte),
  CODE    VARCHAR(4 Byte),
  IDCOUNTRY  VARCHAR(20 Byte),
  CAPITAL VARCHAR(35 Byte),
  PROVINE VARCHAR(35 Byte),
  AREA    NUMBER,
  POPULATION  NUMBER,
  member function toXML return XMLType
);
/


drop type T_ensCountry force;

create or replace type T_ensCountry as table of T_Country;
/
drop table LesCountry force;

create table LesCountry of T_Country;

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


--Airport
drop type T_Airport force; 

create or replace type T_Airport as object(
  IATACODE    VARCHAR( 3 Byte),
  NAME        VARCHAR(100 Byte),
  COUNTRY     VARCHAR(4 Byte),
  CITY        VARCHAR(50 Byte),
  PROVINCE    VARCHAR(50 Byte),
  ISLAND      VARCHAR(50 Byte),
  LATITUDE    NUMBER,
  LONGITUDE   NUMBER,
  ELEVATION   NUMBER,
  GMTOFFSET   NUMBER,
  member function toXML return XMLType
);
/

drop type T_ensAirport force;

create or replace type T_ensAirport as table of T_Airport;
/
drop table LesAirports force;

create table LesAirports of T_Airport;

--Province
drop type T_Province force;

create or replace type T_Province as object(
  NAME    VARCHAR(35 Byte),
  COUNTRY VARCHAR(35 Byte),
  POPULATION  NUMBER,
  AREA    NUMBER,
  CAPITAL VARCHAR(35 Byte),
  CAPPROV VARCHAR(35 Byte),
  member function toXML return XMLType
);
/
drop type T_ensProvince force;

create or replace type T_ensProvince as table of T_Province;
/

drop table LesProvinces force;

create table LesProvinces of T_Province;

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

--GeoCountry
drop type T_GeoCountry force;

create or replace type T_GeoCountry as object(
  COUNTRY   VARCHAR(30 Byte),
  CONTINENT VARCHAR(30 Byte),
  PERCENT   NUMBER
);
/

drop table LesGeoCountry force;

create table LesGeoCountry of T_GeoCountry;

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
drop type T_GeoMountain force ;

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



/**********************************************/

--TYPE BODY

--Mondial

create or replace type body T_Mondial as
  member function toXML return XMLType as
  output XMLType;
  tmpCountry T_ensCountry;
  begin
    output := XMLType.createxml('<mondial></mondial>');
    
    select value(c) bulk collect into tmpCountry
    from LesCountry c
    where c.code='NZ' or c.code='BR';
    
    for indx IN 1..tmpCountry.COUNT
    loop
      output := XMLType.appendchildxml(output,'mondial',tmpCountry(indx).toXML());
    end loop;
    
    return output;
    
  end;
end;
/

--Continent

create or replace type body T_Continent as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<continent name="'||name||'" percent="'||0||'"></continent>');
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


--Airport

create or replace type body T_Airport as
  member function toXML return XMLType is
  output XMLType;
  begin
    output := XMLType.createxml('<airport name="'||name||'" nearCity="'||city||'"></airport>');
    return output;
  end;
  
end;
/

--Mountain

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
    /*
    select GEOCOORD(i.coordinates.latitude, i.coordinates.longitude) bulk collect into tmpCoordinates
    from LesIslands i 
    where i.name=self.name;
    
    for indx IN 1..tmpCoordinates.COUNT
    loop 
    output := XMLType.appendchildxml(output, 'island', tmpCoordinates(indx).toXML());
    end loop;*/
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





--Province

create or replace type body T_Province as
  member function toXML return XMLType is
  output XMLType;
  tmpMountains T_ensMountain;
  tmpDeserts T_ensDesert;
  tmpIslands T_ensIsland;
  begin
    output := XMLType.createxml('<province name="'||name||'" capital="'||capital||'" />');
    
    --add mountain
    select value(m) bulk collect into tmpMountains
    from LesMountains m, LesGeoMountains gm
    where gm.province=self.name and gm.country=self.country and m.name=gm.mountain;
    
    for indx IN 1..tmpMountains.COUNT
    loop
      output := XMLType.appendchildxml(output, 'province', tmpMountains(indx).toXML());
    end loop;
    
    --add desert
    
    select value(d) bulk collect into tmpDeserts
    from LesDeserts d, LesGeoDeserts gd
    where gd.province=self.name and gd.country=self.country and d.name=gd.desert;
    
    for indx IN 1..tmpDeserts.COUNT
    loop
      output := XMLType.appendchildxml(output, 'province', tmpDeserts(indx).toXML());
    end loop;
    
    --add island
    
    select value(i) bulk collect into tmpIslands
    from LesIslands i, LesGeoIslands gi
    where gi.province=self.name and gi.country=self.country and gi.island=i.name;
    
    for indx IN 1..tmpIslands.COUNT
    loop
      output := XMLType.appendchildxml(output, 'province', tmpIslands(indx).toXML());
    end loop;
    
    
    return output;
  end;
end;
/

--Country

create or replace type body T_Country as
  member function toXML return XMLType is 
  output XMLType;
  tmpEncompasses T_ensEncompasses;
  tmpAirport T_ensAirport;
  tmpProvince T_ensProvince;
  begin
      output := XMLType.createxml('<country idcountry="'||idcountry||'" nom="'||name||'"></country>');
     
      select value(e) bulk collect into tmpEncompasses
      from LesEncompasses e
      where self.code=e.COUNTRY ;
      
      for indx IN 1..tmpEncompasses.COUNT
      loop
        output:= XMLType.appendchildxml(output,'country',tmpEncompasses(indx).toXML());
      end loop;
      
     select value(p) bulk collect into tmpProvince
      from LesProvinces p
      where p.COUNTRY=self.code;
      
      for indx IN 1..tmpProvince.COUNT
      loop
        output := XMLType.appendchildxml(output,'country',tmpProvince(indx).toXML());
      end loop;
      
      select value(a) bulk collect into tmpAirport
      from LesAirports a
      where a.COUNTRY=self.code;
      
      for indx IN 1..tmpAirport.COUNT
      loop
      output := XMLType.appendchildxml(output, 'country', tmpAirport(indx).toXML());
      end loop;
      return output;
   end;
end;
/




--Insertions



insert into Les_Mondes values(T_Mondial('LeMonde'));

--'h'||ora_hash(c.code)
insert into LesCountry
  select T_Country(c.name, c.code,c.code ,c.capital, c.province, c.area, c.population)
  from COUNTRY c;
  
drop table LesContinents ;
create table LesContinents of T_Continent;

insert into LesContinents
  select T_Continent(c.name, c.area)
  from CONTINENT c;
  
  
insert into LesProvinces
  select T_Province(p.name,p.country,p.population,p.area,p.capital,p.capprov)
  from PROVINCE p;
  
insert into LesEncompasses
  select T_Encompasses(e.country,e.continent,e.percentage)
  from ENCOMPASSES e;

insert into LesGeoCountry
select  T_GeoCountry(e.country, e.continent, e.percent)
from LesEncompasses e;
  
insert into LesAirports
  select T_Airport(a.iatacode, a.name, a.country, a.city, a.province, a.island, a.latitude,
   a.longitude,a.elevation, a.gmtoffset)
  from AIRPORT a;
  
---------
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
         -file='EXO1_PART01.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/

select m.toXML().getClobVal()
from Les_Mondes m;


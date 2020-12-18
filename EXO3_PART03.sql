--EXO3

--REQUETE 3 ) 
--Provinces
drop type Provinces force;

create or replace type Provinces as object(
  name VARCHAR(10 Byte),
  member function toXML return XMLType
);
/
drop table prov force;

create table prov of Provinces;

--T_Province
drop type T_Province force;

create or replace type T_Province as object(
  name VARCHAR(35 Byte),
  country VARCHAR(35 Byte),
  member function toXML return XMLType
);
/
drop table LesProvinces force;
create table LesProvinces of T_Province;

drop type T_ensProvince force;
create type T_ensProvince as table of T_Province;
/
--T_Mountain
drop type T_Mountain force;

create or replace type T_Mountain as object (
  name VARCHAR(35 Byte),
  altitude NUMBER,
  latitude NUMBER,
  longitude NUMBER,
  member function toXML return XMLType
  
);
/
drop table LesMountains force;
create table LesMountains of T_Mountain; 

drop type T_ensMountain force;
create or replace type T_ensMountain as table of T_Mountain;
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

---****************  TYEP BODY

--T_Province
create or replace type body T_Province as 
  member function toXML return XMLType is
  output XMLType;
  tmpMountain T_ensMountain;
  begin
    output:= XMLType.createxml('<province name="'||name||'" country="'||country||'"></province>');
    
    select value(m) bulk collect into tmpMountain
    from LesMountains m, LesGeoMountains gm
    where gm.country=self.country and gm.province=self.name and gm.mountain=m.name;
    
    for indx IN 1..tmpMountain.COUNT
    loop
      output := XMLType.appendchildxml(output,'province', tmpMountain(indx).toXML());
    end loop;
    
    return output;
  end;
  
end;
/

--T_Mountain
create or replace type body T_Mountain as
  member function toXML return XMLType is
  output XMLType;
  begin
    output:= XMLType.createxml('<mountain name="'||name||'" altitude="'||altitude||'" latitude="'||latitude||'" logitude="'||longitude||'"></mountain>');
    return output;
 end;
  
end;
/

--Provinces 
create or replace type body Provinces as
  member function toXML return XMLType is
  output XMLType;
  tmpProvince T_ensProvince;
  begin
    output := XMLType.createxml('<provinces></provinces>');
    
    select value(p) bulk collect into tmpProvince
    from LesProvinces p;
    
    for indx IN 1..tmpProvince.COUNT
    loop
      output := XMLType.appendchildxml(output, 'provinces', tmpProvince(indx).toXML());
    end loop;
    
    return output;
  end;
  
end;
/

--INSERTIONS

insert into prov values(Provinces('Provinces'));

insert into LesProvinces
  select T_Province(p.name,p.country)
  from PROVINCE p;
  
insert into LesGeoMountains
  select T_GeoMountain(gm.mountain, gm.country, gm.province)
  from GEO_MOUNTAIN gm;
  
insert into LesMountains
  select T_Mountain(m.name,m.height,m.coordinates.latitude,m.coordinates.longitude)
  from MOUNTAIN m;
  
WbExport -type=text
         -file='EXO3_PART03.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
         
/
  
select p.toXML().getClobVal()
from prov p;

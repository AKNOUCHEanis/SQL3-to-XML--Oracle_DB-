--EXO1 PART2
--Type

--Mondial
drop type T_Mondial force;

create or replace type T_Mondial as object(
  NOM   VARCHAR(10 Byte), --Le nom du monde
  member function toXML return XMLType
);
/

drop table LesMondes force;

create table LesMondes of T_Mondial;

--Organization

drop type T_Organization force;

create or replace type T_Organization as object (
  ABBREVIATION    VARCHAR(12 Byte),
  NAME            VARCHAR(80 Byte),
  CITY            VARCHAR(35 Byte),
  COUNTRY         VARCHAR(35 Byte),
  member function toXML return XMLType
);
/
drop table LesOrganizations force;

create table LesOrganizations of T_Organization;

drop type T_ensOrganization force;

create or replace type T_ensOrganization as table of T_Organization;
/


--Country
drop type T_Country force;

create or replace type T_Country as object (
  CODE      VARCHAR(4 Byte),
  NAME      VARCHAR(35 Byte),  
  POPULATION     NUMBER,
  member function toXML return XMLType
);
/
drop table LesCountry force;

create table LesCountry of T_Country;

drop type T_ensCountry force;

create or replace type T_ensCountry as table of T_Country;
/
--Member
drop type T_Member force;

create or replace type T_Member as object(
  COUNTRY       VARCHAR(4 Byte),
  ORGANIZATION  VARCHAR(12 Byte)
);
/

drop table LesMembers force;

create table LesMembers of T_Member;


--Language
drop type T_Language force;

create or replace type T_Language as object(
  COUNTRY VARCHAR(4 Byte),
  NAME   VARCHAR(50 Byte),
  PERCENTAGE   NUMBER,
  member function toXML return XMLType
);
/
drop table LesLanguages force;

create table LesLanguages of T_Language;

drop type T_ensLanguage force;

create type T_ensLanguage as table of T_Language;
/
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
/***********************************************
*/
--Type Body

--Mondial

create or replace type body T_Mondial as
  member function toXML return XMLType is
  output XMLType;
  tmpOrganization T_ensOrganization;
  begin
  output := XMLType.createxml('<mondial></mondial>');
  
  select value(o) bulk collect into tmpOrganization
  from LesOrganizations o;
  
  
  for indx IN 1..tmpOrganization.COUNT
  loop
    output := XMLType.appendchildxml(output , 'mondial',tmpOrganization(indx).toXML());
  end loop;
  return output;
  end;
  
end;
/
--Organization

create or replace type body T_Organization as
  member function toXML return XMLType is
  output XMLType;
  tmpCountry  T_ensCountry;
  begin
  
  output := XMLType.createxml('<organization></organization>');
  
  select value(c) bulk collect into tmpCountry
  from LesMembers m, LesCountry c
  where m.organization=self.abbreviation and c.code=m.country;
  
  
  for indx IN 1..tmpCountry.COUNT
  loop
    output:= XMLType.appendchildxml(output, 'organization', tmpCountry(indx).toXML());
  end loop;
  
  output := XMLType.appendchildxml(output, 'organization', XMLType.createxml('<headquarter name="'||city||'" ></headquarter>'));
 
  return output;
  end;
  
end;
/
--Country

create or replace type body T_Country as
  member function toXML return XMLType is
  output XMLType;
  tmpLanguage T_ensLanguage;
  tmpBorders  T_ensBorder;
  begin
    output := XMLType.createxml('<country code="'||code||'" name="'||name||'" population="'||population||'" ></country>');
  
  select value(l) bulk collect into tmpLanguage
  from LesLanguages l
  where l.country=self.code;
  
  for indx IN 1..tmpLanguage.COUNT
  loop
    output := XMLType.appendchildxml(output, 'country', tmpLanguage(indx).toXML());
  end loop;
  
  output := XMLType.appendchildxml(output, 'country', XMLType.createxml('<borders></borders>'));

  select value(b) bulk collect into tmpBorders
  from LesBorders b
  where b.country1=self.code ;
  
  for indx IN 1..tmpBorders.COUNT
  loop
    output := XMLType.appendchildxml(output, 'country/borders', tmpBorders(indx).toXML());
  end loop;
  
  select T_Border(b.country2,b.country1,b.length) bulk collect into tmpBorders
  from LesBorders b
  where b.country2=self.code;
  
  for indx IN 1..tmpBorders.COUNT
  loop
    output := XMLType.appendchildxml(output, 'country/borders', tmpBorders(indx).toXML());
  end loop;
  
  return output;
  end;
  
end;
/

--Language

create or replace type body T_Language as
  member function toXML return XMLType is
  output XMLType; 
  begin
  
  output := XMLType.createxml('<language language="'||name||'" percent="'||percentage||'"></language>');
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

  --select ref(pays) into val from dual;

--Insertions

--Lesmondes
drop table LesMondes force;
create table LesMondes of T_Mondial;

insert into LesMondes values(T_Mondial('monde'));

--LesOrganizations

insert into LesOrganizations
  select T_Organization(o.abbreviation,o.name, o.city, o.country)
  from ORGANIZATION o;

--LesMembers

insert into LesMembers
  select T_Member(m.country,m.organization)
  from ISMEMBER m;

--LesCountry

insert into LesCountry
  select T_Country(c.code, c.name, c.population)
  from COUNTRY c;

--LesBorders

insert into LesBorders
  select T_Border(b.country1, b.country2, b.length)
  from BORDERS b;

select *
from LesBorders;
--LesLanguages

insert into LesLanguages
  select T_Language(l.country,l.name,l.percentage)
  from LANGUAGE l;
  
WbExport -type=text
         -file='EXO1_PART02.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/


select m.toXML().getClobVal()
from LesMondes m;


select c.toXML().getClobVal()
from LesCountry c, LesBorders b
where c.code='BR' and b.country1='BR';


select *
from LesCountry c
where c.code='A'
;



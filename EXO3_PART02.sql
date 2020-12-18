--EXO3

--REQUETE 2 ) 

--Organizations
drop type Organizations force;

create or replace type Organizations as object(
  name VARCHAR(30 Byte),
  member function toXML return XMLType
);
/
drop table Orga force;
create table Orga of Organizations;

-- T_Organization
drop type T_Organization force;

create or replace type T_Organization as object(
  abbreviation VARCHAR(30 Byte),
  name VARCHAR(80 Byte),
  established date,
  member function toXML return XMLType
);
/
drop table LesOrganizations force;
create table LesOrganizations of T_Organization;

drop type T_ensOrganization force;
create or replace type T_ensOrganization as table of T_Organization;
/

--- TYPE BODY
-- T_Organization
create or replace type body T_Organization as 
  member function toXML return XMLType is
  output XMLType;
  begin
    output:= XMLType.createxml('<organization abbreviation="'||abbreviation||'" name="'||name||'" date="'||established||'"></organization>');
    return output;
  end;
end;
/

--Organizations
create or replace type body Organizations as
 member function toXML return XMLType is
 output XMLType;
 tmpOrganizations T_ensOrganization;
 begin
  
  output := XMLType.createxml('<organizations></organizations>');
  
  select value(o) bulk collect into tmpOrganizations
  from LesOrganizations o;
  
  for indx IN 1..tmpOrganizations.COUNT
  loop
    output := XMLType.appendchildxml(output,'organizations',tmpOrganizations(indx).toXML());
  end loop;
  return output;
 end;
 
end;
/

--INSERTIONS

insert into orga values(Organizations('organizations'));

insert into LesOrganizations
  select T_Organization(o.abbreviation, o.name, o.established)
  from ORGANIZATION o;
  
WbExport -type=text
         -file='EXO3_PART02.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
 
/
select o.toXML().getClobVal()
from orga o;

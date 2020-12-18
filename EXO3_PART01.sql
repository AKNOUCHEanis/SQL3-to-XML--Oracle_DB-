--EXO3

--REQUETE 1 )  

--continents   racine du fichier xml
drop type continents force;

create or replace type continents as object(
  name varchar(30 Byte),
  member function toXML return XMLType
);
/

drop table Les_continents force;
create table Les_continents of continents;

--T_Continent

drop type T_Continent force;

create or replace type T_continent as object (
  name varchar(20 Byte),
  member function toXML return XMLType
);
/
drop table lesContinents force;
create table lesContinents of T_Continent;

drop type T_ensContinent force;
create or replace type T_ensContinent as table of T_Continent;
/

--T_Country
drop type T_Country force;

create or replace type T_Country as object(
  name VARCHAR(35 Byte),
  code VARCHAR(35 Byte),
  continent VARCHAR(35 Byte),
  population NUMBER,
  member function toXML return XMLType
);
/
drop table LesCountry force;
create table LesCountry of T_Country;


drop type T_ensCountry force;
create or replace type T_ensCountry as table of T_Country;
/
----*************** TYPE  BODY 
-- T_Country
create or replace type body T_Country as
  member function toXML return XMLType is
  output XMLType;
  begin

    output := XMLType.createxml('<country name="'||name||'" code="'||code||'" continent="'||continent||'" population="'||population||'"></country>');
    return output;
  end;
  
end;
/

-- T_Continent
create or replace type body T_Continent as
  member function toXML return XMLtype is
  output XMLType;
  tmpCountry T_ensCountry;
  begin
    output := XMLType.createxml('<continent name="'||name||'" ></continent>');
    
    select value(c) bulk collect into tmpCountry
    from LesCountry c
    where c.continent=self.name;
    
    for indx IN 1..tmpCountry.COUNT
    loop
      output :=XMLType.appendchildxml(output, 'continent', tmpCountry(indx).toXML());
    end loop;
    
    return output;
    
  end;
  
end;
/

-- continents
create or replace type body continents as
  member function toXML return XMLType is
  output XMLType;
  tmpContinent T_ensContinent;
  begin
    output := XMLType.createxml('<continents></continents>');
    
    select value(c) bulk collect into tmpContinent
    from LesContinents c;
    
    for indx IN 1..tmpContinent.COUNT
    loop
      output := XMLType.appendchildxml(output, 'continents', tmpContinent(indx).toXML());
    end loop;
    
    return output;
    end;
  
  
end;
/

-----------INSERTIONS
insert into Les_continents values(continents('Continents'));

insert into LesContinents
    select T_Continent(c.name)
    from CONTINENT c;

insert into LesCountry
  select T_Country(c.name,c.code,(select e.continent     /*Pour trouver le continent principal du pays*/
                                  from Encompasses e, Continent con
                                  where e.country=c.code and con.name=e.continent 
                                          and e.percentage in ( select max(e1.percentage)  
                                                             from Encompasses e1 
                                                             where e1.country=c.code)),c.population)
  from COUNTRY c;


WbExport -type=text
         -file='EXO3_PART01.xml'
         -createDir=true
         -encoding=ISO-8859-1
         -header=false
         -delimiter=','
         -decimal=','
         -dateFormat='yyyy-MM-dd'
/


select m.toXML().getClobVal()
from Les_Continents m;

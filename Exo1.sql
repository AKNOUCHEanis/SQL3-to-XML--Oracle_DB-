--EXO 1

--Creation des Types

--Mondial
drop type T_Mondial force;

create or replace type T_Mondial as object(
  NAME  VARCHAR(10 Byte),  --le nom du monde
  member function toXML return XMLType
);
/


create or replace type T_Country;
/
create or replace type T_ensCountry as table of T_Country;
/

create table LesCountry of T_Country;
 
create or replace type body T_Mondial as
  member function toXML return XMLType as
  output XMLType;
  tmpCountry T_ensCountry;
  begin
    output := XMLType.createxml('<mondial/>');
    
    select value(c) bulk collect into tmpCountry
    from LesCountry c;
    
    for indx IN 1..tmpCountry.COUNT
    loop
      output := XMLType.appendchildxml(output,'mondial',tmpCountry(indx).toXML());
    end loop;
    
    return output;
    
  end;
end;
/



--Continent

drop type T_Continent force;

create or replace type T_Continent as object(
  NAME  VARCHAR(35 Byte),
  AREA  NUMBER,
  member function toXML return XMLType
);
/

create or replace type body T_Continent as
  member function toXML return XMLType is
  output XMLType;
  
  begin
    output := XMLType.createxml('<continent/>');
    
    output := XMLType.insertchildxml(output,'<continent/>','@name', NAME);
    output := XMLType.insertchildxml(output,'<continent/>','@percent',0);
    return output;
  end;
end;
/



create table LesContinents of T_Continent;
/
create or replace type T_ensContinent as table of T_Continent; 
/


--Country

drop type T_Country force;

create or replace type T_Country as object(
  NAME    VARCHAR(35 Byte),
  CODE    VARCHAR(4 Byte),
  CAPITAL VARCHAR(35 Byte),
  PROVINE VARCHAR(35 Byte),
  AREA    NUMBER,
  POPULATION  NUMBER,
  member function toXML return XMLType
);
/


create or replace type T_Airport as object(

);
/
create or replace type T_ensAirport as table of T_Airport;
/
create table LesAirports of T_Airport;




create or replace type T_Province as object(

);
/
create or replace type T_ensProvince as table of T_Province;
/
create table LesProvinces of T_Province;


create or replace type T_Encompasses as object(
  COUNTRY   VARCHAR(35 Byte),
  CONTINENT VARCHAR(35 Byte),
  PERCENT   NUMBER
);
/
create table LesEccompasses of T_Encompasses;



create or replace type body T_Country as
  member function toXML return XMLType is 
  output XMLType;
  tmpContinent T_ensContinent;
  tmpAirport T_ensAirport;
  tmpProvince T_ensProvince;
  begin
      output := XMLType.createxml('<country/>');
      
      select value(c) bulk collect into tmpContinent
      from LesContinents c, LesEncompasses e
      where code=e.COUNTRY and c.NAME=e.CONTINENT;
      
      for indx IN 1..tmpContinent.COUNT
      loop
        output:= XMLType.appendchildxml(ouput,'country',tmpContinent(indx).toXML());
        output:= XMLType;
      end loop;
      
      select value(p) bulk collect into tmpProvince
      from LesProvinces p
      where p.COUNTRY=code;
      
      for indx IN 1..tmpProvince.COUNT
      loop
        output := XMLType.appendchildxml(output,'country',tmpProvince.toXML());
      end loop;
      
      select value(a) bulk collect into tmpAirpot
      from LesAirports a
      where a.COUNTRY=code;
      for indx IN 1..tmpAirport.COUNT
      loop
      output := XMLType.appendchildxml(output, 'country', tmpAirport(indx).toXML());
      end loop;
      return output;
   end;
end;
/

--Insertions

drop table LesMondes force;

create table LesMondes of T_Mondial;

insert into LesMondes values(T_Mondial('LeMonde'));

insert into LesCountry
  select T_Country(c.name, c.code, c.capital, c.province, c.area, c.population)
  from COUNTRY c;
  
insert into LesContinents
  select T_Continent(c.name, c.area)
  from CONTINENT c;
  
insert into LesProvinces
  select *
  from PROVINCE p;
  
insert into LesEncompasses
  select *
  from ENCOMPASSES e;
  
select m.toXML().getClobVal()
from LesMondes m;

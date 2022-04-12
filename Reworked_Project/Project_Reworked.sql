set timing on
SET SERVEROUTPUT ON


Create type tpatient as object(
NUM_PATIENT Number(7),
NOM_PATIENT varchar2(30),
PRENOM_PATIENT varchar2(30),
ADRESSE_PATIENT varchar2(100),
TEL_PATIENT varchar2(10),
MUTUELLE varchar2(10)
)
;
/

Create type temploye as object(
NUM_EMP Number(7),
NOM_EMP varchar2(30),
PRENOM_EMP varchar2(30),
ADRESSE_EMP varchar2(100),
TEL_EMP varchar2(10)
) Not final
;
/

Create type tmedecin under temploye(
SPECIALITE  varchar2(20)
)
;
/



Create type tinfirmier under temploye(
CODE_SERVICE char(3),
rotation char(4),
salaire number(10,2)
)
;
/

Create or replace type tservice as object(
CODE_SERVICE char(3),
NOM_SERVICE varchar2(40),
BATIMENT char,
DIRECTEUR ref temploye
)
;
/

Create type tchambre as object(
CODE_SERVICE char(3),
NUM_CHAMBRE Number(4),
SURVEILLANT ref temploye,
NB_LITS integer
);
/

Create or replace type thospitalisation as object(
num_patient Number(7),
CODE_SERVICE char(3),
hos_chambre ref tchambre,
lit integer
);
/

create type t_set_medecin as table of ref tmedecin;
/

create type t_set_patient as table of ref tpatient;
/

create type t_set_infirmiers as table of ref tinfirmier;
/

create type t_set_service as table of ref tservice;
/

create type t_set_hospitalisation as table of ref thospitalisation;
/

create type t_set_chambre as table of ref tchambre;
/


alter type tservice add attribute service_hospitalisation t_set_hospitalisation cascade;
alter type tservice add attribute service_infirmier t_set_infirmiers cascade;
alter type tservice add attribute service_chambre t_set_chambre cascade;

alter type tmedecin add attribute medecin_patient  t_set_patient cascade;

alter type tpatient add attribute patient_medecin t_set_medecin cascade;
alter type tpatient add attribute patient_hospitalisation ref thospitalisation cascade;

alter type tinfirmier add attribute infirmier_service ref tservice cascade;
alter type tinfirmier add attribute infirmier_chambre ref tchambre cascade;

alter type tchambre add attribute chambre_hospitalisation t_set_hospitalisation cascade;
alter type tchambre add attribute chambre_service ref tservice cascade;

alter type thospitalisation add attribute hospitalisation_patient ref tpatient cascade;
alter type thospitalisation add attribute hospitalisation_service ref tservice cascade;


Create table patient of tpatient(primary key (NUM_PATIENT)) 
nested table patient_medecin store as table_patient_medecin;

Create table medecin of tmedecin(primary key (NUM_EMP)) 
nested table medecin_patient store as table_medecin_patient;

Create table infirmier of tinfirmier(primary key (NUM_EMP));

create table service of tservice(primary key (CODE_SERVICE), UNIQUE(nom_service)) 
nested table service_infirmier store as table_service_infirmier
nested table service_hospitalisation store as table_service_hospitalisation
nested table service_chambre store as table_service_chambre;

create table chambre of tchambre(primary key(code_service, num_chambre), foreign key(code_service) references service(code_service))
nested table chambre_hospitalisation store as table_chambre_hospitalisation;

Create table HOSPITALISATION of thospitalisation(primary key(num_patient), foreign key(num_patient) references patient(NUM_PATIENT), foreign key(code_service) references service(code_service));



/************************************************************* PARTIE 3 **********************************************************/
/* @"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\Project_Reworked.sql" */
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\Functions.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table patient.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table medicin.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table service.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table infirmier.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table chambre.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table hospitalisation.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\table soigne.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\Table Patient_hosFill.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\Infirmier_fill.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\Chambre_fill.sql"
@"C:\Users\Tp_sql\Desktop\code project\Project\Reworked_Project\TablesRE\Service_fill.sql"



/************************************************************* PARTIE 2 **********************************************************/

---------------------------------------------------------------------------------------------------
alter type tmedecin add MEMBER FUNCTION Doctors_Quantity(x varchar2) return numeric cascade;

CREATE OR REPLACE TYPE BODY TMEDECIN AS
      MEMBER FUNCTION Doctors_Quantity(x varchar2) return numeric IS
      num number;
      BEGIN
            select count(*) into num
            from medecin
            where specialite = x ;
            return num;
      END;
END;
/

set SERVEROUTPUT ON
select distinct m.doctors_quantity('Traumatologue') from medecin m;
---------------------------------------------------------------------------------------------------
alter type tservice add STATIC PROCEDURE Nurses_Patients_Quantity(x char) cascade;

CREATE OR REPLACE TYPE BODY TSERVICE AS
      STATIC PROCEDURE Nurses_Patients_Quantity(x char) IS
      num number;
      num1 number;
      BEGIN
            select cardinality(s.service_hospitalisation), cardinality(s.service_infirmier) into num1, num
            from service s
            where s.code_service = x;
            dbms_output.put_line('service : ' || x || chr(10) ||'Nombre_infirmiers : ' || num || chr(10) ||'Nombre de Patients : ' || num1);
      END;
END;
/

set SERVEROUTPUT ON
exec tservice.Nurses_Patients_Quantity('CAR');
---------------------------------------------------------------------------------------------------
alter type tpatient add STATIC PROCEDURE Doctors_Quantity(x numeric) cascade;

CREATE OR REPLACE TYPE BODY TPATIENT AS
      STATIC PROCEDURE Doctors_Quantity(x numeric) IS
      num number;
      BEGIN
            select cardinality(patient_medecin) into num
            from patient
            where num_patient = x;
            dbms_output.put_line('Num_Patient : ' || x || chr(10) ||'Nombre_Docs : ' || num);
      END;
END;
/

set SERVEROUTPUT ON
exec tpatient.Doctors_Quantity(3);
---------------------------------------------------------------------------------------------------
alter type tinfirmier add STATIC PROCEDURE Verification_salaire(x number) cascade;


SET SERVEROUTPUT ON

CREATE OR REPLACE TYPE BODY tinfirmier AS
      STATIC PROCEDURE Verification_salaire(x number) IS
      num number;
      BEGIN
            SELECT salaire into num 
            FROM infirmier 
            where num_emp = x;

            if(num > 10000 and num < 30000) then
                  DBMS_OUTPUT.PUT_LINE(chr(10) ||'Verification positive');
            else
                  DBMS_OUTPUT.PUT_LINE(chr(10) ||'Verification Negative');
            end if;
      END;
End;
/

exec tinfirmier.Verification_salaire(195);
INSERT INTO infirmier VALUES(tinfirmier(200,'BELKACEMI','Hocine','Medouha tizi‐ouzou','26889885','CHG','JOUR',33548.45, NULL, NULL));
exec tinfirmier.Verification_salaire(200);





/************************************************************* PARTIE 4 **********************************************************/




---------------------------------------------------------------------------------------------------
select nom_patient, prenom_patient from patient where mutuelle='MAAF';
---------------------------------------------------------------------------------------------------
select DEREF(h.hospitalisation_service).nom_service as Service, DEREF(h.hos_chambre).num_chambre as chambre, lit, DEREF(h.hospitalisation_patient).nom_patient as NOM, DEREF(h.hospitalisation_patient).prenom_patient as PRENOM, DEREF(h.hospitalisation_patient).mutuelle as mutuelle
from hospitalisation h
where DEREF(h.hospitalisation_service).batiment = 'B' and DEREF(h.hospitalisation_patient).mutuelle like 'MN%';
---------------------------------------------------------------------------------------------------
with rws as(
select p.num_patient, t.* 
from patient p, table (p.patient_medecin) t
)
select num_patient, count(column_value) as Nombre_medecins, count(distinct DEREF(column_value).SPECIALITE) as Specialities_total
from rws
having count(column_value) > 2
group by num_patient;
---------------------------------------------------------------------------------------------------
select s.code_service, avg(deref(inf.column_value).salaire)
from service s, table(s.service_infirmier) inf
group by s.code_service;
---------------------------------------------------------------------------------------------------
create view view_infirmiers as
select code_service, (count(num_emp)) as infirmiers
from infirmier  
group by(code_service);

create view view_patients as
select code_service, (count(num_patient)) as patients
from hospitalisation  
group by(code_service);

 
select i.code_service, cast(i.infirmiers/p.patients as decimal(10,2)) as Rapport_Infirmiers_PatientsHos
from view_infirmiers i, view_patients p
where i.code_service = p.code_service;
---------------------------------------------------------------------------------------------------
select distinct DEREF(med.column_value).NOM_EMP as nom, DEREF(med.column_value).PRENOM_EMP as prenom 
from patient, table(patient.patient_medecin) med
where patient_hospitalisation is not NULL;
---------------------------------------------------------------------------------------------------





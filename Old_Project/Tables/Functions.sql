Create or replace FUNCTION ref_medecin(x integer) 
return REF TMEDECIN 
IS 
    ref REF TMEDECIN := NULL; 
BEGIN 
    begin
        Select REF(p) into ref 
        from medecin p 
        where p.num_emp = x;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Medecin does not exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION ref_infirmier(x integer) 
return REF TINFIRMIER 
IS 
    ref REF TINFIRMIER := NULL; 
BEGIN 
    begin
        Select REF(p) into ref 
        from infirmier p 
        where p.num_emp = x;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Medecin does not exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION check_service(x char) 
return char
IS 
    ref char(3); 
BEGIN 
    begin
        Select s.code_service into ref 
        from service s
        where s.code_service = x;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Service does not exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION check_medecin_spec(x varchar2) 
return varchar2
IS 
BEGIN 
    begin
        if x not in ('Anesthésiste','Cardiologue','Généraliste',
        'Orthopédiste','Radiologue','Pneumologue','Traumatologue') then
                raise_application_error (-20001,'Medecin specialite does not exist or Not found');
        end if;
    end;
    return x;
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION ref_chambre(x number, y char) 
return REF TCHAMBRE 
IS 
    ref REF TCHAMBRE := NULL; 
BEGIN 
    begin
        Select REF(p) into ref 
        from chambre p 
        where p.NUM_CHAMBRE = x and p.code_service =y;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Chambre doesnt exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION ref_patient(x number) 
return REF TPATIENT 
IS 
    ref REF TPATIENT := NULL; 
BEGIN 
    begin
        Select REF(p) into ref 
        from patient p 
        where p.num_patient = x;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Patient doesnt exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create or replace FUNCTION ref_hospitalisation(x number) 
return REF THOSPITALISATION 
IS 
    ref REF THOSPITALISATION := NULL; 
BEGIN 
    begin
        Select REF(p) into ref 
        from hospitalisation p 
        where p.num_patient = x;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            raise_application_error (-20001,'Patient doesnt exist or Not found');
    end;
    return ref;
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Create or replace Procedure medecin_patient_fill(x number, y number) 
IS 
BEGIN
        insert into table(
            select medecin_patient
            from medecin
            where num_emp = y
            ) 
        values(ref_patient(x));

        insert into table(
            select patient_medecin
            from patient
            where num_patient = x
            ) 
        values(ref_medecin(y));
END; 
/
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*@"C:\Users\Tp_sql\Desktop\code project\Tables\Functions.sql"*/
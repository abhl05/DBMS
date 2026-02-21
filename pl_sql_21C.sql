-- Problem 1: Procedure (20 Marks)
-- First, create and populate the following table:
-- CREATE TABLE TEMP_EMPLOYEES (
-- EMPLOYEE_ID VARCHAR2(10),
-- NAME VARCHAR2(100),
-- EMAIL VARCHAR2(50),
-- MANAGER_ID NUMBER(4,0),
-- MANAGER_CRED VARCHAR2(20)
-- );
-- INSERT INTO TEMP_EMPLOYEES (EMPLOYEE_ID, NAME, EMAIL, MANAGER_ID)
-- SELECT EMPLOYEE_ID, FIRST_NAME || ' ' || LAST_NAME, EMAIL, MANAGER_ID
-- FROM HR.EMPLOYEES;
-- Write a Procedure named POPULATE_CREDS that takes two integers MIN_EMP_COUNT and
-- MIN_JOB_COUNT as inputs. It populates (using UPDATE/SET) the Manager Credentials
-- (MANAGER_CRED) for only ELIGIBLE managers.
-- The Manager Credential of a manager is determined as the first two letters of their email,
-- followed by two asterisks, followed by the last two letters of the email, followed by a hyphen and
-- then the number of employees they manage. For example, if a manager has an email like
-- “MMORALES” and he manages 42 employees, his MANAGER_CRED will be “MM**ES-42”.
-- The managers ELIGIBLE for credentials are determined as follows:
-- ● If the manager has served at least MIN_JOB_COUNT number of different jobs
-- (including the current one) in the company, then he is eligible.
-- ● If the manager has served less than MIN_JOB_COUNT jobs (including the current one)
-- in the company, but currently he manages no less than MIN_EMP_COUNT employees,
-- then he is also eligible.
-- ● Otherwise, the manager is ineligible and should not get a credential.
-- Write the procedure to update credentials for eligible managers as described above.


CREATE TABLE TEMP_EMPLOYEEzz (
EMPLOYEE_ID VARCHAR2(10),
NAME VARCHAR2(100),
EMAIL VARCHAR2(50),
MANAGER_ID NUMBER(4,0),
MANAGER_CRED VARCHAR2(20)
);
INSERT INTO TEMP_EMPLOYEEZZ (EMPLOYEE_ID, NAME, EMAIL, MANAGER_ID)
SELECT EMPLOYEE_ID, FIRST_NAME || ' ' || LAST_NAME, EMAIL, MANAGER_ID
FROM HR.EMPLOYEES;

create or replace procedure populate_creds(min_emp_count in number, min_job_count in number) is
    v_elligible number;
    v_job_count number;
    v_emp_count number;
    v_cred varchar2(10);
begin 
    v_elligible := 1;
    for rec in (select employee_id, email, manager_cred from temp_employeezz) loop 
        select count(*) into v_job_count
        from job_history
        where employee_id = rec.employee_id;

        select count(*) into v_emp_count
        from temp_employeezz 
        where manager_id = rec.employee_id;

        if (v_job_count >= min_job_count or v_emp_count >= min_emp_count) then 
            v_cred := substr(rec.email, 1, 2) || '**' || substr(rec.email, length(rec.email)-1, 2) || '-' || v_emp_count;
            update temp_employeezz set manager_cred = v_cred where employee_id = rec.employee_id;
        end if;
    end loop;
end;
/

begin 
    populate_creds(5, 3); -- Call the procedure with minimum employee count of 5 and minimum job count of 3
end;

select * from temp_employeezz;

-- Problem 2: Trigger (20 Marks)
-- Write a trigger to update the DEPARTMENT_ID field when an employee transfers from one job
-- to another. The trigger should only be invoked when the JOB_ID column is updated in the
-- TEMP_EMPLOYEES Table.
-- Trigger 1:
-- The trigger should first validate the update in the JOB_ID field. The company has the following
-- policies to validate changes in JOB_ID.
-- ● Case 1: If the new JOB_ID is of higher rank than the current JOB_ID, then the change is
-- valid. The rank of a JOB_ID is calculated based on the maximum salary of all employees
-- in the JOB_ID.
-- ● Case 2: If the new JOB_ID is of a lower rank, then the change should be allowed only for
-- employees who have served less than five years in the company.
-- If the change is valid, then the update can be allowed. In this case, the DEPARTMENT_ID
-- column should be automatically updated to the DEPARTMENT_ID of the new JOB_ID. The new
-- DEPARTMENT_ID should be retrieved from the map table as discussed below.
-- If the change is not valid, then the trigger should throw an exception so that the query results in
-- an error.
-- Hints: You won't be able to use update statements inside triggers. First, create a
-- TEMP_EMPLOYEES table that is a copy of the EMPLOYEES table (SQL given below). Then
-- write your trigger on the TEMP_EMPLOYEES table. To avoid the “mutating” trigger issue, all
-- your PL/SQL statements should perform validation checks on the original EMPLOYEES table
-- (instead of TEMP_EMPLOYEES table).

DROP TABLE TEMP_EMPLOYEES
CREATE TABLE TEMP_EMPLOYEES AS SELECT * FROM EMPLOYEES;
SELECT * FROM TEMP_EMPLOYEES;
CREATE TABLE DEPARTMENT_JOB_MAP_TABLE AS
SELECT DISTINCT JOB_ID, DEPARTMENT_ID FROM EMPLOYEES WHERE
DEPARTMENT_ID IS NOT NULL order by DEPARTMENT_ID;
SELECT * FROM DEPARTMENT_JOB_MAP_TABLE;

-- --UPDATE JOB_ID
-- UPDATE TEMP_EMPLOYEES
-- SET JOB_ID = 'MK_MAN'
-- WHERE EMPLOYEE_ID = 198;
-- --- LOG CHECK
-- SELECT * FROM LOG_TEMP_EMPLOYEES_UPDATE_JID
-- --UPDATE JOB_ID
-- UPDATE TEMP_EMPLOYEES
-- SET JOB_ID = 'AD_VP'
-- WHERE EMPLOYEE_ID = 200
-- --- LOG CHECK
-- SELECT * FROM LOG_TEMP_EMPLOYEES_UPDATE_JID
-- --UPDATE JOB_ID
-- UPDATE TEMP_EMPLOYEES
-- SET JOB_ID = 'AD_ASST'
-- WHERE EMPLOYEE_ID = 101
-- --- LOG CHECK
-- SELECT * FROM LOG_TEMP_EMPLOYEES_UPDATE_JID
-- --UPDATE JOB_ID
-- UPDATE TEMP_EMPLOYEES
-- SET JOB_ID = 'SA_REP'
-- WHERE EMPLOYEE_ID = 178
-- --- LOG CHECK
-- SELECT * FROM LOG_TEMP_EMPLOYEES_UPDATE_JID

        

create or replace trigger update_job 
before update
of job_id
on temp_employees
for each row 
declare 
    v_new_rank number;
    v_old_rank number;
    v_exp number;
    v_new_dept_id number;
begin 
    select max(salary) into v_new_rank
    from employees
    where job_id = :new.job_id;
    
    select max(salary) into v_old_rank
    from employees 
    where job_id = :old.job_id;

    v_exp := months_between(sysdate, :old.hire_date) / 12;

    if(v_new_rank > v_old_rank or v_exp < 5) then 
        select department_id into v_new_dept_id
        from department_job_map_table
        where job_id = :new.job_id
        and rownum = 1;

        :new.department_id := v_new_dept_id;

    else 
        raise_application_error(-39393, 'no');
    end if;
end;
/

begin 
    UPDATE TEMP_EMPLOYEES
    SET JOB_ID = 'MK_MAN'
    WHERE EMPLOYEE_ID = 198;    
end;

SELECT * FROM TEMP_EMPLOYEES WHERE EMPLOYEE_ID = 198;
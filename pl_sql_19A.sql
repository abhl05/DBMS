-- 1. Write a PL/SQL trigger that is fired when a new row is inserted in the
-- EMPLOYEES table. The trigger checks the following constraints on this field.
-- a. Check if the email address follows the format “LAST_NAME@orcl.com”
-- in lowercase. If not, change the email address to
-- LAST_NAME.JOB_ID@orcl.com (All small letters)
-- Example: king.ad_pres@orcl.com
-- b. Check if the phone number has the format
-- “5555-EMPLOYEE_ID-DEPARTMENT_ID”. If not, change the phone
-- number to the mentioned format. If DEPARTMENT_ID is not provided,
-- the phone number would end with 000.
-- c. Check if the salary is positive. If a negative value is provided, raise the
-- following error.
-- “RAISE_APPLICATION_ERROR(-100, “Negative Value in Salary Filed.
-- Insertion Aborted”)
-- Test Queries:
-- 1. INSERT INTO EMPLOYEES
-- (EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY)
-- VALUES (990, 'ROBERT', 'ABC’, SYSDATE, 'AC_MGR', -5000);
-- 2. INSERT INTO EMPLOYEES
-- (EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY)
-- VALUES (990, 'ROBERT', 'ABC’, SYSDATE, 'AC_MGR', 5000);
drop table employees_copy;

create table employees_copy as 
select * from employees;

create or replace trigger validation_employees 
before insert
on employees_copy
for each row
begin 
    -- 1. Validate Email format
    -- Use :NEW instead of :OLD
    if (:new.email is null or :new.email <> lower(:new.last_name) || '@orcl.com') then 
        :new.email := lower(:new.last_name) || '.' || lower(:new.job_id) || '@orcl.com';
    end if;

    -- 2. Validate Phone Number format
    -- Note: Ensure 000 is treated as a string to keep the zeros
    if (:new.phone_number is null or :new.phone_number <> '5555-' || :new.employee_id || '-' || nvl(to_char(:new.department_id), '000')) then 
        :new.phone_number := '5555-' || :new.employee_id || '-' || nvl(to_char(:new.department_id), '000');
    end if;

    -- 3. Salary Check
    if (:new.salary < 0) then 
        RAISE_APPLICATION_ERROR(-20100, 'Negative Value in Salary Field. Insertion Aborted');
    end if;
end;
/

INSERT INTO EMPLOYEES_copy
(EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY)
VALUES (990, 'ROBERT', 'ABC', SYSDATE, 'AC_MGR', 5000);

select * from EMPLOYEES_COPY;


-- 2. Create the following table and sequence.
-- CREATE TABLE Salary_History(
-- HISTORY_ID NUMBER,
-- EMPLOYEE_ID NUMBER,
-- OLD_SALARY NUMBER,
-- NEW_SALARY NUMBER,
-- CHANGE_DATE DATE,
-- CHANGE_TYPE VARCHAR(50)
-- );

CREATE SEQUENCE Salary_History_Seq START WITH 1 INCREMENT BY 1;
-- Write a PL/SQL trigger that will fire only when an employee's salary is
-- inserted, updated, or deleted in the EMPLOYEES table; the trigger should
-- automatically create a new record in the 'Salary_History' table to log the
-- change, including the
-- HISTORY_ID (use Salary_History_Seq.NEXTVAL for this field), EMPLOYEE_ID,
-- the old salary, the new salary, the date of the change, and the change type
-- (INSERT, UPDATE, or DELETE).
-- Test Queries:
-- 3. DELETE FROM EMPLOYEES WHERE EMPLOYEE_ID = 115;
-- 4. UPDATE EMPLOYEES SET SALARY = 9999 WHERE EMPLOYEE_ID =
-- 102;
-- 5. INSERT INTO EMPLOYEES
-- (EMPLOYEE_ID, LAST_NAME, EMAIL, HIRE_DATE, JOB_ID, SALARY)
-- VALUES (990, 'ROBERT', 'ABC', SYSDATE, 'AC_MGR', 5000);
-- 6. ROLLBACK (set the database to default state)

CREATE TABLE Salary_History(
HISTORY_ID NUMBER,
EMPLOYEE_ID NUMBER,
OLD_SALARY NUMBER,
NEW_SALARY NUMBER,
CHANGE_DATE DATE,
CHANGE_TYPE VARCHAR(50)
);

create or replace trigger sal_update 
after insert or update or delete
on employees_copy
for each row
declare 
    v_change_type varchar(50);
begin 
    -- Use DML Predicates to identify the action
    if INSERTING then
        v_change_type := 'INSERT';
    elsif UPDATING then
        v_change_type := 'UPDATE';
    elsif DELETING then
        v_change_type := 'DELETE';
    end if;
    insert into salary_history (history_id, employee_id, old_salary, new_salary, change_date, change_type)
    values(Salary_History_Seq.NEXTVAL, nvl(:old.employee_id, :new.employee_id), :old.salary, :new.salary, sysdate, v_change_type);
end;
/

-- Test Update
UPDATE employees_copy SET salary = 9999 WHERE employee_id = 102;

-- Test Delete
DELETE FROM employees_copy WHERE employee_id = 115;

-- Check results
SELECT * FROM salary_history;


CREATE SEQUENCE my_seq
START WITH 100
INCREMENT BY 1
NOCACHE;

SELECT UPPER('hello world'), SUBSTR('Gemini', 1, 3) 
FROM DUAL;
-- Result: 'HELLO WORLD', 'Gem'
-- Create the following table.

CREATE TABLE EMP_SAL_LOG (
LOG_ID NUMBER,
EMPLOYEE_ID NUMBER,
OLD_SALARY NUMBER,
NEW_SALARY NUMBER,
MOD_DATE DATE,
USER_ID NUMBER,
USERNAME VARCHAR2(100),
STATUS VARCHAR2(10)
);

-- 1. Write a PL/SQL trigger that will fire only when one or more employees have been added to or removed from
-- the EMPLOYEES table. The trigger should populate the EMP_SAL_LOG table with corresponding values. The
-- STATUS should be ‘APPROVED’. MOD_DATE is the current date. LOG_ID should be incremented
-- sequentially (starting from 1). Keep the irrelevant fields null. You may consider that EMPLOYEE_ID will
-- always be unique during insertion into the EMPLOYEES table.
create sequence log_id start with 1 increment by 1;

drop table employees_copy;

create table employees_copy as 
select * from employees;

create or replace trigger employee_logs
after insert or delete 
on employees_copy
for each row
declare 
begin 
    insert into emp_sal_log (
        LOG_ID,
        EMPLOYEE_ID,
        OLD_SALARY,
        NEW_SALARY,
        MOD_DATE,
        USER_ID,
        USERNAME,
        STATUS
    ) values (
        log_id.nextval, 
        nvl(:old.employee_id, :new.employee_id),
        :old.salary,
        :new.salary,
        sysdate,
        null,
        null,
        'APPROVED'
    );
end;
/

-- Test Delete
DELETE FROM employees_copy WHERE employee_id = 115;

-- Check results
SELECT * FROM emp_sal_log;


-- 2. Write another PL/SQL trigger that will fire only when the salary of an existing employee is updated. The
-- trigger should populate the EMP_SAL_LOG table with corresponding values. You must ensure that salary is not
-- changed in either of the following cases.
-- a. If the last update was less than one month ago.
-- b. If the increment or decrement is more than 20%.
-- In any of these cases, users should be informed like ‘SALARY UPDATE FAILED’ and STATUS should be
-- 'DENIED’. Otherwise STATUS should be ‘APPROVED’. MOD_DATE is the current date. LOG_ID should
-- be incremented sequentially.
-- You may check the following query.
-- SELECT * FROM ALL_USERS WHERE USER_ID = USERENV('SCHEMAID');
-- While testing you may try modifying the MOD_DATE:
-- UPDATE EMP_SAL_LOG SET MOD_DATE = (MOD_DATE - ##) WHERE LOG_ID = ##;
-- Here, ## is any integer.

create or replace trigger salary_update_logs
before update of salary
on employees_copy
for each row 
declare 
    last_update_date date;
    salary_change_percentage number;
begin
    -- Get the last update date for the employee
    select max(mod_date) into last_update_date
    from emp_sal_log
    where employee_id = :old.employee_id
    and status = 'APPROVED';
    -- Calculate the percentage change in salary
    if :old.salary is not null and :new.salary is not null then
        salary_change_percentage := abs(:new.salary - :old.salary) / :old.salary * 100;
    else
        salary_change_percentage := 0;
    end if;
    -- Check the conditions for salary update
    if last_update_date is not null and (sysdate - last_update_date) < 30 then
        :new.salary := :old.salary; -- Revert to old salary
        insert into emp_sal_log (
            LOG_ID,
            EMPLOYEE_ID,
            OLD_SALARY,
            NEW_SALARY,
            MOD_DATE,
            USER_ID,
            USERNAME,
            STATUS
        ) values (
            log_id.nextval, 
            :old.employee_id,
            :old.salary,
            :new.salary,
            sysdate,
            null,
            null,
            'DENIED'
        );
        raise_application_error(-20001, 'SALARY UPDATE FAILED: Last update was less than one month ago.');
    elsif salary_change_percentage > 20 then
        :new.salary := :old.salary; -- Revert to old salary
        insert into emp_sal_log (
            LOG_ID,
            EMPLOYEE_ID,
            OLD_SALARY,
            NEW_SALARY,
            MOD_DATE,
            USER_ID,
            USERNAME,
            STATUS
        ) values (
            log_id.nextval, 
            :old.employee_id,
            :old.salary,
            :new.salary,
            sysdate,
            null,
            null,
            'DENIED'
        );
        raise_application_error(-20002, 'SALARY UPDATE FAILED: Increment or decrement is more than 20%.');
    else
        insert into emp_sal_log (
            LOG_ID,
            EMPLOYEE_ID,
            OLD_SALARY,
            NEW_SALARY,
            MOD_DATE,
            USER_ID,
            USERNAME,
            STATUS
        ) values (
            log_id.nextval, 
            :old.employee_id,
            :old.salary,
            :new.salary,
            sysdate,
            null,
            null,
            'APPROVED'
        );
    end if;
end;
/


    update employees_copy set salary = salary * 1.1 where employee_id = 101; -- Should be approved
    update employees_copy set salary = salary * 1.3 where employee_id = 102; -- Should be denied (more than 20%)
    update employees_copy set salary = salary * 0.9 where employee_id = 103; -- Should be approved
    update employees_copy set salary = salary * 0.7 where employee_id = 104; -- Should be denied (more than 20%)
    update employees_copy set salary = salary * 1.05 where employee_id = 105; -- Should be approved
    update employees_copy set salary = salary * 1.1 where employee_id = 101; -- Should be denied (last update less than one month ago)


select * from emp_sal_log;

-- Problem 1: Procedure (20 Marks)
-- Write a Procedure named RANK_JOBS that takes one integer MIN_HIRED_COUNT as input. It
-- ranks the jobs whose JOB_ID matches with the ID extracted from its JOB_TITLE. The extracted
-- ID contains the first two letters of the first word of the title, followed by an underscore, followed
-- by the first three letters of the second word (if any) of the title. For example, from the title
-- ‘Sales Representative’, the extracted ID would be ‘SA_REP’. If the actual JOB_ID also is
-- ‘SA_REP’, then there is a match.
-- The jobs having this match, which also have to have their number of hired employees no less
-- than MIN_HIRED_COUNT, are then ranked by the Procedure RANK_JOBS. The ranking is
-- done according to the descending order of their average salaries, with the job having the
-- highest average salary ranked as 1. Finally, insert the ranks of the jobs in the JOB_RANK table
-- given below.
CREATE TABLE JOB_RANK (
JOB_ID VARCHAR2(10),
RANK NUMBER
);

create or replace procedure rank_jobs(min_hired_count IN NUMBER) is
    v_rank number;
begin 
    delete from job_rank;
    v_rank := 0;
    for rec in (
                select j.job_id 
                from jobs j
                join employees e
                on j.job_id = e.job_id
                where (j.job_id = upper(substr(j.job_title, 1, 2) || '_' || substr(substr(j.job_title, instr(j.job_title, ' ') + 1), 1, 3)))
                group by j.job_id 
                having count(e.employee_id) >= min_hired_count
                order by avg(e.salary) desc
                ) loop
        v_rank := v_rank + 1;
        insert into job_rank (job_id, rank) values (rec.job_id, v_rank);
    end loop;
end;
/

BEGIN
    rank_jobs(3); -- Call the procedure with a minimum hired count of 3
END;

select * from job_rank;

-- Problem 2: Trigger (20 Marks)
-- Please write a trigger to validate updates of salary values in the TEMP_EMPLOYEES table,
-- which is a copy of the HR.EMPLOYEES table). The trigger should only be invoked when the
-- SALARY column is updated in the TEMP_EMPLOYEES Table.

-- This trigger should check if the updates are valid. The constraint for validating salary of an
-- employee is as follows:
-- ● Case 1: The salary cannot be less than the minimum salary of the same JOB_ID of other
-- employees in the company.
-- ● Case 2: If the employee is not a manager, then the salary must be less than the
-- minimum salaries of the managers who manage the same JOB_ID.
-- ● Case 3: If the employee is a manager, the salary must be less than the salary of the
-- manager of the same department.
-- If the salary is not valid, then the trigger should throw an exception so that the update results in
-- an error.
-- If the salary is valid, the update should be allowed.
-- First, create a TEMP_EMPLOYEES table that is a copy of the EMPLOYEES table (SQL given
-- below). Then write your trigger on the test TEMP_EMPLOYEES table. To avoid the “mutating”
-- trigger issue, all your PL/SQL statements should perform validation checks on the original
-- EMPLOYEES table (instead of TEMP_EMPLOYEES table).
create table temp_employees as
select * from employees
commit;

create or replace trigger validate_update 
before update 
of salary
on temp_employees 
for each row
declare 
    v_flag number := 1;
    v_min_job_sal number;
    v_min_mng_sal number;
    v_min_dept_mng_sal number;
begin 
    select min_salary into v_min_job_sal 
    from jobs 
    where job_id = :old.job_id;
    if(:new.salary < v_min_job_sal) then 
        v_flag := 0;
    end if;

    select count(*) into v_min_mng_sal
    from employees 
    where manager_id = :old.employee_id;
    if(v_min_mng_sal = 0) then
        select min(salary) into v_min_mng_sal
        from employees m 
        where m.employee_id in (
            select distinct manager_id 
            from employees
            where job_id = :old.job_id
        );
        if(:new.salary >= v_min_mng_sal) then 
            v_flag := 0;
        end if;
    else 
        select salary into v_min_dept_mng_sal
        from employees 
        where employee_id = :new.manager_id;

        if(:new.salary >= v_min_dept_mng_sal) then 
            v_flag := 0;
        end if;
    end if;
    if(v_flag = 0) then 
        raise_application_error(-20001, 'Invalid salary update');
    end if;
exception 
    when no_data_found then 
        null; -- Handle cases where there are no managers or employees found
    when others then
        dbms_output.put_line('An error occurred: ' || sqlerrm);
end;
/

-- This should fail if it exceeds their manager's salary
UPDATE temp_employees SET salary = 999999 WHERE employee_id = 101;

-- This should fail if it is below the job's minimum (e.g., AD_VP min is 20000)
UPDATE temp_employees SET salary = 1000 WHERE employee_id = 101;
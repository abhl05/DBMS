-- Question 1 
-- Write a PL/SQL trigger that will fire only when either SALARY
-- or JOB_ID column of the EMPLOYEES table will be updated. You need to
-- track if the new salary is within the interval defined by the MIN_SALARY
-- and MAX_SALARY corresponding to the updated JOB_ID. If the new salary
-- is less than the MIN_SALARY, set the new salary to the MIN_SALARY. If
-- the new salary is greater than the MAX_SALARY, set the new salary to the
-- MAX_SALARY. In addition, if JOB_ID is changed, you have to make sure
-- the MIN_SALARY corresponding to the updated JOB_ID is not less than the
-- MIN_SALARY corresponding to the previous JOB_ID. Otherwise do not let
-- the update take place.

create or replace trigger salary_job_update
before update 
of salary, job_id
on employees_copy
for each row 
declare 
    v_new_min_sal number;
    v_new_max_sal number;
    v_old_min_sal number;
begin 
    select min_salary, max_salary into v_new_min_sal, v_new_max_sal
    from jobs
    where job_id = :new.job_id;

    select min_salary into v_old_min_sal
    from jobs
    where job_id = :old.job_id;

    if(:old.job_id <> :new.job_id) then 
        if(v_new_min_sal < v_old_min_sal) then 
            raise_application_error(-20001, 'Invalid job id update');
        end if;
    end if;

    if(:new.salary < v_new_min_sal) then 
        :new.salary := v_new_min_sal; 
    elsif (:new.salary > v_new_max_sal) then 
        :new.salary := v_new_max_sal; 
    end if;
end;
/

update employees_copy set salary = 5000 where employee_id = 101; -- Replace with an actual employee ID to test

update employees_copy set job_id = 'AD_PRES', salary = 1000 where employee_id = 101; -- Replace with an actual employee ID to test

alter trigger salary_update_logs disable;
select * from EMPLOYEES_COPY;
select * from JOBS;


-- Question 2 
-- Write a PL/SQL trigger that activates when no manager is as-
-- signed to an employee during insertion. The trigger outputs to the console “No

-- manager of "FIRST_NAME_OF_THE_NEW_EMPLOYEE" has been assigned”. Then it
-- assigns the manager of the department of the newly inserted employee to be the
-- manager of the employee.

create or replace trigger manager_chk 
before insert 
on employees_copy 
for each row
declare 
begin 
    if(:new.manager_id is null) then 
        dbms_output.put_line('no manager of ' || :new.first_name || ' has been assigned.');
        select manager_id into :new.manager_id 
        from departments 
        where department_id = :new.department_id;
    end if;
end;
/

insert into employees_copy (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary, department_id)
values (999, 'John', 'Doe', 'john.doe@company.com', '555-1234', sysdate, 'IT_PROG', 5000, 60);

select * from employees_copy where employee_id = 999;
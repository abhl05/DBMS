-- Task 1: Write a function to check whether a given employee is among the top N paid employees
-- of his department.
-- Input parameters: employee_id, N
-- Return value: 0/1

create or replace function in_top_n (
    p_employee_id in employees.employee_id%type,
    p_n in number
) return number is 
    v_res number;
    v_itr number;
begin 
    v_itr := 1;
    v_res := 0;
    for rec in (select employee_id 
                from employees 
                where department_id = (select department_id from employees where employee_id = p_employee_id)
                order by salary desc) loop 
        if (rec.employee_id = p_employee_id) then 
            v_res := 1;
        end if;
        exit when (v_itr > p_n);
        v_itr := v_itr + 1;
    end loop;
    return v_res;
exception
    when no_data_found then 
        return 0;
    when others then 
        return 0;
end;
/

begin 
    dbms_output.put_line(in_top_n(101, 5));
end;
/


-- Task 2: Write a function to find the longest serving employee’s last name in a given job. If there
-- are multiple, return anyone.
-- Input parameter: job_title
-- Return parameter: employee last name

create or replace function veteran_employee (p_job_title in jobs.job_title%type) 
    return varchar2 is 
        v_veteran_employee employees.last_name%type;
        v_exp_diff number;
begin 
    select last_name into v_veteran_employee
    from employees
    where job_id = (select job_id from jobs where job_title = p_job_title)
    order by hire_date asc
    fetch first 1 row only;
    return v_veteran_employee;
end;
/

begin 
    dbms_output.put_line(veteran_employee('Programmer'));
end;
    
select * from employees where JOB_ID = 'IT_PROG' order by hire_date;

-- Task 3: Write a procedure transfer(eid, job_id). The procedure changes the job_id of the
-- employee given by eid to the new job given by job_id. New salary will be determined as follows:
-- the lowest salary of the employees who i) are currently working in the same job_id, ii) who
-- joined earlier than eid in the company, and iii) who gets a higher salary than the current salary of
-- eid. If no such employee then employees current salary will remain unchanged. The procedure
-- finally prints the new salary of the employee.

create or replace procedure transfer(eid in employees.employee_id%type, job_id in jobs.job_id%type) is
    v_eid number;
    v_hire_date date;
    v_old_salary number;
    v_new_salary number;
begin 
    select hire_date, salary into v_hire_date, v_old_salary
    from employees
    where employee_id = eid;
    begin
        select salary 
        into v_new_salary 
        from (
            select salary 
            from employees 
            where job_id = transfer.job_id 
            and hire_date < v_hire_date 
            and salary > v_old_salary 
            order by salary asc
        ) where rownum = 1;

    exception 
        when no_data_found then 
            v_new_salary := v_old_salary;
        when others then 
            dbms_output.put_line('An error occurred: ' || sqlerrm);
    end;
    dbms_output.put_line('New Salary: ' || v_new_salary);
end;
/

BEGIN
    transfer(103, 'IT_PROG'); -- Replace with valid IDs from your table
END;



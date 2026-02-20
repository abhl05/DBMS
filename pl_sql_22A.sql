-- Question 1.
-- Write a PL/SQL procedure named LONGEST_SERVING_EMPLOYEE that takes a
-- REGION_NAME as input and identifies the employee who has been working for the longest time within
-- that region.
-- Retrieve and display the following details for that employee.
-- • Full Name (First Name + Last Name)
-- • Job Title
-- • Hire Date
-- • Country Name
-- • Department Name
-- • City
-- Make sure to handle exceptions with appropriate messages.

create or replace procedure longest_serving_employee (
   p_region_name in regions.region_name%type
) is
   v_full_name employees.first_name%type;
   v_job_title jobs.job_title%type;
   v_hire_date employees.hire_date%type;
   v_country_name countries.country_name%type;
   v_department_name departments.department_name%type;
   v_city locations.city%type;
begin 
    select e.first_name || ' ' || e.last_name,
             j.job_title,
             e.hire_date,
             c.country_name,
             d.department_name,
             l.city
      into v_full_name,
             v_job_title,
             v_hire_date,
             v_country_name,
             v_department_name,
             v_city
      from employees e
      join departments d on e.department_id = d.department_id
      join locations l on d.location_id = l.location_id
      join countries c on l.country_id = c.country_id
      join regions r on c.region_id = r.region_id
      join jobs j on e.job_id = j.job_id
     where r.region_name = p_region_name
     order by e.hire_date asc
     fetch first 1 row only;
    dbms_output.put_line('Full Name: ' || v_full_name);
    dbms_output.put_line('Job Title: ' || v_job_title);
    dbms_output.put_line('Hire Date: ' || to_char(v_hire_date, 'YYYY-MM-DD'));
    dbms_output.put_line('Country Name: ' || v_country_name);
    dbms_output.put_line('Department Name: ' || v_department_name);
    dbms_output.put_line('City: ' || v_city);
exception
    when no_data_found then
        dbms_output.put_line('No employee found in the specified region.');
    when too_many_rows then
        dbms_output.put_line('Multiple employees found in the specified region.');
    when others then
        dbms_output.put_line('An error occurred: ' || sqlerrm);
end longest_serving_employee;

BEGIN
    longest_serving_employee('Americas'); -- Replace with an actual region name to test
END;


-- Question 2.
-- Write a procedure named RANK_JOBS in Oracle HR schema. The procedure should rank jobs based on
-- the following criteria:
-- 1. Number of Employees: Jobs should be ranked in descending order of their number of
-- employees. The job with the highest number of employees should be ranked as 1.
-- 2. Average Salary: If multiple jobs have the same number of employees, the ranking should be
-- determined based on the average salary in that job, in descending order.
-- The output should display the following information:

-- o Rank
-- o Job Title
-- o Total Number of Employees
-- o Average Salary
-- o Maximum Salary
-- o Minimum Salary

create or replace procedure rank_jobs is
    v_rank number;
begin
    v_rank := 0;
    for rec in (select j.job_title,
                       count(e.employee_id) as total_employees,
                       avg(e.salary) as average_salary,
                       max(j.max_salary) as max_salary,
                       min(j.min_salary) as min_salary
                  from jobs j
                  left join employees e on j.job_id = e.job_id
                 group by j.job_title
                 order by total_employees desc, average_salary desc) loop
        v_rank := v_rank + 1;
        dbms_output.put_line('Rank: ' || v_rank);
        dbms_output.put_line('-----------------------------');
        dbms_output.put_line('Job Title: ' || rec.job_title);
        dbms_output.put_line('Employees: ' || rec.total_employees);
        dbms_output.put_line('Avg Salary: ' || rec.average_salary);
        dbms_output.put_line('Max Salary: ' || rec.max_salary);
        dbms_output.put_line('Min Salary: ' || rec.min_salary);
    end loop;
end rank_jobs;

BEGIN
    rank_jobs; -- Call the procedure to display the job rankings
END;

-- Question 3.
-- Create a trigger that activates when an employee leaves the job (i.e., when a DELETE operation is
-- performed on the Employee table).
-- 1 new table: Leaves
-- (fields:
-- employee_id,
-- employee_working_instead_of_him/her,
-- current date
-- )
-- Conditions:
-- 1. If that employee has a manager, his/her work should be done by the employee who has the same
-- manager and has the closest salary to him\her.
-- 2. In case the employee is a manager, his/her work is done by a manager who has the closest
-- subordinate count as him/her.
-- 3. If an employee meets both conditions 1 and 2 (is a manager and has a manager), go for 2.
-- 4. If no substitute employee is found, keep that field null.
-- No changes in the Job table and the Job_history table are necessary for your ease.

create table Leaves (
    employee_id number,
    employee_working_instead_of_him number,
    current_date date
)

create or replace trigger job_fire 
before delete 
on employees_copy
for each row 
declare 
    v_sub_count number;
    v_collegue number;
    v_manager_closest number;
begin
    select count(*) into v_sub_count
    from employees_copy 
    where employees_copy.manager_id = :old.employee_id;

    if (:old.manager_id is not null) then 
        select employee_id into v_collegue
        from (
            select employee_id, abs(salary - :old.salary) as salary_diff
            from employees_copy
            where manager_id = :old.manager_id and employee_id != :old.employee_id
            order by salary_diff asc
        )
        where rownum = 1;
    end if;

    if (v_sub_count > 0) then 
        select employee_id into v_manager_closest
        from (
            select e.employee_id, count(s.employee_id) as sub_count_diff
            from employees_copy e
            left join employees_copy s on e.employee_id = s.manager_id
            where e.employee_id != :old.employee_id
            group by e.employee_id
            order by abs(count(s.employee_id) - v_sub_count) asc
        )
        where rownum = 1;

        insert into Leaves (employee_id, employee_working_instead_of_him, current_date)
        values (:old.employee_id, v_manager_closest, sysdate);
    elsif (v_collegue is not null) then
        insert into Leaves (employee_id, employee_working_instead_of_him, current_date)
        values (:old.employee_id, v_collegue, sysdate);
    else 
        insert into Leaves (employee_id, employee_working_instead_of_him, current_date)
        values (:old.employee_id, null, sysdate);
    end if;
end;
/

begin 
    delete from employees_copy where employee_id = 101; -- Replace with an actual employee ID to test
end;



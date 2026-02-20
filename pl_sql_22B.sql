-- Question 1.
-- First create a copy of the EMPLOYEES table in the HR schema, named EMPLOYEES_COPY. Do all
-- the work in EMPLOYEES_COPY table.
-- Write a function named Exchange_Employees that should take two manager_ids as parameters and
-- exchange the lowest-paying employees under each manager. If there is a tie (i.e., multiple employees
-- have the same salary), select any one of them. Note that when employees are exchanged, their jobs will
-- remain the same, but one employee will join the department of the other employee under that employee’s
-- manager. The salaries of the exchanged employees will be updated. The new salary for each employee
-- will be increased by 50% of the difference between their original salaries. Print the employee’s
-- information before and after the exchange and handle appropriate exceptions.

create table employees_copy
   as
      select *
        from employees;
commit;

create or replace procedure show_employee_info (p_employee_id in number) is
   v_employee employees_copy.employee_id%type;
   v_first_name employees_copy.first_name%type;
   v_last_name employees_copy.last_name%type;
   v_salary employees_copy.salary%type;
   v_department_id employees_copy.department_id%type;
begin
   select employee_id,
            first_name,
            last_name,
            salary,
            department_id
         into v_employee,
            v_first_name,
            v_last_name,
            v_salary,
            v_department_id
         from employees_copy
        where employee_id = p_employee_id;  
    dbms_output.put_line('Employee ID: ' || v_employee);
    dbms_output.put_line('Name: ' || v_first_name || ' ' || v_last_name);
    dbms_output.put_line('Salary: ' || v_salary);
    dbms_output.put_line('Department ID: ' || v_department_id);
exception
    when no_data_found then
        dbms_output.put_line('Employee not found');
    when others then
        dbms_output.put_line('An error occurred: ' || sqlerrm);
end show_employee_info;
/

create or replace function exchange_employees (
   mid1 in number,
   mid2 in number
) return varchar2 is
   emp_id1 number;
   dept1   employees_copy.department_id%type;
   sal1    employees_copy.salary%type;
   emp_id2 number;
   dept2   employees_copy.department_id%type;
   sal2    employees_copy.salary%type;
begin
   select employee_id,
          department_id,
          salary
     into
      emp_id1,
      dept1,
      sal1
     from (
      select employee_id,
             department_id,
             salary
        from employees_copy
       where manager_id = mid1
       order by salary asc
   )
    where rownum = 1;
   select employee_id,
          department_id,
          salary
     into
      emp_id2,
      dept2,
      sal2
     from (
      select employee_id,
             department_id,
             salary
        from employees_copy
       where manager_id = mid2
       order by salary asc
   )
    where rownum = 1;

--info before exchange
   show_employee_info(emp_id1);
   show_employee_info(emp_id2);
   update employees_copy
      set department_id = dept2,
          manager_id = mid2,
          salary = abs(sal1 - sal2) * 0.5 + salary
    where employee_id = emp_id1;
   update employees_copy
      set department_id = dept1,
          manager_id = mid1,
          salary = abs(sal1 - sal2) * 0.5 + salary
    where employee_id = emp_id2;
   commit;

-- info after exchange
   show_employee_info(emp_id1);
   show_employee_info(emp_id2);
   return 'Employees have been successfully exchanged.';
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error Code: ' || SQLCODE);
      DBMS_OUTPUT.PUT_LINE('Error Message: ' || SQLERRM);
      RETURN 'Exchange failed.';
end;
/
ALTER TRIGGER SAL_UPDATE DISABLE; -- Disable the salary update trigger to prevent interference with this test

DECLARE
    v_result VARCHAR2(100);
BEGIN
    -- Ensure serveroutput is on to see the names
    v_result := exchange_employees(101, 102); 
    DBMS_OUTPUT.PUT_LINE(v_result);
END;
/

-- Question 2.
-- Write a PL/SQL procedure named LOCATION_SALARY_REPORT that performs the following
-- tasks:
-- • For each location (city), compute:
-- o The number of employees working in that city
-- o The average salary of those employees (rounded to 2 decimal places)
-- o The job title of the highest-paid employee in that city
-- • Rank the cities based on:
-- o Ascending order of the number of employees
-- o Descending order of average salary (used as a tie-breaker)
-- • Print the following information for each location:
-- o Rank
-- o City Name
-- o Number of Employees
-- o Average Salary
-- o Highest Paying Job Title

-- Make sure to handle exceptions with appropriate messages.

create or replace procedure location_salary_report is
   v_rank number := 0;
begin
   for rec in (
      select l.city,
             l.location_id, -- Keep ID for subquery lookup
             count(e.employee_id) as total_employees,
             round(avg(e.salary), 2) as average_salary
        from locations l
        join departments d
      on l.location_id = d.location_id
        join employees e
      on d.department_id = e.department_id
       group by l.city,
                l.location_id
       order by total_employees asc,
                average_salary desc
   ) loop
      v_rank := v_rank + 1;

        -- We find the highest paying job title for this specific location_id
      declare
         v_highest_job jobs.job_title%type;
      begin
         select j.job_title
           into v_highest_job
           from employees e
           join jobs j
         on e.job_id = j.job_id
           join departments d
         on e.department_id = d.department_id
          where d.location_id = rec.location_id
            and e.salary = (
            select max(salary)
              from employees e2
              join departments d2
            on e2.department_id = d2.department_id
             where d2.location_id = rec.location_id
         )
            and rownum = 1; -- Handle ties

         dbms_output.put_line('Rank: '
                              || v_rank
                              || ' | City: '
                              || rec.city
                              || ' | Employees: '
                              || rec.total_employees
                              || ' | Avg Salary: '
                              || rec.average_salary
                              || ' | Highest Paying Job: ' || v_highest_job);
      exception
         when no_data_found then
            v_highest_job := 'N/A';
      end;
   end loop;
exception
   when others then
      dbms_output.put_line('An error occurred: ' || sqlerrm);
end location_salary_report;
/

begin
   location_salary_report; -- Call the procedure to display the report
end;



-- Question 3.
-- Create a trigger that activates when an employee is transferred to a new department (i.e., when an UPDATE
-- operation on the department_id is performed in the Employee table).
-- 1 new table: Transfers
-- (Fields:
-- employee_id,
-- employee_working_instead_of_him,
-- new_department,
-- current date
-- )
-- Conditions:
-- 1. If that employee had a manager,
-- a. An employee with the closest salary to him/her under the same manager will work instead of
-- him/her. The new salary for that work-in-place employee will be equal to previous salary of
-- that work-in-place employee + 0.5* salary of the transferred employee.
-- b. His/her new manager in the new department should be the manager with the closest number of
-- subordinates to his/her previous manager.

-- No changes in the Job table and the Job_history table are necessary for your ease.

-- Step 1: Create the Transfers table
create table transfers (
   employee_id                     number,
   employee_working_instead_of_him number,
   new_department                  number,
   transfer_date                   date
);

-- -- Step 2: Create the Trigger
-- CREATE OR REPLACE TRIGGER trg_transfer_employee
-- BEFORE UPDATE OF department_id ON employees_copy
-- FOR EACH ROW
-- WHEN (OLD.department_id IS NOT NULL AND NEW.department_id != OLD.department_id)
-- DECLARE
--     v_work_instead_id NUMBER;
--     v_new_manager_id  NUMBER;
--     v_prev_sub_count  NUMBER;
-- BEGIN
--     -- Only proceed if the employee had a manager
--     IF :OLD.manager_id IS NOT NULL THEN
        
--         -- Requirement 1a: Find employee with closest salary under same manager
--         -- This query finds the ID of the person whose salary diff is smallest
--         SELECT employee_id INTO v_work_instead_id
--         FROM (
--             SELECT employee_id 
--             FROM employees_copy 
--             WHERE manager_id = :OLD.manager_id 
--             AND employee_id != :OLD.employee_id
--             ORDER BY ABS(salary - :OLD.salary) ASC
--         )
--         WHERE ROWNUM = 1;

--         -- Update the stand-in employee's salary
--         -- New Salary = Current + 0.5 * Transferred Employee's Salary
--         UPDATE employees_copy 
--         SET salary = salary + (0.5 * :OLD.salary)
--         WHERE employee_id = v_work_instead_id;

--         -- Requirement 1b: Find new manager in the new department
--         -- First, get the subordinate count of the old manager
--         SELECT COUNT(*) INTO v_prev_sub_count 
--         FROM employees_copy 
--         WHERE manager_id = :OLD.manager_id;

--         -- Find manager in new dept with closest subordinate count to the old manager
--         SELECT manager_id INTO v_new_manager_id
--         FROM (
--             SELECT manager_id
--             FROM employees_copy
--             WHERE department_id = :NEW.department_id
--             AND manager_id IS NOT NULL
--             GROUP BY manager_id
--             ORDER BY ABS(COUNT(*) - v_prev_sub_count) ASC
--         )
--         WHERE ROWNUM = 1;

--         -- Reassign the transferred employee to this new manager
--         -- Since this is a BEFORE trigger, we use :NEW to change the value before it's saved
--         :NEW.manager_id := v_new_manager_id;

--         -- Record the transfer in the log table
--         INSERT INTO Transfers (
--             employee_id, 
--             employee_working_instead_of_him, 
--             new_department, 
--             transfer_date
--         ) VALUES (
--             :OLD.employee_id, 
--             v_work_instead_id, 
--             :NEW.department_id, 
--             SYSDATE
--         );
        
--     END IF;
-- EXCEPTION
--     WHEN NO_DATA_FOUND THEN
--         -- Handle cases where no colleague or no manager is found in the new dept
--         NULL; 
-- END;
-- /

create or replace trigger trg_transfer_employee 
after update of department_id on employees_copy
   for each row
declare
   v_curr_date             date;
   v_work_instead_id       employees.employee_id%type;
   v_prev_manager_id       employees.manager_id%type;
   v_prev_salary           employees.salary%type;
   v_closest_salary        employees.salary%type := null;
   v_diff                  number := null;
   v_new_salary            number;
   v_prev_manager_subcount number;
   v_new_manager_id        employees.manager_id%type;
   v_new_dept_manager_id   employees.manager_id%type;
   v_min_diff              number := null;
   v_candidate_id          employees.employee_id%type;
   cursor c_managers is
   select e.manager_id,
          count(*) as sub_count
     from employees e
    where e.manager_id is not null
    group by e.manager_id;
   
begin
   v_curr_date := sysdate;
-- Step 1: Record the transfer
   insert into transfers (
      employee_id,
      new_department,
      transfer_date
   ) values ( :old.employee_id,
              :new.department_id,
              v_curr_date );
   v_prev_salary := :old.salary;
   v_prev_manager_id := :old.manager_id;
-- Step 2: If the employee had a manager
   if v_prev_manager_id is not null then
-- Find employee with closest salary under same manager
      for emp in (
         select employee_id,
                salary
           from employees
          where manager_id = v_prev_manager_id
            and employee_id != :old.employee_id
      ) loop
         if v_diff is null
         or abs(emp.salary - v_prev_salary) < v_diff then
            v_diff := abs(emp.salary - v_prev_salary);
            v_work_instead_id := emp.employee_id;
            v_closest_salary := emp.salary;
         end if;
      end loop;
      if v_work_instead_id is not null then
-- Update salary of the work-instead employee
         v_new_salary := v_closest_salary + 0.5 * v_prev_salary;
         update employees
            set
            salary = v_new_salary
          where employee_id = v_work_instead_id;
-- Update Transfers table with the stand-in employee
         update transfers
            set
            employee_working_instead_of_him = v_work_instead_id
          where employee_id = :old.employee_id
            and transfer_date = v_curr_date;
      end if;
-- Step 3: Find new manager in new department
      select count(*)
        into v_prev_manager_subcount
        from employees
       where manager_id = v_prev_manager_id;
      for mgr in (
         select manager_id,
                count(*) as sub_count
           from employees
          where department_id = :new.department_id
            and manager_id is not null
          group by manager_id
      ) loop
         if v_min_diff is null
         or abs(mgr.sub_count - v_prev_manager_subcount) < v_min_diff then
            v_min_diff := abs(mgr.sub_count - v_prev_manager_subcount);
            v_new_manager_id := mgr.manager_id;
         end if;
      end loop;
-- Update manager of transferred employee
      if v_new_manager_id is not null then
         update employees
            set
            manager_id = v_new_manager_id
          where employee_id = :new.employee_id;
      end if;
   end if;
end;
/

begin 
    -- Example update to trigger the transfer logic
   update employees_copy
      set
      department_id = 30 -- Assuming 30 is a different department
    where employee_id = 101; -- Replace with an actual employee ID to test
end;

select * from transfers; -- Check the Transfers log after the update
-- In this assignment, you will write a procedure and a trigger. All tasks are based on the HR
-- schema.
-- Task 1: Write a PL/SQL procedure (25 points)
-- First, create the following table in your database:
-- Create table lowest_paid_employees(employee_id varchar2(100), department_id
-- varchar2(100), saldiff number, bonus number, tag varchar2(100));
-- Every year the company requires publishing a report that shows the lowest paid employees of each
-- department.
-- Create a procedure Update_Lowest_Paid_Employees(m number, n number) that populates the
-- table lowest_paid_employees. The procedure would find the lowest salaried permanent employee of
-- each department and then insert those records in the table appropriately. The company has adopted the
-- following policy to find the lowest paid permanent employee of a department:
--  Case 1: If there is only one such employee having the lowest salary, then insert his records.
--  Case 2: If there is more than one such employee with the lowest salary, then insert the employee
-- who joined the company earlier.
--  Case 3: A lowest salaried employee cannot also be the highest salaried employee of the same
-- department. In this case, no employee of that department will be considered as a lowest paid
-- employee.
--  Note that, an employee is not permanent until his probation period has passed. The company
-- uses a 1-year probation period from the hiring date.
-- See the table definition above to understand the columns you will need to insert.
--  The saldiff column stores the difference between the employee’s salary and the highest salary of
-- the employee’s department.
--  The tag column should be inserted null at this point. This column will later be populated
-- automatically by a trigger (Task 2).
--  Bonus is calculated as follows.
-- o Bonus amount is

-- for every

-- year period the employee has worked in the company.
-- Employees do not get any bonus for fractional periods. For example, if the employee has
-- worked for 6 years where

-- = 10,000 and

-- = 5, then he will get bonus 10,000 for

-- completing only 1 period (first 5 years).
-- o 5,000 management bonus if the employee is a manager and manages at least 5
-- employees.
CREATE TABLE lowest_paid_employees (
    employee_id VARCHAR2(100),
    department_id VARCHAR2(100),
    saldiff NUMBER,
    bonus NUMBER,
    tag VARCHAR2(100)
);

CREATE OR REPLACE PROCEDURE Update_Lowest_Paid_Employees(m IN NUMBER, n IN NUMBER) IS 
    v_highest_sal NUMBER;
    v_lowest_eid  NUMBER;
    v_lowest_sal  NUMBER;
    v_bonus       NUMBER;
    v_hire_date   DATE;
    v_sub_count   NUMBER;
BEGIN 
    -- Clear table for fresh report
    DELETE FROM lowest_paid_employees;

    FOR rec IN (SELECT department_id FROM departments) LOOP 
        -- Get highest salary in department for Case 3
        SELECT MAX(salary) INTO v_highest_sal
        FROM employees 
        WHERE department_id = rec.department_id;

        BEGIN 
            -- Case 1 & 2: Find lowest salaried permanent employee
            -- Order by salary (lowest) then hire_date (earlier joiner)
            SELECT employee_id, salary, hire_date 
            INTO v_lowest_eid, v_lowest_sal, v_hire_date
            FROM (
                SELECT employee_id, salary, hire_date 
                FROM employees 
                WHERE department_id = rec.department_id
                -- Permanent = 1 year probation passed
                AND MONTHS_BETWEEN(SYSDATE, hire_date) >= 12
                ORDER BY salary ASC, hire_date ASC
            ) WHERE ROWNUM = 1;

            -- Case 3: Lowest cannot be the highest
            IF v_lowest_sal < v_highest_sal THEN 
                -- Calculate Tenure Bonus: M for every N year period
                v_bonus := FLOOR(FLOOR(MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12) / n) * m;

                -- Management Bonus: 5,000 if manages at least 5 employees
                SELECT COUNT(*) INTO v_sub_count 
                FROM employees 
                WHERE manager_id = v_lowest_eid;

                IF v_sub_count >= 5 THEN
                    v_bonus := v_bonus + 5000;
                END IF;

                INSERT INTO lowest_paid_employees (employee_id, department_id, saldiff, bonus, tag) 
                VALUES (v_lowest_eid, rec.department_id, v_highest_sal - v_lowest_sal, v_bonus, NULL);
            END IF;

        EXCEPTION 
            WHEN NO_DATA_FOUND THEN 
                NULL; -- Skip departments with no qualifying permanent employees
        END;
    END LOOP;
    COMMIT;
END;
/

begin 
    Update_Lowest_Paid_Employees(10000, 5);
end; 

select * from lowest_paid_employees;


-- Task 2: Write a PL/SQL trigger (15 points)
-- Write a trigger Update_LPET_Tag_Trigger that performs the following:
--  Is fired when an insert is being done on the lowest_paid_employees table.
--  Perform a sanity check on the saldiff value. The value is correct when it is not greater than the
-- maximum of global saldiff values among all departments. The global saldiff for a department is
-- the difference of minimum and maximum salary of the department. If the sanity check fails, the
-- trigger should throw an exception so that the resulting SQL fails. Otherwise, it is executed as given
-- below.
--  Automatically updates the tag column of an employee based on saldiff as follows:
-- o If saldiff is less than 10k, tag will be ‘low’.
-- o If saldiff is above or equal to 10k but less than 20k, tag will be ‘very low’.
-- o If saldiff is above or equal to 20k, tag will be ‘extremely low’.
--  Must be a row level trigger.

create or replace trigger Update_LPET_Tag_Trigger
before insert 
on lowest_paid_employees 
for each row 
declare 
    v_global_saldiff number;
    v_temp_saldiff number;
begin 
    select max(max(salary) - min(salary)) 
    into v_global_saldiff
    from employees
    group by department_id;
    if(:new.saldiff > v_global_saldiff) then 
        raise_application_error(-20001, 'Invalid salary update');
    end if;
    case 
        when (:new.saldiff < 10000) then :new.tag := 'low';
        when (:new.saldiff < 20000) then :new.tag := 'very low';
        else :new.tag := 'extremely low';
    end case;
end;
/

begin 
    Update_Lowest_Paid_Employees(10000, 5);
end;

select * from lowest_paid_employees;
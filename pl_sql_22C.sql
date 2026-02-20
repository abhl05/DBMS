-- Question 1.
-- Write a PL/SQL function named IS_READY_FOR_PROMOTION that takes an EMPLOYEE_ID as
-- input and returns a VARCHAR2 result indicating whether the employee is ready for promotion.
-- The function should return:
-- • YES if the employee meets all the following criteria:
-- o Has worked for at least 5 years since the HIRE_DATE
-- o Has a SALARY greater than the midpoint of their job’s MIN_SALARY and
-- MAX_SALARY
-- o Manages at least one subordinate.
-- • NO if the employee exists but fails any of the above conditions
-- For demonstration, you need to call the function IS_READY_FOR_PROMOTION for each employee
-- and output whether they are eligible or not. Make sure to handle exceptions with appropriate messages.
CREATE OR REPLACE FUNCTION IS_READY_FOR_PROMOTION (
    p_employee_id IN EMPLOYEES.EMPLOYEE_ID%TYPE
) RETURN VARCHAR2 IS
    v_hire_date EMPLOYEES.HIRE_DATE%TYPE;
    v_salary EMPLOYEES.SALARY%TYPE;
    v_job_id EMPLOYEES.JOB_ID%TYPE;
    v_min_salary JOBS.MIN_SALARY%TYPE;
    v_max_salary JOBS.MAX_SALARY%TYPE;
    v_subordinates_count NUMBER;
BEGIN
    -- Fetch employee details
    SELECT HIRE_DATE, SALARY, JOB_ID
    INTO v_hire_date, v_salary, v_job_id
    FROM EMPLOYEES
    WHERE EMPLOYEE_ID = p_employee_id;

    -- Fetch job salary range

    SELECT MIN_SALARY, MAX_SALARY
    INTO v_min_salary, v_max_salary
    FROM JOBS
    WHERE JOB_ID = v_job_id;

    -- Count subordinates
    SELECT COUNT(*)
    INTO v_subordinates_count
    FROM EMPLOYEES
    WHERE MANAGER_ID = p_employee_id;

    -- Check promotion criteria
    IF (MONTHS_BETWEEN(SYSDATE, v_hire_date) >= 60) AND 
       (v_salary > (v_min_salary + v_max_salary) / 2) AND 
       (v_subordinates_count > 0) THEN
        RETURN 'YES';
    ELSE
        RETURN 'NO';
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Employee not found';
    WHEN OTHERS THEN
        RETURN 'An error occurred: ' || SQLERRM;
END IS_READY_FOR_PROMOTION;
-- Demonstration of the function for each employee
BEGIN
    FOR rec IN (SELECT EMPLOYEE_ID FROM EMPLOYEES) LOOP
        DBMS_OUTPUT.PUT_LINE('Employee ID: ' || rec.EMPLOYEE_ID || ' - Ready for Promotion: ' || IS_READY_FOR_PROMOTION(rec.EMPLOYEE_ID));
    END LOOP;
END;



-- Question 2.
-- First create a copy of the EMPLOYEES table in the HR schema, named EMPLOYEES_COPY. Do all
-- the work in EMPLOYEES_COPY table.
-- Write a PL/SQL procedure that updates the salaries of all employees. The new salary for an employee
-- will be calculated as follows:
-- New Salary = Old Salary + (Commission Percentage * Old Salary) + 0.1 * (Min
-- Salary of Employee's Job) + 0.1 * (Average Salary of Employee's Department)
-- Conditions:
-- 1. If the employee's work period is 1 year or less, his/her salary will not be updated. (Use the
-- hire date of the newest employee as today's date instead of SYSDATE).
-- 2. If the employee’s new salary exceeds the maximum salary for his/her job, set the new salary
-- to the maximum salary for that job.

-- The procedure should loop through all employees to update the salary. Handle appropriate exceptions.

-- To copy a table, execute the following script-
-- To show output:

-- CREATE TABLE employees_copy AS
-- SELECT * FROM employees;
-- COMMIT;

-- SELECT e.employee_id, e.salary as Old_Salary, ec.salary as New_Salary,
-- j.min_salary, j.max_salary, e.hire_date
-- FROM employees_copy ec join employees e
-- on ec.employee_id=e.employee_id
-- join jobs j on e.job_id=j.job_id;

drop TABLE employees_copy;

CREATE TABLE employees_copy AS
SELECT * FROM employees;
COMMIT;

CREATE OR REPLACE PROCEDURE UPDATE_SAL IS
    v_newest_hire DATE;
    v_min_salary  JOBS.MIN_SALARY%TYPE;
    v_max_salary  JOBS.MAX_SALARY%TYPE;
    v_avg_dept_sal NUMBER;
    v_new_salary  NUMBER;
BEGIN
    -- Requirement 1: Use the hire date of the newest employee as "today's date"
    SELECT MAX(hire_date) INTO v_newest_hire FROM EMPLOYEES_COPY;

    -- Loop through all employees in the copy table
    FOR emp IN (SELECT employee_id, salary, commission_pct, job_id, department_id, hire_date 
                FROM EMPLOYEES_COPY) 
    LOOP
        -- Condition 1: Check work period (Must be more than 1 year/12 months)
        IF MONTHS_BETWEEN(v_newest_hire, emp.hire_date) > 12 THEN
            
            -- Get Job Min/Max Salary
            SELECT min_salary, max_salary INTO v_min_salary, v_max_salary
            FROM jobs WHERE job_id = emp.job_id;

            -- Get Average Salary of the employee's department
            SELECT AVG(salary) INTO v_avg_dept_sal
            FROM EMPLOYEES_COPY
            WHERE department_id = emp.department_id;

            -- Calculate New Salary
            -- NVL handles cases where Commission is NULL to prevent the result from becoming NULL
            v_new_salary := emp.salary + (NVL(emp.commission_pct, 0) * emp.salary) + 
                            (0.1 * v_min_salary) + (0.1 * v_avg_dept_sal);

            -- Condition 2: Cap the salary at the Job's Maximum
            IF v_new_salary > v_max_salary THEN
                v_new_salary := v_max_salary;
            END IF;

            -- Execute the update
            UPDATE employees_copy
            SET salary = v_new_salary
            WHERE employee_id = emp.employee_id;
            
        END IF;
    END LOOP;
    
    COMMIT; -- Finalize the changes
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END UPDATE_SAL;
/

BEGIN
    UPDATE_SAL; -- Call the procedure to update salaries
END;

SELECT e.employee_id, e.salary as Old_Salary, ec.salary as New_Salary,
j.min_salary, j.max_salary, e.hire_date
FROM employees_copy ec join employees e
on ec.employee_id=e.employee_id
join jobs j on e.job_id=j.job_id;



-- Question 3.
-- Create a trigger that activates when an employee’s salary is updated.
-- Salary decrease>20% → demotion
-- 1 new table: Demotions
-- (fields:
-- employee_id,
-- current_salary,
-- Status- waiting and done,
-- date
-- )
-- In case of demotion:
-- 1. No change if that employee is not a manager
-- 2. If that employee is a manager, switch him/her with the highest-paid employee under him/her. (Do
-- not switch salaries)
-- No changes in the Job table and the Job_history table are necessary for your ease. All current date is
-- the hire date of the newest employee instead of SYSDATE.

-- First, ensure the table exists with correct data types
CREATE TABLE demotions (
    employee_id    NUMBER,
    current_salary NUMBER,
    status         VARCHAR2(20),
    demotion_date  DATE
);

CREATE OR REPLACE TRIGGER sal_update
BEFORE UPDATE OF salary ON employees_copy
FOR EACH ROW
DECLARE
    v_newest_hire         DATE;
    v_highest_paid_emp_id employees_copy.employee_id%TYPE;
    v_sub_count           NUMBER;
BEGIN
    -- 1. Get the reference date
    SELECT MAX(hire_date) INTO v_newest_hire FROM employees_copy;

    -- 2. Salary decrease > 20% check
    IF (:NEW.salary < :OLD.salary * 0.8) THEN 
        
        -- Check if employee is a manager
        -- Note: Querying the table in a Row-Level trigger is allowed for 
        -- simple aggregates, but be wary of complexity.
        SELECT COUNT(*) INTO v_sub_count 
        FROM employees_copy 
        WHERE manager_id = :OLD.employee_id;

        IF v_sub_count > 0 THEN
            -- Find the successor (highest paid subordinate)
            SELECT employee_id INTO v_highest_paid_emp_id
            FROM (
                SELECT employee_id FROM employees_copy
                WHERE manager_id = :OLD.employee_id
                ORDER BY salary DESC
            ) WHERE ROWNUM = 1;

            -- SWITCHING LOGIC:
            -- Because this is a BEFORE trigger, we modify the current row 
            -- simply by assigning values to :NEW.
            
            -- Demote the manager: make them report to their subordinate
            :NEW.manager_id := v_highest_paid_emp_id;

            -- Promote the subordinate: they report to the old boss's boss
            UPDATE employees_copy
            SET manager_id = :OLD.manager_id
            WHERE employee_id = v_highest_paid_emp_id;

            -- Re-assign the rest of the team to the new boss
            UPDATE employees_copy
            SET manager_id = v_highest_paid_emp_id
            WHERE manager_id = :OLD.employee_id
            AND employee_id != v_highest_paid_emp_id;
        END IF;

        -- 3. Log into Demotions table
        INSERT INTO demotions (employee_id, current_salary, status, demotion_date)
        VALUES (:OLD.employee_id, :NEW.salary, 'waiting', v_newest_hire);
        
    END IF;
END;
/

-- To test the trigger, you can run an update that decreases an employee's salary by more than 20% and observe the changes in the employees_copy table and the demotions table.
UPDATE employees_copy
SET salary = salary * 0.75
WHERE employee_id = 101; -- Replace with an actual employee ID to test
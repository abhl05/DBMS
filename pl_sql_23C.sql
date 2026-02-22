1. Write a PL/SQL trigger that will enforce the following business rule: 
The total salary paid to all employees in any single department must never exceed 
$50,000 after any salary modification. 
2. Write a PL/SQL function that checks whether an employee is currently paid more than 
they should be according to their job and years of service. 
The function should: 
● Take one input parameter: employee ID 
● Check if the employee exists in the EMPLOYEES table. If not → return NULL 
● Calculate years of service = number of full years since hire date until today (use 
FLOOR) 
● Apply this simple overpay rule: 
○ If years of service ≥ 10 → employee should not earn more than 95% of 
maximum salary 
○ If years of service ≥ 5 and < 10 → employee should not earn more than 
90% of the maximum salary 
○ If years of service < 5 → employee should not earn more than 85% of the 
maximum salary 
● Return: 
○ 1 → if the employee is overpaid (salary > the allowed percentage of 
maximum salary) 
○ 0 → if the employee is within the allowed range 
○ -1 → if the employee has no job or the job data is missing



CREATE OR REPLACE TRIGGER trg_check_dept_salary_cap
AFTER INSERT OR UPDATE OF salary, department_id ON employees
DECLARE
    v_max_allowed CONSTANT NUMBER := 50000;
    v_dept_id     employees.department_id%TYPE;
    v_total_sal   NUMBER;
BEGIN
    -- We check departments that were modified to ensure the rule holds
    FOR rec IN (SELECT department_id, SUM(salary) as total_salary 
                FROM employees 
                WHERE department_id IS NOT NULL
                GROUP BY department_id)
    LOOP
        IF rec.total_salary > v_max_allowed THEN
            RAISE_APPLICATION_ERROR(-20001, 
                'Transaction rejected: Department ' || rec.department_id || 
                ' total salary ($' || rec.total_salary || ') exceeds the $50,000 limit.');
        END IF;
    END LOOP;
END;
/




CREATE OR REPLACE FUNCTION CHECK_OVERPAID(EID IN NUMBER) 
RETURN NUMBER IS
    v_years NUMBER;
    v_salary NUMBER;
    v_max_sal NUMBER;
    v_allowed_pct NUMBER;
    v_exists NUMBER;
BEGIN
    -- 1. Check if employee exists
    SELECT COUNT(*) INTO v_exists FROM EMPLOYEES WHERE EMPLOYEE_ID = EID;
    IF v_exists = 0 THEN
        RETURN NULL;
    END IF;

    -- 2. Get Employee Data
    -- We join with Jobs to get the MAX_SALARY immediately
    BEGIN
        SELECT E.SALARY, FLOOR(MONTHS_BETWEEN(SYSDATE, E.HIRE_DATE)/12), J.MAX_SALARY
        INTO v_salary, v_years, v_max_sal
        FROM EMPLOYEES E
        JOIN JOBS J ON E.JOB_ID = J.JOB_ID
        WHERE E.EMPLOYEE_ID = EID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN -1; -- Job data missing
    END;

    -- 3. Apply the Overpay Rules
    IF v_years >= 10 THEN
        v_allowed_pct := 0.95;
    ELSIF v_years >= 5 THEN
        v_allowed_pct := 0.90;
    ELSE
        v_allowed_pct := 0.85;
    END IF;

    -- 4. Final Comparison
    IF v_salary > (v_max_sal * v_allowed_pct) THEN
        RETURN 1; -- Overpaid
    ELSE
        RETURN 0; -- Within range
    END IF;

END;
/
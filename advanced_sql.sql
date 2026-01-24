-- Template for JOIN with USING clause
-- SELECT … 
-- FROM table1 JOIN table2 USING (Column1, Column2, …) 
-- WHERE … 
-- GROUP BY … 
-- ORDER BY … 

SELECT E.LAST_NAME, D.DEPARTMENT_NAME 
FROM EMPLOYEES E JOIN DEPARTMENTS D USING (DEPARTMENT_ID) ; 

SELECT E.LAST_NAME, DEPARTMENT_ID, D.DEPARTMENT_NAME -- CANNOT USE ALIAS FOR DEPARTMENT_ID HERE
FROM EMPLOYEES E JOIN DEPARTMENTS D USING (DEPARTMENT_ID) ; 

SELECT E.LAST_NAME,  E.DEPARTMENT_ID,  D.DEPARTMENT_NAME 
FROM EMPLOYEES E JOIN DEPARTMENTS D 
ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID) ; 

SELECT E1.LAST_NAME EMPLOYEE, E2.LAST_NAME MANAGER 
FROM EMPLOYEES E1 JOIN EMPLOYEES E2 
ON (E1.MANAGER_ID = E2.EMPLOYEE_ID) ;

SELECT E.LAST_NAME, E.SALARY, J.GRADE_LEVEL 
FROM EMPLOYEES E JOIN JOB_GRADES J 
ON (E.SALARY BETWEEN J.LOWEST_SAL AND J.HIGHEST_SAL);

SELECT E1.LAST_NAME, COUNT(*) HIGHSAL  
FROM EMPLOYEES E1 JOIN EMPLOYEES E2 
ON (E1.SALARY < E2.SALARY)  
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME 
ORDER BY E1.LAST_NAME ASC ; 

SELECT E.LAST_NAME, D.DEPARTMENT_NAME, L.CITY  
FROM EMPLOYEES E  
JOIN DEPARTMENTS D 
ON (E.DEPARTMENT_ID = D.DEPARTMENT_ID)  
JOIN LOCATIONS L 
ON (D.LOCATION_ID = L.LOCATION_ID) ; 

SELECT E1.LAST_NAME, COUNT(E2.EMPLOYEE_ID) TOTAL 
FROM EMPLOYEES E1 LEFT OUTER JOIN EMPLOYEES E2 
ON (E1.EMPLOYEE_ID = E2.MANAGER_ID) 
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME 
ORDER BY TOTAL ASC ; 

-- a. For each employee print last name, salary, and job title. 
SELECT E.LAST_NAME, E.SALARY, J.JOB_TITLE 
FROM EMPLOYEES E JOIN JOBS J
USING (JOB_ID) ;

-- b. For each department, print department name and country name it is situated in. 
SELECT D.DEPARTMENT_NAME, T.COUNTRY_NAME
FROM DEPARTMENTS D 
JOIN LOCATIONS L USING (LOCATION_ID)
JOIN COUNTRIES T USING (COUNTRY_ID);

-- c. For each country, finds total number of departments situated in the country. 
SELECT C.COUNTRY_NAME, COUNT(D.DEPARTMENT_ID) DEPT_COUNT
FROM DEPARTMENTS D 
LEFT JOIN LOCATIONS L USING (LOCATION_ID)
LEFT JOIN COUNTRIES C USING (COUNTRY_ID)
GROUP BY C.COUNTRY_NAME;

-- d. For each employee, finds the number of job switches of the employee. 
SELECT E.LAST_NAME, COUNT(H.JOB_ID) AS JOBS_SWITCHED
FROM EMPLOYEES E 
LEFT JOIN JOB_HISTORY H 
  ON (E.EMPLOYEE_ID = H.EMPLOYEE_ID)
GROUP BY E.EMPLOYEE_ID, E.LAST_NAME;

-- e. For each department and job types, find the total number of employees working. Print 
-- department names, job titles, and total employees working. 
SELECT D.DEPARTMENT_NAME, J.JOB_TITLE, COUNT(E.EMPLOYEE_ID)
FROM DEPARTMENTS D JOIN EMPLOYEES E USING (DEPARTMENT_ID)
JOIN JOBS J USING (JOB_ID)
GROUP BY D.DEPARTMENT_NAME, J.JOB_TITLE;

-- f. For each employee, finds the total number of employees those were hired before him/her. Print 
-- employee last name and total employees. 
SELECT E1.LAST_NAME, COUNT(E2.EMPLOYEE_ID) AS HIRED_BEFORE
FROM EMPLOYEES E1 
LEFT JOIN EMPLOYEES E2 
  ON (E2.HIRE_DATE < E1.HIRE_DATE)
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME
ORDER BY HIRED_BEFORE DESC;

-- g. For each employee, finds the total number of employees those were hired before him/her and 
-- those were hired after him/her. Print employee last name, total employees hired before him, 
-- and total employees hired after him. 
SELECT E1.LAST_NAME, 
       COUNT(DISTINCT E2.EMPLOYEE_ID) AS HIRED_BEFORE, 
       COUNT(DISTINCT E3.EMPLOYEE_ID) AS HIRED_AFTER
FROM EMPLOYEES E1 
LEFT JOIN EMPLOYEES E2 ON (E2.HIRE_DATE < E1.HIRE_DATE)
LEFT JOIN EMPLOYEES E3 ON (E3.HIRE_DATE > E1.HIRE_DATE)
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME;

-- h. Find the employees having salaries greater than at least three other employees  
SELECT E1.LAST_NAME, COUNT(E2.EMPLOYEE_ID)
FROM EMPLOYEES E1 JOIN EMPLOYEES E2
ON (E1.SALARY > E2.SALARY)
GROUP BY E1.LAST_NAME
HAVING COUNT(E2.EMPLOYEE_ID) >= 3;

-- i. For each employee, find his rank, i.e., position with respect to salary. The highest salaried 
-- employee should get rank 1 and lowest salaried employee should get the last rank. Employees 
-- with same salary should get same rank value. Print employee last names and his/he rank.
SELECT E1.LAST_NAME, E1.SALARY, 
       (COUNT(DISTINCT E2.SALARY) + 1) AS RANK
FROM EMPLOYEES E1 
LEFT JOIN EMPLOYEES E2 
  ON (E2.SALARY > E1.SALARY)
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME, E1.SALARY
ORDER BY RANK ASC;

-- j. Finds the names of employees and their salaries for the top three highest salaried employees. 
-- The number of employees in your output should be more than three if there are employees with 
-- same salary.
SELECT E1.LAST_NAME, E1.SALARY
FROM EMPLOYEES E1 
LEFT JOIN EMPLOYEES E2 
  ON (E2.SALARY > E1.SALARY)
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME, E1.SALARY
HAVING (COUNT(DISTINCT E2.SALARY) + 1) < 3
ORDER BY E1.SALARY DESC;


-- Template for sub-query with condition
-- SELECT Column1, Column2, … 
-- FROM table_name 
-- WHERE sub-query-with-condition 

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE SALARY >  
( 
SELECT SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME = 'Abel' 
) ; 

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE JOB_ID =  
( 
SELECT JOB_ID 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID = 141 
) ;

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE JOB_ID =  
( 
SELECT JOB_ID 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID = 141 
)  
AND SALARY > 
( 
SELECT SALARY 
FROM EMPLOYEES 
WHERE EMPLOYEE_ID = 141 
)  ;

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE  SALARY =  
( 
SELECT MAX(SALARY) 
FROM EMPLOYEES 
)  ;  

SELECT LAST_NAME, JOB_ID, SALARY 
FROM EMPLOYEES 
WHERE  JOB_ID <> 'IT_PROG' 
AND SALARY < ANY  
( 
SELECT SALARY 
FROM EMPLOYEES 
WHERE JOB_ID = 'IT_PROG' 
)  ;

SELECT LAST_NAME, JOB_ID, SALARY 
FROM EMPLOYEES 
WHERE  JOB_ID <> 'IT_PROG' 
AND SALARY < ALL 
( 
SELECT SALARY 
FROM EMPLOYEES 
WHERE JOB_ID = 'IT_PROG' 
)  ;

-- a. Find the last names of all employees that work in the SALES department.  
SELECT LAST_NAME 
FROM EMPLOYEES
WHERE DEPARTMENT_ID = (
    SELECT DEPARTMENT_ID
    FROM DEPARTMENTS
    WHERE UPPER(DEPARTMENT_NAME) = 'SALES'
);

-- b. Find the last names and salaries of those employees who get higher salary than at least one 
-- employee of SALES department. 
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY > ANY (
    SELECT SALARY
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = (
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE UPPER(DEPARTMENT_NAME) = 'SALES'
    )
);

-- c. Find the last names and salaries of those employees whose salary is higher than all employees 
-- of SALES department. 
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY > ALL (
    SELECT SALARY
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = (
        SELECT DEPARTMENT_ID
        FROM DEPARTMENTS
        WHERE UPPER(DEPARTMENT_NAME) = 'SALES'
    )
);

-- d. Find the last names and salaries of those employees whose salary is within ± 5k of the average 
-- salary of SALES department.
SELECT LAST_NAME, SALARY
FROM EMPLOYEES
WHERE SALARY BETWEEN 
    (SELECT AVG(SALARY) 
     FROM EMPLOYEES 
     WHERE DEPARTMENT_ID = (
         SELECT DEPARTMENT_ID 
         FROM DEPARTMENTS 
         WHERE UPPER(DEPARTMENT_NAME) = 'SALES')
    ) - 5000
AND 
    (SELECT AVG(SALARY) 
     FROM EMPLOYEES 
     WHERE DEPARTMENT_ID = (
         SELECT DEPARTMENT_ID 
         FROM DEPARTMENTS 
         WHERE UPPER(DEPARTMENT_NAME) = 'SALES')
    ) + 5000;


SELECT * 
FROM EMPLOYEES E1 
WHERE 3 <= ( 
SELECT COUNT(*) 
FROM EMPLOYEES E2 
WHERE E2.SALARY < E1.SALARY 
)  ;

SELECT DEPARTMENT_NAME 
FROM DEPARTMENTS D 
WHERE  EXISTS 
( 
SELECT * 
FROM EMPLOYEES E 
WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID AND JOB_ID = 'IT_PROG' 
) ; 

SELECT LAST_NAME, SALARY, DEPARTMENT_ID 
FROM EMPLOYEES E1 
WHERE  NOT EXISTS 
( 
SELECT * 
FROM EMPLOYEES E2 
WHERE E2.DEPARTMENT_ID = E1.DEPARTMENT_ID AND 
E2.SALARY > E1.SALARY 
)  ; 

SELECT LAST_NAME, SALARY, (SELECT DEPARTMENT_NAME FROM DEPARTMENTS D  
WHERE D.DEPARTMENT_ID = E1.DEPARTMENT_ID) DEPARTMENT 
FROM EMPLOYEES E1 
WHERE  NOT EXISTS 
( 
SELECT * 
FROM EMPLOYEES E2 
WHERE E2.DEPARTMENT_ID = E1.DEPARTMENT_ID AND 
E2.SALARY > E1.SALARY 
)  ; 

SELECT E.LAST_NAME, E.SALARY, D.MINSAL, D.MAXSAL 
FROM EMPLOYEES E,   
( 
SELECT DEPARTMENT_ID AS DEPT, MIN(SALARY) MINSAL, MAX(SALARY) MAXSAL 
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID 
) D 
WHERE (E.DEPARTMENT_ID = D.DEPT)  
ORDER BY E.SALARY ;

-- a. Find those employees whose salary is higher than at least three other employees. Print last 
-- names and salary of each employee. You cannot use join in the main query. Use sub-query in 
-- WHERE clause only. You can use join in the sub-queries. 
SELECT E1.LAST_NAME, E1.SALARY
FROM EMPLOYEES E1
WHERE 3 <= (
    SELECT COUNT(*) 
    FROM EMPLOYEES E2 
    WHERE E2.SALARY < E1.SALARY 
    );

-- b. Find those departments whose average salary is greater than the minimum salary of all other 
-- departments. Print department names. Use sub-query. You can use join in the sub-queries.
SELECT D1.DEPARTMENT_NAME
FROM DEPARTMENTS D1
WHERE (
    SELECT AVG(SALARY)
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = D1.DEPARTMENT_ID
    ) > ALL (
    SELECT MIN(SALARY)
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID <> D1.DEPARTMENT_ID
);

-- c. Find those department names which have the highest number of employees in service. Print 
-- department names. Use sub-query. You can use join in the sub-queries. 
SELECT DEPARTMENT_NAME
FROM DEPARTMENTS D
WHERE (
    SELECT COUNT(*)
    FROM EMPLOYEES
    WHERE DEPARTMENT_ID = D.DEPARTMENT_ID
    ) = (
        SELECT MAX(COUNT(*))
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
    );

-- d. Find those employees who worked in more than one department in the company. Print 
-- employee last names. You cannot use join in the main query. Use sub-query. You can use join 
-- in the sub-queries. 
SELECT LAST_NAME
FROM EMPLOYEES E
WHERE EXISTS (
    SELECT *
    FROM JOB_HISTORY JH
    WHERE JH.EMPLOYEE_ID = E.EMPLOYEE_ID
    AND JH.DEPARTMENT_ID <> E.DEPARTMENT_ID
);

-- e. For each employee, find the minimum and maximum salary of his/her department. Print 
-- employee last name, minimum salary, and maximum salary. Do not use sub-query in WHERE 
-- clause. Use sub-query in FROM clause. 
SELECT E.LAST_NAME, D.MINSAL, D.MAXSAL
FROM EMPLOYEES E,
    (
        SELECT DEPARTMENT_ID, MIN(SALARY) MINSAL, MAX(SALARY) MAXSAL
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
    ) D
WHERE E.DEPARTMENT_ID = D.DEPARTMENT_ID;

-- f. For each job type, find the employee who gets the highest salary. Print job title and last name 
-- of the employee. Assume that there is one and only one such employee for every job type. 
SELECT J.JOB_TITLE, E.LAST_NAME
FROM EMPLOYEES E
JOIN JOBS J ON (E.JOB_ID = J.JOB_ID)
WHERE E.SALARY = (
    SELECT MAX(SALARY)
    FROM EMPLOYEES
    WHERE JOB_ID = E.JOB_ID
);





-- Template for SET-OPERATOR
-- SELECT Column1, Column2, … , ColumnN 
-- FROM table_name 
-- … 
-- SET-OPERATOR 
-- ( 
-- SELECT Column1, Column2, … , ColumnN  
-- FROM table_name 
-- … 
-- ) 

SELECT EMPLOYEE_ID, JOB_ID 
FROM EMPLOYEES 
UNION 
( 
SELECT EMPLOYEE_ID, JOB_ID 
FROM JOB_HISTORY 
) ; 

SELECT EMPLOYEE_ID, JOB_ID 
FROM EMPLOYEES 
UNION ALL
( 
SELECT EMPLOYEE_ID, JOB_ID 
FROM JOB_HISTORY 
) ; 

SELECT EMPLOYEE_ID, JOB_ID 
FROM EMPLOYEES 
INTERSECT 
( 
SELECT EMPLOYEE_ID, JOB_ID 
FROM JOB_HISTORY 
) ; 

SELECT EMPLOYEE_ID, JOB_ID 
FROM EMPLOYEES 
MINUS 
( 
SELECT EMPLOYEE_ID, JOB_ID 
FROM JOB_HISTORY 
) ;

-- a. Find EMPLOYEE_ID of those employees who are not managers. Use minus operator to 
-- perform this. 
SELECT EMPLOYEE_ID
FROM EMPLOYEES
MINUS
(
SELECT MANAGER_ID
FROM DEPARTMENTS
WHERE MANAGER_ID IS NOT NULL
);

-- b. Find last names of those employees who are not managers. Use minus operator to perform this. 
SELECT LAST_NAME
FROM EMPLOYEES
MINUS
(
SELECT E.LAST_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON (E.EMPLOYEE_ID = D.MANAGER_ID)
);

-- c. Find the LOCATION_ID of those locations having no departments.
SELECT LOCATION_ID
FROM LOCATIONS
MINUS
(
SELECT LOCATION_ID
FROM DEPARTMENTS
);


-- DECODE Examples
SELECT JOB_ID, DECODE(INSTR(UPPER(JOB_TITLE),'MANAGER'),0,'Not a manager', 
'Manager') AS JOB_TYPE
FROM JOBS ;

-- DECODE(EXPR, MATCH_EXPR1, RESULT_EXPR1, MATCH_EXPR2, RESULT_EXPR2,…, 
-- DEFAULT_EXPR) --DEFAULT_EXPR is optional

SELECT FIRST_NAME, SALARY, DECODE(FLOOR(SALARY/5000),0,'C',1,'B',2,'A','A+') 
"SALARY GRADE" 
FROM EMPLOYEES  
ORDER BY SALARY DESC ;

-- CASE 
--  WHEN COMPARISON_EXPR1 THEN RESULT_EXPR1 
--  WHEN COMPARISON_EXPR2 THEN RESULT_EXPR2 
--  … 
--  ELSE DEFAULT_EXPR 
-- END 
 
-- Or 
 
-- CASE EXPR 
--  WHEN CONDITION_EXPR1 THEN RESULT_EXPR1 
--  WHEN CONDITION_EXPR2 THEN RESULT_EXPR2 
--  … 
--  ELSE DEFAULT_EXPR 
-- END 

SELECT FIRST_NAME, SALARY,  
CASE 
WHEN SALARY < 5000 THEN 'C' 
WHEN SALARY < 10000 THEN 'B' 
WHEN SALARY < 15000 THEN 'A' 
ELSE 'A+' 
END "SALARY GRADE" 
FROM EMPLOYEES  
ORDER BY SALARY DESC;

SELECT FIRST_NAME, SALARY,  
CASE SALARY
WHEN 5000 THEN 'C' 
WHEN 10000 THEN 'B' 
WHEN 24000 THEN 'A' 
ELSE 'A+' 
END "SALARY GRADE" 
FROM EMPLOYEES  
ORDER BY SALARY DESC;

SELECT (CASE 
WHEN SALARY < 5000 THEN 'C' 
WHEN SALARY < 10000 THEN 'B' 
WHEN SALARY < 15000 THEN 'A' 
ELSE 'A+'
END )"SALARY GRADE", COUNT(*) 
FROM EMPLOYEES  
GROUP BY (CASE 
WHEN SALARY < 5000 THEN 'C' 
WHEN SALARY < 10000 THEN 'B' 
WHEN SALARY < 15000 THEN 'A' 
ELSE 'A+' 
END )
ORDER BY "SALARY GRADE" ASC ;

SELECT DEPARTMENT_ID,  
SUM(CASE WHEN SALARY > 15000 THEN 1 ELSE 0 END) "A+", 
SUM(CASE WHEN SALARY >= 10000 AND SALARY < 15000 THEN 1 ELSE 0 END) "A", 
SUM(CASE WHEN SALARY >= 5000 AND SALARY < 10000 THEN 1 ELSE 0 END) "B", 
SUM(CASE WHEN SALARY < 5000 THEN 1 ELSE 0 END) "C" 
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID 
ORDER BY DEPARTMENT_ID ASC;

WITH EMPCOUNTBYDEPT AS  
( 
SELECT DEPARTMENT_ID, COUNT(*) EMPCOUNT 
FROM EMPLOYEES  
GROUP BY DEPARTMENT_ID 
) 
SELECT E1.FIRST_NAME, E2.EMPCOUNT 
FROM EMPLOYEES E1 JOIN EMPCOUNTBYDEPT E2 ON (E1.DEPARTMENT_ID = E2.DEPARTMENT_ID) 
ORDER BY E1.EMPLOYEE_ID ASC;

SELECT E1.FIRST_NAME, E2.EMPCOUNT 
FROM EMPLOYEES E1 JOIN   
( 
 SELECT DEPARTMENT_ID, COUNT(*) EMPCOUNT 
 FROM EMPLOYEES  
 GROUP BY DEPARTMENT_ID 
) E2 ON (E1.DEPARTMENT_ID = E2.DEPARTMENT_ID) 
ORDER BY E1.EMPLOYEE_ID ASC;

WITH EMPCOUNTBYDEPT AS  
( 
 SELECT DEPARTMENT_ID, COUNT(*) EMPCOUNT 
 FROM EMPLOYEES  
 GROUP BY DEPARTMENT_ID 
) 
SELECT E1.FIRST_NAME, E3.EMPCOUNT "Emp Count Employee Dept", E4.EMPCOUNT "Emp 
Count Maneger Dept" 
FROM EMPLOYEES E1 JOIN EMPLOYEES E2 ON (E1.MANAGER_ID = E2.EMPLOYEE_ID) 
JOIN EMPCOUNTBYDEPT E3 ON (E1.DEPARTMENT_ID = E3.DEPARTMENT_ID)  
JOIN EMPCOUNTBYDEPT E4 ON (E2.DEPARTMENT_ID = E4.DEPARTMENT_ID)  
ORDER BY E1.EMPLOYEE_ID ASC ;


-- a. Calculate the number of employees in different salary grades for each department using 
-- COUNT aggregation function instead of SUM. 
SELECT DEPARTMENT_ID,
         COUNT(DECODE(FLOOR(SALARY/5000),0,1)) "C",
         COUNT(DECODE(FLOOR(SALARY/5000),1,1)) "B",
         COUNT(DECODE(FLOOR(SALARY/5000),2,1)) "A",
         COUNT(DECODE(FLOOR(SALARY/5000),3,1)) "A+"
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID ASC ;

-- b. Calculate the number of employees in different salary grades for each department using 
-- DECODE instead of CASE. 
SELECT DEPARTMENT_ID,
         SUM(DECODE(FLOOR(SALARY/5000),0,1,0)) "C",
         SUM(DECODE(FLOOR(SALARY/5000),1,1,0)) "B",
         SUM(DECODE(FLOOR(SALARY/5000),2,1,0)) "A",
         SUM(DECODE(FLOOR(SALARY/5000),3,1,0)) "A+"
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID ASC ;

-- c. Write the query to show total employees working in the employee’s department and in the 
-- employee’s manager’s department without using WITH clause. You can use subqueries in the 
-- FROM clause. 
SELECT E1.FIRST_NAME, E3.EMPCOUNT "Emp Count Employee Dept", E4.EMPCOUNT "Emp
Count Maneger Dept"
FROM EMPLOYEES E1 JOIN EMPLOYEES E2 ON (E1.MANAGER_ID = E2.EMPLOYEE_ID)
JOIN
    (
        SELECT DEPARTMENT_ID, COUNT(*) EMPCOUNT
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
    ) E3 ON (E1.DEPARTMENT_ID = E3.DEPARTMENT_ID)
JOIN
    (
        SELECT DEPARTMENT_ID, COUNT(*) EMPCOUNT
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
    ) E4 ON (E2.DEPARTMENT_ID = E4.DEPARTMENT_ID)
ORDER BY E1.EMPLOYEE_ID ASC ;



-- B SECTION QUIZ
-- 1. List managers whose departments have average salaries higher than the overall company average, 
-- for departments located in Toronto and Oxford. 
SELECT E.FIRST_NAME, E.LAST_NAME, D.DEPARTMENT_NAME
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.EMPLOYEE_ID = D.MANAGER_ID
JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
WHERE L.CITY IN ('Toronto', 'Oxford')
AND D.DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
    HAVING AVG(SALARY) > (SELECT AVG(SALARY) FROM EMPLOYEES)
);
-- 2. Find employees who both work in departments with more than 5 employees AND have salaries 
-- greater than the overall average salary across all employees. 
SELECT FIRST_NAME, LAST_NAME
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
    HAVING COUNT(*) > 5
)
AND SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES);

-- 3. Write a SQL query for employees in departments that have managers, with no job history records, 
-- and salary > dept average. Show full_name, salary, dept_name, and label 'Stable High Earner' if 
-- salary > 1.7 times dept average, else 'Dept Above Avg'. 
SELECT (E.FIRST_NAME || ' ' || E.LAST_NAME) AS FULL_NAME, 
       E.SALARY, 
       D.DEPARTMENT_NAME,
       CASE 
           WHEN E.SALARY > 1.7 * AVG_DEPT.AVG_SAL THEN 'Stable High Earner'
           ELSE 'Dept Above Avg'
       END AS LABEL
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN (
    SELECT DEPARTMENT_ID, AVG(SALARY) AVG_SAL 
    FROM EMPLOYEES 
    GROUP BY DEPARTMENT_ID
) AVG_DEPT ON E.DEPARTMENT_ID = AVG_DEPT.DEPARTMENT_ID
WHERE D.MANAGER_ID IS NOT NULL
AND E.SALARY > AVG_DEPT.AVG_SAL
AND NOT EXISTS (
    SELECT 1 FROM JOB_HISTORY JH WHERE JH.EMPLOYEE_ID = E.EMPLOYEE_ID
);

-- 4. Find employees who are either in departments with more than 5 employees or have a job with 
-- minimum salary above 10000. 
-- Display: employee_id, first_name, last_name, department_id, job_id, salary. 
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, DEPARTMENT_ID, JOB_ID, SALARY
FROM EMPLOYEES
WHERE DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
    HAVING COUNT(*) > 5
)
OR JOB_ID IN (
    SELECT JOB_ID
    FROM JOBS
    WHERE MIN_SALARY > 10000
);

-- 5. Write an SQL query to find employees who satisfy exactly one of the following conditions: 
-- (i) they work in a department with more than 5 employees, or 
-- (ii) their job has a minimum salary greater than 10000. 
-- Employees who satisfy both conditions or neither condition must be excluded. Display employee 
-- ID, full name, department ID, job ID, and salary.
SELECT EMPLOYEE_ID, (FIRST_NAME || ' ' || LAST_NAME) AS FULL_NAME, 
       DEPARTMENT_ID, JOB_ID, SALARY
FROM EMPLOYEES
WHERE (
    DEPARTMENT_ID IN (
        SELECT DEPARTMENT_ID
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
        HAVING COUNT(*) > 5
    )
    AND JOB_ID NOT IN (
        SELECT JOB_ID
        FROM JOBS
        WHERE MIN_SALARY > 10000
    )
)
OR (
    DEPARTMENT_ID NOT IN (
        SELECT DEPARTMENT_ID
        FROM EMPLOYEES
        GROUP BY DEPARTMENT_ID
        HAVING COUNT(*) > 5
    )
    AND JOB_ID IN (
        SELECT JOB_ID
        FROM JOBS
        WHERE MIN_SALARY > 10000
    )
);

/* Condition A: Dept > 5 employees. Condition B: Job Min Salary > 10000 */

(
    /* Satisfies A but not B */
    SELECT E.EMPLOYEE_ID, (E.FIRST_NAME || ' ' || E.LAST_NAME) AS FULL_NAME, E.DEPARTMENT_ID, E.JOB_ID, E.SALARY
    FROM EMPLOYEES E
    WHERE E.DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES GROUP BY DEPARTMENT_ID HAVING COUNT(*) > 5)
    MINUS
    SELECT E.EMPLOYEE_ID, (E.FIRST_NAME || ' ' || E.LAST_NAME), E.DEPARTMENT_ID, E.JOB_ID, E.SALARY
    FROM EMPLOYEES E
    JOIN JOBS J ON E.JOB_ID = J.JOB_ID
    WHERE J.MIN_SALARY > 10000
)
UNION
(
    /* Satisfies B but not A */
    SELECT E.EMPLOYEE_ID, (E.FIRST_NAME || ' ' || E.LAST_NAME), E.DEPARTMENT_ID, E.JOB_ID, E.SALARY
    FROM EMPLOYEES E
    JOIN JOBS J ON E.JOB_ID = J.JOB_ID
    WHERE J.MIN_SALARY > 10000
    MINUS
    SELECT E.EMPLOYEE_ID, (E.FIRST_NAME || ' ' || E.LAST_NAME), E.DEPARTMENT_ID, E.JOB_ID, E.SALARY
    FROM EMPLOYEES E
    WHERE E.DEPARTMENT_ID IN (SELECT DEPARTMENT_ID FROM EMPLOYEES GROUP BY DEPARTMENT_ID HAVING COUNT(*) > 5)
);


SELECT E.EMPLOYEE_ID, E.LAST_NAME, D.DEPARTMENT_NAME, E.COMMISSION_PCT
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
WHERE D.DEPARTMENT_NAME = 'Sales'
OR E.COMMISSION_PCT IS NOT NULL;

-- XOR = (Set A MINUS Set B) UNION (Set B MINUS Set A)



-- Question 1
-- Problem: List the last names and salaries of managers whose departments are located in the 'United Kingdom' (Country Name) and whose department's minimum salary is greater than the minimum salary of the 'IT' department.

-- Concepts: JOIN (4 tables: Emp, Dept, Loc, Countries), Aggregation (MIN), Subquery (Scalar), Filtering.

-- Hint: You first need to join tables from Employees down to Countries to filter by 'United Kingdom'. Then, use GROUP BY to find the minimum salary per department. Finally, compare this against a subquery that fetches the MIN(SALARY) for the department named 'IT'.

-- Solution:

SQL
SELECT E.LAST_NAME, E.SALARY
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
JOIN COUNTRIES C ON L.COUNTRY_ID = C.COUNTRY_ID
WHERE C.COUNTRY_NAME = 'United Kingdom'
AND E.EMPLOYEE_ID IN (SELECT MANAGER_ID FROM EMPLOYEES) -- Ensures person is a manager
AND (
    SELECT MIN(SALARY)
    FROM EMPLOYEES E2
    WHERE E2.DEPARTMENT_ID = E.DEPARTMENT_ID
) > (
    SELECT MIN(SALARY)
    FROM EMPLOYEES E3
    JOIN DEPARTMENTS D3 ON E3.DEPARTMENT_ID = D3.DEPARTMENT_ID
    WHERE D3.DEPARTMENT_NAME = 'IT'
);
-- Question 2
-- Problem: Find employees who both have a history of changing jobs (record exists in JOB_HISTORY) AND currently work in a department that has a higher average salary than the department they previously worked in (use the most recent job history record if multiple exist, or just any record in JOB_HISTORY for simplicity). For this exercise, simplified version: Work in a department with Avg Salary > 10000 AND have a job history record.

-- Concepts: INTERSECT (or AND with EXISTS), Aggregation (AVG), Subquery.

-- Hint: This is an intersection problem. You can find the set of employees satisfying Condition A (Dept Avg > 10k) and Condition B (In Job History) and use the AND operator or INTERSECT set operator.

-- Solution:

SQL
SELECT EMPLOYEE_ID, LAST_NAME
FROM EMPLOYEES E
WHERE DEPARTMENT_ID IN (
    SELECT DEPARTMENT_ID
    FROM EMPLOYEES
    GROUP BY DEPARTMENT_ID
    HAVING AVG(SALARY) > 10000
)
AND EXISTS (
    SELECT 1
    FROM JOB_HISTORY JH
    WHERE JH.EMPLOYEE_ID = E.EMPLOYEE_ID
);
-- Question 3
-- Problem: Write a SQL query for employees who do not manage anyone, have been hired after the year 1999, and whose salary is less than the average salary of their job title (JOB_ID). Show full_name, salary, job_title, and a label 'Training Needed' if their salary is less than 80% of the job average, else 'On Track'.

-- Concepts: NOT EXISTS (for checking managers), Date logic (EXTRACT or TO_CHAR), Correlated Subquery (Job Avg), CASE expression.

-- Hint: To check if an employee is not a manager, ensure their EMPLOYEE_ID is not present in the MANAGER_ID column of the EMPLOYEES table. Use a CASE statement to compare their salary against 0.8 * (Avg Salary of their Job ID).

-- Solution:

SQL
SELECT (E.FIRST_NAME || ' ' || E.LAST_NAME) AS FULL_NAME,
       E.SALARY,
       J.JOB_TITLE,
       CASE
           WHEN E.SALARY < 0.8 * (SELECT AVG(SALARY) FROM EMPLOYEES WHERE JOB_ID = E.JOB_ID) THEN 'Training Needed'
           ELSE 'On Track'
       END AS STATUS_LABEL
FROM EMPLOYEES E
JOIN JOBS J ON E.JOB_ID = J.JOB_ID
WHERE E.EMPLOYEE_ID NOT IN (SELECT DISTINCT MANAGER_ID FROM EMPLOYEES WHERE MANAGER_ID IS NOT NULL)
AND EXTRACT(YEAR FROM E.HIRE_DATE) > 1999
AND E.SALARY < (SELECT AVG(SALARY) FROM EMPLOYEES WHERE JOB_ID = E.JOB_ID);
-- Question 4
-- Problem: Find employees who are either working in the 'Sales' department or earn a commission (COMMISSION_PCT is not null). Display: employee_id, last_name, department_name, commission_pct.

-- Concepts: OR logic, JOIN (to get Department Name), IS NOT NULL.

-- Hint: This is a standard Union/OR problem. Join Employees with Departments and check the two conditions with an OR operator in the WHERE clause.

-- Solution:

SQL
SELECT E.EMPLOYEE_ID, E.LAST_NAME, D.DEPARTMENT_NAME, E.COMMISSION_PCT
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
WHERE D.DEPARTMENT_NAME = 'Sales'
OR E.COMMISSION_PCT IS NOT NULL;
-- Question 5 (XOR Logic)
-- Problem: Write an SQL query to find employees who satisfy exactly one of the following conditions: (i) They have a salary greater than 10,000. (ii) They report to a manager who works in a department located in the 'United States of America'. Employees who satisfy both conditions or neither condition must be excluded.

-- Concepts: Set Operations (MINUS, UNION) or Complex WHERE logic ((A AND NOT B) OR (B AND NOT A)).

-- Hint: The easiest way to handle "Exactly one" (XOR) without complex boolean logic is: (Set A MINUS Set B) UNION (Set B MINUS Set A). Set A = Employees with Salary > 10k. Set B = Employees with Manager in US.

-- Solution:

SQL
-- Employees satisfying Condition (i) ONLY
(
    SELECT EMPLOYEE_ID, LAST_NAME
    FROM EMPLOYEES
    WHERE SALARY > 10000
    MINUS
    SELECT E.EMPLOYEE_ID, E.LAST_NAME
    FROM EMPLOYEES E
    JOIN EMPLOYEES M ON E.MANAGER_ID = M.EMPLOYEE_ID
    JOIN DEPARTMENTS D ON M.DEPARTMENT_ID = D.DEPARTMENT_ID
    JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
    JOIN COUNTRIES C ON L.COUNTRY_ID = C.COUNTRY_ID
    WHERE C.COUNTRY_NAME = 'United States of America'
)
UNION
-- Employees satisfying Condition (ii) ONLY
(
    SELECT E.EMPLOYEE_ID, E.LAST_NAME
    FROM EMPLOYEES E
    JOIN EMPLOYEES M ON E.MANAGER_ID = M.EMPLOYEE_ID
    JOIN DEPARTMENTS D ON M.DEPARTMENT_ID = D.DEPARTMENT_ID
    JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
    JOIN COUNTRIES C ON L.COUNTRY_ID = C.COUNTRY_ID
    WHERE C.COUNTRY_NAME = 'United States of America'
    MINUS
    SELECT EMPLOYEE_ID, LAST_NAME
    FROM EMPLOYEES
    WHERE SALARY > 10000
);

-- Question 1
-- Problem: List the department names and city names for departments that have at least one employee earning more than 12,000, but the department’s overall average salary is strictly less than 8,000.Concepts: JOIN (3 tables), GROUP BY, HAVING with multiple aggregate conditions (MAX, AVG).Hint: Join Departments, Locations, and Employees. Group by the Department Name and City. In the HAVING clause, use MAX(SALARY) to check the first condition and AVG(SALARY) to check the second.Solution:SQLSELECT D.DEPARTMENT_NAME, L.CITY
FROM DEPARTMENTS D
JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME, L.CITY
HAVING MAX(E.SALARY) > 12000
AND AVG(E.SALARY) < 8000;
-- Question 2
-- Problem: Find managers who manage a team of more than 3 people, where the minimum salary of their direct reports is greater than 6,000. Display the manager's ID, Last Name, and the count of their reports.Concepts: Self-Join (Manager ID = Employee ID), Aggregation (COUNT, MIN), GROUP BY, HAVING.Hint: Join the EMPLOYEES table to itself. E1 represents the Manager, E2 represents the direct report (the employee). Group by the Manager's details and filter groups where the count of E2 rows is $>3$ and the minimum salary of E2 is $>6000$.Solution:SQLSELECT E1.EMPLOYEE_ID, E1.LAST_NAME, COUNT(E2.EMPLOYEE_ID) AS REPORT_COUNT
FROM EMPLOYEES E1
JOIN EMPLOYEES E2 ON E1.EMPLOYEE_ID = E2.MANAGER_ID
GROUP BY E1.EMPLOYEE_ID, E1.LAST_NAME
HAVING COUNT(E2.EMPLOYEE_ID) > 3
AND MIN(E2.SALARY) > 6000;
-- Question 3
-- Problem: Write a query for employees whose hire date is earlier than their manager's hire date.Display the Employee's Name, Hire Date, Manager's Hire Date, and a label 'Veteran' if they were hired more than 2 years (730 days) before their manager, otherwise label them 'Senior Staff'.Concepts: Self-Join, Date Arithmetic (DATE - DATE), CASE expression, Column Aliases.Hint: Perform a self-join (E1.MANAGER_ID = E2.EMPLOYEE_ID). In the WHERE clause, ensure E1.HIRE_DATE < E2.HIRE_DATE. In the SELECT list, use a CASE statement to check if (E2.HIRE_DATE - E1.HIRE_DATE) > 730.Solution:SQLSELECT E1.LAST_NAME AS EMP_NAME,
       E1.HIRE_DATE AS EMP_HIRED,
       E2.HIRE_DATE AS MGR_HIRED,
       CASE
           WHEN (E2.HIRE_DATE - E1.HIRE_DATE) > 730 THEN 'Veteran'
           ELSE 'Senior Staff'
       END AS STATUS_LABEL
FROM EMPLOYEES E1
JOIN EMPLOYEES E2 ON E1.MANAGER_ID = E2.EMPLOYEE_ID
WHERE E1.HIRE_DATE < E2.HIRE_DATE;
-- Question 4
-- Problem: Find employees who have never changed jobs (no record in JOB_HISTORY) BUT work in a department located in 'Seattle'.Display Employee ID, Last Name, and Job ID.Concepts: NOT EXISTS or MINUS, Joins (Dept, Loc).Hint: You can find all employees in 'Seattle' first. Then, exclude those who appear in the JOB_HISTORY table. Using MINUS or NOT EXISTS is efficient here.Solution:SQLSELECT E.EMPLOYEE_ID, E.LAST_NAME, E.JOB_ID
FROM EMPLOYEES E
JOIN DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN LOCATIONS L ON D.LOCATION_ID = L.LOCATION_ID
WHERE L.CITY = 'Seattle'
AND NOT EXISTS (
    SELECT 1
    FROM JOB_HISTORY JH
    WHERE JH.EMPLOYEE_ID = E.EMPLOYEE_ID
);
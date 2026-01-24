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
FROM JOBS J JOIN EMPLOYEES E
ON (J.JOB_ID = E.JOB_ID)
WHERE E.SALARY = (
    SELECT MAX(SALARY)
    FROM EMPLOYEES E2
    WHERE E2.JOB_ID = J.JOB_ID
);
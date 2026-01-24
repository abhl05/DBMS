-- SELECT * FROM EMPLOYEES ; 
-- SELECT EMPLOYEE_ID, LAST_NAME, (SALARY + SALARY*0.15) / 1000  
-- FROM EMPLOYEES ; 
SELECT EMPLOYEE_ID, LAST_NAME, SALARY*12 ANNSAL 
FROM EMPLOYEES ; 

SELECT EMPLOYEE_ID, LAST_NAME, SALARY*12 "ANNUAL SALARY" --quotation marks if space in alias
FROM EMPLOYEES ; 

SELECT LAST_NAME, COMMISSION_PCT 
FROM EMPLOYEES ; 

SELECT LAST_NAME, SALARY, COMMISSION_PCT, (SALARY+SALARY*COMMISSION_PCT) SALCOMM 
FROM EMPLOYEES ;

SELECT FIRST_NAME, LAST_NAME, (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, SALARY 
FROM EMPLOYEES ; 
-- Note the use of single quotes in the above statement. The single quote is used to mean text values. This is 
-- necessary and without the single quote, Oracle will think the text as a column name, which is definitely 
-- wrong in this case. So, you must use single quote around text values (not around column names). However, 
-- no quote is used for numeric values, e.g., 350, and 7777.

SELECT DISTINCT DEPARTMENT_ID, JOB_ID  -- to eliminate duplicate values
FROM EMPLOYEES ; 

DESCRIBE EMPLOYEES ; 

SELECT EMPLOYEE_ID, LAST_NAME, HIRE_DATE, 
       TO_CHAR(HIRE_DATE, 'DD-MON-YYYY') HIRE_DT_FORMATTED
FROM EMPLOYEES ;

SELECT EMPLOYEE_ID, LAST_NAME, HIRE_DATE, 
       TO_CHAR(HIRE_DATE, 'DAY, DDth MONTH, YYYY') HIRE_DT_FORMATTED
FROM EMPLOYEES ;

SELECT EMPLOYEE_ID, LAST_NAME, HIRE_DATE, 
       TO_CHAR(HIRE_DATE, 'FMDay, DDth FMMonth, YYYY') HIRE_DT_FORMATTED
FROM EMPLOYEES ;

SELECT EMPLOYEE_ID, LAST_NAME, HIRE_DATE, 
       TO_CHAR(HIRE_DATE, 'FMDay, DDth FMMonth, YYYY HH:MI:SS AM') HIRE_DT_FORMATTED
FROM EMPLOYEES ;

SELECT EMPLOYEE_ID, LAST_NAME, HIRE_DATE, 
       TO_CHAR(HIRE_DATE, 'YYYY-MM-DD HH24:MI:SS') HIRE_DT_FORMATTED
FROM EMPLOYEES ;
-- Note: HH12 is for 12-hour format, HH24 is for 24-hour format

SELECT EMPLOYEE_ID, LAST_NAME, SALARY, 
       TO_CHAR(SALARY, 'L99,999.00') SALARY_FORMATTED
FROM EMPLOYEES ;
-- Note: L is for local currency symbol

SELECT * FROM EMPLOYEES;

-- a. Write an SQL query to retrieve all country names. 
SELECT COUNTRY_NAME
FROM COUNTRIES;

-- b. Write an SQL query to retrieve all job titles. 
SELECT JOB_TITLE
FROM JOBS;

-- c. Write an SQL query to retrieve all MANAGER_IDs.
SELECT MANAGER_ID
FROM DEPARTMENTS;

-- d. Write an SQL query to retrieve all city names. Remove duplicate outputs. 
SELECT DISTINCT CITY
FROM LOCATIONS;

-- e. Write an SQL query to retrieve LOCATION_ID, ADDRESS from LOCATIONS table. The 
-- ADDRESS should print each location in the following format: STREET_ADDRESS, CITY, 
-- STATE_PROVINCE, POSTAL_CODE.
SELECT LOCATION_ID, (STREET_ADDRESS || ', ' || CITY || ', ' || STATE_PROVINCE || ', ' || POSTAL_CODE) ADDRESS
FROM LOCATIONS;

SELECT LAST_NAME, SALARY, DEPARTMENT_ID
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 80;

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME = 'Whalen'; 
 
SELECT LAST_NAME, SALARY, HIRE_DATE
FROM EMPLOYEES 
WHERE HIRE_DATE = '16-NOV-2007'; 
-- Note: The date format may vary based on your NLS_DATE_FORMAT settings.

 
SELECT LAST_NAME, SALARY, COMMISSION_PCT
FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NULL; 

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE SALARY BETWEEN 5000 AND 10000; 

SELECT LAST_NAME, SALARY, HIRE_DATE
FROM EMPLOYEES 
WHERE HIRE_DATE >= '01-JAN-1990' AND HIRE_DATE <= '31-DEC-2005' ;

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID IN (50, 60, 70, 80, 90, 100) ; 
SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME IN ('Ernst', 'Austin', 'Pataballa', 'Lorentz') ; 

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME LIKE '%s%' ;

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME LIKE '____a' ; 
SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME LIKE '_ _ b' ; 
SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
WHERE LAST_NAME LIKE '_%' ;  -- names with at least 1 characters

SELECT LAST_NAME, SALARY, COMMISSION_PCT 
FROM EMPLOYEES 
WHERE COMMISSION_PCT <  0.20 OR COMMISSION_PCT IS NULL ;

-- a. Select names of all employees who have joined before January 01, 1998. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, HIRE_DATE
FROM EMPLOYEES
WHERE HIRE_DATE < '01-JAN-1998' ;

-- b. Select all locations in the following countries: Canada, Germany, United Kingdom. 
SELECT LOCATION_ID, CITY, COUNTRY_ID
FROM LOCATIONS
WHERE COUNTRY_ID IN (SELECT COUNTRY_ID 
                     FROM COUNTRIES 
                     WHERE COUNTRY_NAME IN ('Canada', 'Germany', 'United Kingdom')) ;

-- c. Select first names of all employees who do not get any commission. 
SELECT FIRST_NAME 
FROM EMPLOYEES
WHERE COMMISSION_PCT IS NULL; 

-- d. Select first names of employees whose last name starts with an 'a'. 
SELECT FIRST_NAME
FROM EMPLOYEES 
WHERE LAST_NAME LIKE 'a%';

-- e. Select first names of employees whose last name starts with an 's' and ends with an 'n'. 
SELECT FIRST_NAME
FROM EMPLOYEES 
WHERE LAST_NAME LIKE 's%n' ;

-- f. Select all department names whose MANAGER_ID is 100. 
SELECT DEPARTMENT_ID
FROM DEPARTMENTS
WHERE MANAGER_ID = 100 ;

-- g. Select all names of employees whose job type is 'AD_PRES' and whose salary is at least 23000. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, JOB_ID, SALARY
FROM EMPLOYEES
WHERE JOB_ID = 'AD_PRES' AND SALARY >= 23000 ;

-- h. Select names of all employees whose last name do not contain the character 's'. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME
FROM EMPLOYEES
WHERE LAST_NAME NOT LIKE '%s%';

-- i. Select names and COMMISSION_PCT of all employees whose commission is at most 0.30. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, COMMISSION_PCT
FROM EMPLOYEES
WHERE COMMISSION_PCT <= 0.30 OR COMMISSION_PCT IS NULL;

-- j. Select names of all employees who have joined after January 01, 1998. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, HIRE_DATE
FROM EMPLOYEES
WHERE HIRE_DATE > '01-JAN-1998' ;

-- k. Select names of all employees who have joined in the year 1998. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, HIRE_DATE
FROM EMPLOYEES
WHERE HIRE_DATE BETWEEN '01-JAN-1998' AND '31-DEC-1998' ;

-- Template for ORDER BY clause
-- SELECT … 
-- FROM table_name 
-- WHERE … 
-- ORDER BY Column1 [ASC | DESC], Column2 [ASC | DESC], … 

SELECT LAST_NAME, SALARY 
FROM EMPLOYEES 
ORDER BY SALARY DESC, LAST_NAME ASC ;

SELECT JOB_TITLE, (MAX_SALARY - MIN_SALARY) DIFF_SALARY 
FROM JOBS 
ORDER BY DIFF_SALARY DESC ;

-- a. Select names, salary, and commissions of all employees of job type 'AD_PRES'. Sort the result 
-- in ascending order of commission and then descending order of salary. 
SELECT (FIRST_NAME || ' ' || LAST_NAME) FULLNAME, SALARY, COMMISSION_PCT
FROM EMPLOYEES 
WHERE JOB_ID = 'AD_PRES'
ORDER BY COMMISSION_PCT ASC, SALARY DESC ;

-- b. Retrieve all country names in lexicographical ascending order.
SELECT COUNTRY_NAME
FROM COUNTRIES
ORDER BY COUNTRY_NAME ASC ;

SELECT (INITCAP(FIRST_NAME) || ' ' || LOWER(LAST_NAME)) NAME, UPPER(JOB_ID) JOB 
FROM EMPLOYEES ; 

SELECT * 
FROM DEPARTMENTS 
WHERE UPPER(DEPARTMENT_NAME) LIKE '%SALE%' ;  
SELECT * 
FROM DEPARTMENTS 
WHERE LOWER(DEPARTMENT_NAME) LIKE '%sale%' ; 

SELECT CONCAT(FIRST_NAME,CONCAT(' ', LAST_NAME)) NAME, JOB_ID 
FROM EMPLOYEES 
WHERE INSTR( UPPER(JOB_ID), 'CLERK') > 0 ; 

SELECT (INITCAP(FIRST_NAME) || ' ' || LOWER(LAST_NAME)) NAME, 
        ( SUBSTR(FIRST_NAME, 1, 1) || '.' || SUBSTR(LAST_NAME, 1, 1) || '.' ) ABBR 
FROM EMPLOYEES ; 

SELECT INITCAP( TRIM(LAST_NAME) )  NAME, LPAD(SALARY, 10, 0) 
FROM EMPLOYEES ;


-- a. Print the first three characters and last three characters of all country names. Print in capital 
-- letters. 
SELECT UPPER(SUBSTR(COUNTRY_NAME, 1, 3)) FIRST_3_CHARS,
       UPPER(SUBSTR(COUNTRY_NAME, -3)) LAST_3_CHARS
FROM COUNTRIES 
WHERE ROWNUM <= 10;  -- limiting output for readability


-- b. Print all employee full names (first name followed by a space then followed by last name). All 
-- names should be printed in width of 60 characters and left padded with '*' symbol for names 
-- less than 60 characters. 
SELECT LPAD( (FIRST_NAME || ' ' || LAST_NAME), 60, '*') FULLNAME_PADDED
FROM EMPLOYEES 
WHERE ROWNUM <= 10;  -- limiting output for readability

-- c. Print all job titles that contain the text 'manager'. The search should be case insensitive.
SELECT JOB_TITLE
FROM JOBS 
WHERE INSTR( UPPER(JOB_TITLE), 'MANAGER') > 0 ;

SELECT LAST_NAME, SALARY, ROUND(SALARY/1000, 2) "SALARY (IN THOUSANDS)" 
FROM EMPLOYEES 
WHERE INSTR(JOB_ID, 'CLERK') > 0 ; 

SELECT LAST_NAME, ROUND( (SYSDATE - HIRE_DATE)/7, 4) WEEKS_EMPLOYED 
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 80 ; 

SELECT LAST_NAME, TRUNC(SALARY/1000, 0) || ' thousands ' ||  
TRUNC( MOD(SALARY,1000)/100, 0) || ' hundreds ' || MOD(SALARY,100) || ' taka only' AS FULL_SALARY_FORMAT
FROM EMPLOYEES ;

-- a. Print employee last name and number of days employed. Print the second information rounded 
-- up to 2 decimal places. 
SELECT LAST_NAME, ROUND((SYSDATE - HIRE_DATE), 2) DAYS_EMPLOYED
FROM EMPLOYEES ;

-- b. Print employee last name and number of years employed. Print the second information 
-- truncated up to 3 decimal place. 
SELECT LAST_NAME, TRUNC((SYSDATE - HIRE_DATE) / 365, 3) YEARS_EMPLOYED
FROM EMPLOYEES ;

-- a. For all employees, find the number of years employed. Print first names and number of years 
-- employed for each employee. 
SELECT FIRST_NAME, TRUNC((SYSDATE - HIRE_DATE) / 365, 2) YEARS_EMPLOYED
FROM EMPLOYEES ;

-- b. Suppose you need to find the number of days each employee worked during the first month of 
-- his joining. Write an SQL query to find this information for all employees.
SELECT FIRST_NAME, 
--          CASE 
--               WHEN TO_CHAR(HIRE_DATE, 'DD') = '01' THEN 30
--               ELSE 30 - TO_NUMBER(TO_CHAR(HIRE_DATE, 'DD')) + 1
--        END AS DAYS_IN_FIRST_MONTH
    (ROUND(HIRE_DATE + 16, 'MONTH') - HIRE_DATE - 1) AS DAYS_IN_FIRST_MONTH
FROM EMPLOYEES ;


SELECT LAST_NAME, NVL(COMMISSION_PCT, 0) -- replace null with 0
FROM EMPLOYEES ; 

SELECT * 
FROM EMPLOYEES 
WHERE NVL(COMMISSION_PCT, -1) = -1 ; 

SELECT LAST_NAME,  
(SALARY*12 + SALARY*12*NVL(COMMISSION_PCT, 0) ) ANNSAL 
FROM EMPLOYEES 
WHERE NVL(COMMISSION_PCT, -1) = -1 ; 

-- a. Print the commission_pct values of all employees whose commission is at least 20%. Use NVL 
-- function. 
SELECT LAST_NAME, NVL(COMMISSION_PCT, 0) COMM_PCT
FROM EMPLOYEES
WHERE NVL(COMMISSION_PCT, 0) >= 0.20 ;

-- b. Print the total salary of an employee for 5 years and 6 months period. Print all employee last 
-- names along with this salary information. Use NVL function assuming that salary may contain 
-- NULL values. 
SELECT LAST_NAME, NVL(SALARY, 0) * 66 TOTAL_SALARY_5_5_YEARS
FROM EMPLOYEES ;


SELECT LAST_NAME, TO_CHAR(HIRE_DATE, 'DD-MON-YYYY') HD 
FROM EMPLOYEES 
WHERE HIRE_DATE < TO_DATE('01-JAN-2007', 'DD-MON-YYYY')  
ORDER BY HIRE_DATE ASC ; 

SELECT LAST_NAME, TO_CHAR(HIRE_DATE, 'fmddspth FMMONTH FMYYYY') HD
FROM EMPLOYEES 
ORDER BY HIRE_DATE ASC ;

-- DDSPTH: Day of month with suffix (1st, 2nd, 3rd, etc.)
-- MONTH: Full month name
-- YYYY: 4-digit year
-- Dday and Month with FM: removes leading spaces
-- FMDay, FMMonth
-- e.g., 3rd March 2020

-- Template for GROUP BY clause
-- SELECT Column1, Column2, … , SUM(Column1), MAX(Column1), … 
-- FROM table_name 
-- GROUP BY Column1, Column2, … 
-- grouping columns must be in select clause
-- grouping columns determine how rows are grouped together

SELECT *
FROM EMPLOYEES ;

SELECT DEPARTMENT_ID, SUM(SALARY) 
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID 
ORDER BY DEPARTMENT_ID ASC;

SELECT JOB_ID, MAX(SALARY), MIN(SALARY), AVG(SALARY)  
FROM EMPLOYEES 
GROUP BY JOB_ID ;

SELECT JOB_ID, JOB_TITLE, COUNT(*) TOTAL 
FROM JOBS 
GROUP BY JOB_ID, JOB_TITLE ;

SELECT DEPARTMENT_ID, COUNT(*)
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID ; 

SELECT MAX(SALARY), MIN(SALARY), AVG(SALARY) 
FROM EMPLOYEES ; 

SELECT COUNT(*) 
FROM EMPLOYEES ; 

DESCRIBE EMPLOYEES;


-- 
-- SELECT Column1, Column2, … , SUM(Column1), MAX(Column1), … 
-- FROM table_name 
-- WHERE condition 
-- GROUP BY Column1, Column2, … 

SELECT JOB_ID, MAX(SALARY), MIN(SALARY), AVG(SALARY)
FROM EMPLOYEES 
WHERE DEPARTMENT_ID = 80
GROUP BY JOB_ID
ORDER BY JOB_ID ASC ;

-- a. For all managers, find the number of employees he/she manages. Print the MANAGER_ID 
-- and total number of such employees. 
SELECT MANAGER_ID, COUNT(*) TOTAL_EMPLOYEES
FROM EMPLOYEES 
WHERE MANAGER_ID IS NOT NULL
GROUP BY MANAGER_ID
ORDER BY MANAGER_ID ASC ;

-- b. For all departments, find the number of employees who get more than 30k salary. Print the 
-- DEPARTMENT_ID and total number of such employees. 
SELECT DEPARTMENT_ID, COUNT(*) TOTAL_EMPLOYEES_ABOVE_30K
FROM EMPLOYEES
WHERE SALARY > 30000
GROUP BY DEPARTMENT_ID
ORDER BY DEPARTMENT_ID ASC ;

-- c. Find the minimum, maximum, and average salary of all departments except 
-- DEPARTMENT_ID 80. Print DEPARTMENT_ID, minimum, maximum, and average salary. 
-- Sort the results in descending order of average salary first, then maximum salary, then 
-- minimum salary. Use column alias to rename column names in output for better display.
SELECT DEPARTMENT_ID, MAX(SALARY), MIN(SALARY), AVG(SALARY)
FROM EMPLOYEES 
WHERE DEPARTMENT_ID != 80
GROUP BY DEPARTMENT_ID
ORDER BY AVG(SALARY) DESC, MAX(SALARY) DESC, MIN(SALARY) DESC ;

SELECT JOB_ID, MAX(DISTINCT SALARY), MIN(DISTINCT SALARY),  
SUM(DISTINCT SALARY), COUNT(DISTINCT DEPARTMENT_ID) 
FROM EMPLOYEES  
WHERE DEPARTMENT_ID = 80 
GROUP BY JOB_ID  
ORDER BY JOB_ID ASC ;

-- HAVING works like WHERE except that HAVING works on 
-- groups. 
SELECT DEPARTMENT_ID, MAX(SALARY), MIN(SALARY) 
FROM EMPLOYEES  
GROUP BY DEPARTMENT_ID 
HAVING DEPARTMENT_ID <> 80 ; -- <> means not equal to

SELECT JOB_ID, MAX(SALARY), MIN(SALARY) 
FROM EMPLOYEES  
GROUP BY JOB_ID 
HAVING MAX(SALARY) > 5000 ; 
 
SELECT JOB_ID, AVG(SALARY)  
FROM EMPLOYEES  
GROUP BY JOB_ID 
HAVING AVG(SALARY) <= 5000  
ORDER BY AVG(SALARY) DESC ; 

-- a. Find for each department, the average salary of the department. Print only those 
-- DEPARTMENT_ID and average salary whose average salary is at most 50k.

SELECT DEPARTMENT_ID, AVG(SALARY) AVG_SAL
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING AVG(SALARY) <= 50000;


SELECT TO_CHAR(HIRE_DATE, 'YYYY') YEAR, COUNT(*) TOTAL 
FROM EMPLOYEES  
GROUP BY TO_CHAR(HIRE_DATE, 'YYYY')  
ORDER BY YEAR ASC ; 

SELECT SUBSTR(FIRST_NAME, 1, 1) FC, COUNT(*) TOTAL 
FROM EMPLOYEES  
GROUP BY SUBSTR(FIRST_NAME, 1, 1)  
ORDER BY FC ASC ; 

SELECT DEPARTMENT_ID, JOB_ID, COUNT(*) TOTAL 
FROM EMPLOYEES  
GROUP BY DEPARTMENT_ID, JOB_ID ;

SELECT JOB_ID, JOB_TITLE, COUNT(*) TOTAL 
FROM JOBS 
GROUP BY JOB_ID, JOB_TITLE ; 
-- Oracle does not allow to select columns in the SELECT clause that are 
-- not present in the GROUP BY clause.

-- a. Find number of employees in each salary group. Salary groups are considered as follows. 
-- Group 1: 0k to <5K, 5k to <10k, 10k to <15k, and so on. 
SELECT TRUNC(SALARY/5000) SAL_GRP, COUNT(*) TOTAL_EMPLOYEES 
FROM EMPLOYEES
GROUP BY TRUNC(SALARY/5000)
ORDER BY SAL_GRP ASC ;


-- b. Find the number of employees that were hired in each year in each job type. Print year, job id, 
-- and total employees hired. 

SELECT TO_CHAR(HIRE_DATE, 'YYYY') YEAR, JOB_ID, COUNT(*) TOTAL_EMPLOYEES
FROM EMPLOYEES
GROUP BY TO_CHAR(HIRE_DATE, 'YYYY'), JOB_ID
ORDER BY YEAR ASC, JOB_ID ASC ;

-- Template for INSERT statement
-- INSERT INTO table_name (column1, column2, column3, …) 
-- VALUES (value1, value2, value3, ...) ; 

INSERT INTO DEPARTMENTS (DEPARTMENT_ID, DEPARTMENT_NAME, MANAGER_ID, LOCATION_ID) 
VALUES (179, 'Public Relations', 100, 2600) ; 

SELECT *
FROM DEPARTMENTS 
WHERE DEPARTMENT_ID = 189 ;

INSERT INTO DEPARTMENTS VALUES (189, 'PRINTING_STATIONARY', 100, 2600) ;


-- Template for UPDATE statement
-- UPDATE table_name 
-- SET Column1 = value1, Column2 = value2, … 
-- WHERE condition ;

-- UPDATE EMPLOYEES 
-- SET DEPARTMENT_ID = 50 
-- WHERE EMPLOYEE_ID = 113 ; 

UPDATE EMPLOYEES 
SET COMMISSION_PCT TO NULL
WHERE COMMISSION_PCT = 0 ;

-- SELECT *
-- FROM EMPLOYEES
-- WHERE COMMISSION_PCT = 0 ;

SELECT *
FROM EMPLOYEES 
WHERE COMMISSION_PCT IS NULL ;

-- a. Update COMMISSION_PCT value to 0 for those employees who have NULL in that column. 
UPDATE EMPLOYEES 
SET COMMISSION_PCT = 0
WHERE COMMISSION_PCT IS NULL ;

-- b. Update salary of all employees to the maximum salary of the department in which he/she 
-- works. 
UPDATE EMPLOYEES E1
SET SALARY = (SELECT MAX(SALARY)
              FROM EMPLOYEES E2
              WHERE E1.DEPARTMENT_ID = E2.DEPARTMENT_ID) ;


-- c. Update COMMISSION_PCT to 𝑁 times for each employee where 𝑁 is the number of 
-- employees he/she manages. When 𝑁 = 0, keep the old value of COMMISSION_PCT column. 
UPDATE EMPLOYEES E1
SET COMMISSION_PCT = COMMISSION_PCT * 
    (SELECT COUNT(*) 
     FROM EMPLOYEES E2
     WHERE E1.EMPLOYEE_ID = E2.MANAGER_ID)
WHERE EXISTS (SELECT 1 
              FROM EMPLOYEES E2
              WHERE E1.EMPLOYEE_ID = E2.MANAGER_ID) ;


-- d. Update the hiring dates of all employees to the first day of the same year. Do not change this 
-- for those employees who joined on or after year 2000.
UPDATE EMPLOYEES
SET HIRE_DATE = TO_DATE('01-JAN-' || TO_CHAR(HIRE_DATE, 'YYYY'), 'DD-MON-YYYY')
WHERE HIRE_DATE < TO_DATE('01-JAN-2000', 'DD-MON-YYYY') ;


-- Template for DELETE statement
-- DELETE FROM table_name
-- WHERE condition ;

-- a. Delete those employees who earn less than 5k. 
-- b. Delete those locations having no departments. 
-- c. Delete those employees from the EMPLOYEES table who joined before the year 1997.

SELECT SUBSTR(NVL(PHONE_NUMBER, ''), 1, 3) AS COUNTRY_CODE,
       COUNT(*) AS TOTAL
FROM EMPLOYEES
WHERE HIRE_DATE > DATE '2005-01-01'
GROUP BY SUBSTR(NVL(PHONE_NUMBER, ''), 1, 3)
ORDER BY COUNTRY_CODE;

SELECT EMPLOYEE_ID, SALARY, ABS(SALARY - ROUND(SALARY, -3)) AS SALARY_DIFF
FROM EMPLOYEES;

SELECT DEPARTMENT_ID, TO_CHAR(SUM(SALARY) * 12, '99,999,999') AS ANNUAL_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING COUNT(*) > 2 AND MIN(SALARY) >= 2500
ORDER BY DEPARTMENT_ID;

SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, PHONE_NUMBER, (SUBSTR(UPPER(FIRST_NAME), 1, 2) || LENGTH(LAST_NAME) || SUBSTR(PHONE_NUMBER, -1)) AS SECURITY_CODE
FROM EMPLOYEES
WHERE PHONE_NUMBER IS NOT NULL AND LENGTH(FIRST_NAME) > LENGTH(LAST_NAME)
ORDER BY LENGTH(SECURITY_CODE) DESC, SECURITY_CODE ASC;


CREATE TABLE EMP_TRAINING (
       TRAINING_ID NUMBER PRIMARY KEY,
       EMPLOYEE_ID NUMBER NOT NULL,
       TRAINING_NAME VARCHAR2(100) NOT NULL,
       REG_DATE DATE DEFAULT SYSDATE,

       CONSTRAINT fk_emp FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id) 
);

INSERT INTO EMP_TRAINING (TRAINING_ID, EMPLOYEE_ID, TRAINING_NAME)
VALUES (1, 101, 'SQL Basics');

SELECT * FROM EMP_TRAINING;

DROP TABLE EMP_TRAINING;

SELECT * FROM EMPLOYEES;

SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, SALARY,
       CASE 
           WHEN SALARY < 5000 THEN 'Low'
           WHEN SALARY BETWEEN 5000 AND 10000 THEN 'Medium'
           ELSE 'High'
       END AS SALARY_BRACKET
FROM EMPLOYEES
ORDER BY SALARY ASC;

SELECT SUBSTR(PHONE_NUMBER, 1, 3) AS COUNTRY_CODE, AVG(SALARY) AS AVG_SALARY
FROM EMPLOYEES
WHERE HIRE_DATE > DATE '2005-01-01'
GROUP BY SUBSTR(PHONE_NUMBER, 1, 3);

SELECT EMPLOYEE_ID, SALARY, ROUND(SALARY/500) * 500 AS ROUNDED_SALARY_TO_500
FROM EMPLOYEES;

SELECT EMPLOYEE_ID, SALARY, ABS(SALARY - ROUND(SALARY/5000) * 5000) AS SALARY_DIFF_5000
FROM EMPLOYEES;

CREATE TABLE EMP_BONUS (
       BONUS_ID NUMBER PRIMARY KEY,
       EMPLOYEE_ID NUMBER NOT NULL,
       BONUS_AMOUNT NUMBER NOT NULL CHECK (BONUS_AMOUNT >= 0),
       BONUS_DATE DATE DEFAULT SYSDATE,

       CONSTRAINT fk_emp_bonus FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
);

INSERT INTO EMP_BONUS (BONUS_ID, EMPLOYEE_ID, BONUS_AMOUNT)
VALUES (1, 102, 1500);

SELECT * FROM EMP_BONUS;

INSERT INTO EMP_BONUS (BONUS_ID, EMPLOYEE_ID, BONUS_AMOUNT)
VALUES (2, 103, -2000);

SELECT DEPARTMENT_ID, AVG(SALARY) AS AVG_SALARY
from EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING COUNT(*) > 5;

SELECT DEPARTMENT_ID, MAX(SALARY) AS MAX_SALARY, MIN(SALARY) AS MIN_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING MAX(SALARY) > 10000;

SELECT DEPARTMENT_ID, SUM(SALARY) * 12 AS TOTAL_SALARY
FROM EMPLOYEES
GROUP BY DEPARTMENT_ID
HAVING MIN(SALARY) >= 3000;

SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, PHONE_NUMBER
FROM EMPLOYEES
WHERE MOD(TO_NUMBER(SUBSTR(PHONE_NUMBER, -1)), 2) = 0;

SELECT DEPARTMENT_ID, JOB_ID, COUNT(*) AS TOTAL_EMPLOYEES, (SUBSTR(DEPARTMENT_NAME, 1, 1) || COUNT(*) || MAX(SALARY) || ) AS DEPT_KEY
FROM EMPLOYEES 
GROUP BY DEPARTMENT_ID, JOB_ID, DEPARTMENT_NAME
HAVING COUNT(*) > 2;

SELECT EMPLOYEE_ID, FIRST_NAME
FROM EMPLOYEES
WHERE SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES);

SELECT EMPLOYEE_ID, LAST_NAME
FROM EMPLOYEES
WHERE SUBSTR(LAST_NAME, 1, 1) = UPPER(SUBSTR(LAST_NAME, -1));

CREATE TABLE EMP_CERTIFICATION (
       CERT_ID NUMBER PRIMARY KEY, 
       EMPLOYEE_ID NUMBER NOT NULL,
       CERT_NAME VARCHAR2(100) NOT NULL,
       ISSUE_DATE DATE DEFAULT SYSDATE,
       EXPIRY_DATE DATE DEFAULT (SYSDATE + 365),

       CONSTRAINT fk_emp_cert FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
);

INSERT INTO EMP_CERTIFICATION (CERT_ID, EMPLOYEE_ID, CERT_NAME)
VALUES (1, 104, 'Oracle SQL Certification');

SELECT 'Q' || CEIL(EXTRACT(MONTH FROM hire_date) / 3) AS quarter,
       COUNT(*) AS employee_count
FROM employees
GROUP BY CEIL(EXTRACT(MONTH FROM hire_date) / 3)
ORDER BY quarter;


SELECT LPAD(first_name || ' ' || last_name, 20) AS full_name
FROM employees
ORDER BY LENGTH(first_name || ' ' || last_name) ASC;

SELECT DEPARTMENT_ID, JOB_ID, MIN(HIRE_DATE) AS EARLIEST_HIRE_DATE, MAX(HIRE_DATE) AS LATEST_HIRE_DATE, ROUND(AVG(SALARY), 2) AS AVG_SALARY
FROM EMPLOYEES
WHERE DEPARTMENT_ID IS NOT NULL
  AND JOB_ID IS NOT NULL
  AND SALARY IS NOT NULL
  AND HIRE_DATE IS NOT NULL
GROUP BY DEPARTMENT_ID, JOB_ID
HAVING AVG(SALARY) > 8000;
ORDER BY DEPARTMENT_ID;

SELECT first_name || ' ' || last_name AS full_name,
       hire_date
FROM employees
WHERE REGEXP_LIKE(first_name, '^[^AEIOUaeiou]')
  AND NOT REGEXP_LIKE(last_name, '[Bb]')
  AND TO_CHAR(hire_date, 'MM') = '11'
ORDER BY full_name;

-- Template for JOIN with USING clause
-- SELECT … 
-- FROM table1 JOIN table2 USING (Column1, Column2, …) 
-- WHERE … 
-- GROUP BY … 
-- ORDER BY … 

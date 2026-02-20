BEGIN 
      DBMS_OUTPUT.PUT_LINE('Hello World') ; 
END ;
/

DECLARE 
      ENAME VARCHAR2(100) ; 
BEGIN 
      SELECT (FIRST_NAME || ' ' || LAST_NAME) INTO ENAME 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 100 ; 
      DBMS_OUTPUT.PUT_LINE('The name is : ' || ENAME) ; 
END ; 
/

DECLARE 
      JDATE DATE ; 
      MONTHS NUMBER ; 
      RMONTHS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 100 ;
      MONTHS := MONTHS_BETWEEN(SYSDATE, JDATE);
      RMONTHS := ROUND(MONTHS, 0);

      DBMS_OUTPUT.PUT_LINE('The employee worked ' || RMONTHS || ' months.');
END;
/
SHOW ERRORS ;


DECLARE 
      JDATE DATE ;
      YEARS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 100 ; 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
      IF YEARS >= 10 THEN              
            DBMS_OUTPUT.PUT_LINE('The employee worked 10 years or more') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('The employee worked less than 10 years') ; 
      END IF ; 
END ; 
/

DECLARE 
      ESALARY NUMBER ; 
BEGIN 
      SELECT SALARY INTO ESALARY 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 100 ; 
      IF ESALARY < 1000 THEN              
            DBMS_OUTPUT.PUT_LINE('Job grade is D') ; 
      ELSIF ESALARY >= 1000 AND ESALARY < 2000 THEN 
            DBMS_OUTPUT.PUT_LINE('Job grade is C') ; 
      ELSIF ESALARY >= 2000 AND ESALARY < 3000 THEN 
            DBMS_OUTPUT.PUT_LINE('Job grade is B') ; 
      ELSIF ESALARY >= 3000 AND ESALARY < 5000 THEN 
            DBMS_OUTPUT.PUT_LINE('Job grade is A') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('Job grade is A+') ; 
      END IF ; 
END ; 
/

DECLARE 
      JDATE DATE ; 
      YEARS NUMBER ; 
BEGIN 
      --first retrieve hire_date and store the value into JDATE variable 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 10000 ; 
      --calculate years from the hire_date field 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ;
      IF YEARS >= 10 THEN              
            DBMS_OUTPUT.PUT_LINE('The employee worked 10 years or more') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('The employee worked less than 10 years') ; 
      END IF ; 
EXCEPTION 
    --handle exceptions one by one here 
    WHEN NO_DATA_FOUND THEN 
    DBMS_OUTPUT.PUT_LINE('Employee is not present in database.') ; 
    WHEN TOO_MANY_ROWS THEN 
    DBMS_OUTPUT.PUT_LINE('There are more than one employee with same employee id.') ;
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('I dont know what happened!') ; 
END ; 
/

BEGIN
    INSERT INTO COUNTRIES (COUNTRY_ID, COUNTRY_NAME, REGION_ID) VALUES ('AR', 'Test Country', 1);
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Country with this ID already exists.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;
/

SELECT * FROM COUNTRIES ;


DECLARE 
BEGIN 
    FOR i in 1..100 
    LOOP  
    DBMS_OUTPUT.PUT_LINE(i); 
    END LOOP ; 
End ; 
/

DECLARE 
      i number; 
BEGIN 
      i := 1; 
      WHILE i<=100 
      LOOP  
            DBMS_OUTPUT.PUT_LINE(i); 
            i := i + 1; 
      END LOOP ; 
End ; 
/ 
 
DECLARE 
      i number; 
BEGIN 
      --this is an unconditional loop, must have EXIT WHEN inside loop 
      i := 1; 
      LOOP  
            DBMS_OUTPUT.PUT_LINE(i); 
            i := i + 1; 
      EXIT WHEN  (i > 100) ; 
 END LOOP ; 
End ; 
/

-- CURSOR FOR LOOP
-- FOR variable in (SELECT statement) 
-- LOOP 
--       Statement1 ; 
--       Statement2 ; 
--       ...  
-- END LOOP ;

DECLARE
      YEARS NUMBER ; 
      COUNTER NUMBER ; 
BEGIN 
      COUNTER := 0 ; 
      --the following for loop will iterate over all rows of the SELECT results 
      FOR R IN (SELECT HIRE_DATE FROM EMPLOYEES ) 
      LOOP 
      --variable R is used to retrieve columns 
            YEARS := (MONTHS_BETWEEN(SYSDATE, R.HIRE_DATE) / 12) ; 
            IF YEARS >= 10 THEN              
                  COUNTER := COUNTER + 1 ; 
            END IF ; 
      END  LOOP ; 
      DBMS_OUTPUT.PUT_LINE('Number  of  employees  worked  10  years  or  more:  '  || 
COUNTER) ;     
END ; 
/

DECLARE 
      YEARS NUMBER ; 
      COUNTER NUMBER ; 
      OLD_SAL NUMBER; 
      NEW_SAL NUMBER; 
BEGIN 
      COUNTER := 0 ; 
      FOR R IN (SELECT EMPLOYEE_ID, SALARY, HIRE_DATE FROM EMPLOYEES ) 
      LOOP 
            OLD_SAL := R.SALARY ; 
            YEARS := (MONTHS_BETWEEN(SYSDATE, R.HIRE_DATE) / 12) ; 
            IF YEARS >= 10 THEN              
                  UPDATE EMPLOYEES SET SALARY = SALARY * 1.15 
                  WHERE EMPLOYEE_ID = R.EMPLOYEE_ID ; 
            END IF ; 
            SELECT SALARY INTO NEW_SAL FROM EMPLOYEES  
            WHERE EMPLOYEE_ID = R.EMPLOYEE_ID ; 
      DBMS_OUTPUT.PUT_LINE('Employee id:' || R.EMPLOYEE_ID || ' Salary: ' || OLD_SAL || ' -> ' || NEW_SAL) ; 
      END  LOOP ; 
END ; 
/

DECLARE
      HIREDATE DATE;
      TODAY DATE;
BEGIN
      TODAY := SYSDATE;
      FOR R IN (SELECT FIRST_NAME || ' ' || LAST_NAME AS FULL_NAME, HIRE_DATE, EMPLOYEE_ID 
            FROM EMPLOYEES
            WHERE TO_CHAR(HIRE_DATE, 'MM-DD') = TO_CHAR(SYSDATE, 'MM-DD'))
      LOOP
            DBMS_OUTPUT.PUT_LINE('HAPPY ANNIVERSARY ' || R.FULL_NAME || '!');
      END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE IS_SENIOR_EMPLOYEE IS 
      JDATE DATE ; 
      YEARS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = 100 ; 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
      IF YEARS >= 10 THEN              
            DBMS_OUTPUT.PUT_LINE('The employee worked 10 years or more') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('The employee worked less than 10 years') ;
      END IF ; 
END ; 
/


EXEC  IS_SENIOR_EMPLOYEE ;

BEGIN 
      IS_SENIOR_EMPLOYEE ; 
END ;



CREATE OR REPLACE PROCEDURE IS_SENIOR_EMPLOYEE(EID IN VARCHAR2) IS 
      JDATE DATE ; 
      YEARS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = EID ; 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
      IF YEARS >= 10 THEN              
            DBMS_OUTPUT.PUT_LINE('The employee worked 10 years or more') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('The employee worked less than 10 years') ; 
      END IF ;
END ;
/


EXEC  IS_SENIOR_EMPLOYEE(120) ;

DECLARE 
BEGIN 
      IS_SENIOR_EMPLOYEE(100) ; 
      IS_SENIOR_EMPLOYEE(105) ; 
END ; 
/

CREATE OR REPLACE PROCEDURE IS_SENIOR_EMPLOYEE(EID IN VARCHAR2) IS 
      JDATE DATE ; 
      YEARS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = EID ; 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
      IF YEARS >= 10 THEN              
            DBMS_OUTPUT.PUT_LINE('The employee worked 10 years or more') ; 
      ELSE 
            DBMS_OUTPUT.PUT_LINE('The employee worked less than 10 years') ; 
      END IF ; 
EXCEPTION 
      WHEN NO_DATA_FOUND THEN 
            DBMS_OUTPUT.PUT_LINE('No employee found.') ; 
      WHEN TOO_MANY_ROWS THEN 
            DBMS_OUTPUT.PUT_LINE('More than one employee found.') ; 
      WHEN OTHERS THEN 
            DBMS_OUTPUT.PUT_LINE('Some unknown error occurred.') ; 
END ; 
/

EXEC  IS_SENIOR_EMPLOYEE(12) ;


CREATE OR REPLACE PROCEDURE IS_SENIOR_EMPLOYEE(EID IN VARCHAR2, MSG OUT VARCHAR2) 
IS 
      JDATE DATE ; 
      YEARS NUMBER ; 
BEGIN 
      SELECT HIRE_DATE INTO JDATE 
      FROM EMPLOYEES 
      WHERE EMPLOYEE_ID = EID ; 
      YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
      IF YEARS >= 10 THEN              
            MSG := 'The employee worked 10 years or more' ; 
      ELSE 
            MSG := 'The employee worked less than 10 years' ; 
      END IF ; 
EXCEPTION 
      WHEN NO_DATA_FOUND THEN 
            MSG := 'No employee found.' ; 
      WHEN TOO_MANY_ROWS THEN 
            MSG := 'More than one employee found.' ; 
      WHEN OTHERS THEN 
            MSG := 'Some unknown error occurred.' ;
END ;
/

DECLARE 
      MSG VARCHAR2(100) ;
BEGIN 
      IS_SENIOR_EMPLOYEE(10220, MSG) ;
      DBMS_OUTPUT.PUT_LINE(MSG) ;
END ;
/

--FUNCTIONS
CREATE OR REPLACE FUNCTION GET_SENIOR_EMPLOYEE(EID IN VARCHAR2)  
RETURN VARCHAR2 IS 
      JDATE DATE ; 
      YEARS NUMBER ; 
      MSG VARCHAR2(100) ; 
BEGIN 
       SELECT HIRE_DATE INTO JDATE 
       FROM EMPLOYEES 
       WHERE EMPLOYEE_ID = EID ; 
       YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
       IF YEARS >= 10 THEN              
            MSG := 'The employee worked 10 years or more' ; 
       ELSE 
            MSG := 'The employee worked less than 10 years' ; 
       END IF ; 
 RETURN MSG ; --return the message 
EXCEPTION 
 --you must return value from this section also 
 WHEN NO_DATA_FOUND THEN 
  RETURN 'No employee found.' ; 
 WHEN TOO_MANY_ROWS THEN 
  RETURN 'More than one employee found.' ; 
 WHEN OTHERS THEN 
  RETURN 'Some unknown error occurred.' ; 
END ; 
/

DECLARE 
      MESSAGE VARCHAR2(100) ;
BEGIN 
      MESSAGE := GET_SENIOR_EMPLOYEE(10000) ; 
      DBMS_OUTPUT.PUT_LINE(MESSAGE) ; 
      MESSAGE := GET_SENIOR_EMPLOYEE(105) ; 
      DBMS_OUTPUT.PUT_LINE(MESSAGE) ; 
END ;
/

SELECT LAST_NAME, GET_SENIOR_EMPLOYEE(EMPLOYEE_ID) -- calling function for each employee
FROM EMPLOYEES ;


CREATE OR REPLACE FUNCTION GET_SENIOR_EMPLOYEE(EID IN VARCHAR2)  
RETURN VARCHAR2 IS 
      ECOUNT NUMBER; 
      JDATE DATE ; 
      YEARS NUMBER ; 
      MSG VARCHAR2(100) ; 
BEGIN 
      --Inner PL/SQL block
      BEGIN 
            SELECT COUNT(*) INTO ECOUNT 
            FROM EMPLOYEES  
            WHERE EMPLOYEE_ID = EID ; 
      END ; 
      IF ECOUNT = 0 THEN 
            MSG := 'No employee found.' ; 
      ELSIF ECOUNT > 1 THEN 
            MSG := 'More than one employee found.' ; 
      ELSE 
            SELECT HIRE_DATE INTO JDATE 
            FROM EMPLOYEES 
            WHERE EMPLOYEE_ID = EID ; 
            YEARS :=  (MONTHS_BETWEEN(SYSDATE, JDATE) / 12) ; 
            IF YEARS >= 10 THEN              
                  MSG := 'The employee worked 10 years or more' ; 
            ELSE 
                  MSG := 'The employee worked less than 10 years' ; 
            END IF ; 
      END IF ; 
      RETURN MSG ; 
END ; 
/ 

-- CREATE OR REPLACE TRIGGER <TRIGGER_NAME>  
-- (BEFORE | AFTER) (INSERT | UPDATE | DELETE)  
-- [OF <COLUMN_NAME>] 
-- ON <TABLE_NAME> 
-- [FOR EACH ROW] 
-- [WHEN <CONDITION>] 
-- DECLARE 
--  Declaration1 ; 
--  Declaration2 ; 
--  ... ; 
-- BEGIN 
--  Statement1 ; 
--  Statement2 ; 
--  ... ; 
-- EXCEPTION 
--  Exception handing codes ; 
-- END ; 
-- /

CREATE TABLE STUDENTS( 
STUDENT_NAME VARCHAR2(250), 
CGPA NUMBER 
) ;

CREATE OR REPLACE TRIGGER HELLO_WORLD 
AFTER INSERT 
ON STUDENTS 
DECLARE 
BEGIN 
 DBMS_OUTPUT.PUT_LINE('Hello World'); 
END ; 
/

INSERT INTO STUDENTS VALUES ('Fahim Hasan', 3.71);  
INSERT INTO STUDENTS VALUES ('Ahmed Nahiyan', 3.80);

CREATE OR REPLACE TRIGGER HELLO_WORLD2
BEFORE INSERT 
ON STUDENTS 
DECLARE 
BEGIN
      DBMS_OUTPUT.PUT_LINE('Hello World2');
END;
/

INSERT INTO STUDENTS VALUES ('Fahim Hasan', 3.71);

CREATE OR REPLACE TRIGGER HELLO_WORLD5 
AFTER UPDATE 
OF CGPA
ON STUDENTS 
FOR EACH ROW 
DECLARE 
BEGIN 
 DBMS_OUTPUT.PUT_LINE('Hello World5'); 
END ; 
/

CREATE OR REPLACE TRIGGER HELLO_WORLD4 
AFTER UPDATE 
OF CGPA 
ON STUDENTS 
DECLARE 
BEGIN 
 DBMS_OUTPUT.PUT_LINE('Hello World4'); 
END ; 
/

CREATE OR REPLACE TRIGGER HELLO_WORLD3 
AFTER INSERT OR DELETE 
ON STUDENTS 
DECLARE 
BEGIN 
 DBMS_OUTPUT.PUT_LINE('Hello World3'); 
END ; 
/

INSERT INTO STUDENTS VALUES ('Shakib Ahmed', 3.63); 
--This will run HELLO_WORLD, HELLO_WORLD2, HELLO_WORLD3 
 
DELETE FROM STUDENTS WHERE CGPA < 3.65 ; 
--This will run HELLO_WOLRD3 
 
UPDATE STUDENTS SET CGPA = CGPA + 0.01 WHERE STUDENT_NAME LIKE '%Shakib%';  
--This will run HELLO_WORLD4, but will not run HELLO_WORLD5!!! Why? Because 
--HELLO_WORLD5 is declared with FOR EACH ROW clause. This means trigger should be 
--run for each row affected. Since, the above statement does not update any row 
--(as the previous DELETE operation already deleted that row from the table)  
--it will not run HELLO_WORLD5! 
 
UPDATE STUDENTS SET STUDENT_NAME = 'Fahim Ahmed' 
WHERE STUDENT_NAME = 'Fahim Hasan' ; 
--This will not run any trigger. Although HELLO_TRIGGER4 is declared to be run 
--after an update operation, the trigger will not run because the update is done 
--on the column STUDENT_NAME rather than CGPA 
 
UPDATE STUDENTS SET CGPA = CGPA + 0.01 ; 
--This will run both HELLO_WORLD4 and HELLO_WORLD5 trigger. However, HELLO_WORLD5 
--will run twice! Why? Because two rows will be affected by the SQL statement!

--problem 1
CREATE TABLE LOG_TABLE_CGPA_UPDATE 
( 
USERNAME VARCHAR2(25), 
DATETIME DATE 
) 

CREATE OR REPLACE TRIGGER LOG_CGPA_UPDATE 
AFTER UPDATE  
OF CGPA 
ON STUDENTS 
DECLARE 
      USERNAME VARCHAR2(25);
BEGIN 
      USERNAME := USER; --USER is a function that returns current username 
      INSERT INTO LOG_TABLE_CGPA_UPDATE VALUES (USERNAME, SYSDATE); 
END ; 
/ 

--First update 
UPDATE STUDENTS SET CGPA = CGPA + 0.01 ; 
 
--Another update 
UPDATE STUDENTS SET CGPA = CGPA - 0.01 ; 
 
--View the rows inserted by the trigger 
SELECT * FROM LOG_TABLE_CGPA_UPDATE;

-- Problem Example 2

CREATE TABLE STUDENTS_DELETED( 
STUDENT_NAME VARCHAR2(25), 
CGPA NUMBER, 
USERNAME VARCHAR2(25), 
DATETIME DATE 
) ;

CREATE OR REPLACE TRIGGER BACKUP_DELETED_STUDENTS 
BEFORE DELETE 
ON STUDENTS 
FOR EACH ROW 
DECLARE 
 V_NAME VARCHAR2(25); 
 V_USERNAME VARCHAR2(25); 
 V_CGPA NUMBER; 
 V_DATETIME DATE; 
BEGIN 
 V_NAME := :OLD.STUDENT_NAME ; 
 V_CGPA := :OLD.CGPA ; 
 V_USERNAME := USER ; 
 V_DATETIME := SYSDATE ; 
 INSERT INTO STUDENTS_DELETED VALUES (V_NAME,V_CGPA,V_USERNAME,V_DATETIME); 
END ; 
/

--Delete the two rows 
DELETE FROM STUDENTS WHERE CGPA < 3.85 ; 
 
--View the rows inserted by the trigger
SELECT * FROM STUDENTS_DELETED ;

CREATE OR REPLACE TRIGGER OLD_NEW_TEST 
BEFORE INSERT OR UPDATE OR DELETE 
ON STUDENTS 
FOR EACH ROW 
DECLARE 
BEGIN 
 DBMS_OUTPUT.PUT_LINE(':OLD.CGPA = ' || :OLD.CGPA) ; 
 DBMS_OUTPUT.PUT_LINE(':NEW.CGPA = ' || :NEW.CGPA) ; 
END ; 
/ 
 
--Issue the following SQL statements and view the dbms outputs 
INSERT INTO STUDENTS VALUES ('SOUMIK SARKAR', 3.85); 
 
UPDATE STUDENTS SET CGPA = CGPA + 0.02 ; 
 
DELETE FROM STUDENTS WHERE CGPA < 3.90; 

-- Problem Example 3

CREATE OR REPLACE TRIGGER CORRECT_STUDENT_NAME 
BEFORE INSERT 
ON STUDENTS 
FOR EACH ROW 
DECLARE 
BEGIN 
 :NEW.STUDENT_NAME := INITCAP(:NEW.STUDENT_NAME) ; 
END ; 
/ 
 
--Issue the following SQL statements and then view the rows of STUDENTS table 
INSERT INTO STUDENTS VALUES ('SHAkil ahMED', 3.80); 
 
INSERT INTO STUDENTS VALUES ('masum billah', 3.60);

select * from STUDENTS ;

DROP TRIGGER OLD_NEW_TEST ;

-- a. In Oracle, there is a function TO_NUMBER that converts a VARCHAR2 value to a numeric 
-- value.  If the input to this function is not a valid number, then this function throws an exception. 
-- This is a problem in a SQL query because the whole query would not produce any result if one 
-- row  generates  an  exception.  So,  your  job  is  to  write  a  PL/SQL  function  ISNUMBER  that 
-- receives an input VARCHAR2 value and checks whether the input can be converted to a valid 
-- number. If the input can be converted to a valid number than ISNUMBER should return ‘YES’, 
-- otherwise ISNUMBER should return ‘NO’.

CREATE OR REPLACE FUNCTION ISNUMBER(STR IN VARCHAR2)
RETURN VARCHAR2 IS 
      V_NUM NUMBER;
BEGIN
      V_NUM := TO_NUMBER(STR); --try to convert the input string to a number 
      RETURN 'YES'; --if conversion is successful, return YES
EXCEPTION
      WHEN OTHERS THEN 
            RETURN 'NO'; --if any exception occurs, return NO
END;
/

-- b. Write a trigger HELLO_WORLD6 that will run after a deletion operation on the STUDENTS 
-- table. The trigger should be a ROW LEVEL trigger.

CREATE OR REPLACE TRIGGER HELLO_WORLD6
AFTER DELETE
ON STUDENTS
FOR EACH ROW
DECLARE
BEGIN
      DBMS_OUTPUT.PUT_LINE('Hello World6');
END;
/

-- c. Write down a PL/SQL trigger on STUDENTS table. The trigger will ensure that whenever a 
-- new row is inserted in the STUDENTS table, the name of the student contains only alphabetic 
-- characters. Name your trigger INVALID_NAME. If the name is valid, then insertion should 
-- be allowed. However, if the name is invalid, then insertion should be denied. To deny insertion, 
-- you can throw an exception from the trigger that would halt the insertion operation.

CREATE OR REPLACE TRIGGER INVALID_NAME
BEFORE INSERT
ON STUDENTS
FOR EACH ROW
DECLARE
      V_NAME VARCHAR2(25);
BEGIN
      V_NAME := :NEW.STUDENT_NAME; --get the name of the student being inserted
      --check if the name contains only alphabetic characters using regular expression
      IF NOT REGEXP_LIKE(V_NAME, '^[A-Za-z ]+$') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid name. Name must contain only alphabetic characters.');
      END IF;
END;
/

-- d. Write a  trigger that will save  a  student records in a table  named LOW_CGPA_STUDENTS 
-- which contain only one column to store student’s names. The trigger will work before an update 
-- operation or an insert operation. Whenever the update operation results in a CGPA value less 
-- than  2.0,  the  trigger  will  be  fired  and  the  trigger  will  save  the  students  name  in  the 
-- LOW_CGPA_STUDENTS table. Similarly, when an insert operation inserts a new row with 
-- CGPA less than 2.0, the corresponding row must be saved in the LOW_CGPA_STUDENTS 
-- table.

CREATE TABLE LOW_CGPA_STUDENTS (
      STUDENT_NAME VARCHAR2(25)
);

CREATE OR REPLACE TRIGGER KMS
BEFORE INSERT OR UPDATE ON STUDENTS
FOR EACH ROW
BEGIN
    -- Check the new CGPA value
    IF :NEW.CGPA < 2.0 THEN
        INSERT INTO LOW_CGPA_STUDENTS (STUDENT_NAME)
        VALUES (:NEW.STUDENT_NAME);
    END IF;
END;
/
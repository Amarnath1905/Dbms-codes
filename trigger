16)
Trigger

Write a after trigger for Insert, update and delete event considering following requirement:
Emp(Emp_no, Emp_name, Emp_salary)
Trigger should be initiated when salary tried to be inserted is less than Rs.50,000/-
Trigger should be initiated when salary tried to be updated for value less than Rs. 50,000/-
Also the new values expected to be inserted will be stored in new table Tracking(Emp_no,Emp_salary).
-- Employee table
CREATE TABLE Emp (
    Emp_no NUMBER PRIMARY KEY,
    Emp_name VARCHAR2(50),
    Emp_salary NUMBER
);

-- Tracking table to store low salary attempts
CREATE TABLE Tracking (
    Emp_no NUMBER,
    Emp_salary NUMBER
);

CREATE OR REPLACE TRIGGER trg_salary_check
AFTER INSERT OR UPDATE OR DELETE ON Emp
FOR EACH ROW
BEGIN
    -- For INSERT: check new salary
    IF INSERTING THEN
        IF :NEW.Emp_salary < 50000 THEN
            INSERT INTO Tracking (Emp_no, Emp_salary)
            VALUES (:NEW.Emp_no, :NEW.Emp_salary);
        END IF;
    END IF;

    -- For UPDATE: check new salary
    IF UPDATING THEN
        IF :NEW.Emp_salary < 50000 THEN
            INSERT INTO Tracking (Emp_no, Emp_salary)
            VALUES (:NEW.Emp_no, :NEW.Emp_salary);
        END IF;
    END IF;

    -- For DELETE: optional, just log deleted record
    IF DELETING THEN
        INSERT INTO Tracking (Emp_no, Emp_salary)
        VALUES (:OLD.Emp_no, :OLD.Emp_salary);
    END IF;
END;
/

-- Insert employees
INSERT INTO Emp VALUES (1, 'Alice', 60000);  -- No trigger
INSERT INTO Emp VALUES (2, 'Bob', 45000);    -- Trigger fires
INSERT INTO Emp VALUES (3, 'Charlie', 30000); -- Trigger fires

-- Update employee salary
UPDATE Emp SET Emp_salary = 40000 WHERE Emp_no = 1; -- Trigger fires

-- Delete employee
DELETE FROM Emp WHERE Emp_no = 3; -- Trigger fires

-- Check Tracking table
SELECT * FROM Tracking;
17)
Trigger 
Consider CUSTOMER (ID, Name, Age, Address, Salary) create a row level trigger for the CUSTOMERS table that would fire for INSERT or UPDATE or DELETE operations performed on the CUSTOMERS table. This trigger will display the salary difference between the old values and new values.
CREATE TABLE CUSTOMERS (
    ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50),
    Age NUMBER,
    Address VARCHAR2(100),
    Salary NUMBER
);

-- Optional: table to store salary differences (works in online compilers)
CREATE TABLE SALARY_DIFF (
    ID NUMBER,
    Old_Salary NUMBER,
    New_Salary NUMBER,
    Difference NUMBER,
    Operation VARCHAR2(10)
);
CREATE OR REPLACE TRIGGER trg_salary_diff
AFTER INSERT OR UPDATE OR DELETE ON CUSTOMERS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        -- For INSERT, old salary is null
        INSERT INTO SALARY_DIFF (ID, Old_Salary, New_Salary, Difference, Operation)
        VALUES (:NEW.ID, NULL, :NEW.Salary, :NEW.Salary, 'INSERT');

        -- Optional: Display in console
        DBMS_OUTPUT.PUT_LINE('INSERT: Salary = ' || :NEW.Salary);

    ELSIF UPDATING THEN
        -- For UPDATE, calculate difference
        INSERT INTO SALARY_DIFF (ID, Old_Salary, New_Salary, Difference, Operation)
        VALUES (:NEW.ID, :OLD.Salary, :NEW.Salary, (:NEW.Salary - :OLD.Salary), 'UPDATE');

        DBMS_OUTPUT.PUT_LINE('UPDATE: Old Salary = ' || :OLD.Salary || ', New Salary = ' || :NEW.Salary || 
                             ', Difference = ' || (:NEW.Salary - :OLD.Salary));

    ELSIF DELETING THEN
        -- For DELETE, new salary is null
        INSERT INTO SALARY_DIFF (ID, Old_Salary, New_Salary, Difference, Operation)
        VALUES (:OLD.ID, :OLD.Salary, NULL, -:OLD.Salary, 'DELETE');

        DBMS_OUTPUT.PUT_LINE('DELETE: Old Salary = ' || :OLD.Salary || ', Difference = -' || :OLD.Salary);
    END IF;
END;
/
-- Enable output in SQL Developer
SET SERVEROUTPUT ON;

-- Insert
INSERT INTO CUSTOMERS VALUES (1, 'Alice', 25, 'Pune', 50000);
INSERT INTO CUSTOMERS VALUES (2, 'Bob', 30, 'Mumbai', 60000);

-- Update
UPDATE CUSTOMERS SET Salary = 55000 WHERE ID = 1;

-- Delete
DELETE FROM CUSTOMERS WHERE ID = 2;

-- Check the SALARY_DIFF table
SELECT * FROM SALARY_DIFF ORDER BY ID;


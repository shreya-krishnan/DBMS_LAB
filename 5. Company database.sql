
-- PROGRAM 5: COMPANY DATABASE

DROP DATABASE IF EXISTS company_187;
CREATE DATABASE company_187;
USE company_187;

-- TABLE CREATION

CREATE TABLE Employee (
    ssn VARCHAR(35) PRIMARY KEY,
    name VARCHAR(35) NOT NULL,
    address VARCHAR(255) NOT NULL,
    sex VARCHAR(7) NOT NULL,
    salary INT NOT NULL,
    super_ssn VARCHAR(35),
    d_no INT,
    FOREIGN KEY (super_ssn) REFERENCES Employee(ssn) ON DELETE SET NULL
);

CREATE TABLE Department (
    d_no INT PRIMARY KEY,
    dname VARCHAR(100) NOT NULL,
    mgr_ssn VARCHAR(35),
    mgr_start_date DATE,
    FOREIGN KEY (mgr_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE
);

CREATE TABLE DLocation (
    d_no INT NOT NULL,
    d_loc VARCHAR(100) NOT NULL,
    FOREIGN KEY (d_no) REFERENCES Department(d_no) ON DELETE CASCADE
);

CREATE TABLE Project (
    p_no INT PRIMARY KEY,
    p_name VARCHAR(25) NOT NULL,
    p_loc VARCHAR(25) NOT NULL,
    d_no INT NOT NULL,
    FOREIGN KEY (d_no) REFERENCES Department(d_no) ON DELETE CASCADE
);

CREATE TABLE WorksOn (
    ssn VARCHAR(35) NOT NULL,
    p_no INT NOT NULL,
    hours INT NOT NULL DEFAULT 0,
    FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE,
    FOREIGN KEY (p_no) REFERENCES Project(p_no) ON DELETE CASCADE
);

-- INSERT DATA

INSERT INTO Employee VALUES
("01NB235", "Chandan_Krishna", "Siddartha Nagar, Mysuru", "Male", 1500000, "01NB235", 5),
("01NB354", "Employee_2", "Lakshmipuram, Mysuru", "Female", 1200000, "01NB235", 2),
("02NB254", "Employee_3", "Pune, Maharashtra", "Male", 1000000, "01NB235", 4),
("03NB653", "Employee_4", "Hyderabad, Telangana", "Male", 2500000, "01NB354", 5),
("04NB234", "Employee_5", "JP Nagar, Bengaluru", "Female", 1700000, "01NB354", 1);

INSERT INTO Department VALUES
(001, "Human Resources", "01NB235", "2020-10-21"),
(002, "Quality Assesment", "03NB653", "2020-10-19"),
(003, "System assesment", "04NB234", "2020-10-27"),
(005, "Production", "02NB254", "2020-08-16"),
(004, "Accounts", "01NB354", "2020-09-04");

INSERT INTO DLocation VALUES
(001, "Jaynagar, Bengaluru"),
(002, "Vijaynagar, Mysuru"),
(003, "Chennai, Tamil Nadu"),
(004, "Mumbai, Maharashtra"),
(005, "Kuvempunagar, Mysuru");

INSERT INTO Project VALUES
(241563, "System Testing", "Mumbai, Maharashtra", 004),
(532678, "IOT", "JP Nagar, Bengaluru", 001),
(453723, "Product Optimization", "Hyderabad, Telangana", 005),
(278345, "Yeild Increase", "Kuvempunagar, Mysuru", 005),
(426784, "Product Refinement", "Saraswatipuram, Mysuru", 002);

INSERT INTO WorksOn VALUES
("01NB235", 278345, 5),
("01NB354", 426784, 6),
("04NB234", 532678, 3),
("02NB254", 241563, 3),
("03NB653", 453723, 6);

-- DISPLAY TABLES

SELECT * FROM Employee;
SELECT * FROM Department;
SELECT * FROM DLocation;
SELECT * FROM Project;
SELECT * FROM WorksOn;


-- QUESTION 1:
-- List project numbers for projects involving an employee whose
-- last name is Krishna, either as a worker or as department manager.

SELECT DISTINCT p.p_no, p.p_name, e.name
FROM Project p
JOIN WorksOn w ON p.p_no = w.p_no
JOIN Employee e ON w.ssn = e.ssn
WHERE e.name LIKE "%Krishna%"

UNION

SELECT DISTINCT p.p_no, p.p_name, e.name
FROM Project p
JOIN Department d ON p.d_no = d.d_no
JOIN Employee e ON d.mgr_ssn = e.ssn
WHERE e.name LIKE "%Krishna%";


-- QUESTION 2:
-- Show the resulting salaries if every employee working on the
-- IOT project gets a 10% raise (display the computed salary).

SELECT e.ssn, e.name,
       e.salary AS old_salary,
       e.salary * 1.1 AS new_salary
FROM WorksOn w
JOIN Employee e ON w.ssn = e.ssn
WHERE w.p_no = (
    SELECT p_no
    FROM Project
    WHERE p_name = "IOT"
);


-- QUESTION 3:
-- Find the sum, maximum, minimum and average salaries
-- of employees working in the Accounts department.

SELECT SUM(e.salary) AS sal_sum,
       MAX(e.salary) AS sal_max,
       MIN(e.salary) AS sal_min,
       AVG(e.salary) AS sal_avg
FROM Employee e
JOIN Department d ON e.d_no = d.d_no
WHERE d.dname = "Accounts";


-- QUESTION 4:
-- Retrieve the names of employees working on all projects
-- controlled by department 1.

SELECT e.ssn, e.name, e.d_no
FROM Employee e
WHERE NOT EXISTS (
    SELECT p.p_no
    FROM Project p
    WHERE p.d_no = 1
    AND p.p_no NOT IN (
        SELECT w.p_no
        FROM WorksOn w
        WHERE w.ssn = e.ssn
    )
);


-- QUESTION 5:
-- For each department having more than one employee,
-- retrieve department number and the number of employees
-- earning more than Rs. 600000.

SELECT d.d_no,
       SUM(CASE WHEN e.salary > 600000 THEN 1 ELSE 0 END)
       AS employee_count
FROM Department d
JOIN Employee e ON d.d_no = e.d_no
GROUP BY d.d_no
HAVING COUNT(e.ssn) > 1;


-- QUESTION 6:
-- Create a view displaying employee name, department name
-- and department location.

CREATE VIEW emp_details AS
SELECT e.name, d.dname, dl.d_loc
FROM Employee e
JOIN Department d ON e.d_no = d.d_no
JOIN DLocation dl ON d.d_no = dl.d_no;

SELECT * FROM emp_details;


-- QUESTION 7:
-- Create a trigger to prevent deletion of a project
-- if an employee is currently working on it.

DROP TRIGGER IF EXISTS PreventDelete;

DELIMITER //

CREATE TRIGGER PreventDelete
BEFORE DELETE ON Project
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM WorksOn
        WHERE p_no = OLD.p_no
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'This project has an employee assigned';
    END IF;
END;//

DELIMITER ;

-- This DELETE will generate an error because employees
-- are currently assigned to project 241563.

DELETE FROM Project
WHERE p_no = 241563;


-- PROGRAM 2: INSURANCE DATABASE

DROP DATABASE IF EXISTS insurance_187;
CREATE DATABASE insurance_187;
USE insurance_187;

-- TABLE CREATION

CREATE TABLE person (
    driver_id VARCHAR(255) NOT NULL,
    driver_name TEXT NOT NULL,
    address TEXT NOT NULL,
    PRIMARY KEY (driver_id)
);

CREATE TABLE car (
    reg_no VARCHAR(255) NOT NULL,
    model TEXT NOT NULL,
    c_year INTEGER,
    PRIMARY KEY (reg_no)
);

CREATE TABLE accident (
    report_no INTEGER NOT NULL,
    accident_date DATE,
    location TEXT,
    PRIMARY KEY (report_no)
);

CREATE TABLE owns (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE participated (
    driver_id VARCHAR(255) NOT NULL,
    reg_no VARCHAR(255) NOT NULL,
    report_no INTEGER NOT NULL,
    damage_amount FLOAT NOT NULL,
    FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
    FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
    FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

-- INSERT DATA

INSERT INTO person VALUES
("D111", "Driver_1", "Kuvempunagar, Mysuru"),
("D222", "Smith", "JP Nagar, Mysuru"),
("D333", "Driver_3", "Udaygiri, Mysuru"),
("D444", "Driver_4", "Rajivnagar, Mysuru"),
("D555", "Driver_5", "Vijayanagar, Mysore");

INSERT INTO car VALUES
("KA-20-AB-4223", "Swift", 2020),
("KA-20-BC-5674", "Mazda", 2017),
("KA-21-AC-5473", "Alto", 2015),
("KA-21-BD-4728", "Triber", 2019),
("KA-09-MA-1234", "Tiago", 2018);

INSERT INTO accident VALUES
(43627, "2020-04-05", "Nazarbad, Mysuru"),
(56345, "2019-12-16", "Gokulam, Mysuru"),
(63744, "2020-05-14", "Vijaynagar, Mysuru"),
(54634, "2019-08-30", "Kuvempunagar, Mysuru"),
(65738, "2021-01-21", "JSS Layout, Mysuru"),
(66666, "2021-01-21", "JSS Layout, Mysuru");

INSERT INTO owns VALUES
("D111", "KA-20-AB-4223"),
("D222", "KA-20-BC-5674"),
("D333", "KA-21-AC-5473"),
("D444", "KA-21-BD-4728"),
("D222", "KA-09-MA-1234");

INSERT INTO participated VALUES
("D111", "KA-20-AB-4223", 43627, 20000),
("D222", "KA-20-BC-5674", 56345, 49500),
("D333", "KA-21-AC-5473", 63744, 15000),
("D444", "KA-21-BD-4728", 54634, 5000),
("D222", "KA-09-MA-1234", 65738, 25000);

-- DISPLAY TABLES

SELECT * FROM person;
SELECT * FROM car;
SELECT * FROM accident;
SELECT * FROM owns;
SELECT * FROM participated;


-- QUESTION 1:
-- Find the total number of people who owned a car involved in accidents in 2021.

SELECT COUNT(driver_id)
FROM participated p, accident a
WHERE p.report_no = a.report_no
AND a.accident_date LIKE "2021%";


-- QUESTION 2:
-- Find the number of accidents in which cars belonging to Smith were involved.

SELECT COUNT(DISTINCT a.report_no)
FROM accident a
WHERE EXISTS (
    SELECT *
    FROM person p, participated ptd
    WHERE p.driver_id = ptd.driver_id
    AND p.driver_name = "Smith"
    AND a.report_no = ptd.report_no
);


-- QUESTION 3:
-- Add a new accident and record the car's participation.

INSERT INTO accident VALUES
(45562, "2024-04-05", "Mandya");

INSERT INTO participated VALUES
("D222", "KA-21-BD-4728", 45562, 50000);

SELECT * FROM accident;
SELECT * FROM participated;


-- QUESTION 4:
-- Delete the Mazda car belonging to Smith.

DELETE c
FROM car c
JOIN owns o ON c.reg_no = o.reg_no
JOIN person p ON o.driver_id = p.driver_id
WHERE c.model = "Mazda"
AND p.driver_name = "Smith";

SELECT * FROM car;
SELECT * FROM owns;
SELECT * FROM participated;


-- QUESTION 5:
-- Update the damage amount for car KA-09-MA-1234
-- in report number 65738 to 10000.

UPDATE participated
SET damage_amount = 10000
WHERE report_no = 65738
AND reg_no = "KA-09-MA-1234";

SELECT * FROM participated;


-- QUESTION 6:
-- Create a view displaying the model and year of cars involved in accidents.

CREATE VIEW CarsInAccident AS
SELECT DISTINCT model, c_year
FROM car c, participated p
WHERE c.reg_no = p.reg_no;

SELECT * FROM CarsInAccident;


-- QUESTION 7:
-- Create a trigger to prevent a driver from participating
-- in more than 2 accidents in a given year.

DROP TRIGGER IF EXISTS PreventParticipation;

DELIMITER //

CREATE TRIGGER PreventParticipation
BEFORE INSERT ON participated
FOR EACH ROW
BEGIN
    DECLARE accident_year INT;
    DECLARE accident_count INT;

    SELECT YEAR(accident_date)
    INTO accident_year
    FROM accident
    WHERE report_no = NEW.report_no;

    SELECT COUNT(*)
    INTO accident_count
    FROM participated p
    JOIN accident a ON p.report_no = a.report_no
    WHERE p.driver_id = NEW.driver_id
    AND YEAR(a.accident_date) = accident_year;

    IF accident_count >= 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver has already participated in 2 accidents in this year';
    END IF;
END;//

DELIMITER ;

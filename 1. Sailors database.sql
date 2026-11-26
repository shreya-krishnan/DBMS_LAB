
-- PROGRAM 1: SAILORS DATABASE

DROP DATABASE IF EXISTS sailors_187;
CREATE DATABASE sailors_187;
USE sailors_187;

-- TABLE CREATION

CREATE TABLE Sailors (
    sid INT PRIMARY KEY,
    sname VARCHAR(35) NOT NULL,
    rating FLOAT NOT NULL,
    age INT NOT NULL
);

CREATE TABLE Boat (
    bid INT PRIMARY KEY,
    bname VARCHAR(35) NOT NULL,
    color VARCHAR(25) NOT NULL
);

CREATE TABLE reserves (
    sid INT NOT NULL,
    bid INT NOT NULL,
    sdate DATE NOT NULL,
    FOREIGN KEY (sid) REFERENCES Sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES Boat(bid) ON DELETE CASCADE
);

-- INSERT DATA

INSERT INTO Sailors VALUES
(1, "Albert", 5.0, 40),
(2, "Nakul", 5.0, 49),
(3, "Darshan", 9, 18),
(4, "Astorm Gowda", 2, 68),
(5, "Armstormin", 7, 19);

INSERT INTO Boat VALUES
(1, "Boat_1", "Green"),
(2, "Boat_2", "Red"),
(103, "Boat_3", "Blue"),
(104, "Boat_4", "Pink");

INSERT INTO reserves VALUES
(1, 103, "2023-01-01"),
(1, 2, "2023-02-01"),
(2, 1, "2023-02-05"),
(3, 2, "2023-03-06"),
(5, 103, "2023-03-06"),
(1, 1, "2023-03-06"),
(1, 104, "2023-12-12");

-- DISPLAY TABLES

SELECT * FROM Sailors;
SELECT * FROM Boat;
SELECT * FROM reserves;


-- QUESTION 1:
-- Find the colours of the boats reserved by Albert.

SELECT color
FROM Sailors s, Boat b, reserves r
WHERE s.sid = r.sid
AND b.bid = r.bid
AND s.sname = "Albert";


-- QUESTION 2:
-- Find all sailor SIDs who have rating at least 8
-- OR have reserved boat 103.

(SELECT sid
FROM Sailors
WHERE rating >= 8)

UNION

(SELECT sid
FROM reserves
WHERE bid = 103);


-- QUESTION 3:
-- Find the names of sailors who have NOT reserved a boat
-- whose name contains the string "storm".
-- Order the names in ascending order.

SELECT s.sname
FROM Sailors s
WHERE NOT EXISTS (
    SELECT *
    FROM reserves r
    JOIN Boat b ON r.bid = b.bid
    WHERE r.sid = s.sid
    AND b.bname LIKE "%storm%"
)
ORDER BY s.sname ASC;


-- QUESTION 4:
-- Find the names of sailors who have reserved all boats.

SELECT s.sname
FROM Sailors s
WHERE NOT EXISTS (
    SELECT *
    FROM Boat b
    WHERE NOT EXISTS (
        SELECT *
        FROM reserves r
        WHERE r.sid = s.sid
        AND r.bid = b.bid
    )
);


-- QUESTION 5:
-- Find the name and age of the oldest sailor.

SELECT sname, age
FROM Sailors
WHERE age IN (
    SELECT MAX(age)
    FROM Sailors
);


-- QUESTION 6:
-- For each boat reserved by at least 2 sailors aged 40 or above,
-- find the boat ID and average age of those sailors.

SELECT b.bid, AVG(s.age) AS average_age
FROM Sailors s, Boat b, reserves r
WHERE r.sid = s.sid
AND r.bid = b.bid
AND s.age >= 40
GROUP BY b.bid
HAVING COUNT(DISTINCT r.sid) >= 2;


-- QUESTION 7:
-- Create a view showing the names and colours of boats
-- reserved by sailors with a specific rating (rating = 5).

CREATE VIEW ReservedBoatsWithRatedSailor AS
SELECT DISTINCT b.bname, b.color
FROM Sailors s, Boat b, reserves r
WHERE s.sid = r.sid
AND b.bid = r.bid
AND s.rating = 5;

SELECT * FROM ReservedBoatsWithRatedSailor;


-- QUESTION 8:
-- Create a trigger that prevents boats from being deleted
-- if they have active reservations.

DROP TRIGGER IF EXISTS CheckAndDelete;

DELIMITER //

CREATE TRIGGER CheckAndDelete
BEFORE DELETE ON Boat
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT *
        FROM reserves
        WHERE reserves.bid = OLD.bid
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Boat is reserved and hence cannot be deleted';
    END IF;
END;//

DELIMITER ;

-- This DELETE will generate an error because boat 103 is reserved.

DELETE FROM Boat
WHERE bid = 103;

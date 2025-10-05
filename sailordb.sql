-- Create SAILORS table
CREATE TABLE SAILORS (
    sid INT PRIMARY KEY,
    sname VARCHAR(50),
    rating INT,
    age INT
);

-- Create BOAT table
CREATE TABLE BOAT (
    bid INT PRIMARY KEY,
    bname VARCHAR(50),
    color VARCHAR(50)
);


-- Create RESERVES table
CREATE TABLE RESERVES (
    sid INT,
    bid INT,
    date DATE,
    FOREIGN KEY (sid) REFERENCES SAILORS(sid),
    FOREIGN KEY (bid) REFERENCES BOAT(bid)
);


-- Queries with Relational Algebra

-- 1. Find the colors of boats reserved by Albert
SELECT DISTINCT b.color
FROM BOAT b
JOIN RESERVES r ON b.bid = r.bid
JOIN SAILORS s ON r.sid = s.sid
WHERE s.sname = 'Albert';

-- Relational Algebra:
-- π color (σ sname='Albert' (SAILORS ⨝ RESERVES ⨝ BOAT))

-- 2. Find all sailor IDs who have a rating of at least 8 or reserved boat 103
SELECT DISTINCT s.sid
FROM SAILORS s
LEFT JOIN RESERVES r ON s.sid = r.sid
WHERE s.rating >= 8 OR r.bid = 103;

-- Relational Algebra:
-- π sid (σ rating >= 8 (SAILORS) ∪ π sid (σ bid=103 (RESERVES)))

-- 3. Find the names of sailors who have not reserved a boat with "storm" in its name, ordered ASC
SELECT s.sname
FROM SAILORS s
WHERE s.sid NOT IN (
    SELECT r.sid 
    FROM RESERVES r 
    JOIN BOAT b ON r.bid = b.bid 
    WHERE b.bname LIKE '%storm%'
)
ORDER BY s.sname ASC;

-- Relational Algebra:
-- π sname (SAILORS) - π sname (SAILORS ⨝ RESERVES ⨝ σ bname LIKE '%storm%' (BOAT))

-- 4. Find sailors who have reserved all boats
SELECT s.sname
FROM SAILORS s
WHERE NOT EXISTS (
    SELECT b.bid FROM BOAT b
    WHERE NOT EXISTS (
        SELECT r.bid FROM RESERVES r WHERE r.sid = s.sid AND r.bid = b.bid
    )
);

-- Relational Algebra:
-- π sname (σ ∀bid∈BOAT (bid∈RESERVES) (SAILORS ⨝ RESERVES))

-- 5. Find the name and age of the oldest sailor
SELECT sname, age
FROM SAILORS
ORDER BY age DESC
LIMIT 1;

-- Relational Algebra:
-- π sname, age (σ age = MAX(age) (SAILORS))

-- 6. Find boats reserved by at least 5 sailors aged >= 40, with average age
SELECT r.bid AS BOAT_id, AVG(s.age) AS avg_age
FROM RESERVES r
JOIN SAILORS s ON r.sid = s.sid
WHERE s.age >= 40
GROUP BY r.bid
HAVING COUNT(DISTINCT r.sid) >= 5;

-- Relational Algebra:
-- π bid, AVG(age) (σ age >= 40 (SAILORS ⨝ RESERVES) GROUP BY bid HAVING COUNT(sid) >= 5)

-- 7. Create a view showing boats reserved by sailors of a specific rating
CREATE OR REPLACE VIEW ReservedBoatsByRating AS
SELECT DISTINCT s.sname AS sailor_name, b.bname AS boat_name, b.color
FROM SAILORS s
JOIN RESERVES r ON s.sid = r.sid
JOIN BOAT b ON r.bid = b.bid
WHERE s.rating = 8;

-- Relational Algebra:
-- π sname, bname, color (σ rating=8 (SAILORS ⨝ RESERVES ⨝ BOAT))

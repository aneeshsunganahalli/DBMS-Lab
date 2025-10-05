CREATE TABLE IF NOT EXISTS person (
driver_id VARCHAR(255) NOT NULL,
driver_name TEXT NOT NULL,
address TEXT NOT NULL,
PRIMARY KEY (driver_id)
);

CREATE TABLE IF NOT EXISTS car (
reg_no VARCHAR(255) NOT NULL,
model TEXT NOT NULL,
c_year INTEGER,
PRIMARY KEY (reg_no)
);

CREATE TABLE IF NOT EXISTS accident (
report_no INTEGER NOT NULL,
accident_date DATE,
location TEXT,
PRIMARY KEY (report_no)
);

CREATE TABLE IF NOT EXISTS owns (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS participated (
driver_id VARCHAR(255) NOT NULL,
reg_no VARCHAR(255) NOT NULL,
report_no INTEGER NOT NULL,
damage_amount FLOAT NOT NULL,
FOREIGN KEY (driver_id) REFERENCES person(driver_id) ON DELETE CASCADE,
FOREIGN KEY (reg_no) REFERENCES car(reg_no) ON DELETE CASCADE,
FOREIGN KEY (report_no) REFERENCES accident(report_no)
);

-- 1. Find the total number of people who owned cars that were involved in accidents in 2021.
-- Relational Algebra: 
-- π count(*) (σ accident_date>='2021-01-01' ∧ accident_date<='2021-12-31' (accident ⋈ participated))
SELECT COUNT(*) FROM accident JOIN participated USING(report_no)
 WHERE accident_date>='2021-01-01' AND accident_date<='2021-12-31';
 
-- 2. Find the number of accidents in which cars belonging to "Smith" were involved.
-- Relational Algebra:
-- π count(*) (σ driver_name='Smith' (accident ⋈ participated ⋈ person))
SELECT COUNT(*) FROM accident JOIN participated USING(report_no) 
JOIN person USING(driver_id) WHERE person.driver_name='Smith';

-- 3. Add a new accident to the database
-- (This is an insertion operation, no relational algebra expression needed)

-- 4. Delete the Mazda belonging to "Smith"
-- Relational Algebra for the subquery:
-- π reg_no (σ model='Mazda' ∧ driver_name='Smith' (car ⋈ owns ⋈ person))
DELETE FROM CAR WHERE
model='Mazda' AND reg_no IN 
(SELECT reg_no FROM OWNS JOIN PERSON USING(driver_id) 
WHERE driver_name='Smith');

-- 5. Update damage amount
-- (This is an update operation, no relational algebra expression needed)

-- 6. View of car models in accidents
-- Relational Algebra:
-- π DISTINCT model, c_year (car ⋈ participated)
CREATE OR REPLACE VIEW AccidentCars AS
SELECT DISTINCT model, c_year
FROM car JOIN participated USING(reg_no);

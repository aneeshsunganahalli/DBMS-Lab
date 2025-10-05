-- Create table STUDENT
CREATE TABLE STUDENT (
    regno VARCHAR(40) PRIMARY KEY,
    name VARCHAR(100),
    major VARCHAR(100),
    bdate DATE
);

-- Create table COURSE
CREATE TABLE COURSE (
    course INT PRIMARY KEY,
    cname VARCHAR(100),
    dept VARCHAR(100)
);


-- Create table ENROLL
CREATE TABLE ENROLL (
    regno VARCHAR(40),
    course INT,
    sem INT,
    marks INT,
    FOREIGN KEY (regno) REFERENCES STUDENT(regno) ON DELETE CASCADE,
    FOREIGN KEY (course) REFERENCES COURSE(course) ON DELETE CASCADE
);

-- CREATE table TEXT
CREATE TABLE TEXT (
    book_ISBN INT PRIMARY KEY,
    title VARCHAR(100),
    publisher VARCHAR(100),
    author VARCHAR(100)
);

-- Create table BOOK_ADOPTION
CREATE TABLE BOOK_ADOPTION (
    course INT,
    sem INT,
    book_ISBN INT,
    FOREIGN KEY (course) REFERENCES COURSE(course)  ON DELETE CASCADE,
    FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)  ON DELETE CASCADE
);

-- 2. Produce a list of text books for CS department courses with more than two books
-- Relational Algebra:
-- π course, book_ISBN, title (
--   σ dept='CS' ∧ course ∈ (π course (γ course, COUNT(*) AS book_count (BOOK_ADOPTION) σ book_count > 2)) (
--     BOOK_ADOPTION ⋈ COURSE ⋈ TEXT
--   )
-- )

SELECT course, book_ISBN, title
FROM BOOK_ADOPTION 
JOIN COURSE USING(course) 
JOIN TEXT USING(book_ISBN) 
WHERE dept="CS" 
AND course IN (
    SELECT course
    FROM BOOK_ADOPTION 
    GROUP BY course
    HAVING COUNT(*) > 2
)
ORDER BY title;

-- 3. List departments with all books from a specific publisher
-- Relational Algebra:
-- π dept (COURSE) - π dept (
--   σ publisher≠'Delphi Classics' (
--     COURSE ⋈ BOOK_ADOPTION ⋈ TEXT
--   )
-- )

SELECT DISTINCT dept FROM
COURSE WHERE dept IN(
    SELECT dept FROM COURSE JOIN BOOK_ADOPTION 
    USING(course) JOIN TEXT USING(book_ISBN) 
    WHERE publisher='Delphi Classics'
)
AND 
dept NOT IN(
    SELECT dept FROM COURSE JOIN BOOK_ADOPTION 
    USING(course) JOIN TEXT USING(book_ISBN) 
    WHERE publisher != 'Delphi Classics'
);

-- 4. List students with maximum marks in DBMS
-- Relational Algebra:
-- π S.regno, S.name, E.marks (
--   σ C.cname='DBMS' ∧ E.marks = max(marks) (
--     STUDENT(S) ⋈ ENROLL(E) ⋈ COURSE(C)
--   )
-- )

SELECT S.regno, S.name, E.marks
FROM STUDENT S
JOIN ENROLL E ON S.regno = E.regno
JOIN COURSE C ON E.course = C.course
WHERE C.cname = 'DBMS'
ORDER BY E.marks DESC
LIMIT 1;

-- 5. Create view for student courses with marks
-- Relational Algebra:
-- π regno, course, cname, marks (
--   ENROLL ⋈ COURSE
-- )

CREATE OR REPLACE VIEW StudentCourses AS
SELECT regno, course, cname, marks
FROM ENROLL 
JOIN COURSE USING(course);

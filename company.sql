-- Create the EMPLOYEE table
CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY, -- Social Security Number of the employee
    EName VARCHAR(100), 
    Address VARCHAR(100),
    Sex VARCHAR(10),
    Salary DECIMAL(10, 2),
    SuperSSN INT,
    DNo INT
);


-- Create the DEPARTMENT table
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY, -- Department number
    DName VARCHAR(100),
    MgrSSN INT,  -- Department manager in
    MgrStartDate DATE,  -- date when manager started the department.
    FOREIGN KEY (MgrSSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE
);


-- Create the DLOCATION table
CREATE TABLE DLOCATION (
    DNo INT PRIMARY KEY,
    DLoc VARCHAR(200), -- department location
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

-- Create the PROJECT table
CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY, -- project number
    PName VARCHAR(50),  -- project name
    PLocation VARCHAR(100), -- project location
    DNo INT,  
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo) ON DELETE CASCADE
);

-- Create the WORKS_ON table
CREATE TABLE WORKS_ON (
    SSN INT,
    PNo INT,
    Hours DECIMAL(6, 2), -- number of hours the employee works on the project
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE,
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo) ON DELETE CASCADE
);


-- 1. Make a list of all project numbers for projects that involve an employee whose last name 
-- is 'Scott', either as a worker or as a manager of the department that controls the project.  
-- Relational Algebra:
-- π[PNo, PName](σ[DNo IN (π[DNo](σ[EName LIKE '%Scott%'](EMPLOYEE))] OR 
-- DNo IN (π[DNo](σ[MgrSSN IN (π[SSN](σ[EName LIKE '%Scott%'](EMPLOYEE))]](DEPARTMENT))](PROJECT))

SELECT DISTINCT P.PNo, P.PName
FROM PROJECT P, DEPARTMENT D, EMPLOYEE E
WHERE (P.DNo IN (SELECT E1.DNo 
                 FROM EMPLOYEE E1 
                 WHERE E1.EName LIKE '%Scott%')
OR P.DNo IN (SELECT D1.DNo 
             FROM DEPARTMENT D1 
             WHERE D1.MgrSSN IN (SELECT E2.SSN 
                                FROM EMPLOYEE E2 
                                WHERE E2.EName LIKE '%Scott%')));

-- 2. Show the resulting salaries if every employee working on the 'IoT' project is given a 10 percent raise.
-- Relational Algebra:
-- π[SSN, EName, Salary](σ[SSN IN (π[SSN](σ[PNo IN (π[PNo](σ[PName='IoT'](PROJECT))]](WORKS_ON))]](EMPLOYEE))

SELECT E.SSN, E.EName, E.Salary * 1.1 AS Updated_Salary
FROM EMPLOYEE E, WORKS_ON W, PROJECT P
WHERE E.SSN = W.SSN AND W.PNo = P.PNo AND P.PName = 'IoT';

-- 3. Find the sum of the salaries of all employees of the 'Accounts' department
-- Relational Algebra:
-- ℱ[SUM(Salary), MAX(Salary), MIN(Salary), AVG(Salary)](σ[DName='Accounts'](EMPLOYEE ⋈[E.DNo = D.DNo] DEPARTMENT))

SELECT SUM(E.Salary) AS Total_Salary, MAX(E.Salary) AS Max_Salary,
       MIN(E.Salary) AS Min_Salary, AVG(E.Salary) AS Avg_Salary
FROM EMPLOYEE E, DEPARTMENT D
WHERE E.DNo = D.DNo AND D.DName = 'Accounts';

-- 4. Retrieve the name of each employee who works on all the projects controlled by department number 5
-- Relational Algebra:
-- π[EName](EMPLOYEE) - π[EName](
--   (π[SSN, EName](EMPLOYEE) × π[PNo](σ[DNo=5](PROJECT))) - 
--   π[SSN, EName, PNo](EMPLOYEE ⋈ WORKS_ON)
-- )

SELECT E.EName
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT P.PNo
    FROM PROJECT P
    WHERE P.DNo = 5
    AND NOT EXISTS (
        SELECT W.PNo
        FROM WORKS_ON W
        WHERE W.SSN = E.SSN AND W.PNo = P.PNo
    )
);

-- 5. For each department that has more than five employees, retrieve the department number and employees with salary > 600000
-- Relational Algebra:
-- ℱ[DNo, COUNT(SSN)](σ[Salary > 600000](
--   γ[DNo, COUNT(SSN) as emp_count](EMPLOYEE ⋈[E.DNo = D.DNo] DEPARTMENT)
-- )) WHERE emp_count >= 5

SELECT E.DNo, E.EName, E.Salary
FROM EMPLOYEE E
WHERE E.Salary > 600000 AND E.DNo IN (
    SELECT DNo
    FROM EMPLOYEE
    GROUP BY DNo
    HAVING COUNT(*) > 5
);

-- 6. Create a view that shows name, dept name and location of all employees
-- Relational Algebra:
-- π[EName, DName, DLoc](EMPLOYEE ⋈[E.DNo = D.DNo] DEPARTMENT ⋈[D.DNo = DL.DNo] DLOCATION)

CREATE VIEW EMP_DEPT_LOC AS
SELECT E.EName, D.DName, DL.DLoc
FROM EMPLOYEE E, DEPARTMENT D, DLOCATION DL
WHERE E.DNo = D.DNo AND D.DNo = DL.DNo;

CREATE DATABASE Hospital;

USE Hospital;

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Premium MONEY NOT NULL CHECK (Premium >= 0) DEFAULT 0,
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE,
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EndTime TIME NOT NULL,
    StartTime TIME NOT NULL CHECK (StartTime BETWEEN '08:00' AND '18:00'),
    DoctorId INT NOT NULL,
    ExaminationId INT NOT NULL,
    WardId INT NOT NULL,
    FOREIGN KEY (DoctorId) REFERENCES Doctors(Id),
    FOREIGN KEY (ExaminationId) REFERENCES Examinations(Id),
    FOREIGN KEY (WardId) REFERENCES Wards(Id),
    CHECK (EndTime > StartTime)
);

CREATE TABLE Sponsors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Donations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Amount MONEY NOT NULL CHECK (Amount > 0),
    Date DATE NOT NULL CHECK (Date <= GETDATE()) DEFAULT GETDATE(),
    DepartmentId INT NOT NULL,
    SponsorId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
    FOREIGN KEY (SponsorId) REFERENCES Sponsors(Id)
);

-- INSERTING COMMANDS

INSERT INTO Departments (Building, Name)
VALUES
(1, 'Cardiology'),
(1, 'Gastroenterology'),
(2, 'General Surgery'),
(3, 'Microbiology'),
(4, 'Neurology'),
(5, 'Oncology');

INSERT INTO Doctors (Name, Premium, Salary, Surname)
VALUES
('Thomas', 500, 3000, 'Gerada'),
('Anthony', 200, 2500, 'Davis'),
('Joshua', 300, 4000, 'Bell'),
('Emily', 400, 3500, 'Clark'),
('Michael', 100, 2800, 'Brown');

INSERT INTO Examinations (Name)
VALUES
('Blood Test'),
('X-Ray'),
('MRI'),
('Ultrasound'),
('Endoscopy');

INSERT INTO Wards (Name, Places, DepartmentId)
VALUES
('Ward A', 10, 1),
('Ward B', 15, 2),
('Ward C', 20, 3),
('Ward D', 12, 4),
('Ward E', 18, 5);

INSERT INTO DoctorsExaminations (StartTime, EndTime, DoctorId, ExaminationId, WardId)
VALUES
('10:00', '11:00', 1, 1, 1),
('12:00', '13:00', 2, 2, 2),
('14:00', '15:00', 3, 3, 3),
('16:00', '17:00', 4, 4, 4),
('12:30', '13:30', 5, 5, 5);

INSERT INTO Sponsors (Name)
VALUES
('Sponsor A'),
('Sponsor B'),
('Sponsor C'),
('Sponsor D'),
('Sponsor E');

INSERT INTO Donations (Amount, Date, DepartmentId, SponsorId)
VALUES
(1000, '2023-10-01', 1, 1),
(2000, '2023-10-02', 2, 2),
(1500, '2023-10-03', 3, 3),
(500, '2023-10-04', 4, 4),
(3000, '2023-10-05', 5, 5);

-- updating db


-- selecting db


SELECT Name FROM Departments
WHERE Building = (SELECT Building FROM Departments WHERE Name = 'Cardiology');

SELECT Name FROM Departments
WHERE Building IN (SELECT Building FROM Departments WHERE Name IN ('Gastroenterology', 'General Surgery'));

SELECT TOP 1 D.Name FROM Departments D
JOIN Donations DON ON D.Id = DON.DepartmentId
GROUP BY D.Name
ORDER BY SUM(DON.Amount) ASC;


SELECT Surname FROM Doctors
WHERE Salary > (SELECT Salary FROM Doctors WHERE Name = 'Thomas' AND Surname = 'Gerada');

SELECT Name
FROM Wards
WHERE Places > ( 
	SELECT AVG(Places) FROM Wards
    WHERE DepartmentId = (SELECT Id FROM Departments WHERE Name = 'Microbiology')
);

SELECT Name + ' ' + Surname AS FullName
FROM Doctors
WHERE (Salary + Premium) > (
    SELECT (Salary + Premium) + 100 FROM Doctors
    WHERE Name = 'Anthony' AND Surname = 'Davis'
);

SELECT DISTINCT D.Name
FROM Departments D
JOIN Wards W ON D.Id = W.DepartmentId
JOIN DoctorsExaminations DE ON W.Id = DE.WardId
JOIN Doctors Doc ON DE.DoctorId = Doc.Id
WHERE Doc.Name = 'Joshua' AND Doc.Surname = 'Bell';

SELECT S.Name 
FROM Sponsors S
WHERE S.Id NOT IN (
    SELECT DISTINCT D.SponsorId 
    FROM Donations D
    JOIN Departments Dep ON D.DepartmentId = Dep.Id
    WHERE Dep.Name IN ('Neurology', 'Oncology')
);

SELECT DISTINCT d.Surname 
FROM Doctors d
JOIN DoctorsExaminations de ON d.Id = de.DoctorId
WHERE de.StartTime BETWEEN '12:00' AND '15:00';

-- deleting db

DROP TABLE Donations;

DROP TABLE Departments;

DROP TABLE Sponsors;

DROP TABLE DoctorsExaminations;

DROP TABLE Examinations;

DROP TABLE Wards;

DROP TABLE Doctors;



USE MASTER;

DROP DATABASE Hospital;

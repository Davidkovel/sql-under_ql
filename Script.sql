CREATE DATABASE Academy

USE Academy

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CHECK (Name <> '') UNIQUE
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    Name NVARCHAR(100) NOT NULL CHECK (Name <> '') UNIQUE,
    FacultyId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL CHECK (Name <> '') UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL CHECK (Name <> '') UNIQUE
);

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    IsProfessor BIT NOT NULL DEFAULT 0,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL CHECK (Date <= GETDATE()),
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE Students (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Rating INT NOT NULL CHECK (Rating BETWEEN 0 AND 5),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE GroupsStudents (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    StudentId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (StudentId) REFERENCES Students(Id)
);
-- INSERTING COMMANDS

INSERT INTO Faculties (Name) VALUES
('Computer Science'),
('Software Development'),
('Mathematics'),
('Physics');

INSERT INTO Departments (Building, Financing, Name, FacultyId) VALUES
(1, 50000, 'Department of Algorithms', 1),
(2, 120000, 'Department of Software Engineering', 2),
(3, 80000, 'Department of Applied Mathematics', 3),
(4, 90000, 'Department of Quantum Physics', 4);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('D221', 5, 2),
('D222', 5, 2),
('M101', 3, 3),
('P201', 4, 4);

INSERT INTO Curators (Name, Surname) VALUES
('John', 'Doe'),
('Jane', 'Smith'),
('Alice', 'Johnson'),
('Bob', 'Brown');

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1, 1),
(2, 1),
(3, 2),
(4, 3);

INSERT INTO Students (Name, Rating, Surname) VALUES
('Mike', 4, 'Johnson'),
('Anna', 5, 'Williams'),
('Chris', 3, 'Brown'),
('Laura', 4, 'Davis');


INSERT INTO GroupsStudents (GroupId, StudentId) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

INSERT INTO Subjects (Name) VALUES
('Algorithms'),
('Software Engineering'),
('Calculus'),
('Quantum Mechanics');

INSERT INTO Teachers (IsProfessor, Name, Salary, Surname) VALUES
(1, 'Michael', 5000, 'Smith'),
(0, 'Emily', 4000, 'Jones'),
(1, 'David', 6000, 'Wilson'),
(0, 'Sarah', 4500, 'Taylor');

INSERT INTO Lectures (Date, SubjectId, TeacherId) VALUES
('2023-10-01', 1, 1),
('2023-10-02', 2, 2),
('2023-10-03', 3, 3),
('2023-10-04', 4, 4);

INSERT INTO GroupsLectures (GroupId, LectureId) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);


-- selecting db

SELECT Building FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

SELECT G.Name FROM Groups G
INNER JOIN Departments D ON G.DepartmentId = D.Id
INNER JOIN Faculties F ON D.FacultyId = F.Id
WHERE G.Year = 5 AND F.Name = 'Software Development'
AND (SELECT COUNT(*) FROM GroupsLectures GL WHERE GL.GroupId = G.Id) > 10;

SELECT g.Name
FROM Groups g
JOIN GroupsStudents gs ON g.Id = gs.GroupId
JOIN Students s ON gs.StudentId = s.Id
GROUP BY g.Name
HAVING AVG(s.Rating) > (
    SELECT AVG(s.Rating)
    FROM Groups g2
    INNER JOIN GroupsStudents gs2 ON g2.Id = gs2.GroupId
    INNER JOIN Students s ON gs2.StudentId = s.Id
    WHERE g2.Name = 'D221'
);

SELECT Name, Surname FROM Teachers
WHERE Salary > (SELECT AVG(Salary) FROM Teachers WHERE IsProfessor = 1);

SELECT G.Name FROM Groups G
INNER JOIN GroupsCurators GC ON GC.GroupId = G.Id
INNER JOIN Curators C ON GC.CuratorId = C.Id
GROUP BY G.Name
HAVING COUNT(GC.CuratorId) > 1;

WITH GroupRatings AS ( -- DBEAVER DOES NOT SUPPORTS DOUBLE AGR. QUERIES
    SELECT g.Name, AVG(s.Rating) AS AvgRating
    FROM Groups g
    INNER JOIN GroupsStudents gs ON g.Id = gs.GroupId
    INNER JOIN Students s ON gs.StudentId = s.Id
    GROUP BY g.Name
)
SELECT gr.Name
FROM GroupRatings gr
WHERE gr.AvgRating < (
    SELECT MIN(AvgRating)
    FROM GroupRatings
    WHERE gr.Name IN (
        SELECT g.Name
        FROM Groups g
        WHERE g.Year = 5
    )
);

-- 7 TASK

SELECT f.Name
FROM Faculties f
INNER JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Name
HAVING SUM(d.Financing) > (
    SELECT SUM(d.Financing)
    FROM Departments d
    JOIN Faculties f ON d.FacultyId = f.Id
    WHERE f.Name = 'Computer Science'
);

SELECT s.Name AS SubjectName, t.Name + ' ' + t.Surname AS TeacherName
FROM Lectures l
INNER JOIN Subjects s ON l.SubjectId = s.Id
INNER JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY s.Name, t.Name, t.Surname
HAVING COUNT(l.Id) = (
    SELECT MAX(LectureCount)
    FROM (
        SELECT COUNT(l2.Id) AS LectureCount
        FROM Lectures l2
        GROUP BY l2.SubjectId, l2.TeacherId
    ) AS MaxLectures
);

SELECT S.Name FROM Subjects S
INNER JOIN Lectures L ON L.SubjectId = S.Id
GROUP BY S.Name
HAVING COUNT(l.Id) = (
    SELECT MIN(LectureCount)
    FROM (
        SELECT COUNT(l2.Id) AS LectureCount
        FROM Lectures l2
        GROUP BY l2.SubjectId
    ) AS MinLectures
);


SELECT COUNT(DISTINCT s.Id) AS StudentCount, COUNT(DISTINCT l.SubjectId) AS SubjectCount 
FROM Departments d
INNER JOIN Groups g ON d.Id = g.DepartmentId
INNER JOIN GroupsStudents  gs ON g.Id = gs.GroupId
INNER JOIN Students S ON gs.StudentId = S.Id
INNER JOIN GroupsLectures gl ON g.Id = gl.GroupId
INNER JOIN Lectures l ON gl.LectureId = l.Id
WHERE d.Name = 'Department of Sofware Development';

-- deleting db

DROP TABLE GroupsLectures;
DROP TABLE GroupsStudents;
DROP TABLE GroupsCurators;
DROP TABLE Lectures;
DROP TABLE Students;
DROP TABLE Groups;
DROP TABLE Departments;
DROP TABLE Teachers;
DROP TABLE Subjects;
DROP TABLE Curators;
DROP TABLE Faculties;

USE MASTER;

DROP DATABASE Academy;


CREATE DATABASE OnlineExam;
USE OnlineExam;

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name NVARCHAR(20)
);

CREATE TABLE Student (
    St_id INT PRIMARY KEY,
    St_Name NVARCHAR(10),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Instructor (
    ins_id INT PRIMARY KEY,
    ins_name NVARCHAR(20),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);

CREATE TABLE Course (
    course_id INT PRIMARY KEY,
    course_name NVARCHAR(20),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);
ALTER TABLE Course ALTER COLUMN course_name NVARCHAR(50);

CREATE TABLE Questions (
    Q_ID INT PRIMARY KEY,
    Q_Type NVARCHAR(20) CHECK (Q_Type IN ('TF', 'MCQ')),
    Q_text NVARCHAR(255),
    model_answer NVARCHAR(10), 
    grade INT,
    course_id INT,
    FOREIGN KEY (course_id) REFERENCES Course(course_id)
);

CREATE TABLE Exam (
	E_ID INT IDENTITY(1,1) PRIMARY KEY,
	E_DATE DATE,
	E_DURATION TIME
);

CREATE TABLE ExamQuestions (
    E_ID INT,
    Q_ID INT,
    PRIMARY KEY(E_ID, Q_ID),
    FOREIGN KEY (E_ID) REFERENCES Exam(E_ID),
    FOREIGN KEY (Q_ID) REFERENCES Questions(Q_ID)
);

CREATE TABLE Student_Answer (
    st_id INT,
    Q_id INT,
    grade INT,
    st_choice NVARCHAR(10),
    PRIMARY KEY (st_id, Q_id),
    FOREIGN KEY (Q_id) REFERENCES Questions(Q_ID),
    FOREIGN KEY (st_id) REFERENCES Student(St_ID)
);

CREATE TABLE MCQ_Choices (
    Q_id INT,
    Choice_text NVARCHAR(255),
    PRIMARY KEY (Q_id, Choice_text),
    FOREIGN KEY (Q_id) REFERENCES Questions(Q_ID)
);

INSERT INTO Department (dept_id, dept_name) VALUES
(1, 'Computer Science'),
(2, 'Information Systems'),
(3, 'Mathematics'),
(4, 'Physics'),
(5, 'Statistics');

INSERT INTO Student (St_id, St_Name, dept_id) VALUES
(101, 'Ali', 1),
(102, 'Sara', 2),
(103, 'Khaled', 1),
(104, 'Mona', 3),
(105, 'Omar', 2),
(106, 'Noor', 4),
(107, 'Hassan', 1),
(108, 'Layla', 3),
(109, 'Tamer', 5),
(110, 'Hana', 2);

INSERT INTO Instructor (ins_id, ins_name, dept_id) VALUES
(201, 'Dr. Ahmed', 1),
(202, 'Dr. Waleed', 2),
(203, 'Dr. Fatima', 3),
(204, 'Dr. Salma', 4),
(205, 'Dr. Youssef', 5),
(206, 'Dr. Ayman', 1),
(207, 'Dr. Samar', 2),
(208, 'Dr. Hoda', 3),
(209, 'Dr. Kareem', 4),
(210, 'Dr. Rania', 5);

INSERT INTO Course (course_id, course_name, dept_id) VALUES
(301, 'Database Systems', 1),
(302, 'Artificial Intelligence', 1), 
(303, 'Data Structures', 1),
(304, 'Web Development', 2),
(305, 'Software Engineering', 2),
(306, 'Calculus', 3),
(307, 'Linear Algebra', 3),
(308, 'Quantum Physics', 4),
(309, 'Probability', 5),
(310, 'Big Data Technologies', 2); 

INSERT INTO Questions (Q_ID, Q_Type, Q_text, model_answer, grade, course_id) VALUES
(401, 'MCQ', 'What is SQL?', 'A', 5, 301),
(402, 'MCQ', 'What is AI?', 'B', 5, 302),
(403, 'TF', 'Data Structures are used in AI?', 'T', 4, 303),
(404, 'TF', 'HTML is a programming language?', 'F', 4, 304),
(405, 'MCQ', 'What is Software Engineering?', 'C', 5, 305),
(406, 'TF', 'Calculus is a branch of mathematics?', 'T', 4, 306),
(407, 'MCQ', 'What is a Matrix?', 'B', 5, 307),
(408, 'TF', 'Quantum Physics deals with subatomic particles?', 'T', 4, 308),
(409, 'MCQ', 'Probability is part of statistics?', 'A', 5, 309),
(410, 'MCQ', 'What is Big Data?', 'D', 5, 310);

INSERT INTO MCQ_Choices (Q_id, Choice_text) VALUES
(401, 'A. Structured Query Language'),
(401, 'B. Simple Query Logic'),
(401, 'C. System Query Language'),
(401, 'D. Sequential Query Language'),

(402, 'A. Artificial Intelligence'),
(402, 'B. Advanced Integration'),
(402, 'C. Algorithmic Interpretation'),
(402, 'D. Automated Information'),

(405, 'A. Study of AI'),
(405, 'B. Study of Programming'),
(405, 'C. Study of Software Development'),
(405, 'D. Study of Computers'),

(409, 'A. Yes'),
(409, 'B. No'),
(409, 'C. Maybe'),
(409, 'D. I don’t know'),

(410, 'A. Small Data'),
(410, 'B. Medium Data'),
(410, 'C. Large Data'),
(410, 'D. Huge Data');

ALTER PROCEDURE GenerateRandomExam
    @NumTF INT,
    @NumMCQ INT,
    @CourseName NVARCHAR(50),
    @DURATION TIME,
    @ExamID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CourseID INT;
    
    SELECT @CourseID = course_id FROM Course WHERE course_name = @CourseName;

    INSERT INTO Exam(E_DATE, E_DURATION) 
    VALUES (GETDATE(), @DURATION);

    SET @ExamID = SCOPE_IDENTITY();

    PRINT 'Generated ExamID: ' + CAST(@ExamID AS NVARCHAR);
   
    INSERT INTO ExamQuestions (Q_ID, E_ID)
    SELECT TOP (@NumTF) Q_ID, @ExamID
    FROM Questions
    WHERE course_id = @CourseID AND Q_Type = 'TF'
    ORDER BY NEWID();

  
    INSERT INTO ExamQuestions (Q_ID, E_ID)
    SELECT TOP (@NumMCQ) Q_ID, @ExamID
    FROM Questions
    WHERE course_id = @CourseID AND Q_Type = 'MCQ'
    ORDER BY NEWID();

    PRINT 'Inserted Questions for ExamID: ' + CAST(@ExamID AS NVARCHAR);
END

CREATE PROCEDURE EXAM_ANSWER
	@ExamID int,
	@St_ID INT,
	@Q_ID INT,
	@St_Choice NVARCHAR(10)
AS
BEGIN
	INSERT INTO Student_Answer(st_id,Q_id,st_choice)
	VALUES (@St_ID, @Q_ID,@St_Choice)
END


DECLARE @ExamID1 INT, @ExamID2 INT, @ExamID3 INT, @ExamID4 INT, @ExamID5 INT;

EXEC GenerateRandomExam @NumTF = 3, @NumMCQ = 2, @CourseName = 'Database Systems', @DURATION = '01:30:00', @ExamID = @ExamID1 OUTPUT;
EXEC GenerateRandomExam @NumTF = 2, @NumMCQ = 3, @CourseName = 'Artificial Intelligence', @DURATION = '01:20:00', @ExamID = @ExamID2 OUTPUT;
EXEC GenerateRandomExam @NumTF = 1, @NumMCQ = 4, @CourseName = 'Data Structures', @DURATION = '01:40:00', @ExamID = @ExamID3 OUTPUT;
EXEC GenerateRandomExam @NumTF = 2, @NumMCQ = 3, @CourseName = 'Web Development', @DURATION = '01:30:00', @ExamID = @ExamID4 OUTPUT;
EXEC GenerateRandomExam @NumTF = 3, @NumMCQ = 2, @CourseName = 'Probability', @DURATION = '01:45:00', @ExamID = @ExamID5 OUTPUT;

EXEC EXAM_ANSWER @ExamID = @ExamID1, @St_ID = 101, @Q_ID = 401, @St_Choice = 'a';

SELECT * FROM Exam;
SELECT * FROM ExamQuestions ORDER BY E_ID;

SELECT * FROM Student_Answer;

--Report that returns the students information according to Department No parameter
CREATE PROCEDURE Std_Info_Based_On_DeptNo
	@deptNo int
AS
BEGIN
	SELECT Student.St_id, Student.St_Name, Student.dept_id
	FROM Student
	WHERE  Student.dept_id = @deptNo
END

EXEC Std_Info_Based_On_DeptNo @deptNo = 1;

--Report that takes the instructor ID and returns the name of the courses that he teaches and the number of students per course.
CREATE PROCEDURE INSRTUCTOR_INFO
	@INS_ID int
AS
BEGIN
	SELECT Course.course_name, COUNT(Student.St_id) AS Student_number
	FROM Course
	JOIN Department
	ON Course.dept_id = Department.dept_id
	JOIN Instructor
	ON Instructor.dept_id = Department.dept_id
	JOIN Student
	ON Student.dept_id = Department.dept_id
	where Instructor.ins_id = @INS_ID
	GROUP BY Course.course_name;
end

EXEC INSRTUCTOR_INFO @INS_ID = 203;

CREATE PROCEDURE CorrectExamPerQuestion
    @ExamID INT,
    @St_ID INT
AS
BEGIN
   
    UPDATE SA
    SET SA.grade = Q.grade
    FROM Student_Answer SA
    JOIN Questions Q ON SA.Q_id = Q.Q_ID
    JOIN ExamQuestions EQ ON Q.Q_ID = EQ.Q_ID
    WHERE SA.st_id = @St_ID 
    AND EQ.E_ID = @ExamID 
    AND SA.st_choice = Q.model_answer;

    UPDATE SA
    SET SA.grade = 0
    FROM Student_Answer SA
    JOIN Questions Q ON SA.Q_id = Q.Q_ID
    JOIN ExamQuestions EQ ON Q.Q_ID = EQ.Q_ID
    WHERE SA.st_id = @St_ID 
    AND EQ.E_ID = @ExamID 
    AND SA.st_choice != Q.model_answer;



END;

EXEC CorrectExamPerQuestion @ExamID = 1, @St_ID = 101;

--Report that takes the student ID and returns the grades of the student in all courses.
CREATE PROCEDURE STUDENT_GRADES
	@STUDENT_ID INT
AS
BEGIN

	SELECT Course.course_name, SUM(Student_Answer.grade) AS total_grade
    FROM Student_Answer 
    JOIN Questions  
	ON Student_Answer.Q_id = Questions.Q_ID 
    JOIN Course ON Questions.course_id = Course.course_id 
    WHERE Student_Answer.st_id = @STUDENT_ID 
    GROUP BY Course.course_name;
END
EXEC STUDENT_GRADES @STUDENT_ID = 101;

create proc GetQuestions @ExamID int
as
begin

    select q.Q_text
    from ExamQuestions EQ
    join Questions q on EQ.Q_ID = q.Q_ID
    where EQ.E_ID = @ExamID;
end

exec GetQuestions @ExamID = 1;

CREATE PROCEDURE GetAnswers 
	@ExamID INT,
	@stId INT
AS
BEGIN
select
        Q.Q_text,st_choice 
    from ExamQuestions EQ
    join Questions q on EQ.Q_ID = q.Q_ID
   join Student_Answer SA ON SA.Q_id = EQ.Q_ID
    where EQ.E_ID = @ExamID and SA.st_id = @stId;
end

exec GetAnswers @ExamID = 1, @stId = 101;
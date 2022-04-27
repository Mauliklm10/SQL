--Create and populate a column called  NJITID_Total_Salary and a column called NJIT_Average_Salary in the PEOPLE table

Alter Table People
Add NJITID_Total_Salary [money],
NJIT_Average_Salary [money]

--Next populate both columns with the appropriate aggregate functions for each player.

Update People
Set NJITID_Total_Salary = (Select sum(salary)
						   from Salaries 
						   where People.playerID = Salaries.playerID 
						   Group By Salaries.playerID),
	NJIT_Average_Salary = (Select avg(salary) 
						   from Salaries 
						   where People.playerID = Salaries.playerID 
						   Group By Salaries.playerID)

--Write a trigger that updates the both of the columns you created in the PEOPLE table whenever there is a row inserted, 
--updated or deleted from the salary table. The trigger name must start with your NJITID and the DDL that creates the 
--trigger must also check to see if the trigger exists before creating it.

IF EXISTS (SELECT * 
		   FROM sys.triggers 
           WHERE 
		   Name = 'mp766_trigger')
	Drop Trigger mp766_trigger
	On all server
Go

Create Trigger mp766_trigger
on salaries
after insert, delete, update
as
Begin
if exists(SELECT * from inserted) and exists (SELECT * from deleted)
begin  
	UPDATE People
	SET NJITID_Total_Salary = (NJITID_Total_Salary - d.salary + i.salary)
	FROM deleted d, inserted i
	WHERE People.playerid = d.playerid and People.playerid = i.playerID

	UPDATE People
	SET NJIT_Average_Salary = (a.Avg_Salary)
	FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
	FROM salaries s, inserted i
	WHERE s.playerid = i.playerID
	GROUP BY s.playerid) a
	WHERE people.playerid = a.playerid
end

If exists (Select * from deleted) and not exists(Select * from inserted)
begin
	UPDATE People
	SET NJITID_Total_Salary = (NJITID_Total_Salary - d.salary)
	FROM deleted d
	WHERE People.playerid = d.playerid

	UPDATE People
	SET NJIT_Average_Salary = (a.Avg_Salary)
	FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
	FROM salaries s
	GROUP BY s.playerid) a
	WHERE people.playerid = a.playerid    
end

If exists(select * from inserted) and not exists(Select * from deleted)
begin 
	UPDATE People
	SET NJITID_Total_Salary = (NJITID_Total_Salary + i.salary)
	FROM inserted i
	WHERE People.playerid = i.playerID

	UPDATE People
	SET NJIT_Average_Salary = (a.Avg_Salary)
	FROM (SELECT s.playerid, AVG(s.salary) AS Avg_Salary
	FROM salaries s
	GROUP BY s.playerid) a
	WHERE people.playerid = a.playerid    
end
end
Go

--Insert test
SELECT yearID,playerID,salary FROM salaries WHERE playerID = 'grayjo02'

INSERT INTO salaries VALUES (2023,'PGTH','NP','grayjo02',90000,5000,4000)
INSERT INTO salaries VALUES (2025,'PGTH','NL','grayjo02',50000001,71000,14000)

SELECT yearID,playerID,salary FROM salaries WHERE playerID = 'grayjo02'

--Update test
SELECT playerID,NJITID_Total_Salary,NJIT_Average_Salary FROM People WHERE playerid ='grayjo02'

SELECT yearID,teamID,lgID,playerID,salary,[401K Contributions],[401K Team Contributions]
FROM Salaries
WHERE playerid = 'grayjo02' AND yearid = 2023 AND lgID = 'NP'

update Salaries 
SET salary = 90025
WHERE playerid ='grayjo02' AND lgID = 'NP' AND yearID = 2023 AND salary = 90000

SELECT * FROM Salaries WHERE playerid = 'grayjo02' AND lgID = 'NP' AND yearID = 2023

--Delete test
SELECT playerID,NJITID_Total_Salary,NJIT_Average_Salary FROM People WHERE playerid ='grayjo02' 

delete FROM Salaries
WHERE playerid = 'grayjo02'
AND yearid = 2023
AND lgid = 'NP'

delete FROM Salaries
WHERE playerid = 'grayjo02'
AND yearid = 2025

SELECT playerID,NJITID_Total_Salary,NJIT_Average_Salary FROM People WHERE playerid ='grayjo02'

SELECT * FROM Salaries WHERE playerID = 'grayjo02'




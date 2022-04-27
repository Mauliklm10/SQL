IF OBJECT_ID (N'dbo.FullName', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.FullName
GO  
Create function dbo.FullName(@playerID varchar(255))
returns varchar(255)
As
Begin
declare @ret varchar(255)
select 
@ret = nameGiven + ' ( ' + nameFirst + ' ) ' + nameLast
from 
People a
where
a.playerID = @playerID
Return @ret
end
go

--1.Using the view provided in the assignment page, write a query that uses the RANK function to rank the careerBA 
--column where the careerBA < 0.40. Your results must show the playerid, Full Name, CareerBA and the rank for the players. 
--The full name in all questions must use the function you created in the Chapter #2 – Function Assignment
Select 
playerid, 
[dbo].[FullName](playerID) as FullName, 
format((sum(H)*1.0/sum(AB)),'0.0000') as Career_Batting_Average,
rank() over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as All_Batting_rank
From
Batting
where
ab >  0
Group By
playerid
Having
(sum(H)*1.0/sum(AB)) < 0.4
Order By
(sum(H)*1.0/sum(AB)) DESC

--2. Write the same query as #2 but eliminate any gaps in the ranking
Select 
playerid, 
[dbo].[FullName](playerID) as FullName, 
format((sum(H)*1.0/sum(AB)),'0.0000') as Career_Batting_Average,
dense_rank() over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as All_Batting_rank
From
Batting
where
ab >  0
Group By
playerid
Having
(sum(H)*1.0/sum(AB)) < 0.4
Order By
(sum(H)*1.0/sum(AB)) DESC

--3.Write the same query as #1, but find the ranking within the last year played by the player starting with the most 
--current year and working backwards. Also eliminate any player where the career batting average is = 0.
Select 
playerid, 
[dbo].[FullName](playerID) as FullName, 
Max(yearID) as Last_Year_Played,
format((sum(H)*1.0/sum(AB)),'0.0000') as Career_Batting_Average,
--dense_rank() over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as All_Batting_rank
ROW_NUMBER() OVER(PARTITION BY Max(yearID)  ORDER BY format((sum(H)*1.0/sum(AB)),'0.0000') desc) AS All_Batting_rank
From
Batting
where
ab >  0
Group By
playerid
Having
(sum(H)*1.0/sum(AB)) between 0.0 and  0.3999
Order By
Max(yearID) DESC,
(sum(H)*1.0/sum(AB)) DESC

--4. Write the same query as #3, but show the ranking by quartile ( use the NTILE(4) parmeter)
Select 
playerid, 
[dbo].[FullName](playerID) as FullName, 
Max(yearID) as Last_Year_Played,
format((sum(H)*1.0/sum(AB)),'0.0000') as Career_Batting_Average,
ntile(4) over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as Ntile_rank
--ROW_NUMBER() OVER(PARTITION BY Max(yearID)  ORDER BY format((sum(H)*1.0/sum(AB)),'0.0000') desc) AS All_Batting_rank
From
Batting
where
ab >  0
Group By
playerid
Having
(sum(H)*1.0/sum(AB)) between 0.0 and  0.3999
Order By
Max(yearID) DESC,
(sum(H)*1.0/sum(AB)) DESC

--5.Using the Salaries table, write a query that compares the averages salary by team and year with the windowed average 
--of the 3 prior years and the 1 year after the current year. 
SELECT 
yearID,
teamID,
format(avg_salary, 'C') as Average_Salary,
avg(a.avg_salary) over(ORDER BY a.yearid rows between 3 preceding and 1 following) AS windowing_salary
FROM (SELECT 
	  yearid, 
	  teamid, 
	  avg(salary) AS avg_salary
      FROM Salaries
      GROUP BY teamID,yearID ) a
ORDER BY teamID asc, yearID asc

--6.Write a query that shows that teamid, playerid, Player Full Name, total hits, total at bats, total batting average 
--(calculated by using sum(H)*1.0/sum(AB) as the formula) and show the players rank within the team and the rank within 
--all players. Only include players that have a minimum of 150 career hits. 
SELECT
teamid, 
playerID, 
[dbo].[FullName](playerID) as FullName, 
sum(H) as Total_hits, 
sum(AB) as Total_At_Bats,
format((sum(H)*1.0/sum(AB)),'0.0000') as Batting_Average,
rank() over (partition by teamid order by format((sum(H)*1.0/sum(AB)), '0.0000') desc) as Team_Batting_rank,
rank() over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as All_Batting_rank
from 
Batting
where 
ab >  0
group by
teamID,
playerID
having 
sum(h) >= 150 
order by
teamID ASC,
rank() over (partition by teamid order by format((sum(H)*1.0/sum(AB)), '0.0000') desc)

--7.You’ve decided that due to the number of queries that use the Salaries table, you need to create a primary key 
--consisting of Playerid, Teamid, Yearid and LGID. 
SELECT 
playerid, 
yearid, 
lgid, 
teamid, 
count(*)
FROM 
salaries
GROUP BY 
playerid, 
yearid, 
lgid, 
teamid
having 
count(*) >1

SELECT 
playerid, 
yearid, 
lgid, 
teamid
FROM 
salaries
GROUP BY 
playerid, 
yearid, 
lgid, 
teamid
having 
count(playerID)>1

WITH abc_CTE (playerid, yearid, lgid, teamid, RN) AS
	(
    SELECT 
	playerid, 
	yearid, 
	lgid, 
	teamid,
	ROW_NUMBER() OVER (PARTITION BY playerid,yearid, lgid, teamid ORDER BY playerid DESC) AS RN 
	FROM 
	Salaries    
    )
Delete
FROM
abc_CTE 
WHERE
RN > 1

ALTER TABLE dbo.Salaries ADD CONSTRAINT PK_Salaries PRIMARY KEY (teamID, yearID, lgID, playerID)

ALTER TABLE dbo.Salaries ALTER column lgID varchar(255) not null

ALTER TABLE dbo.Salaries ALTER column yearid varchar(255) not null

ALTER TABLE dbo.Salaries ALTER column teamid varchar(255) not null

ALTER TABLE dbo.Salaries ALTER column playerid varchar(255) not null

ALTER TABLE dbo.Salaries ALTER column lgID varchar(255) not null















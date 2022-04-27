-- 1.	Write a query that lists the playerid, birthcity, birthstate, salary and batting average for all players born 
-- in New Jersey sorted by last name and year in ascending order using the PEOPLE and Batting tables. 
-- The joins must be made using the WHERE clause. Make sure values are properly formatted.
-- Note: your query should return 342 rows.
Select
batting.playerID,
people.birthCity,
people.birthState,
batting.yearID,
format(Salaries.salary, 'C') as Salary,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as Batting_Average
From 
Batting, People, Salaries
Where 
Batting.playerID = People.playerID
and People.playerID = Salaries.playerID
and Batting.lgID = Salaries.lgID
and Batting.teamID = Salaries.teamID
and Batting.yearID = Salaries.yearID
and people.birthState = 'NJ'
and batting.ab > 0
Order BY
People.nameLast ASC,
Batting.yearID ASC

-- 2.Write the same query as #1 but you need to use JOIN clauses in the FROM clause to join the tables. 
-- Your answers and rows returned should be the same. 
Select
batting.playerID,
people.birthCity,
people.birthState,
batting.yearID,
format(Salaries.salary, 'C') as Salary,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as Batting_Average
From 
Batting
Join
People On
Batting.playerID = People.playerID
Join
Salaries On
Batting.lgID = Salaries.lgID
and Batting.teamID = Salaries.teamID
and Batting.yearID = Salaries.yearID
and People.playerID = Salaries.playerID
Where 
people.birthState = 'NJ'
and batting.ab > 0
Order BY
People.nameLast ASC,
Batting.yearID ASC

--3. Write the same query as #2 but use a LEFT JOIN.   
-- Note that 1939 rows will be returned and armstja01 will be the first player with a non-null salary. 
-- Hint: Look at the data to see what needs to be done to get the correct number of rows
Select
batting.playerID,
people.birthCity,
people.birthState,
batting.yearID,
format(Salaries.salary, 'C') as Salary,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as Batting_Average
From 
Batting
Left Join
People On
Batting.playerID = People.playerID
Left Join
Salaries On
Batting.lgID = Salaries.lgID
and Batting.teamID = Salaries.teamID
and Batting.yearID = Salaries.yearID
and People.playerID = Salaries.playerID
Where 
people.birthState = 'NJ'
and batting.ab > 0
and Salary IS NOT Null
Order BY
People.nameLast ASC,
Batting.yearID ASC

--4.You get into a debate regarding the level of school that professional sports players attend. 
--Your stance is that there are plenty of baseball players who attended Ivy League schools and were good 
--batters in addition to being scholars. Write a query to support your argument using the People, CollegePlaying 
--and Batting tables. You must use an IN clause in the WHERE clause to identify the Ivy League schools. 
--You have also decided that a batting average less than .4 indicates a good batter. 
--Sort you answer by schoolid in ascending order and Batting Average in descending order. 
--Your answer should return 455 rows and contain the columns below. The colleges in the Ivy League are Brown, 
--Columbia, Cornell, Dartmouth, Harvard, Princeton, Pennsylvania, and Yale. Your query should return 5,564 rows. 
--You will need to use the BATTING and newly created COLLEGEPLAYING tables.
Select
People.playerID,
CollegePlaying.schoolID,
CollegePlaying.CollegeyearID,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as Batting_Average
From 
People
Join
CollegePlaying On
People.playerID = CollegePlaying.playerID
Join
Batting On
People.playerID = Batting.playerID
and CollegePlaying.CollegeyearID = Batting.yearID
Where
CollegePlaying.schoolID IN ('brown','columbia', 'cornell', 'umassdartm', 'harvard', 'princeton', 'upenn','yale')
and (batting.h) * 1.0 / (batting.ab) < '0.4000'
and batting.ab > 0
Order By
schoolID ASC,
Batting_Average DESC

--5.You are now interested in the longevity of players careers. Using the Appearances table and the appropriate 
--SET clause from slide 45 of the Chapter 3 PowerPoint presentation, find the players that played for the same teams in 
--2010 and 2020. Your query only needs to return the playerid and teamids. The query should return 17 rows.
Select
playerID,
teamID
from
Appearances
where
yearID = '2010'
intersect
Select
playerID,
teamID
from
Appearances
where
yearID = '2020'

--6.Using the Appearances table and the appropriate SET clause from slide 45 of the Chapter 3 PowerPoint presentation, 
--find the players that played for the different teams in 2015 and 2020 or played in 2015 and did not play in 2020. 
--Your query only needs to return the playerids and the 2015 teamid. The query should return 1,364 rows.
(Select
playerID,
teamID
from
Appearances
where
yearID = '2015'
except
Select
playerID,
teamID
from
Appearances
where
yearID = '2020')
union
(Select
playerID,
teamID
from
Appearances
where
yearID = '2015'
intersect
Select
playerID,
teamID
from
Appearances
where
yearID IS NULL)

--7.Using the Salaries table, calculate the average and total salary for each player. 
--Make sure the amounts are properly formatted and sorted by the total salary in descending order. 
--Your query should return 5,828 rows.
Select
playerID,
format(avg(salary), 'C') as Average_salary,
format(sum(salary), 'C') as Total_salary
From
Salaries
group by 
playerID
order by
Total_salary DESC

--8.Using the Batting  and People tables and a HAVING clause, write a query that lists the playerid, 
--the players full name, the number of home runs (HR) for all players having more than 500 home runs and the number of 
--years they played. The query should return 27 rows.
Select
People.playerID,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
sum(Batting.HR) as Total_Homeruns,
count(yearid) as Years_played
--CONVERT(INT, STUFF(Max(People.finalGame), 1, 1, ''))- CONVERT(INT, STUFF(Min(People.debut), 1, 1, ''))as Years_played
From
Batting
Join
People On
Batting.playerID = people.playerID
Group By
People.playerID,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast
--(cast(Right(People.finalGame,8) as integer)- cast(Right(People.debut,8)as integer))
--CONVERT(INT, STUFF(Max(People.finalGame), 1, 1, ''))- CONVERT(INT, STUFF(Min(People.debut), 1, 1, ''))
Having
sum(Batting.HR) > '500'

--9.Using a subquery along with an IN clause in the WHERE statement, write a query that identifies all the playerids, 
--the players full name and the team names who in 2020 that were playing on teams that existed in 1910. 
--You should use the appearances table to identify the players years and the TEAMS table to identify the team name. 
--Sort your results by players last name. Your query should return 451 rows.
Select
People.playerID,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
Teams.teamID
From
Appearances
Join
Teams On
Appearances.yearID = Teams.yearID
and Appearances.lgID = Teams.lgID
and Appearances.teamID = Teams.teamID
Join
People On
Appearances.playerID = People.playerID
Where
Appearances.yearID = '2020'
and Appearances.teamID IN (Select Appearances.teamID From Appearances where Appearances.yearID = '1910')
Order By
People.nameLast

--10.Using the Salaries table, find the players full name, average salary and the last year they played  for each 
--team they played for during their career. Also find the difference between the players salary and the average team 
--salary. You must use subqueries in the FROM statement to get the team and player average salaries and calculate the 
--difference in the SELECT statement. Sort your answer by the playerid in ascending and last year in descending order. 
--The query should return 12,928 rows
Select distinct
people.playerID,
format(TeamAverage, 'C') as tavg,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
Format((T2.TeamAverage - T1.PlayerAverage) , 'C') as Salary_diff,
T1.teamID,
t1.LastYear,
Format(PlayerAverage, 'C') as Pavg
From
People,
(
Select
playerID,
Max(yearID) as LastYear,
avg(salary) as PlayerAverage,
teamID
From
Salaries
Group By 
playerID,
teamID
) T1,
(
Select
teamID,
avg(salary) as TeamAverage
from
Salaries
group by
teamID
) T2
Where
T1.teamID = T2.teamID
and T1.playerID = People.playerID
Order By
People.playerID,
T1.LastYear DESC

--11.Rewrite the query in #11 using a WITH statement for the subqueries instead of having the subqueries in the from 
--statement. The answer will be the same. Please make sure you put a GO statement before and after this problem. 
--5 points will be deducted if the GO statements are missing and I have to add them manually.
GO
With T1
as
(
Select
playerID,
Max(yearID) as LastYear,
avg(salary) as PlayerAverage,
teamID
From
Salaries
Group By 
playerID,
teamID
),
T2 
as
(
Select
teamID,
avg(salary) as TeamAverage
from
Salaries
group by
teamID
)
Select distinct
people.playerID,
format(TeamAverage, 'C') as tavg,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
Format((T2.TeamAverage - T1.PlayerAverage) , 'C') as Salary_diff,
T1.teamID,
t1.LastYear,
Format(PlayerAverage, 'C') as Pavg
From
People, T1, T2
where
T1.teamID = T2.teamID
and T1.playerID = People.playerID
Order By
People.playerID,
T1.LastYear DESC
Go

--12.Using a scalar queries in the SELECT statement and the salaries and people tables , write a query that shows the 
--full Name, the average salary and the number of teams the player played. This query returns 5,718 rows
Select
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
(select count(*) 
from Salaries
where People.playerid = Salaries.playerid) as Num_Teams,
Format(Avg(Salaries.salary), 'C') as Avg_Sal
From
People
Join
Salaries On
People.playerID = Salaries.playerID
Group By
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast,
People.playerid,
Salaries.playerID

--13.The player’s union has negotiated that players will start to have a 401K retirement plan. Using the 
--[401K Contributions] column in the Salaries table,  populate this column for each row by updating it to contain 6% of 
--the salary in the row. You must use an UPDATE query to fill in the amount. This query updates 30,067 rows. 
--Use the column names given, do not create your own columns.
Update Salaries
Set [401K Contributions] = 0.06 * salary
where
playerID IS NOT NULL

--Select
--playerID, salary, [401K Contributions]
--From Salaries

--14.Contract negotiations have proceeded and now the team owner will make a matching contribution to each players 
--401K each year. If the player’s salary is under $1 million, the team will contribute another 5%. If the salary is over 
--$1 million, the team will contribute 2.5%. You now need to write an UPDATE query for the [401K Team Contributions] column 
--in the Salaries table to populate the team contribution with the correct amount. You must use a CASE clause in 
--the UPDATE query to handle the different amounts contributed. This query updates 30,067 rows.
Update Salaries
Set [401K Team Contributions] = Case
									When salary < 1000000 then 0.05 * salary
									When salary > 1000000 then 0.025 * salary
									Else 0
								End
where
playerID IS NOT NULL

Select
playerID, salary, [401K Team Contributions]
From Salaries

--15.Write a query that shows the Playerid, yearid, Salary, Player contribution, Team Contribution and total 401K 
--contribution each year for each player. Use the columns you populated in questions #13 and 14. 
--Do not include players with no contributions. Sort your results by playerid. Exclude rows where the salary is null. 
--This query returns 30,027 rows.
Select
playerID,
yearID,
salary,
[401K Contributions],
[401K Team Contributions],
[401K Contributions] + [401K Team Contributions] as Total_contributions
From
Salaries
Where
[401K Contributions] IS NOT NULL
and salary IS NOT NULL
Order By
playerID

--16.You have now been asked to populate the columns to the PEOPLE table that contain the total number of HRs hit 
--( Total_HR column) by the player and the highest Batting Average the player had during any year they played 
--( High_BA column). Write the SQL that correctly populates these columns. This query updates 17,593 rows.
Update People
Set Total_HR = (Select sum(HR) as career_HR 
				from Batting 
				where People.playerID = Batting.playerID 
				Group By Batting.playerID),
	High_BA = (Select max(format(((batting.H * 1.0)/(batting.AB)), '0.0000')) as Batting_Average
			   from Batting
			   where People.playerID = Batting.playerID
					 and batting.ab > 0
			   Group By Batting.playerID)

--select
--playerID, Total_HR, High_BA
--from People

--17.Write a query that shows the playerid, Total HRs and Highest Batting Average for each player. 
--The Batting Average must be formatted to only show 4 decimal places. Sort the results by playerid. 
--This query returns 20.093 rows.
Select
playerID,
Total_HR,
High_BA
From
People
Order By
playerID

--18.You have also been asked to populate a column in the PEOPLE table ( Total_401K column) that contains the total 
--value of the 401K for each player in the Salaries table.  Write the SQL that correctly populates the column. 
--This query updates 5,718 rows. 
UPDATE People
	set people.Total_401K= (select sum(Salaries.[401K Contributions] + Salaries.[401K Team Contributions])
							from Salaries
							where People.playerID = Salaries.playerID 
								  and Salaries.salary IS NOT NULL 
							group by Salaries.playerID)

--19.Write a query that shows the playerid, the player full name and their 401K total from the people table. 
--Only show players that have contributed to their 401Ks. Sort the results by playerid. This query returns 5,718 rows.
Select distinct
people.playerID,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
Total_401K
From
People
Join
Salaries On
People.playerID = Salaries.playerID
where
[401K Contributions] IS NOT NULL
Order By
people.playerID

--20.As with any job, players are given raises each year, write a query that calculates the increase each player 
--received and calculate the % increase that raise makes. You will only need to use the SALARIES  and PEOPLE tables. 
--You answer should include the columns below. Include the players full name and sort your results by playerid in 
--ascending order and year in descending order. This query returns 15,569 rows. You cannot use advanced aggregate 
--functions for this question. The answer can be written using only the SQL parameters you learned in this chapter.
select
S2.playerID,
S2.yearID,
S2.salary
--Lag(Salaries.salary) Over (Order By salaries.yearID) as Previous_year,
--Salaries.salary - Lag(Salaries.salary) Over (Order By salaries.yearID) as difference_amount
--LEAD(salary, 1, 0) OVER (ORDER BY yearID) - salary,
--S2.salary - first_value(S2.salary) OVER (ORDER BY S2.yearID) AS diff_first
--COALESCE(
--       (
--       SELECT TOP 1 salary
--       FROM salaries S1
--       WHERE S1.yearID > S2.yearID
--       ORDER BY
--             yearID
--       ), 0) - salary AS diff
from
Salaries S2
Join
People On
S2.playerID = People.playerID
Group By
S2.playerID,
yearID,
S2.salary
order By
playerID,
yearID 






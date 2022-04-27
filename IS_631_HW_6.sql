--Create a function
--And use it in the above/below query 
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

IF OBJECT_ID (N'dbo.HW6', N'IF') IS NOT NULL
	DROP FUNCTION dbo.HW6
GO 
CREATE FUNCTION dbo.HW6(@playerID varchar(255))
RETURNS TABLE
AS 
RETURN
(
	SELECT
	teamid, 
	playerID, 
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
	playerID,
	teamid
	having 
	sum(h) >= 150 
)

Select 
teamid, 
playerid, 
[dbo].[FullName](playerID) as FullName, 
Total_hits, 
Total_At_Bats,
Batting_Average,
Team_Batting_rank,
All_Batting_rank
from 
dbo.HW6 ('')
order by
teamID

/*
IF OBJECT_ID (N'dbo.HW6', N'TF') IS NOT NULL  
    DROP FUNCTION dbo.HW6
GO 
CREATE FUNCTION dbo.HW6 (@playerID INTEGER)  
RETURNS @ret TABLE   
(  
    playerID varchar(255) primary key NOT NULL,  
    teamID varchar(255) NOT NULL,  
    LastName varchar(255) NOT NULL,  
    JobTitle varchar(50) NOT NULL,  
    RecursionLevel int NOT NULL  
)  
--Returns a result set that lists all the employees who report to the   
--specific employee directly or indirectly. 
AS  
BEGIN  
WITH EMP_cte(teamid, playerID, Fullname, Total_hits, Total_At_Bats, Batting_Average, Team_Batting_rank, All_Batting_rank)  
    AS (  
        SELECT
	teamid, 
	people.playerID, 
	people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
	sum(H) as Total_hits, 
	sum(AB) as Total_At_Bats,
	format((sum(H)*1.0/sum(AB)),'0.0000') as Batting_Average,
	rank() over (partition by teamid order by format((sum(H)*1.0/sum(AB)), '0.0000') desc) as Team_Batting_rank,
	rank() over (order by format((sum(H)*1.0/sum(AB)),'0.0000') desc) as All_Batting_rank
	from 
	Batting Join
	People On
	Batting.playerID = people.playerID
	where 
	ab >  0
	group by 
	people.playerID,
	people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast,
	teamid
	having 
	sum(h) >= 150  
        )  
-- copy the required columns to the result of the function   
   INSERT @ret 
   SELECT EmployeeID, FirstName, LastName, JobTitle, RecursionLevel  
   FROM EMP_cte   
   RETURN  
END;  
GO
*/

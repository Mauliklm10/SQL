use Spring_2021_BaseBall

--People, Batting, Salary, College?, Appearcnces, Pitching, AwardsManagers, AwardsShareManagers
--AwardsPlayers, AwardsSharePlayers, HallOfFame

GO
IF OBJECT_ID('mp766_Player_History', 'V') IS NOT NULL
 DROP VIEW mp766_Player_History;
GO
create view mp766_Player_History
As
with A as (
		   select
		   playerID,
		   people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
		   format(Total_401K, 'C') as Total_401K
		   from 
		   People
		   group by 
		   playerID,
		   people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast,
		   Total_401K
		   ),
	B as (
		  Select
		  playerID,
		  COUNT(distinct teamID) as Teams_Played,
		  Count(yearID) as Years_Played,
		  format((sum(H) * 1.0/sum(AB)), '0.0000') as Batting_Average,
		  sum(HR) as Total_HR
		  from 
		  Batting
		  Where
		  batting.ab > 0
		  group by 
		  playerID
		  ),
	C as (
		  Select
		  playerID,
		  format(avg(salary), 'C') as Average_salary,
		  format(sum(salary), 'C') as Total_salary
		  From
		  Salaries
		  group by 
		  playerID
		  ),
	D as (
		  Select
		  playerID,
		  max(CollegeyearID) as Last_College_Year
		  From
		  CollegePlaying
		  group By
		  playerID
		  ),
	E as (
		  Select
		  playerID,
		  Max(yearID) as Last_Year_Played
		  From
		  Appearances
		  group by
		  playerID
		  ),
	F as (
		  Select
		  playerID,
		  sum(W) as Total_wins,
		  sum(SO) as Total_Strike_outs
		  From
		  Pitching
		  Group By
		  playerID
		  ),
	G as (
		  Select
		  AwardsManagers.playerID,
		  (count(AwardsManagers.awardID) + count(AwardsShareManagers.awardID)) as Manager_Awards
		  From
		  AwardsManagers
		  Left Join
		  AwardsShareManagers On
		  AwardsManagers.playerID = AwardsShareManagers.playerID
		  Group By
		  AwardsManagers.playerID
		  ),
	H as (
		  Select
		  AwardsPlayers.playerID,
		  (count(AwardsPlayers.awardID) + count(AwardsSharePlayers.awardID)) as Player_Awards
		  From
		  AwardsPlayers
		  Left Join
		  AwardsSharePlayers On
		  AwardsPlayers.playerID = AwardsSharePlayers.playerID
		  Group By
		  AwardsPlayers.playerID
		  ),
	I as (
		  Select distinct
		  playerID,
		  yearid as Year_Inducted
		  From
		  HallOfFame
		  where
		  inducted = 'Y'
		  Group By
		  playerID,
		  yearid
		  ),
	J as (
		  Select distinct
		  playerID, 
		  count(yearID) as Times_Nominated
		  From
		  HallOfFame
		  where
		  inducted = 'N'
		  group by
		  playerID
		  ),
	K as (
		  Select distinct
		  playerID,
		  Case
			When inducted = 'Y' Then 'Hall Of Famer'
			else NULL
			end as Hall_Of_Fame
		  From
		  HallOfFame
		  )
		  
Select distinct
A.playerID, A.Fullname, B.Teams_Played, B.Years_Played, C.Average_salary, C.Total_salary, A.Total_401K, 
D.Last_College_Year, E.Last_Year_Played, B.Batting_Average, B.Total_HR, F.Total_wins, F.Total_Strike_outs,
G.Manager_Awards, H.Player_Awards, I.Year_Inducted, J.Times_Nominated, K.Hall_Of_Fame
from 
A
Left Join
B On
A.playerID = B.playerID
Left Join
C On
A.playerID = C.playerID
Left Join
D On
A.playerID = D.playerID
left Join
E On
A.playerID = E.playerID
Left Join 
F On
A.playerID = F.playerID
Left Join
G on
A.playerID = G.playerID
Left Join
H On
A.playerID = H.playerID
Left Join
I On
A.playerID = I.playerID
Left Join
J On
A.playerID = J.playerID
Left join
K On
K.playerID = A.playerID
go
select * from mp766_Player_History
--Just to show I am somewhere within the ballpark lol
select count(*) from mp766_Player_History
select count(*) from People
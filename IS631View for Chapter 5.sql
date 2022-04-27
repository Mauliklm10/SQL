IF OBJECT_ID('IS631view', 'V') IS NOT NULL
    DROP VIEW IS631View;
GO
create view IS631View 
As
With 
Player as
	(Select playerid, nameGiven + ' ( ' + nameFirst + ' ) ' + NameLast as [Full Name]
		from people),
HallofFame1 as
	(Select distinct playerid, inducted 
		from HallofFame where inducted = 'Y'),
AvSalaries as
	(select playerid, avg(Salary) as [Average Salary], sum(salary) as [Total Salary]
		from salaries
		group by playerid), 
Teams as
	(select playerid, count(distinct teamid) as numteams, count(yearid) as yearsPLayed, max(yearid) as LastPlayed
		from appearances
		group by playerid),
College as
	(select distinct collegeplaying.playerid, Lastyear, numcollege, numyears,
		(Select Top 1 schoolid 
			from collegeplaying
			where collegePLaying.playerid = t.playerid and
				collegeplaying.CollegeyearID = t.lastyear) as LastCollege
		from collegeplaying, (select playerid, max(CollegeyearID) as LastYear, count( distinct schoolid) as NumCollege, count(CollegeyearID) as numyears
								from collegeplaying
								group by playerid) T
		where collegeplaying.playerid = t.playerid  and
			collegeplaying.CollegeyearID = t.lastyear),
CareerBat AS
	( select playerid, sum(HR) as CareerRuns, convert(Decimal(6,4),(Sum(H)*1.0/sum(AB))) as CareerBA,
			 Convert(Decimal(6,4),max(H*1.0/AB)) as MaxBA
		from Batting
		where AB > 0
		group by PLayerid),
CareerPitch As
	(select PLayerid, Sum(W) as CareerWins, sum(l) as CareerLoss, Sum(HR) as CareerPHR, Convert(Decimal(5,2),avg(ERA)) as AvgERA, MAX(ERA) as MaxERA, SUm(SO) as [Career SO], max(so) as [High SO]
		from pitching
		group by playerid),
PlayerAwards as 
	(select PLayerid, count(awardID) as PLayerAwards
		from AwardsPlayers
		group by PLayerid),
PlayerAwardsShared as 
(select PLayerid, count(awardID) as PLayerSharedAwards
		from AwardsSharePlayers
		group by PLayerid),
LastTeam as 
	(select distinct appearances.playerid,
		(Select Top 1 TeamID 
			from appearances
			where Appearances.playerid = t.playerid and
				Appearances.yearid = t.Alastyear) as LastTeamID
		from Appearances, (select playerid, max(yearid) as ALastYear
								from Appearances
								group by playerid) T
		where Appearances.playerid = t.playerid  and
			Appearances.yearid = t.Alastyear)
select player.playerid, player.[Full NAme], 
		Case When inducted = 'Y'  Then 'Hall of Famer' ELSE 'No Inducted' end as HallofFamer, 
		[Average Salary], [Total Salary], numteams, yearsplayed, College.lastyear, numcollege, college.numyears, 
		CareerRuns, CareerBA, MaxBA, CareerWins, CareerLoss, CareerPHR, AvgERA, MaxERA, [Career SO], [High SO], 
		LastPlayed
	from player left join college on player.playerid = college.playerid
		left join HallofFame1 on player.playerid = hallofFame1.playerid
		left join AvSalaries on player.playerid = AvSalaries.playerID
		left join Teams on player.playerid = teams.playerid
		left join CareerBat on PLayer.PLayerid = CareerBat.playerid
		left join CareerPitch on player.playerid = CareerPitch.playerid
		left join PlayerAwards on player.playerid = PlayerAwards.playerid
		left join playerAwardsShared on player.playerid = PlayerAwardsShared.playerid
		left join LastTeam on PLayer.playerid = LastTeam.playerID

go
select * from IS631View
select count(*) from IS631View
select count(*) from people

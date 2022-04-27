--1.Using the Batting table, write a query that select the playerid, teamid, Hits (H), Home
--Runs (HR) and Walks (BB) for every player (Slide 15). This query should return 108,789 rows.
Select
playerid,
teamid,
h,
HR,
BB
from Batting
--2.Modify the query you wrote in #1 to be sorted by playerid in descending order and the teamid in ascending order 
--(Slide 34). This query should return 108,789 rows.
Select
playerid,
teamid,
h,
HR,
BB
from Batting
order by playerID DESC, teamid ASC
-- 3.You decide you only want to know the playerid and each team that the player played for. 
--Modify your query in #2 to remove the columns no longer wanted
-- and only return 1 row for each playerid and team combination. 
--You answer should remain sorted by playerid and teamid (Slide 16 Distinct ). This query should return 47,113 rows.
Select Distinct
playerid,
teamid
from Batting
order by playerID DESC, teamid ASC
-- 4.A friend is wondering how many bases a player “touches” in a given year.
--Write a query that calculates the bases touched for each player. You can calculate this by multiplying
-- B2 *2, B3*3 and HR *4 and then adding all these calculated values to the values in BB and H. (Slide 17) and 
--rename the calculated column Total_Bases_Touched.
-- Your output should include the playerid, yearid and teamid in addition to the Totlal_Bases_Touched column. 
--This query should return 108,789 rows
Select
playerID,
yearID,
teamID,
(B2 *2 + B3*3 + HR *4 + BB + H) as Total_Bases_Touched
from Batting
-- 5.Since we are in the New York area, we’re only interested in the NY teams, 
--Modify the query you wrote for #4 by adding a where statement (Slide 22) that only select the 2 NY teams, 
-- the Yankees and the Mets (Teamid equals NYA or NYM) so that only the information for the NY teams is returned. 
--This query should return 4,471 rows.
Select
playerID,
yearID,
teamID,
(B2 *2 + B3*3 + HR *4 + BB + H) as Total_Bases_Touched
from Batting
where teamID IN ('NYA','NYM')
-- 6. Your curious how a player’s “bases touched “compares to the teams for a given
--year. You do this by adding the Teams table to the query (Slide 24) and calculating a
-- Teams_Bases_Touched columns using the same formula for the H, HR, BB, B2 and B3 columns in the teams table.
-- You also want to know the percentage of the teams touched bases each payer was responsible for.
-- Calculated the Touched_% column and use the FORMAT statement for show the results as a 
-- % and with commas(Slide 20 and 29).
-- Only select the 2 NY teams, the Yankees and the Mets (Teamid equals NYA or NYM) so
-- that only the information for the NY teams is returned.
-- Write your query with a FROM statement that uses the format FROM BATTING, TEAMS. Your query should return 4,471 rows.
-- The FROM parameter should be in the format FROM table1, table2 and the join
-- parameters need to be in the WHERE parameter.
Select
batting.playerID,
batting.yearID,
batting.teamID,
(batting.B2 *2 + batting.B3*3 + batting.HR *4 + batting.BB + batting.H) as Total_Bases_Touched,
(teams.B2 *2 + teams.B3*3 + teams.HR *4 + teams.BB + teams.H) as Teams_Bases_Touched,
format(((batting.B2 *2 + batting.B3*3 + batting.HR *4 + batting.BB + batting.H)*1.0/
(teams.B2 *2 + teams.B3*3 + teams.HR *4 + teams.BB + teams.H)),'P') as 'Touched_%'
from Batting, Teams
where batting.teamid = teams.teamid
and batting.yearid = teams.yearid
and batting.lgid = teams.lgid
and teams.teamid IN ('NYA','NYM')
-- 7. Rewrite the query in #6 using a JOIN parameter in the from statement. 
-- The results will be the same. Your query should return 4,471rows
Select
batting.playerID,
batting.yearID,
batting.teamID,
(batting.B2 *2 + batting.B3*3 + batting.HR *4 + batting.BB + batting.H) as Total_Bases_Touched,
(teams.B2 *2 + teams.B3*3 + teams.HR *4 + teams.BB + teams.H) as Teams_Bases_Touched,
format(((batting.B2 *2 + batting.B3*3 + batting.HR *4 + batting.BB + batting.H)*1.0/
(teams.B2 *2 + teams.B3*3 + teams.HR *4 + teams.BB + teams.H)),'P') as 'Touched_%'
from Batting 
Join Teams
ON batting.teamid = teams.teamid
and batting.yearid = teams.yearid
and batting.lgid = teams.lgid
where
teams.teamid IN ('NYA','NYM')
-- 8. Using the PEOPLE table, write a query lists the playerid, the first, last and given
--names for all players that use their initials as their first name (Hint: nameFirst contains at least 1 period(.).
-- See slide 32) Also, concatenate the nameGiven, nameFirst and nameLast into an additional single column called 
-- Full Name putting the nameFirst in parenthesis.
-- For example: James (Jim) Markulic) (Slide 35) and their batting average for 2019.
-- Batting Average is calculated using H/AB from the batting table.
-- The batting_average needs to be formatted with 4 digits behind the decimal point 
-- (research Convert to decimal using Google).
-- Only select the 2 NY teams, the Yankees and the Mets (Teamid equals NYA or NYM)
-- and yearid between 2020 and 2000 so that only the information for the
-- NY teams with the year between 2000 and 2020 are returned. Your query should return 8 rows.
Select
people.playerID,
people.nameFirst,
people.nameLast,
people.nameGiven,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as 'Batting_Average'
from Batting
Join People
ON batting.playerID = people.playerID
where
nameFirst like '%.%'
and batting.teamID IN ('NYA','NYM')
and batting.yearID between '2000' and '2020'
and batting.ab > 0
-- 9.Using a Between clause in the where statement (Slide 38) to return the same data as #8, 
-- but only where the batting averages that are between .2and .4999. 
--The batting_average needs to be formatted with 4 digits behind the decimal point
-- (research Convert to decimal using Google). The results need also the teamid and
-- yearid added and are to be sorted by batting_average in descending order
-- and then playerid and yearid in ascending order. Only select the 2 NY teams, the
-- Yankees and the Mets (Teamid equals NYA or NYM) and yearid between 2020 and 2000
-- so that only the information for the NY teams with the year between 2000 and 2020 are
-- returned. Your query should return 3 rows
Select
people.playerID,
batting.teamID,
batting.yearID,
people.nameFirst,
people.nameLast,
people.nameGiven,
people.nameGiven + ' ( ' + people.nameFirst + ' ) ' + people.nameLast as Fullname,
format(((batting.H * 1.0)/(batting.AB)), '0.0000') as Batting_Average
from Batting
Join People
ON batting.playerID = people.playerID
where
nameFirst like '%.%'
and Batting.teamID IN ('NYA','NYM')
and batting.yearID between '2000' and '2020'
and (batting.h) * 1.0 / (batting.ab) between '0.2000' and '0.4999'
and batting.ab > 0
Order by
Batting_Average DESC,
batting.teamID ASC,
batting.yearID ASC
-- 10. Now you decide to pull all the information you’ve developed together.
-- Write a query that shows the Total_bases_touched in #5, the batting_averages from #9
-- and the player’s name as formatted in #8.
-- You also want to add the teamid and the team’s batting average for the year. As a final
-- piece of information, calculate the percentage of the team’s made up by the player’s batting average.
-- Note, a percentage over 100% indicates the player is better than the average batter on the team.
-- Additionally, rename the tables to only use the first letter of the table in the select and 
-- where statement(ex: FROM TEAMS T).
-- This saves a considerable amount of typing and makes the query easier to read. 
-- Order the results by batting average in descending order then playerid and yearid id ascending order.
-- Eliminate any results where the batting average is .5 or greater as well as where the player has an AB of 50 or less. 
--Your query should return 52,850 rows.
Select
p.playerID,
b.yearID,
t.teamID,
(b.B2 *2 + b.B3*3 + b.HR *4 + b.BB + b.H) as Total_Bases_Touched,
format(((b.H * 1.0)/(b.AB)), '0.0000') as Batting_Average,
format(((t.H * 1.0)/(t.AB)), '0.0000') as Teams_Batting_Average,
p.nameGiven + ' ( ' + p.nameFirst + ' ) ' + p.nameLast as Fullname,
format((((b.H * 1.0)/(b.AB*1.0))/((t.H * 1.0)/(t.AB * 1.0))),'P') as 'BA_%'
from Batting b
Join People p
ON b.playerID = p.playerID
Join Teams t
ON b.yearID = t.yearID
and b.lgid = t.lgid
and b.teamid = t.teamid
where 
(b.h) * 1.0 / (b.ab) < '0.5000'
and b.ab > '50'
Order by
Batting_Average DESC,
b.teamID ASC,
b.yearID ASC
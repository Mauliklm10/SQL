use Baseball_Spring_2020

create function FullName (@playerid varchar(255))
return varchar(255)
as
begin
   declare @s as varchar(255);
   select @s = nameGiven + ' ( ' + NameFirst + ' ) ' + nameLast as FullName from people where people.playerID = @playerID;
   return(@s)
end

go

--select dbo.FullName(playerID) as 'Full Name' from people

select teamid, playerid, [dbo].[FullName](playerID) as 'Full Name', sum(h) as 'Total hits', sum(ab) as 'total At Bats',
format((sum(h)*1.0/sum(ab)),'0.####') as 'Batting Avg'
rank() over (partition by teamid order by format((sum(h)*1.0/sum(ab)), '0.####') desc) as 'Team Batting rank',
rank() over (order by format((sum(h)*1.0/sum(ab)),'0.####') desc) as 'All Batting rank'
from Batting
where ab >  0
group by playerid, teamid
having sum(h) >= 150
order by teamid
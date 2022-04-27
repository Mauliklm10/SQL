--1.Determine the date range of the records in the Temperature table
--First Date	Last Date
--1986-01-01	2017-05-09

select top 10 * from Temperature
select min(Date_Local),max(Date_Last_Change) from Temperature

--2.Find the minimum, maximum and average of the average temperature column for each state sorted by state name.

select AQS_Sites.State_Name,min(cast(Temperature.Average_Temp as float)) as min_temp,max(cast(Temperature.Average_Temp as float)) as max_temp,avg(cast(Temperature.Average_Temp as float)) as avg_temp from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code
group by AQS_Sites.State_Name
order by AQS_Sites.State_Name

--3.The results from question #2 show issues with the database.  Obviously, a temperature of -99 degrees 
--Fahrenheit in Arizona is not an accurate reading as most likely is 135.5 degrees.  Write the queries to 
--find all suspect temperatures (below -39o and above 105o). Sort your output by State Name and Average Temperature.

select AQS_Sites.State_Name,Temperature.State_Code,Temperature.County_Code,Temperature.Site_Num,cast(Temperature.Average_Temp as float) as avg_temp,Temperature.Date_Local from AQS_Sites join Temperature
on AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num 
where cast(Temperature.Average_Temp as float)<-39 or cast(Temperature.Average_Temp as float)>105
order by AQS_Sites.State_Name,cast(Temperature.Average_Temp as float)

--select cast(Average_Temp as float) from Temperature
--where cast(Average_Temp as float)<-39 or cast(Average_Temp as float)>105

--4.You noticed that the average temperatures become questionable below -39 o and above 125 o and that it is 
--unreasonable to have temperatures over 105 o for state codes 30, 29, 37, 26, 18, 38. You also decide that you are 
--only interested in living in the United States, not Canada or the US territories. 
--Create a view that combines the data in the AQS_Sites and Temperature tables. The view should have the 
--appropriate SQL to exclude the data above. You should use this view for all subsequent queries. 
--My view returned 5,616,112 rows. The view includes the State_code, State_Name, County_Code, Site_Number, 
--Make sure you include schema binding in your view for later problems.

CREATE VIEW [tempData1]
AS
select Temperature.State_Code,AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and cast(Temperature.Average_Temp as float) between -39 and  125
and Temperature.State_Code not in('30', '29', '37', '26', '18', '38')
go

select * from [tempData1]

--5.Using the SQL RANK statement, rank the states by Average Temperature

select AQS_Sites.State_Name,min(cast(Temperature.Average_Temp as float)) as min_temp,
max(cast(Temperature.Average_Temp as float)) as max_temp,
avg(cast(Temperature.Average_Temp as float)) as avg_temp,RANK() OVER (ORDER BY avg(cast(Temperature.Average_Temp as float))desc) AS State_rank from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
group by AQS_Sites.State_Name
order by State_rank

--6.At this point, you’ve started to become annoyed at the amount of time each query is taking to run. 
--You’ve heard that creating indexes can speed up queries. Create an index for your view.
--You are required to create an index with the unique and clustered parameters and the index will be on the 
--State_Code, County_Code, Site_Number, Date_Local columns.
--Note: There are a couple of thousand duplicate rows that you must delete before you can create a unique index. 
--I used the Rownumber parameter in a partition statement and deleted any row where the row number was greater than 1.
--To see if the indexing help, add print statements that write the start and stop time for the query 
--in question #2 and run the query before and after the indexes are created. Note the differences in the times. 
--Also make sure that the create index steps include a check to see if the index exists before trying to create it.
--The following is a sample of the output that should appear in the messages tab that you will need to calculate the 
--difference in execution times before and after the indexes are created
--Begin Question 6 before Index Create At - 13:40:03
--(777 row(s) affected)
--Complete Question 6 before Index Create At - 13:45:18
BEGIN
	IF EXISTS (SELECT *  FROM SYS.INDEXES
	WHERE name in (N'index_name') AND object_id = OBJECT_ID('dbo.Temperature'))
	BEGIN
		DROP INDEX index_name ON Temperature
	END
END

Create Index index_name ON Temperature (State_Code, County_Code, Site_Num, Date_Local)

select Temperature.State_Code,AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num,Temperature.date_local,dense_RANK() OVER(ORDER BY Temperature.County_Code) state_temp from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and cast(Temperature.Average_Temp as float) between -39 and  125
and Temperature.State_Code not in('30', '29', '37', '26', '18', '38')

select AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num,Temperature.date_local,count(*) from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and cast(Temperature.Average_Temp as float) between -39 and  125
and Temperature.State_Code not in('30', '29', '37', '26', '18', '38')
group by AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num,Temperature.date_local
having count(*) !>1

WITH stateTemp_CTE(State_Code,State_Name,County_Code,Site_Num,date_local,RN1) AS
    (
    select Temperature.State_Code,AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num,Temperature.date_local,ROW_NUMBER() OVER (PARTITION BY Temperature.State_Code,AQS_Sites.State_Name,Temperature.County_Code,Temperature.Site_Num,Temperature.date_local ORDER BY Temperature.State_Code DESC) as RN1 from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and cast(Temperature.Average_Temp as float) between -39 and  125
and Temperature.State_Code not in('30', '29', '37', '26', '18', '38')
   )
DELETE stateTemp_CTE WHERE [rn1] > 1

select * from stateTemp_CTE

--7.You’ve decided that you want to see the ranking of each high temperatures for each city in each state to see 
--if that helps you decide where to live. Write a query that ranks (using the rank function) the states by averages 
--temperature and then ranks the cities in each state. The ranking of the cities should restart at 1 when the query 
--returns a new state. You also want to only show results for the 15 states with the highest average temperatures.
--Note: you will need to use multiple nested queries to get the State and City rankings, join them together and 
--then apply a where clause to limit the state ranks shown.

select 
RANK() OVER(order by Temperature.Average_Temp desc) state_rank,
AQS_Sites.State_Name as state_name,
rank() OVER(partition by State_Name order by aqs_sites.city_name desc) state_city_rank,
AQS_Sites.City_Name as city_name,
Temperature.Average_Temp as avg_temp
from 
AQS_Sites,
Temperature
where 
AQS_Sites.State_Code=Temperature.State_Code 
and AQS_Sites.County_Code=Temperature.County_Code 
and AQS_Sites.Site_Number=Temperature.Site_Num 
group by 
Temperature.Average_Temp,
AQS_Sites.State_Name,
AQS_Sites.City_Name


select AQS_Sites.State_Name,City_Name,Temperature.Average_Temp,
(select rank () over (order by Temperature.Average_Temp desc) as State_Rank from Temperature where AQS_Sites.State_Code=Temperature.State_Code),
(select rank () over (partition by State_Name order by Temperature.Average_Temp desc) as State_City_Rank from AQS_Sites where AQS_Sites.State_Code=Temperature.State_Code)
from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num 
go

--8.You notice in the results that sites with Not in a City as the City Name are include but do not provide 
--you useful information. Exclude these sites from all future answers. You can do this by either adding it to 
--the where clause in the remaining queries or updating the view you created in #4

select RANK() OVER(order by Temperature.Average_Temp desc) state_temp,AQS_Sites.State_Name,AQS_Sites.City_Name,rank() OVER(partition by State_Name order by aqs_sites.city_name desc) city_temp,Temperature.Average_Temp from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num 
and AQS_Sites.City_Name not like 'Not in a C%'
group by Temperature.Average_Temp,AQS_Sites.State_Name,AQS_Sites.City_Name

--9.You’ve decided that the results in #8 provided too much information and you only want to 2 cities with the 
--highest temperatures and group the results by state rank then city rank. 

select 
RANK() OVER(order by Temperature.Average_Temp desc) state_temp,
AQS_Sites.State_Name,
AQS_Sites.City_Name,
rank() OVER(partition by State_Name order by aqs_sites.city_name desc) city_temp,
Temperature.Average_Temp 
from AQS_Sites,Temperature
where 
AQS_Sites.State_Code=Temperature.State_Code 
and AQS_Sites.County_Code=Temperature.County_Code 
and AQS_Sites.Site_Number=Temperature.Site_Num 
group by 
Temperature.Average_Temp,
AQS_Sites.State_Name,
AQS_Sites.City_Name


--10.	You decide you like the average temperature to be in the 80's.
--Pick 2 cities that meets this condition and calculate the average temperature by month for those 2 cities. 
--You also decide to include a count of the number of records for each of the cities to make sure your comparisons 
--are being made with comparable data for each city. 

select 
AQS_Sites.City_Name,
DATEPART(month, Temperature.Date_Local) [month],
Count(Average_Temp) [# of Records],
avg(cast(Average_Temp as float)) as avg_temp
from AQS_Sites, Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and AQS_Sites.City_Name='Mission'
group by AQS_Sites.City_Name,Temperature.Date_Local,Temperature.Average_Temp
order by DATEPART(month, Temperature.Date_Local)

--11.	You assume that the temperatures follow a normal distribution and that the majority of the temperatures 
--will fall within the 40% to 60% range of the cumulative distribution. Using the CUME_DIST function,
--show the temperatures for the same 3 cities that fall within the range.

select AQS_Sites.City_Name,cast(Temperature.Average_Temp as float),CUME_DIST()over (order by cast(Temperature.average_temp as float)) as cum from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
and AQS_Sites.City_Name='Mission' 

--group by AQS_Sites.City_Name,Temperature.Average_Temp

--12.	You decide this is helpful, but too much information. You decide to write a query that shows the 
--first temperature and the last temperature that fall within the 40% and 60% range for the 
--3 cities your focusing on.
select AQS_Sites.City_Name,min(cast(Temperature.Average_Temp as float)) as min_temp,CUME_DIST()over (order by cast(Temperature.average_temp as float)) as mt,max(cast(Temperature.Average_Temp as float))as max_temp,CUME_DIST()over (order by cast(Temperature.average_temp as float)) as mat from AQS_Sites,Temperature
where AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num
group by AQS_Sites.City_Name,Temperature.Average_Temp
--and AQS_Sites.City_Name='Mission'


--13.You remember from your statistics classes that to get a smoother distribution of the temperatures and 
--eliminate the small daily changes that you should use a moving average instead of the actual temperatures.
--Using the windowing within a ranking function to create a 4 day moving average, calculate the moving average 
--for each day of the year. 

select 
RANK() OVER(order by Temperature.Average_Temp desc) state_temp,
AQS_Sites.State_Name,
AQS_Sites.City_Name,
rank() OVER(partition by State_Name order by aqs_sites.city_name desc) city_temp,
Temperature.Average_Temp 
from 
AQS_Sites,Temperature
where 
AQS_Sites.State_Code=Temperature.State_Code and AQS_Sites.County_Code=Temperature.County_Code and AQS_Sites.Site_Number=Temperature.Site_Num 
and AQS_Sites.City_Name not like 'Not in a C%'
group by 
Temperature.Average_Temp,AQS_Sites.State_Name,AQS_Sites.City_Name

--1.Determine the date range of the records in the Temperature table

select 
min(Date_Local) as first_date, 
max(Date_Local) as last_date
from Temperature

-- 2.Find the minimum, maximum and average temperature for each state

select 
State_Name, 
min(cast(Temperature.Average_Temp as float)) as min_temp, 
max(cast(Temperature.Average_Temp as float)) as max_temp, 
avg(cast(Temperature.Average_Temp as float)) as avg_temp
from 
AQS_Sites,
Temperature
where 
AQS_Sites.State_Code=Temperature.State_Code
group by 
AQS_Sites.State_Name
order by 
AQS_Sites.State_Name

--3.The results from question #2 show issues with the database.  Obviously, a temperature of -99 degrees 
--Fahrenheit in Arizona is not an accurate reading as most likely is 135.5 degrees.  Write the queries to 
--find all suspect temperatures (below -39o and above 105o). Sort your output by State Name and Average Temperature.

select 
AQS_Sites.State_Name,
Temperature.State_Code,
Temperature.County_Code,
Temperature.Site_Num,
cast(Temperature.Average_Temp as float) as avg_temp,
Temperature.Date_Local 
from 
AQS_Sites 
join 
Temperature
on AQS_Sites.State_Code=Temperature.State_Code 
and AQS_Sites.County_Code=Temperature.County_Code 
and AQS_Sites.Site_Number=Temperature.Site_Num 
where 
cast(Temperature.Average_Temp as float)<-39 or cast(Temperature.Average_Temp as float)>105
order by 
AQS_Sites.State_Name,
cast(Temperature.Average_Temp as float)

--4.You noticed that the average temperatures become questionable below -39 o and above 125 o and that it is 
--unreasonable to have temperatures over 105 o for state codes 30, 29, 37, 26, 18, 38. You also decide that you are 
--only interested in living in the United States, not Canada or the US territories. 
--Create a view that combines the data in the AQS_Sites and Temperature tables. The view should have the 
--appropriate SQL to exclude the data above. You should use this view for all subsequent queries. 
--My view returned 5,616,112 rows. The view includes the State_code, State_Name, County_Code, Site_Number, 
--Make sure you include schema binding in your view for later problems.

IF EXISTS(select * FROM sys.views where name = 'New_Temperature_Data')
DROP VIEW New_Temperature_Data

GO
CREATE VIEW New_Temperature_Data AS
WITH
Temperature_Data AS
(
SELECT 
*
FROM 
Temperature
WHERE 
cast(Temperature.Average_Temp as float) between -39 and  125
),
AQS_data AS 
(
SELECT 
*
FROM 
AQS_Sites
WHERE 
State_Name NOT IN ('Canada','Country Of Mexico','District Of Columbia','Guam','Puerto Rico','Virgin Islands')
)

SELECT 
Temperature_Data.State_Code, 
State_Name, 
Temperature_Data.County_Code, 
Temperature_Data.Site_Num, 
Average_Temp,
City_Name,
Date_Local
FROM 
Temperature_Data, 
AQS_data
WHERE 
Temperature_Data.State_Code = AQS_data.State_Code 
AND Temperature_Data.Site_Num = AQS_data.Site_Number 
AND  Temperature_Data.County_Code = AQS_data.County_Code

GO
BEGIN
Select * from New_Temperature_Data
END

-- 5.	Using the SQL RANK statement, rank the states by Average Temperature

SELECT 
State_Name, 
MIN(Average_Temp) AS min_temp, 
MAX(ABS(Average_Temp)) AS max_temp, 
avg(cast(Average_Temp as float)) as avg_temp, 
RANK() OVER(ORDER BY avg(cast(Average_Temp as float)) DESC) AS State_rank
FROM 
New_Temperature_Data
GROUP BY 
State_Name
ORDER BY 
State_rank

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

DECLARE @StartTime datetime
DECLARE @EndTime datetime
SELECT @StartTime = GETDATE()

Print 'Before Question 6, the execution of the query started at - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

select 
State_Name, 
min(cast(Average_Temp as float)) as min_temp, 
max(cast(Average_Temp as float)) as max_temp, 
avg(cast(Average_Temp as float)) as avg_temp
from 
New_Temperature_Data
group by 
State_Name
order by 
State_Name

PRINT 'Before Question 6, the execution of the query ended at - ' + (CAST(convert(varchar,getdate(),108) AS nvarchar(30)))

GO
BEGIN
	IF EXISTS (SELECT *  FROM SYS.INDEXES
	WHERE name in (N'Date_Local_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
	BEGIN
		DROP INDEX Date_Local_Index ON Temperature
	END
END

GO
Create Index Date_Local_Index ON Temperature (Date_Local)

GO
	BEGIN
	IF EXISTS (SELECT *  FROM SYS.INDEXES
	WHERE name in (N'Temp_Index') AND object_id = OBJECT_ID('dbo.Temperature'))
	BEGIN
		DROP INDEX Temp_Index ON Temperature
	END
END

GO
Create Index Temp_Index ON Temperature (State_Code, County_Code, Site_Num)

GO
BEGIN
	IF EXISTS (SELECT *  FROM SYS.INDEXES
	WHERE name in (N'AQS_Index') AND object_id = OBJECT_ID('dbo.aqs_sites'))
	BEGIN
		DROP INDEX AQS_Index ON aqs_sites
	END
END

GO
Create Index AQS_Index ON AQS_Sites (State_Code,county_code, Site_Number)

GO
DECLARE @StartTimeAfterIndex datetime
DECLARE @EndTimeAfterIndex datetime
SELECT @StartTimeAfterIndex = GETDATE()

Print 'After Question 6, the execution of the query started at - ' + (CAST(CONVERT(VARCHAR, GETDATE(),108) AS NVARCHAR(30)))

select 
State_Name, 
min(cast(Average_Temp as float)) as min_temp, 
max(cast(Average_Temp as float)) as max_temp, 
avg(cast(Average_Temp as float)) as avg_temp
from 
New_Temperature_Data
group by 
State_Name
order by 
State_Name

PRINT 'After Question 6, the execution of the query ended at - ' + (CAST(CONVERT(VARCHAR, GETDATE(),108) AS NVARCHAR(30)))

WITH stateTemp_CTE(State_Code,State_Name,County_Code,Site_Num,date_local,RN1) AS
(
select 
State_Code,
State_Name,
County_Code,
Site_Num,
date_local,
ROW_NUMBER() OVER (PARTITION BY State_Code,State_Name,County_Code,Site_Num,date_local ORDER BY State_Code DESC) as RN1 
from 
New_Temperature_Data
where 
cast(Average_Temp as float) between -39 and  125
)
DELETE stateTemp_CTE WHERE [rn1] > 1

--7.You’ve decided that you want to see the ranking of each high temperatures for each city in each state to see 
--if that helps you decide where to live. Write a query that ranks (using the rank function) the states by averages 
--temperature and then ranks the cities in each state. The ranking of the cities should restart at 1 when the query 
--returns a new state. You also want to only show results for the 15 states with the highest average temperatures.
--Note: you will need to use multiple nested queries to get the State and City rankings, join them together and 
--then apply a where clause to limit the state ranks shown.

select 
RANK() OVER(order by Average_Temp desc) state_rank,
State_Name as state_name,
rank() OVER(partition by AQS_Sites.State_Name order by city_name desc) state_city_rank,
City_Name as city_name,
Average_Temp as avg_temp
from 
New_Temperature_Data
group by 
Average_Temp,
State_Name,
City_Name

--8.You notice in the results that sites with Not in a City as the City Name are include but do not provide 
--you useful information. Exclude these sites from all future answers. You can do this by either adding it to 
--the where clause in the remaining queries or updating the view you created in #4

select 
RANK() OVER(order by Average_Temp desc) state_rank,
State_Name as state_name,
rank() OVER(partition by AQS_Sites.State_Name order by city_name desc) state_city_rank,
City_Name as city_name,
Average_Temp as avg_temp
from 
New_Temperature_Data
Where
City_Name <> 'Not in a City'
group by 
Average_Temp,
State_Name,
City_Name

--9.You’ve decided that the results in #8 provided too much information and you only want to 2 cities with the 
--highest temperatures and group the results by state rank then city rank. 

-- State_Rank	State_Name	State_City_Rank	City_Name		Average Temp
-- 1		Florida		1			Pinellas Park		72.878784
-- 1		Florida		2			Valrico			71.729440
-- 2		Louisiana	1			Baton Rouge		69.704466
-- 2		Louisiana	2			Laplace (La Place)	68.115400

select 
RANK() OVER(order by Average_Temp desc) as state_rank,
State_Name as state_name,
rank() OVER(partition by AQS_Sites.State_Name order by city_name desc) as state_city_rank,
City_Name as city_name,
Average_Temp as avg_temp
from 
New_Temperature_Data
Where
City_Name <> 'Not in a City'
group by 
RANK() OVER(order by Average_Temp desc),
rank() OVER(partition by State_Name order by city_name desc)

--10.	You decide you like the average temperature to be in the 80's.
--Pick 2 cities that meets this condition and calculate the average temperature by month for those 2 cities. 
--You also decide to include a count of the number of records for each of the cities to make sure your comparisons 
--are being made with comparable data for each city. 

SELECT 
City_Name [City Name],
DATEPART(MONTH,Date_Local) [Month],
Count(Average_Temp) [# of Records], 
avg(cast(Average_Temp as float)) as avg_temp
from 
New_Temperature_Data
where 
City_Name in ('Mission','Pinellas Park','Tucson') 
and City_Name <> 'Not in a City'
Group by 
City_Name,DATEPART(MONTH,Date_Local) 
Order by 
City_Name ,DATEPART(MONTH,Date_Local) 

--11.	You assume that the temperatures follow a normal distribution and that the majority of the temperatures 
--will fall within the 40% to 60% range of the cumulative distribution. Using the CUME_DIST function,
--show the temperatures for the same 3 cities that fall within the range.

SELECT 
City_Name [City_Name], 
Average_Temp [Avg_Temp], 
CumeDist [Temp_Cume_Dist]
FROM
(
SELECT distinct 
City_Name, 
Average_Temp, 
CUME_DIST () OVER (PARTITION BY city_name ORDER BY Average_Temp) AS CumeDist
from 
New_Temperature_Data
Where 
City_Name in ('Mission','Pinellas Park','Tucson') 
and City_Name <> 'Not in a City'
) A
Where 
ROUND(A.CumeDist,3)> 0.400 
and ROUND(A.CumeDist,3)< 0.600
Order by 
A.City_Name,
A.Average_Temp,
A.CumeDist

--12.	You decide this is helpful, but too much information. You decide to write a query that shows the 
--first temperature and the last temperature that fall within the 40% and 60% range for the 
--3 cities your focusing on.

SELECT 
AB.City_Name,
MIN(AB.Avg_Temp) [40 Percentile Temp],
MAX(AB.Avg_Temp) [60 Percentile Temp]
FROM
(
SELECT 
City_Name [City_Name], 
Average_Temp [Avg_Temp], 
CumeDist [Temp_Cume_Dist]
FROM
(
SELECT distinct 
City_Name, 
Average_Temp, 
CUME_DIST () OVER (PARTITION BY city_name ORDER BY Average_Temp) AS CumeDist
from 
New_Temperature_Data
Where 
City_Name in ('Mission','Pinellas Park','Tucson') 
and City_Name <> 'Not in a City'
) A
Where 
ROUND(A.CumeDist,3)> 0.400 
and ROUND(A.CumeDist,3)< 0.600
) AB
Group by 
AB.City_Name

--13.You remember from your statistics classes that to get a smoother distribution of the temperatures and 
--eliminate the small daily changes that you should use a moving average instead of the actual temperatures.
--Using the windowing within a ranking function to create a 4 day moving average, calculate the moving average 
--for each day of the year. 

SELECT 
A.[City Name],
A.DayYear,
avg(cast(avg_temp as float)) over(partition by [City Name] order by DayYear rows between 3 preceding and 1 following) as [Rolling Avg Temp]
FROM
(
SELECT 
City_Name [City Name],
DATEPART(DAYOFYEAR,Date_Local) [DayYear],
avg(cast(Average_Temp as float)) as avg_temp
from 
New_Temperature_Data 
WHERE 
City_Name in ('Mission','Pinellas Park','Tucson') 
and City_Name <> 'Not in a City'
group by 
City_Name, DATEPART(DAYOFYEAR,Date_Local)
) A
order by 
[City Name],
DayYear
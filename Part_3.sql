use Weather
select * from guncrimes

alter table dbo.guncrimes add [GeoLocation] geography

UPDATE [dbo].[guncrimes]
SET [GeoLocation] = geography::Point([Latitude], [Longitude], 4326)
where latitude is not null

Declare @h geography;
Set @h = geography::STGeomFromText('POINT(-119.417932 36.778261)', 4326);
select distinct
case when local_site_name = '' or Local_Site_Name is null
then Site_Number + ' ' + city_name
else
case when local_site_name is not null or local_site_name
= ''
then Local_Site_Name
END
END
as local_site_name, city_name, DATEPART(year, [Date]) as
Crime_Year,
count(incident_id) as Shooting_Count
from AQS_Sites, guncrimes
where guncrimes.GeoLocation.STDistance(@h) < 16000
and State_Name = 'california'
group by City_Name, DATEPART(year, [Date]), Local_Site_Name, Site_Number
order by City_Name, DATEPART(year, [Date])

select distinct 
state, 
city_or_county, 
dense_rank () over (order by count(incident_id) asc) as City_Rank,
count(incident_id) as Crime_Count
from guncrimes
where state like 'california'
group by city_or_county, [state]
Order by
count(incident_id) ASC
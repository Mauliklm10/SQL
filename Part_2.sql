IF NOT EXISTS(
    SELECT *
    FROM sys.columns 
    WHERE Name = N'GeoLocation'
    AND Object_ID = Object_ID(N'AQS_Sites'))
BEGIN
      ALTER TABLE AQS_Sites ADD GeoLocation Geography NULL
END

go
alter table dbo.AQS_Sites 
add GeoLocation GEOGRAPHY
go

UPDATE [dbo].[AQS_Sites]
SET [GeoLocation] = geography::Point([Latitude], [Longitude], 4326)
GO

IF EXISTS ( SELECT  *
            FROM    sys.objects
            WHERE   object_id = OBJECT_ID(N'mp766_Fall2021_Calc_GEO_Distance')
                    AND type IN ( N'P', N'PC' ) ) 
BEGIN
DROP PROCEDURE dbo.mp766_Fall2021_Calc_GEO_Distance
END
GO

Create PROCEDURE dbo.mp766_Fall2021_Calc_GEO_Distance
@longitude NVARCHAR(255),
@latitude NVARCHAR(255),
@State VARCHAR(Max),
@rownum bigint
as
Begin
    SET NOCOUNT ON; 
    DECLARE @h GEOGRAPHY
    SET @h = geography::Point(@latitude, @longitude, 4326);
    with calculate_distance
    as
    (select 
    TOP (@rownum) GeoLocation.STDistance(@h) as [Distance_In_Meters], 
    GeoLocation.STDistance(@h)/80000 as [Hours_of_Travel],
    State_Name,
    (CASE
    when Local_Site_Name is null or Local_Site_Name = ''
    Then concat(convert(varchar, Site_Number), City_Name) 
    else Local_Site_Name
    end) as [Local_Site_Names],
    Zip_Code,
    Latitude, Longitude

    from AQS_Sites
    where State_Name = @State
    AND GeoLocation IS NOT NULL
    )
    select [Distance_In_Meters], Hours_of_Travel, Local_Site_Names,
    State_Name,
    Zip_Code,
    Latitude, Longitude 
    from calculate_distance
    where Zip_Code is not null 
END
GO 
EXEC mp766_Fall2021_Calc_GEO_Distance @longitude='-86.472891', @latitude='32.437458', @State="Alabama", @rownum=1000

--Example 1
USE [Weather]
GO
DECLARE @RC int
DECLARE @longitude NVARCHAR(255)
DECLARE @latitude NVARCHAR(255)
DECLARE @State VARCHAR(Max)
DECLARE @rownum bigint
SET @rownum = 20
SET @longitude = '-74.426598'
SET @latitude = '40.4991'
SET @State = 'Arizona'
EXECUTE @RC = [dbo].[mp766_Fall2021_Calc_GEO_Distance]
 @longitude
 ,@latitude
 ,@State
 ,@rownum
GO
--Example 2
USE [Weather]
GO
DECLARE @RC int
DECLARE @longitude NVARCHAR(255)
DECLARE @latitude NVARCHAR(255)
DECLARE @State VARCHAR(Max)
DECLARE @rownum bigint
SET @rownum = 20
SET @longitude = '-74.426598'
SET @latitude = '40.4991'
SET @State = 'Maryland'
EXECUTE @RC = [dbo].[mp766_Fall2021_Calc_GEO_Distance]
 @longitude
 ,@latitude
 ,@State
 ,@rownum
GO





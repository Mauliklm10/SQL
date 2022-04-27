ALTER TABLE People
ADD 
NJITID_Date_Last_Update varchar (255) NULL,
NJITID_Total_Games_Played INT DEFAULT NULL

GO

DECLARE 
@today DATE

SET 
@today = convert(DATE, getdate())

DECLARE 
@NJITID_Total_Games_Played INT,
@PlayerID VARCHAR(50)

DECLARE 
updatecursor CURSOR STATIC FOR

SELECT 
Appearances.playerID, 
SUM (G_all) AS NJITID_Total_Games_Played
FROM 
People, 
Appearances
WHERE 
People.playerID = Appearances.playerid and
(NJITID_Date_Last_Update <> @today or NJITID_Date_Last_Update is Null)
GROUP BY 
Appearances.playerID

OPEN 
updatecursor

Select 
@@CURSOR_ROWS as 'Number of Cursor Rows After Declare'
FETCH NEXT FROM 
updatecursor INTO @PLayerid, @NJITID_Total_Games_Played
WHILE 
@@fetch_status = 0
BEGIN

UPDATE People
SET 
NJITID_Date_Last_Update = @today
WHERE 
@PlayerID = playerID

UPDATE People
SET 
@NJITID_Total_Games_Played = @NJITID_Total_Games_Played
WHERE 
@PlayerID = playerID
FETCH NEXT FROM 
updatecursor INTO @PLayerid, @NJITID_Total_Games_Played
END

Select
playerID,
@NJITID_Total_Games_Played,
@NJITID_Date_Last_Update
from
People

CLOSE updatecursor
DEALLOCATE updatecursor
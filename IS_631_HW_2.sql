ALTER TABLE People ADD PRIMARY KEY(playerID)
ALTER TABLE Schools ADD PRIMARY KEY(schoolID)
--ALTER TABLE CollegePlaying ADD playerID [varchar] (255),FOREIGN KEY(playerID) REFERENCES dbo.People(playerID)
ALTER TABLE CollegePlaying ADD FOREIGN KEY(playerID) REFERENCES dbo.People(playerID)
ALTER TABLE CollegePlaying ADD FOREIGN KEY(schoolID) REFERENCES Schools(schoolID)
ALTER TABLE CollegePlaying ADD CONSTRAINT CHK_YEARID CHECK (CollegeyearID<=1864 AND CollegeyearID>=2014)
--FOREIGN KEY [playerID] REFERENCES dbo.People[playerID],
--FOREIGN KEY [schoolID] REFERENCES dbo.Schools[schoolID]
ALTER TABLE CollegePlaying ADD PRIMARY KEY(playerID, schoolID, CollegeyearID)
--CONSTRAINT FK_PLAYERID
--CONSTRAINT FK_SCHOOLID

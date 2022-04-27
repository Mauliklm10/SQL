ALTER TABLE People ALTER COLUMN playerID varchar (255) NOT NULL
Alter Table People Add Primary Key (playerID)
ALTER TABLE AllstarFull ADD FOREIGN KEY (playerID) REFERENCES People (playerID)
ALTER TABLE Batting ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE AwardsPlayers ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE AwardsSharePlayers ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE Managers ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE AwardsShareManagers ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE AwardsManagers ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE Fielding ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE HallOfFame ADD FOREIGN KEY (playerID) REFERENCES people (playerID)
ALTER TABLE Pitching ADD FOREIGN KEY (playerID) REFERENCES people (playerID)

ALTER TABLE TeamsFranchises ALTER COLUMN franchID varchar (255) NOT NULL
Alter Table TeamsFranchises Add Primary Key (franchID)
alter table Teams ADD FOREIGN KEY (franchID) REFERENCES TeamsFranchises (franchID)

Alter Table Teams Alter Column yearID [int] NOT NULL
Alter Table Teams Alter Column lgID varchar (25) NOT NULL
Alter Table Teams Alter Column teamID varchar (255) NOT NULL
Alter Table Teams Add Primary Key (yearID,lgID,teamID)
alter table HomeGames ADD FOREIGN KEY (yearID,lgID,teamID) REFERENCES Teams (yearID,lgID,teamID)
alter table Managers ADD FOREIGN KEY (yearID,lgID,teamID) REFERENCES Teams (yearID,lgID,teamID)

ALTER TABLE HomeGames ADD park_key varchar (255) NULL
Alter Table Parks Alter Column park_key varchar (255) NOT NULL
Alter Table Parks Add primary key (park_key)
alter table HomeGames ADD FOREIGN KEY (park_key) REFERENCES Parks (park_key)

-- Create Primary keys for the references and make sure the order is the same in the creation of the primary key as well as the creation of the foreign keys

select * from Salaries
delete from Salaries
where playerid not in (select playerid from People)

ALTER TABLE Salaries ADD FOREIGN KEY (playerID) REFERENCES people (playerID)

select Appearances.playerID
from
Appearances
Left Join
People On
Appearances.playerID = People.playerID
where
Appearances.playerID Not In (select playerid from People)

delete from Appearances where playerID='thompan01'

ALTER TABLE Appearances ADD FOREIGN KEY (playerID) REFERENCES people (playerID)

CREATE TABLE [dbo].[League](
[LgID] [varchar] (25) not NULL
) ON [PRIMARY]

Alter Table League Add Primary Key (lgID)

insert into League
select distinct LgID
from [dbo].[Teams]

ALTER TABLE Teams ADD FOREIGN KEY (lgID) REFERENCES dbo.League (lgID)

--Alter Table League Alter Column lgID [varchar] (25) NOT NULL

--Insert into league values ('ML')

ALTER TABLE AwardsManagers ADD FOREIGN KEY (lgID) REFERENCES League (lgID)

ALTER TABLE CollegePlaying ALTER COLUMN playerID varchar (255) NOT NULL
ALTER TABLE CollegePlaying ALTER COLUMN schoolID varchar (255) NOT NULL
ALTER TABLE CollegePlaying ALTER COLUMN CollegeyearID int NOT NULL
ALTER TABLE CollegePlaying ADD PRIMARY KEY(playerID, schoolID, CollegeyearID)
ALTER TABLE CollegePlaying ADD FOREIGN KEY(playerID) REFERENCES People(playerID)
ALTER TABLE CollegePlaying ADD FOREIGN KEY(schoolID) REFERENCES Schools(schoolID)
--FOREIGN KEY [playerID] REFERENCES dbo.People[playerID],
--FOREIGN KEY [schoolID] REFERENCES dbo.Schools[schoolID]

ALTER TABLE schools ALTER COLUMN SchoolID varchar (255) NOT NULL
alter table schools add primary key (schoolID)


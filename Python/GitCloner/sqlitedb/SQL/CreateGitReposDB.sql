
/*
File: CreateGitReposDB.sql
	
Create Database: 
C:\opt\sqlite\sqlite3 GitRepos.s3db

List Database:
sqlite>.databases

Exit Sqlite:
sqlite>.quit

Dump Database to text file:
sqlite3 GitRepos.s3db .dump > GitRepos.sql

Here's an example of using ATTACH DATABASE to create a database:
ATTACH DATABASE 'GitRepos.s3db' AS GitRepos;

*/


/*
Create Tables:
*/
CREATE TABLE [Repos] (
[ID] INTEGER  NOT NULL PRIMARY KEY,
[RepoUrl] VARCHAR(500)  NOT NULL,
[ProjectName] VARCHAR(50)  NOT NULL
);

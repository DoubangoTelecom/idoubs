########### History Database ##############

sqlite3 HistoryDatabase.sql '

--
-- Audio/Video History Table
--
DROP TABLE if EXISTS hist_av;
CREATE TABLE hist_av(
	id INTEGER PRIMARY KEY, 
	seen TINYINT(1),
	status TINYINT(1),
	type TINYINT(1),
	remoteParty TEXT,
	start DOUBLE,
	end DOUBLE
);


'

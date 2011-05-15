-- sqlite3 NgnDataBase.db && .read ./NgnDataBase.sql

--					--
-- Application Info --
--					--
CREATE TABLE app_info(
	id INTEGER PRIMARY KEY,
	softVersion INTEGER,
	databaseVersion INTEGER 
);

--			--
--	History --
--			--

CREATE TABLE hist_event( 
	id INTEGER PRIMARY KEY, 
	seen TINYINT(1),
	status TINYINT(1),
	type TINYINT(1),
	remoteParty TEXT,
	start DOUBLE,
	end DOUBLE
);

CREATE TABLE hist_event_av(
	id INTEGER PRIMARY KEY, 
	hist_event_id INTEGER,
	
	FOREIGN KEY(hist_event_id) REFERENCES hist_event(id)
);

CREATE TABLE hist_event_msg(
	id INTEGER PRIMARY KEY, 
	hist_event_id INTEGER,
	BLOB content,
	
	FOREIGN KEY(hist_event_id) REFERENCES hist_event(id)
);
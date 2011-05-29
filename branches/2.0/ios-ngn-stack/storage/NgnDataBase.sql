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
	status TINYINT(8),
	mediaType TINYINT(8),
	remoteParty TEXT,
	start DOUBLE,
	end DOUBLE,
	content BLOB
);

--			--
--	Favorites --
--			--

CREATE TABLE favorites( 
	id INTEGER PRIMARY KEY, 
	number TEXT,
	mediaType TINYINT(8)
);
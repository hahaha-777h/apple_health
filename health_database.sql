CREATE TABLE health_dates (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	record_date DATE UNIQUE NOT NULL
);

CREATE TABLE health_metrics (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	health_date_id INTEGER,
	step_count INTEGER,
	burned_energy INTEGER,
	flights_climbed INTEGER,
	headphone_volume REAL,
	walking_speed REAL,
	step_length REAL,
	FOREIGN KEY(health_date_id) REFERENCES health_dates(id)
);

PRAGMA foreign_key=ON;
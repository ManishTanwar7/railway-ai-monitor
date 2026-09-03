-- ====================================================================
-- INDIAN RAILWAYS &bull; CRIS NATIONAL AUTONOMOUS MONITORING SYSTEM
-- 10+ INTERLINKED STATIONS SQL DATASHEET & NETWORK TOPOLOGY
-- CORRIDOR: NEW DELHI (NDLS) -> VARANASI JN (BSB) VIA KANPUR CENTRAL
-- ====================================================================

DROP TABLE IF EXISTS ai_decisions;
DROP TABLE IF EXISTS live_train_tracking;
DROP TABLE IF EXISTS station_platforms;
DROP TABLE IF EXISTS track_signals;
DROP TABLE IF EXISTS interlinked_tracks;
DROP TABLE IF EXISTS stations;

-- --------------------------------------------------------------------
-- 1. STATIONS TABLE (11 INTERLINKED STATIONS ACROSS 805 KM CORRIDOR)
-- --------------------------------------------------------------------
CREATE TABLE stations (
    station_code VARCHAR(10) PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    division VARCHAR(50) NOT NULL,
    zone VARCHAR(10) NOT NULL,
    chainage_km REAL NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    altitude_m REAL NOT NULL,
    platform_count INT NOT NULL,
    junction_category VARCHAR(50) NOT NULL,
    kavach_station_unit_installed BOOLEAN DEFAULT TRUE
);

INSERT INTO stations VALUES 
('NDLS', 'New Delhi', 'Delhi', 'NR', 0.0, 28.6139, 77.2090, 215.0, 16, 'High Density Terminal Hub', 1),
('GZB',  'Ghaziabad Junction', 'Delhi', 'NR', 26.0, 28.6692, 77.4538, 214.0, 6, 'Interlocking Junction Hub', 1),
('ALJN', 'Aligarh Junction', 'Prayagraj', 'NCR', 131.0, 27.8974, 78.0880, 187.0, 7, 'Intermediate Junction', 1),
('TDL',  'Tundla Junction', 'Prayagraj', 'NCR', 209.0, 27.2069, 78.2384, 167.0, 5, 'Crew Change & Freight Divert', 1),
('ETW',  'Etawah Junction', 'Prayagraj', 'NCR', 301.0, 26.7769, 79.0306, 153.0, 5, 'Main Bypass Junction', 1),
('CNB',  'Kanpur Central', 'Prayagraj', 'NCR', 440.0, 26.4539, 80.3507, 126.0, 10, 'Central Divisional Mega-Hub', 1),
('FTP',  'Fatehpur', 'Prayagraj', 'NCR', 518.0, 25.9286, 80.8130, 118.0, 4, 'Intermediate Junction', 1),
('PRYJ', 'Prayagraj Junction', 'Prayagraj', 'NCR', 635.0, 25.4358, 81.8463, 102.0, 10, 'Headquarters Divisional Hub', 1),
('MZP',  'Mirzapur', 'Prayagraj', 'NCR', 724.0, 25.1337, 82.5644, 85.0, 4, 'River Corridor Hub', 1),
('DDU',  'Pt. Deen Dayal Upadhyaya Jn', 'Pt DDU', 'ECR', 787.0, 25.2818, 83.1206, 76.0, 8, 'Marshalling & Strategic Yard', 1),
('BSB',  'Varanasi Junction', 'Lucknow', 'NR', 805.0, 25.3268, 82.9876, 80.0, 9, 'High-Priority Terminal Hub', 1);

-- --------------------------------------------------------------------
-- 2. INTERLINKED TRACK SECTIONS (CONNECTING ALL 11 STATIONS)
-- --------------------------------------------------------------------
CREATE TABLE interlinked_tracks (
    track_id VARCHAR(20) PRIMARY KEY,
    source_station VARCHAR(10) NOT NULL,
    destination_station VARCHAR(10) NOT NULL,
    segment_distance_km REAL NOT NULL,
    track_type VARCHAR(50) NOT NULL,
    speed_limit_kmh REAL NOT NULL,
    gradient_per_thousand REAL NOT NULL,
    electrification_type VARCHAR(20) DEFAULT '25kV AC 50Hz',
    kavach_rfid_tags_count INT NOT NULL,
    FOREIGN KEY(source_station) REFERENCES stations(station_code),
    FOREIGN KEY(destination_station) REFERENCES stations(station_code)
);

INSERT INTO interlinked_tracks VALUES
('TRK-NDLS-GZB', 'NDLS', 'GZB', 26.0, 'Quadruple Track Auto Block', 130.0, 1.2, '25kV AC 50Hz', 52),
('TRK-GZB-ALJN', 'GZB', 'ALJN', 105.0, 'Double Line Automatic Signalling', 160.0, 0.8, '25kV AC 50Hz', 210),
('TRK-ALJN-TDL', 'ALJN', 'TDL', 78.0, 'Double Line High-Speed Corridor', 160.0, 0.5, '25kV AC 50Hz', 156),
('TRK-TDL-ETW', 'TDL', 'ETW', 92.0, 'Double Line Automatic Block', 160.0, 0.7, '25kV AC 50Hz', 184),
('TRK-ETW-CNB', 'ETW', 'CNB', 139.0, 'Double Line Automatic Block', 160.0, 0.6, '25kV AC 50Hz', 278),
('TRK-CNB-FTP', 'CNB', 'FTP', 78.0, 'Double Line Dedicated Passenger', 160.0, 0.4, '25kV AC 50Hz', 156),
('TRK-FTP-PRYJ', 'FTP', 'PRYJ', 117.0, 'Double Line Automated Block', 160.0, 0.5, '25kV AC 50Hz', 234),
('TRK-PRYJ-MZP', 'PRYJ', 'MZP', 89.0, 'Double Line River Corridor', 140.0, 1.4, '25kV AC 50Hz', 178),
('TRK-MZP-DDU', 'MZP', 'DDU', 63.0, 'Triple Track High Density', 130.0, 1.1, '25kV AC 50Hz', 126),
('TRK-DDU-BSB', 'DDU', 'BSB', 18.0, 'Double Line River Bridge Link', 110.0, 2.0, '25kV AC 50Hz', 40);

-- --------------------------------------------------------------------
-- 3. INTERLOCKING SIGNALS TABLE
-- --------------------------------------------------------------------
CREATE TABLE track_signals (
    signal_id VARCHAR(20) PRIMARY KEY,
    station_code VARCHAR(10) NOT NULL,
    signal_aspect VARCHAR(20) NOT NULL,
    aspect_type VARCHAR(30) NOT NULL,
    safe_braking_distance_m REAL NOT NULL,
    kavach_interlocked BOOLEAN DEFAULT TRUE,
    last_switched TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(station_code) REFERENCES stations(station_code)
);

INSERT INTO track_signals VALUES
('SIG-NDLS-01', 'NDLS', 'GREEN', '4-Aspect Auto', 1200.0, 1, CURRENT_TIMESTAMP),
('SIG-GZB-04',  'GZB',  'GREEN', '4-Aspect Auto', 1150.0, 1, CURRENT_TIMESTAMP),
('SIG-ALJN-12', 'ALJN', 'GREEN', '4-Aspect Auto', 1250.0, 1, CURRENT_TIMESTAMP),
('SIG-TDL-07',  'TDL',  'DOUBLE_YELLOW', '4-Aspect Auto', 1300.0, 1, CURRENT_TIMESTAMP),
('SIG-ETW-09',  'ETW',  'GREEN', '4-Aspect Auto', 1220.0, 1, CURRENT_TIMESTAMP),
('SIG-CNB-02',  'CNB',  'GREEN', '4-Aspect Auto', 1100.0, 1, CURRENT_TIMESTAMP),
('SIG-FTP-05',  'FTP',  'GREEN', '4-Aspect Auto', 1240.0, 1, CURRENT_TIMESTAMP),
('SIG-PRYJ-08', 'PRYJ', 'GREEN', '4-Aspect Auto', 1180.0, 1, CURRENT_TIMESTAMP),
('SIG-MZP-03',  'MZP',  'GREEN', '4-Aspect Auto', 1200.0, 1, CURRENT_TIMESTAMP),
('SIG-DDU-06',  'DDU',  'YELLOW', '4-Aspect Auto', 1050.0, 1, CURRENT_TIMESTAMP),
('SIG-BSB-01',  'BSB',  'GREEN', '4-Aspect Auto', 1100.0, 1, CURRENT_TIMESTAMP);

-- --------------------------------------------------------------------
-- 4. LIVE TRAIN FLEET TRACKING ON 10-STATION CORRIDOR
-- --------------------------------------------------------------------
CREATE TABLE live_train_tracking (
    train_id VARCHAR(10) PRIMARY KEY,
    train_name VARCHAR(100) NOT NULL,
    current_station VARCHAR(10) NOT NULL,
    next_station VARCHAR(10) NOT NULL,
    speed_kmh REAL NOT NULL,
    delay_minutes REAL NOT NULL,
    signal_aspect VARCHAR(20) NOT NULL,
    kavach_safe_margin_m REAL NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY(current_station) REFERENCES stations(station_code),
    FOREIGN KEY(next_station) REFERENCES stations(station_code)
);

INSERT INTO live_train_tracking VALUES
('15558', 'Amrit Bharat Express', 'ETW', 'CNB', 158.5, 0.0, 'GREEN', 1200.0, 'Cruising (On Time)'),
('99001', 'Hydrogen Green Express', 'NDLS', 'ALJN', 140.0, 0.0, 'GREEN', 1250.0, 'Eco-Cruise (On Time)'),
('12002', 'Bhopal Shatabdi Express', 'GZB', 'ALJN', 130.0, 6.0, 'DOUBLE_YELLOW', 980.0, 'Regulated (+6m)'),
('12952', 'Mumbai Rajdhani Express', 'NDLS', 'GZB', 128.4, 0.0, 'GREEN', 1150.0, 'Departed (On Time)');

-- --------------------------------------------------------------------
-- 5. AI MODEL DECISION INFERENCE LOG
-- --------------------------------------------------------------------
CREATE TABLE ai_decisions (
    decision_id INTEGER PRIMARY KEY AUTOINCREMENT,
    train_id VARCHAR(10) NOT NULL,
    station_code VARCHAR(10) NOT NULL,
    ai_module VARCHAR(50) NOT NULL,
    recommended_speed_kmh REAL NOT NULL,
    interlocking_action VARCHAR(100) NOT NULL,
    safety_margin_m REAL NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ai_decisions (train_id, station_code, ai_module, recommended_speed_kmh, interlocking_action, safety_margin_m) VALUES
('15558', 'CNB', 'Fast Track Finder', 160.0, 'Clear Main Platform 1 Docking Path for Amrit Bharat', 1200.0),
('15558', 'ETW', 'Rain & Track Grip Checker', 158.5, '0mm Dry Rail - Grip 95% Verified', 1200.0),
('99001', 'ALJN', 'Eco-Speed Governor', 140.0, 'Hydrogen Fuel Cell Optimum Consumption', 1250.0),
('15558', 'CNB', 'Kavach Crash Guard', 158.5, 'Safe Headway Clear - Zero Collision Risk', 1200.0);

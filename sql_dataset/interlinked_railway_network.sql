-- ====================================================================
-- INDIAN RAILWAYS AUTONOMOUS AI MONITORING SYSTEM
-- STANDALONE SQL DATASET: 10+ INTERLINKED HIGH-SPEED STATIONS
-- CORRIDOR: NEW DELHI (NDLS) TO VARANASI JN (BSB) VIA KANPUR CENTRAL
-- Compatible with: MySQL 8.0+, PostgreSQL 14+, SQLite 3+, Oracle, SQL Server
-- ====================================================================

-- --------------------------------------------------------------------
-- TABLE 1: STATIONS (11 Interlinked High-Density Railway Stations)
-- --------------------------------------------------------------------
DROP TABLE IF EXISTS ai_decisions;
DROP TABLE IF EXISTS live_train_tracking;
DROP TABLE IF EXISTS track_signals;
DROP TABLE IF EXISTS interlinked_tracks;
DROP TABLE IF EXISTS stations;

CREATE TABLE stations (
    station_code VARCHAR(10) PRIMARY KEY,
    station_name VARCHAR(100) NOT NULL,
    division VARCHAR(50) NOT NULL,
    zone VARCHAR(10) NOT NULL,
    chainage_km DECIMAL(6,2) NOT NULL,
    latitude DECIMAL(9,6) NOT NULL,
    longitude DECIMAL(9,6) NOT NULL,
    altitude_m DECIMAL(6,2) NOT NULL,
    platform_count INT NOT NULL,
    junction_category VARCHAR(50) NOT NULL,
    electrification_status VARCHAR(20) DEFAULT '25kV AC',
    kavach_atp_installed INT DEFAULT 1
);

INSERT INTO stations (station_code, station_name, division, zone, chainage_km, latitude, longitude, altitude_m, platform_count, junction_category, electrification_status, kavach_atp_installed) VALUES
('NDLS', 'New Delhi', 'Delhi', 'NR', 0.00, 28.613900, 77.209000, 215.00, 16, 'High Density Terminal Hub', '25kV AC', 1),
('GZB',  'Ghaziabad Junction', 'Delhi', 'NR', 26.00, 28.669200, 77.453800, 214.00, 6, 'Interlocking Junction Hub', '25kV AC', 1),
('ALJN', 'Aligarh Junction', 'Prayagraj', 'NCR', 131.00, 27.897400, 78.088000, 187.00, 7, 'Intermediate Junction', '25kV AC', 1),
('TDL',  'Tundla Junction', 'Prayagraj', 'NCR', 209.00, 27.206900, 78.238400, 167.00, 5, 'Crew Change & Freight Divert', '25kV AC', 1),
('ETW',  'Etawah Junction', 'Prayagraj', 'NCR', 301.00, 26.776900, 79.030600, 153.00, 5, 'Main Bypass Junction', '25kV AC', 1),
('CNB',  'Kanpur Central', 'Prayagraj', 'NCR', 440.00, 26.453900, 80.350700, 126.00, 10, 'Central Divisional Mega-Hub', '25kV AC', 1),
('FTP',  'Fatehpur', 'Prayagraj', 'NCR', 518.00, 25.928600, 80.813000, 118.00, 4, 'Intermediate Junction', '25kV AC', 1),
('PRYJ', 'Prayagraj Junction', 'Prayagraj', 'NCR', 635.00, 25.435800, 81.846300, 102.00, 10, 'Headquarters Divisional Hub', '25kV AC', 1),
('MZP',  'Mirzapur', 'Prayagraj', 'NCR', 724.00, 25.133700, 82.564400, 85.00, 4, 'River Corridor Hub', '25kV AC', 1),
('DDU',  'Pt. Deen Dayal Upadhyaya Jn', 'Pt DDU', 'ECR', 787.00, 25.281800, 83.120600, 76.00, 8, 'Marshalling & Strategic Yard', '25kV AC', 1),
('BSB',  'Varanasi Junction', 'Lucknow', 'NR', 805.00, 25.326800, 82.987600, 80.00, 9, 'High-Priority Terminal Hub', '25kV AC', 1);

-- --------------------------------------------------------------------
-- TABLE 2: INTERLINKED TRACK SECTIONS (Corridor Segments Topology)
-- --------------------------------------------------------------------
CREATE TABLE interlinked_tracks (
    track_id VARCHAR(20) PRIMARY KEY,
    source_station VARCHAR(10) NOT NULL,
    destination_station VARCHAR(10) NOT NULL,
    segment_distance_km DECIMAL(6,2) NOT NULL,
    track_type VARCHAR(50) NOT NULL,
    speed_limit_kmh DECIMAL(5,2) NOT NULL,
    gradient_per_thousand DECIMAL(4,2) NOT NULL,
    electrification_type VARCHAR(20) DEFAULT '25kV AC 50Hz',
    kavach_rfid_tags_count INT NOT NULL,
    axle_load_tonnes DECIMAL(4,1) DEFAULT 25.0,
    FOREIGN KEY(source_station) REFERENCES stations(station_code),
    FOREIGN KEY(destination_station) REFERENCES stations(station_code)
);

INSERT INTO interlinked_tracks (track_id, source_station, destination_station, segment_distance_km, track_type, speed_limit_kmh, gradient_per_thousand, electrification_type, kavach_rfid_tags_count, axle_load_tonnes) VALUES
('TRK-NDLS-GZB', 'NDLS', 'GZB', 26.00, 'Quadruple Track Auto Block', 130.00, 1.20, '25kV AC 50Hz', 52, 25.0),
('TRK-GZB-ALJN', 'GZB', 'ALJN', 105.00, 'Double Line Automatic Signalling', 160.00, 0.80, '25kV AC 50Hz', 210, 25.0),
('TRK-ALJN-TDL', 'ALJN', 'TDL', 78.00, 'Double Line High-Speed Corridor', 160.00, 0.50, '25kV AC 50Hz', 156, 25.0),
('TRK-TDL-ETW', 'TDL', 'ETW', 92.00, 'Double Line Automatic Block', 160.00, 0.70, '25kV AC 50Hz', 184, 25.0),
('TRK-ETW-CNB', 'ETW', 'CNB', 139.00, 'Double Line Automatic Block', 160.00, 0.60, '25kV AC 50Hz', 278, 25.0),
('TRK-CNB-FTP', 'CNB', 'FTP', 78.00, 'Double Line Dedicated Passenger', 160.00, 0.40, '25kV AC 50Hz', 156, 25.0),
('TRK-FTP-PRYJ', 'FTP', 'PRYJ', 117.00, 'Double Line Automated Block', 160.00, 0.50, '25kV AC 50Hz', 234, 25.0),
('TRK-PRYJ-MZP', 'PRYJ', 'MZP', 89.00, 'Double Line River Corridor', 140.00, 1.40, '25kV AC 50Hz', 178, 25.0),
('TRK-MZP-DDU', 'MZP', 'DDU', 63.00, 'Triple Track High Density', 130.00, 1.10, '25kV AC 50Hz', 126, 25.0),
('TRK-DDU-BSB', 'DDU', 'BSB', 18.00, 'Double Line River Bridge Link', 110.00, 2.00, '25kV AC 50Hz', 40, 25.0);

-- --------------------------------------------------------------------
-- TABLE 3: INTERLOCKING SIGNALS (4-Aspect Automatic Signalling)
-- --------------------------------------------------------------------
CREATE TABLE track_signals (
    signal_id VARCHAR(20) PRIMARY KEY,
    station_code VARCHAR(10) NOT NULL,
    signal_aspect VARCHAR(20) NOT NULL,
    aspect_type VARCHAR(30) NOT NULL,
    safe_braking_distance_m DECIMAL(7,2) NOT NULL,
    kavach_interlocked INT DEFAULT 1,
    last_switched TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(station_code) REFERENCES stations(station_code)
);

INSERT INTO track_signals (signal_id, station_code, signal_aspect, aspect_type, safe_braking_distance_m, kavach_interlocked) VALUES
('SIG-NDLS-01', 'NDLS', 'GREEN', '4-Aspect Auto Block', 1200.00, 1),
('SIG-GZB-04',  'GZB',  'GREEN', '4-Aspect Auto Block', 1150.00, 1),
('SIG-ALJN-12', 'ALJN', 'GREEN', '4-Aspect Auto Block', 1250.00, 1),
('SIG-TDL-07',  'TDL',  'DOUBLE_YELLOW', '4-Aspect Auto Block', 1300.00, 1),
('SIG-ETW-09',  'ETW',  'GREEN', '4-Aspect Auto Block', 1220.00, 1),
('SIG-CNB-02',  'CNB',  'GREEN', '4-Aspect Auto Block', 1100.00, 1),
('SIG-FTP-05',  'FTP',  'GREEN', '4-Aspect Auto Block', 1240.00, 1),
('SIG-PRYJ-08', 'PRYJ', 'GREEN', '4-Aspect Auto Block', 1180.00, 1),
('SIG-MZP-03',  'MZP',  'GREEN', '4-Aspect Auto Block', 1200.00, 1),
('SIG-DDU-06',  'DDU',  'YELLOW', '4-Aspect Auto Block', 1050.00, 1),
('SIG-BSB-01',  'BSB',  'GREEN', '4-Aspect Auto Block', 1100.00, 1);

-- --------------------------------------------------------------------
-- TABLE 4: LIVE TRAIN TRACKING ON CORRIDOR
-- --------------------------------------------------------------------
CREATE TABLE live_train_tracking (
    train_id VARCHAR(10) PRIMARY KEY,
    train_name VARCHAR(100) NOT NULL,
    current_station VARCHAR(10) NOT NULL,
    next_station VARCHAR(10) NOT NULL,
    speed_kmh DECIMAL(5,2) NOT NULL,
    delay_minutes DECIMAL(5,2) NOT NULL,
    signal_aspect VARCHAR(20) NOT NULL,
    kavach_safe_margin_m DECIMAL(7,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    FOREIGN KEY(current_station) REFERENCES stations(station_code),
    FOREIGN KEY(next_station) REFERENCES stations(station_code)
);

INSERT INTO live_train_tracking (train_id, train_name, current_station, next_station, speed_kmh, delay_minutes, signal_aspect, kavach_safe_margin_m, status) VALUES
('22436', 'Vande Bharat Express', 'ETW', 'CNB', 158.50, 0.00, 'GREEN', 1200.00, 'Cruising (On Time)'),
('12002', 'Bhopal Shatabdi Express', 'GZB', 'ALJN', 130.00, 6.00, 'DOUBLE_YELLOW', 980.00, 'Regulated (+6m)'),
('12952', 'Mumbai Rajdhani Express', 'NDLS', 'GZB', 128.40, 0.00, 'GREEN', 1150.00, 'Departed (On Time)'),
('12424', 'Dibrugarh Rajdhani Express', 'CNB', 'PRYJ', 131.20, 0.00, 'GREEN', 1220.00, 'Express Run (On Time)');

-- --------------------------------------------------------------------
-- TABLE 5: AI MODEL INFERENCE & DECISION LOGS
-- --------------------------------------------------------------------
CREATE TABLE ai_decisions (
    decision_id INTEGER PRIMARY KEY AUTOINCREMENT,
    train_id VARCHAR(10) NOT NULL,
    station_code VARCHAR(10) NOT NULL,
    ai_module VARCHAR(50) NOT NULL,
    recommended_speed_kmh DECIMAL(5,2) NOT NULL,
    interlocking_action VARCHAR(100) NOT NULL,
    safety_margin_m DECIMAL(7,2) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(train_id) REFERENCES live_train_tracking(train_id),
    FOREIGN KEY(station_code) REFERENCES stations(station_code)
);

INSERT INTO ai_decisions (train_id, station_code, ai_module, recommended_speed_kmh, interlocking_action, safety_margin_m) VALUES
('22436', 'CNB', 'Fast Track Finder', 160.00, 'Clear Main Platform 1 Docking Path', 1200.00),
('22436', 'ETW', 'Rain & Track Grip Checker', 158.50, '0mm Dry Rail - Grip 95% Verified', 1200.00),
('12002', 'ALJN', 'Traffic Jam Avoider', 130.00, 'Hold Freight Goods Train on Loop 2', 980.00),
('22436', 'CNB', 'Kavach Crash Guard', 158.50, 'Safe Headway Clear - Zero Collision Risk', 1200.00);

-- --------------------------------------------------------------------
-- SAMPLE ANALYTICAL QUERIES
-- --------------------------------------------------------------------
-- 1. Full Corridor Chainage and Interlinked Tracks
SELECT 
    t.track_id,
    s1.station_name AS [From],
    s2.station_name AS [To],
    t.segment_distance_km AS [Distance (km)],
    t.speed_limit_kmh AS [Max Speed (km/h)],
    s2.chainage_km AS [Cumulative Distance (km)]
FROM interlinked_tracks t
JOIN stations s1 ON t.source_station = s1.station_code
JOIN stations s2 ON t.destination_station = s2.station_code
ORDER BY s1.chainage_km ASC;

-- 2. Real-Time Kavach Protection Audit
SELECT 
    tr.train_id,
    tr.train_name,
    tr.speed_kmh,
    tr.signal_aspect,
    tr.kavach_safe_margin_m,
    sig.safe_braking_distance_m
FROM live_train_tracking tr
JOIN track_signals sig ON tr.current_station = sig.station_code;

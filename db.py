import sqlite3
from pathlib import Path
from typing import List, Dict, Any, Optional

DB_PATH = Path(__file__).resolve().parent / "railway_network.db"
SQL_SCRIPT_PATH = Path(__file__).resolve().parent / "data" / "railway_datasheet.sql"

def get_connection():
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    """Initializes the SQLite database with the 10+ interlinked stations datasheet."""
    if not SQL_SCRIPT_PATH.exists():
        return
    with open(SQL_SCRIPT_PATH, "r", encoding="utf-8") as f:
        sql_content = f.read()
    with get_connection() as conn:
        conn.executescript(sql_content)
        conn.commit()

def get_all_stations() -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM stations ORDER BY chainage_km ASC")
        return [dict(row) for row in cursor.fetchall()]

def get_interlinked_tracks() -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT t.*, s1.station_name as source_name, s2.station_name as dest_name
            FROM interlinked_tracks t
            JOIN stations s1 ON t.source_station = s1.station_code
            JOIN stations s2 ON t.destination_station = s2.station_code
            ORDER BY s1.chainage_km ASC
        """)
        return [dict(row) for row in cursor.fetchall()]

def get_live_tracking_from_db() -> List[Dict[str, Any]]:
    """Fetches real-time train positions directly from the live SQL database."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT l.*, s1.station_name as current_station_name, s2.station_name as next_station_name
            FROM live_train_tracking l
            JOIN stations s1 ON l.current_station = s1.station_code
            JOIN stations s2 ON l.next_station = s2.station_code
        """)
        return [dict(row) for row in cursor.fetchall()]

def update_train_telemetry_in_db(
    train_id: str,
    speed_kmh: float,
    signal_aspect: str,
    status: str,
    kavach_safe_margin_m: Optional[float] = None,
    delay_minutes: Optional[float] = None
):
    """Updates train position, speed, signal and safety buffer in real-time in SQLite."""
    with get_connection() as conn:
        cursor = conn.cursor()
        query = "UPDATE live_train_tracking SET speed_kmh = ?, signal_aspect = ?, status = ?"
        params = [speed_kmh, signal_aspect, status]
        if kavach_safe_margin_m is not None:
            query += ", kavach_safe_margin_m = ?"
            params.append(kavach_safe_margin_m)
        if delay_minutes is not None:
            query += ", delay_minutes = ?"
            params.append(delay_minutes)
        query += " WHERE train_id = ?"
        params.append(train_id)
        cursor.execute(query, params)
        conn.commit()

def update_signal_in_db(signal_id: str, new_aspect: str):
    """Updates interlocking aspect in SQLite database in real-time."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE track_signals SET signal_aspect = ?, last_switched = CURRENT_TIMESTAMP WHERE signal_id = ?",
            (new_aspect, signal_id)
        )
        conn.commit()

def record_ai_decision_in_db(
    train_id: str,
    station_code: str,
    ai_module: str,
    recommended_speed_kmh: float,
    interlocking_action: str,
    safety_margin_m: float
):
    """Records real-time AI decision log directly into SQLite database."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO ai_decisions 
            (train_id, station_code, ai_module, recommended_speed_kmh, interlocking_action, safety_margin_m)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (train_id, station_code, ai_module, recommended_speed_kmh, interlocking_action, safety_margin_m))
        conn.commit()

def get_ai_decisions_from_db(limit: int = 10) -> List[Dict[str, Any]]:
    """Retrieves live AI model decision history from SQLite."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT d.*, s.station_name
            FROM ai_decisions d
            LEFT JOIN stations s ON d.station_code = s.station_code
            ORDER BY d.decision_id DESC LIMIT ?
        """, (limit,))
        return [dict(row) for row in cursor.fetchall()]

def get_signals_from_db() -> List[Dict[str, Any]]:
    """Retrieves interlocking signals from SQLite."""
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT sig.*, s.station_name
            FROM track_signals sig
            JOIN stations s ON sig.station_code = s.station_code
            ORDER BY sig.signal_id ASC
        """)
        return [dict(row) for row in cursor.fetchall()]

if __name__ == "__main__":
    init_db()
    stations = get_all_stations()
    trains = get_live_tracking_from_db()
    print(f"Verified live database: {len(stations)} stations, {len(trains)} active trains linked!")

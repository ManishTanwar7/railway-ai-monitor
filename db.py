import sqlite3
from pathlib import Path
from typing import List, Dict, Any

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
            ORDER BY t.segment_distance_km DESC
        """)
        return [dict(row) for row in cursor.fetchall()]

def get_live_tracking_from_db() -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM live_train_tracking")
        return [dict(row) for row in cursor.fetchall()]

def get_ai_decisions_from_db() -> List[Dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM ai_decisions ORDER BY decision_id DESC LIMIT 10")
        return [dict(row) for row in cursor.fetchall()]

if __name__ == "__main__":
    init_db()
    stations = get_all_stations()
    print(f"Successfully initialized SQLite database with {len(stations)} interlinked stations!")

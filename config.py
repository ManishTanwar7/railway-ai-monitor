import os

# JWT & Security Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "railway-ai-secret-key-hyper-loop-sentinel-2026")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 12  # 12 hours
COOKIE_NAME = "railway_ai_session_token"

# Role Definitions
ROLE_ADMIN = "admin"
ROLE_STATION_MASTER = "station_master"
ROLE_EMPLOYEE = "employee"
ROLE_PASSENGER = "passenger"

# Predefined User Database
USERS_DB = {
    "admin": {
        "username": "admin",
        "password_hash": "admin123",  # Will verify via auth.py
        "full_name": "Chief Overseer Sterling",
        "role": ROLE_ADMIN,
        "role_display": "Admin (Boss AI Controller)",
        "badge": "LVL-3 BOSS CLEARANCE",
        "avatar": "fa-user-astronaut",
        "color": "amber",
        "dashboard_url": "/dashboard/admin"
    },
    "stationmaster": {
        "username": "stationmaster",
        "password_hash": "station123",
        "full_name": "Commander Elena Rostova",
        "role": ROLE_STATION_MASTER,
        "role_display": "Station Master",
        "badge": "STATION CONTROL DISPATCH",
        "avatar": "fa-tower-observation",
        "color": "cyan",
        "dashboard_url": "/dashboard/station-master"
    },
    "employee": {
        "username": "employee",
        "password_hash": "emp123",
        "full_name": "Field Specialist Kenneth Sato",
        "role": ROLE_EMPLOYEE,
        "role_display": "Railway Systems Technician",
        "badge": "ASSIGNED AI MODULE SPECIALIST",
        "avatar": "fa-screwdriver-wrench",
        "color": "emerald",
        "assigned_modules": [
            "Signal Pulse Agent",
            "Weather Telemetry Analyzer"
        ],
        "dashboard_url": "/dashboard/employee"
    },
    "passenger": {
        "username": "passenger",
        "password_hash": "pass123",
        "full_name": "Valued Rail Passenger",
        "role": ROLE_PASSENGER,
        "role_display": "Commuter Passenger",
        "badge": "PASSENGER PORTAL",
        "avatar": "fa-ticket",
        "color": "blue",
        "dashboard_url": "/dashboard/passenger"
    }
}

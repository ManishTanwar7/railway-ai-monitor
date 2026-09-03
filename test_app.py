import json
import sys
from pathlib import Path

# Ensure UTF-8 stdout on Windows
if sys.stdout.encoding != 'utf-8':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except Exception:
        pass

from starlette.testclient import TestClient

from main import app, load_dataset, DATA_DIR
from config import COOKIE_NAME, USERS_DB
from auth import create_access_token, authenticate_user

client = TestClient(app)

def test_datasets_exist_and_valid():
    print("[TEST 1/5] Verifying all required JSON datasets exist and parse properly...")
    required_datasets = [
        "gps_tracker",
        "weather",
        "delay_patterns",
        "congestion",
        "signals",
        "station_ops",
        "ai_hierarchy"
    ]
    for ds in required_datasets:
        data = load_dataset(ds)
        assert data is not None, f"Dataset {ds} is empty"
        if isinstance(data, list):
            assert len(data) >= 1, f"Dataset {ds} should have at least 1 row"
        elif isinstance(data, dict):
            assert len(data.keys()) >= 1, f"Dataset {ds} has no keys"
        print(f"  ✓ {ds}.json loaded successfully ({type(data).__name__})")

def test_authentication_logic():
    print("\n[TEST 2/5] Testing authentication and JWT token lifecycle...")
    # Test valid credentials
    for username, creds in USERS_DB.items():
        user = authenticate_user(username, creds["password_hash"])
        assert user is not None, f"Failed authenticating {username}"
        assert user["role"] == creds["role"]
        
        # Test token creation
        token = create_access_token({"sub": username, "role": user["role"]})
        assert isinstance(token, str) and len(token) > 20
        print(f"  ✓ User '{username}' ({user['role']}) authenticated, token verified")

    # Test invalid password rejection
    bad_user = authenticate_user("admin", "wrongpassword999")
    assert bad_user is None, "Invalid password should return None"
    print("  ✓ Invalid password rejected properly")

def test_api_endpoints():
    print("\n[TEST 3/5] Testing REST API dynamic endpoints...")
    # Health check
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json()["status"] == "healthy"
    print("  ✓ GET /health: 200 OK")

    # Dynamic datasets
    for ds in ["gps_tracker", "weather", "delay_patterns", "congestion", "signals", "station_ops", "ai_hierarchy"]:
        res = client.get(f"/api/data/{ds}")
        assert res.status_code == 200
        print(f"  ✓ GET /api/data/{ds}: 200 OK")

    # Live train telemetry simulation
    res = client.get("/api/trains/live")
    assert res.status_code == 200
    trains = res.json()
    assert len(trains) > 0
    assert "speed_kmh" in trains[0]
    print(f"  ✓ GET /api/trains/live: 200 OK ({len(trains)} trains streaming)")

def test_rbac_and_dashboard_views():
    print("\n[TEST 4/5] Testing Role-Based Access Control on dashboard routes...")
    
    # 1. Unauthenticated request should redirect to /login
    res = client.get("/dashboard/admin", follow_redirects=False)
    assert res.status_code in [302, 307]
    assert "/login" in res.headers["location"]
    print("  ✓ Unauthenticated access to /dashboard/admin redirected to /login")

    # Helper to get authenticated client
    def get_role_client(username: str, role: str):
        token = create_access_token({"sub": username, "role": role})
        c = TestClient(app, cookies={COOKIE_NAME: token})
        return c

    admin_client = get_role_client("admin", "admin")
    station_client = get_role_client("stationmaster", "station_master")
    employee_client = get_role_client("employee", "employee")
    passenger_client = get_role_client("passenger", "passenger")

    # Admin dashboard access
    res = admin_client.get("/dashboard/admin")
    assert res.status_code == 200
    assert "CHRONOS-OMNI" in res.text
    print("  ✓ Admin role can view /dashboard/admin (200 OK)")

    # Station Master cannot access Admin dashboard
    res = station_client.get("/dashboard/admin", follow_redirects=False)
    assert res.status_code in [302, 307]
    print("  ✓ Station Master denied from /dashboard/admin (Redirected)")

    # Station Master dashboard access
    res = station_client.get("/dashboard/station-master")
    assert res.status_code == 200
    assert "STATION DISPATCH" in res.text
    print("  ✓ Station Master can view /dashboard/station-master (200 OK)")

    # Employee dashboard access (restricted to assigned modules)
    res = employee_client.get("/dashboard/employee")
    assert res.status_code == 200
    assert "RESTRICTED ACCESS" in res.text
    assert "Signal Pulse Agent" in res.text
    print("  ✓ Employee can view /dashboard/employee with assigned modules (200 OK)")

    # Passenger dashboard access
    res = passenger_client.get("/dashboard/passenger")
    assert res.status_code == 200
    assert "LIVE TRAIN ARRIVALS" in res.text
    print("  ✓ Passenger can view /dashboard/passenger (200 OK)")

def test_override_endpoints():
    print("\n[TEST 5/5] Testing interactive override endpoints...")
    
    # Signal override by Station Master
    token = create_access_token({"sub": "stationmaster", "role": "station_master"})
    c = TestClient(app, cookies={COOKIE_NAME: token})
    res = c.post("/api/override/signal", json={"signal_id": "SIG-N101", "new_aspect": "YELLOW"})
    assert res.status_code == 200
    assert res.json()["aspect"] == "YELLOW"
    print("  ✓ Station Master signal override POST /api/override/signal succeeded")

    # Restore signal to GREEN
    c.post("/api/override/signal", json={"signal_id": "SIG-N101", "new_aspect": "GREEN"})

    # AI parameter override by Admin
    admin_token = create_access_token({"sub": "admin", "role": "admin"})
    ac = TestClient(app, cookies={COOKIE_NAME: admin_token})
    res = ac.post("/api/override/ai-parameter", json={"parameter": "safety_margin_factor", "value": 1.55})
    assert res.status_code == 200
    assert res.json()["value"] == 1.55
    print("  ✓ Admin AI parameter override POST /api/override/ai-parameter succeeded")

    # Employee diagnostic action
    emp_token = create_access_token({"sub": "employee", "role": "employee"})
    ec = TestClient(app, cookies={COOKIE_NAME: emp_token})
    res = ec.post("/api/employee/action", json={"action": "DIAGNOSTIC_TEST", "module": "Signal Pulse Agent"})
    assert res.status_code == 200
    assert res.json()["status"] == "PASSED"
    print("  ✓ Employee diagnostic trigger POST /api/employee/action succeeded")


if __name__ == "__main__":
    print("=========================================================")
    print("    RUNNING AUTOMATED TEST SUITE: CHRONOS RAILWAY AI     ")
    print("=========================================================")
    try:
        test_datasets_exist_and_valid()
        test_authentication_logic()
        test_api_endpoints()
        test_rbac_and_dashboard_views()
        test_override_endpoints()
        print("\n=========================================================")
        print("    ALL TESTS PASSED! SYSTEM VERIFICATION COMPLETE.      ")
        print("=========================================================")
    except Exception as e:
        print(f"\n❌ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

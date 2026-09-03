# Chronos Railway AI Monitoring Platform

An enterprise-grade, interactive railway AI supervision and monitoring dashboard built with **FastAPI** (backend) and **Jinja2 + TailwindCSS** (frontend). 

The platform simulates an advanced cybernetic railway control room with multi-role authentication, interactive interlocking controls, mathematical AI formulation breakdowns, and live GPS train telemetry.

---

## 🚀 Key Features

### 1. Multi-Authentication & Role-Based Access Control (RBAC)
Four distinct roles with secure JWT authentication stored in HTTP-only cookies:

| Role | Username | Password | Access Scope |
| :--- | :--- | :--- | :--- |
| **Admin (Boss)** | `admin` | `admin123` | Master AI hierarchy view (Workers, Leaders, Boss AI), calculation formulas, parameter override sliders, telemetry logs. |
| **Station Master** | `stationmaster` | `station123` | Control-room operations: GPS train movement, live signal switchboard overrides, junction congestion meters, delay pattern warnings. |
| **Employee** | `employee` | `emp123` | Restricted field technician view: only assigned AI modules (Signal Safety AI & Weather Telemetry), self-diagnostics, maintenance reports. |
| **Passenger** | `passenger` | `pass123` | Simple, clean commuter board with live train ETA, delay status, platform locator, search filter, and weather advisories. |

> **Note:** The login page also features **Instant 1-Click Role Login** buttons for immediate testing without typing.

### 2. Specialized Dashboards
- **Boss AI View (`/dashboard/admin`)**:
  - Full 3-tier AI tree (Level 3 Boss $\rightarrow$ Level 2 Leaders $\rightarrow$ Level 1 Workers).
  - Mathematical and neural calculations for Train ETA, Delay Propagation, Congestion Queuing, and Weather Traction degradation.
  - Interactive parameter overrides (Safety Margin, Reroute Sensitivity, Delay Penalty Weights).
- **Station Master Console (`/dashboard/station-master`)**:
  - Live GPS train movement radar with bogie velocity and brake health.
  - Interlocking signal switchboard with manual GREEN/YELLOW/RED aspect overrides.
  - Junction congestion meters with automated bypass recommendations and Emergency All-Stop trigger.
- **Field Technician Portal (`/dashboard/employee`)**:
  - Filtered exclusively to assigned AI modules (`Signal Pulse Agent` & `Weather Telemetry Analyzer`).
  - Interactive deep self-diagnostic testing with real-time audit logging.
- **Passenger Live Board (`/dashboard/passenger`)**:
  - Live ETA countdown, platform numbers, interactive search filter, and station facility status.

### 3. Railway-Themed UI/UX
- **Railway Control-Room Dark Theme**: Dark slate canvas (`#060913`) with glowing neon cyan, amber, emerald, and crimson accents.
- **Animated Glowing Train Headlight Cursor**: Custom directional train headlight cursor that casts a warm beam and leaves trailing sparks following mouse velocity.
- **Dynamic Live Telemetry Mode**: Real-time polling cycle (3s) with dynamic speed/ETA jitter simulation and interactive toast notifications.

---

## 📁 Project Structure

```
railway-ai-monitor/
├── main.py                     # FastAPI application, routes, and REST API
├── config.py                   # Configuration, role definitions, and user DB
├── auth.py                     # JWT token generation, verification, and guards
├── requirements.txt            # Python dependencies
├── render.yaml                 # Render cloud deployment blueprint
├── README.md                   # Documentation
├── data/                       # Dynamic JSON Datasets
│   ├── gps_tracker.json        # Live train GPS positions, speed, ETA, status
│   ├── weather.json            # Sector weather, track temp, friction index
│   ├── delay_patterns.json     # Predicted delays, root causes, mitigations
│   ├── congestion.json         # Junction occupancy, queue, bottleneck scores
│   ├── signals.json            # Interlocking signals, aspects, auto-clearance
│   ├── station_ops.json        # Platform allocations, power load, crowd density
│   └── ai_hierarchy.json       # 3-tier AI agents, math formulas, telemetry logs
├── static/
│   ├── css/
│   │   └── custom.css          # Control-room styling, radar animations, cursor
│   └── js/
│       ├── cursor.js           # Animated locomotive headlight cursor engine
│       └── dashboard.js        # Dynamic API fetchers, signal toggles, toasts
└── templates/
    ├── base.html               # Main layout with Tailwind, header clock, footer
    ├── login.html              # Cybernetic login terminal with 1-click presets
    ├── admin_dashboard.html    # Boss AI hierarchy & math formulation view
    ├── station_master_dashboard.html # Control room radar & signal board
    ├── employee_dashboard.html # Restricted technician AI module console
    └── passenger_dashboard.html# High-contrast live passenger arrival board
```

---

## 🛠️ Local Development Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Run the Application
```bash
uvicorn main:app --reload
```
Open your browser and navigate to:
```
http://127.0.0.1:8000
```

---

## ☁️ Deployment on Render

This project is pre-configured for instant zero-configuration deployment on Render:

1. Push this repository to GitHub or GitLab.
2. Log in to [Render](https://render.com) and click **New + > Web Service**.
3. Select your repository.
4. Set the following build & start commands:
   - **Environment:** `Python`
   - **Build Command:** `pip install -r requirements.txt`
   - **Start Command:** `uvicorn main:app --host 0.0.0.0 --port 10000`
   - **Health Check Path:** `/health`
5. Click **Deploy Web Service**.

# 10+ Interlinked Stations SQL Dataset
**Corridor**: New Delhi (`NDLS`) to Varanasi Junction (`BSB`) via Kanpur Central (`CNB`)  
**Authority**: Ministry of Railways & CRIS, Government of India  
**Total Corridor Length**: 805.00 Kilometers  
**Standard**: High-Speed Kavach 4.0 Collision Avoidance & Autonomous AI Interlocking  

---

## 📊 Dataset Structure
This folder contains the complete, standalone relational dataset for the 11 interlinked stations:

| File | Format | Description |
| :--- | :--- | :--- |
| `interlinked_railway_network.sql` | SQL | Full DDL & DML script (Stations, Tracks, Signals, Live Trains, AI Decisions) |
| `stations.csv` | CSV | 11 Interlinked Stations (Chainage km, GPS, Altitude, Platforms, Category) |
| `tracks.csv` | CSV | 10 Consecutive Interlinked Track Segments (Distances, Speed Limits, Gradients) |

---

## 🚉 The 11 Interlinked Stations (Golden Corridor)
1. **NDLS** - New Delhi (0.0 km, 16 Platforms)
2. **GZB** - Ghaziabad Junction (26.0 km, 6 Platforms)
3. **ALJN** - Aligarh Junction (131.0 km, 7 Platforms)
4. **TDL** - Tundla Junction (209.0 km, 5 Platforms)
5. **ETW** - Etawah Junction (301.0 km, 5 Platforms)
6. **CNB** - Kanpur Central (440.0 km, 10 Platforms)
7. **FTP** - Fatehpur (518.0 km, 4 Platforms)
8. **PRYJ** - Prayagraj Junction (635.0 km, 10 Platforms)
9. **MZP** - Mirzapur (724.0 km, 4 Platforms)
10. **DDU** - Pt. Deen Dayal Upadhyaya Junction (787.0 km, 8 Platforms)
11. **BSB** - Varanasi Junction (805.0 km, 9 Platforms)

---

## 💻 How to Load in Any Database
### SQLite:
```bash
sqlite3 railway.db < interlinked_railway_network.sql
```

### MySQL:
```bash
mysql -u root -p railway_db < interlinked_railway_network.sql
```

### PostgreSQL:
```bash
psql -U postgres -d railway_db -f interlinked_railway_network.sql
```

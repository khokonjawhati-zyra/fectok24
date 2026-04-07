---
description: Sovereign "One-Click" System Ignition [Full Engine + Docker + Multi-Panel]
---

# Sovereign V15 Master Ignition Protocol (ULTIMATE)

// turbo-all

This workflow performs a surgical cleanup and fresh launch of the entire Sovereign Ecosystem, including all Dockerized sub-systems.

## 1. ECOSYSTEM CLEANUP

`Stop-Process -Name "python" -Force -ErrorAction SilentlyContinue; Stop-Process -Name "dart" -Force -ErrorAction SilentlyContinue; taskkill /F /IM "python.exe" /T; taskkill /F /IM "dart.exe" /T; taskkill /F /IM "chrome.exe" /T;` (Cwd: `c:/Users/Admin/23226`)

### 2. DOCKER SYSTEM IGNITE (Impression, Revenue, Sound, Sponsor)

`Set-Location "c:/Users/Admin/23226/Sovereign_Impression_Engine"; docker-compose up -d; Set-Location "c:/Users/Admin/23226/Sovereign_Revenue_Control"; docker-compose up -d; Set-Location "c:/Users/Admin/23226/Sovereign_Sound_Loop"; docker-compose up -d; Set-Location "c:/Users/Admin/23226/Sovereign_Sponsor_System"; docker-compose up -d;` (Cwd: `c:/Users/Admin/23226`)

## 3. ENGINE ACTIVATION (Backend 5000, Uplink 8080, Processor)

`Start-Process python -ArgumentList "-m uvicorn main:app --host 0.0.0.0 --port 5000" -WorkingDirectory "c:/Users/Admin/23226/backend" -WindowStyle Minimized; Start-Process python -ArgumentList "uplink_server.py" -WorkingDirectory "c:/Users/Admin/23226/sovereign_media_hub/uplink" -WindowStyle Minimized; Start-Process python -ArgumentList "processor_engine.py" -WorkingDirectory "c:/Users/Admin/23226/sovereign_media_hub/processor" -WindowStyle Minimized;` (Cwd: `c:/Users/Admin/23226`)

## 4. UI PANEL IGNITE (Stable HTTP Serving)

`Start-Process python -ArgumentList "-m http.server 9090" -WorkingDirectory "c:/Users/Admin/23226/webadmin_panel" -WindowStyle Minimized; Start-Process python -ArgumentList "-m http.server 8181" -WorkingDirectory "c:/Users/Admin/23226/webuser_panel" -WindowStyle Minimized;` (Cwd: `c:/Users/Admin/23226`)

---
**[Sovereign Ignition: ULTIMATE OMNI-SYNC LIVE | DOCKER + ENGINES + UI]**

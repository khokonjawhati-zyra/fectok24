# Sovereign Absolute Mirror-🧬: Zero-Manual-Change Protocol

This document defines the **Ultimate Parity Strategy** to transplant your "Nursery" (Localhost) to the "Field" (Live Server) without a single manual edit on the server.

## 🧬 Mirror Architecture

| Service | Dynamic Host | Internal Port | Environment Parity |
| :--- | :--- | :--- | :--- |
| **Admin Panel** | `vazo.fectok.com` | `8108` | Ghost-Locked 🛡️ |
| **User Panel** | `fectok.com` | `3000` | SSL-Bridge 🔗 |
| **Backend API** | `Uri.base.origin` | `5000` | Auto-Sensing 💓 |

---

## 💎 The Absolute Mirror Guarantee

> [!IMPORTANT]
> **Zero-Drift Execution**: All IPs, Ports, and Paths are decoupled from the source code. The DNA automatically adapts based on whether it detects a Local Mesh or a Production Domain.
> **IaC (Infrastructure as Code)**: `antigravity_deploy.py` is the single source of truth. NO server-side `nginx.conf` or `docker-compose.yml` edits are ever allowed.

---

## 🛠️ Step 1: Genesis (Local PC)

1. **Ignite Orchestrator**:
   Run the one-click master script:
   ```bash
   python sovereign_ignition.py
   ```
   *This single command handles DNA generation, Global Sync, and Remote Ignition.*

---

## 🚀 Step 2: The Transplant (Hybrid Mirror)

1. **Unified Sync**:
   The orchestrator will first attempt a `git push` to your GitHub repo. 
   If any network hang is detected, it automatically executes a **Surgical SFTP Mirror** to transplant the DNA directly to the server cores.

---

## 🏗️ Step 3: Harvesting (Live Server)

1. **Automatic Ignition**:
   The server will pull/receive the DNA and run:
   ```bash
   docker-compose up -d --build
   ```
   *Antigravity handles SSL (Cloudflare-safe), asset remapping, and port locking automatically.*

---

## 🛡️ Sovereign Security Guard

> [!IMPORTANT]
> **Port Lockdown**: Ports 8108 and 3000 are NEVER exposed to the public internet. Access is strictly audited via the Nginx Gateway.
> **SSL Universal**: Automatic HTTPS-Handshake for all domains managed via the master DNA.

*Status: Absolute Parity [ENFORCED] v1.5.3*

# Sovereign V15 Global Domain Deployment Protocol

This document serves as the **Sovereign Blueprint** for deploying FecTok panels to domains and the live IP. Follow this protocol to ensure zero-downtime, conflict-free delivery of Flutter web assets.

---

## 1. Asset Sync Architecture (The ROOT Strategy)

We discovered that standard Flutter build directories (`/build/web`) can sometimes be outdated. The **Definitive Build Source** is located in the root of the project:

- **Admin Assets:** `c:/Users/Admin/23226/webadmin_panel`
- **User Assets:** `c:/Users/Admin/23226/webuser_panel`

### **Step A: Atomic Zipping**

We pack the contents directly using `ZipFile` (Python) to ensure no parent directory nesting occurs inside the zip.

- **Admin Zip:** `admin_v3.zip`
- **User Zip:** `user_v3.zip`

### **Step B: Remote Injection**

Using Paramiko (SSH/SFTP), we upload to `/tmp/` and then perform an **Atomic Replace**:

1. `rm -rf /opt/sovereign/core/webadmin_panel/*` (Wipe old junk)
2. `unzip -o /tmp/admin_v3.zip -d /target/dir` (Extract fresh)
3. `chown -R www-data:www-data` (Nginx Permission ownership)
4. `chmod -R 755` (Read/Execute permissions)

---

## 2. Nginx "Golden" Routing (Dual-Identity Shield)

To prevent the **White Screen of Death** and **Identity Crisis** (Admin UI appearing on User IP), we use a strictly partitioned Nginx configuration.

### **The "Golden Static" Rule**

One of the most critical fixes: We forced Nginx to NOT fallback to `index.html` for JS/WASM files.

```nginx
location ~* \.(js|wasm|css|png|json)$ {
    try_files $uri =404; # Fail fast if file is missing, do not serve HTML
    add_header Cache-Control "no-store, no-cache, must-revalidate";
}
```

*Why?* If `main.dart.js` is missing, Nginx used to return `index.html`. Browser receives HTML for a Script tag -> **White Screen.**

### **The Cloudflare "Flexible" Loop Destroyer**

We removed the `301 https://` redirect from Nginx Port 80 for the domain.

- **Cloudflare (Flexible SSL)** talks to Nginx on Port 80.
- If Nginx says "Go to HTTPS", Cloudflare retries on Port 80.
- Result: **ERR_TOO_MANY_REDIRECTS.**
- **Solution:** Allow Port 80 and 443 to serve content simultaneously; let Cloudflare edge handle the SSL termination.

---

## 3. Explicit IP Identity Lock

To ensure the **User Panel** appears on direct IP access (even via HTTPS):

- We created a dedicated `server` block for `167.71.193.34`.
- We gave it its own `root /opt/sovereign/core/webuser_panel`.
- This prevents the "First SSL Server" from hijacking IP traffic.

---

## 4. API & WebSocket Mesh

All panels share a unified proxy logic to connect to the Sovereign V15 Backend:

- **REST/JSON:** `proxy_pass http://127.0.0.1:5000;`
- **WebSockets (Real-time):**

```nginx
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
```

---

## 5. Deployment Checklist (The "Vazo" Protocol)

1. [ ] **Build:** Confirm original assets in `webadmin_panel` or `webuser_panel`.
2. [ ] **Zip:** Generate fresh `admin_v3.zip` / `user_v3.zip`.
3. [ ] **Upload:** Use `SFTP` to push to `/tmp/`.
4. [ ] **Align:** Extract to `/opt/sovereign/core/`.
5. [ ] **Reload:** Apply `golden_static_sync.py` to Nginx.
6. [ ] **Refresh:** User performs `Ctrl + F5` to purge browser cache.

---

**Saved to Sovereign Protocol Brain.**

## 6. Sovereign DNA Ledger Policy (The OK Zone Protection)

As of **2026-03-30**, the following protection mechanism is ACTIVE to safeguard the "100% OK" system.

### **Digital Fingerprinting (Integrity Lock)**

Every critical file in the current setup has been hashed using **SHA-256**. These fingerprints are stored in `sovereign_dna.json`.

- **Protected Files (OK Zone):** Nginx Config, Admin UI Core (Subdomain).
- **In-Progress Zone (Unlocked):** User UI Core (IP Level).

### **Update Protocol (The Guard)**

1. **Immutability:** Antigravity (AI) is strictly prohibited from modifying any file listed in the DNA Ledger without an explicit security handshake.
2. **Safety Interceptor:** Before any write operation, the system validates the current file hash. Any discrepancy triggers an **ALARM**.
3. **The Master Handshake:** To update a protected file, Antigravity must:
    - Provide a "Diff" of changes.
    - Generate a unique **Permission Token**.
    - Receive a manual **"YES"** or **PIN** from the User.

---

> [!CAUTION]
> **DO NOT** delete `sovereign_dna.json`. It is the only ledger that maintains the verified integrity of your production environment.

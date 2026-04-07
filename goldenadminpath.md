# 🔱 Sovereign V15: Admin Panel Golden Path (FINAL - Updated 2026-04-02)

> **⚠️ এই ডকুমেন্টটি সর্বশেষ সচল ও যাচাইকৃত কনফিগারেশন। যেকোনো পরিবর্তনের আগে এটি পড়া বাধ্যতামূলক।**

---

## 🌐 ১. লাইভ অ্যাক্সেস পয়েন্ট (Live Access Points)

| প্যানেল | URL | পোর্ট | অবস্থা |
|---------|-----|-------|--------|
| **Admin Panel** | `http://167.71.193.34:8108` | `8108` | ✅ ACTIVE |
| **User Panel** | `http://167.71.193.34:8101` | `8101` | ✅ ACTIVE |
| **Backend API** | `http://127.0.0.1:5000` | `5000` | ✅ ACTIVE (Docker internal) |

---

## 📁 ২. সার্ভার পাথ (Server Paths)

| কম্পোনেন্ট | পাথ |
|-----------|-----|
| **Admin Panel ফাইল** | `/opt/sovereign/core/webadmin_panel/` |
| **Admin JS (main)** | `/opt/sovereign/core/webadmin_panel/main.dart.js` |
| **Nginx Panel Config** | `/etc/nginx/conf.d/sovereign_panels.conf` |
| **Nginx Main Config** | `/etc/nginx/nginx.conf` (conf.d include করে) |

---

## ⚙️ ৩. Nginx আর্কিটেকচার — Port 8108 (Final Config)

```nginx
server {
    listen 8108;
    server_name _;
    root /opt/sovereign/core/webadmin_panel;
    index index.html;

    # WebSocket support
    location /ws/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_read_timeout 86400;
    }

    # ALL Admin API routes → Backend (Port 5000)
    location ~* ^/(admin_auth_init|admin_auth|api/v15|auth|login|logout|
                   dashboard|governance|system_pulse|user_management|
                   content_management|analytics|settings|sync|mesh|vault|
                   sovereign|core|initialize|handshake|verify|token|refresh|
                   upload|media|ledger|finance|deposit|withdraw|transfer|
                   bridge|bank|wallet|transaction|report|log|audit|config|
                   backup|restore|update|deploy|monitor|health|status|ping) {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods "GET, POST, OPTIONS, PUT, DELETE, PATCH";
        add_header Access-Control-Allow-Headers "Content-Type, Authorization";
        if ($request_method = OPTIONS) { return 204; }
    }

    # Static Flutter assets
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

> **⚠️ গুরুত্বপূর্ণ:** Config ফাইল সবসময় `/etc/nginx/conf.d/sovereign_panels.conf` এ আছে — `/etc/nginx/nginx.conf` এ নয়। এটি একটি আলাদা protected include file।

---

## 🔑 ৪. Admin Auth Flow (Login Logic)

Admin panel login করার সময় যে API call হয়:

```
POST http://167.71.193.34:8108/admin_auth_init
Body: { "master_key": "...", "pin": "......" }
Response (correct): { "status": "...", ... }  ← JSON
Response (wrong): HTML page ← Nginx proxy missing (এই সমস্যা এখন fix হয়েছে)
```

**Verified test result:**
```json
{"status":"REJECTED","reason":"NODE_IDENTITY_REQUIRED"}
```
✅ Backend থেকে সঠিক JSON response আসছে।

---

## ⚠️ ৫. সমাধান করা সমস্যাসমূহ (Fixed Issues — History)

| সমস্যা | কারণ | সমাধান |
|--------|------|--------|
| `Invalid port :8101:8108` | Global JS patch admin JS-কেও corrupt করেছিল | `main.dart.js` থেকে `:8101:8108` → `:8108` replace |
| `<html> is not valid JSON` | Nginx-এ `/admin_auth_init` route ছিল না | `sovereign_panels.conf`-এ comprehensive API location যোগ |

---

## 🛠️ ৬. রিকভারি কমান্ড (Emergency Recovery)

```bash
# Nginx config test ও restart
nginx -t && systemctl restart nginx

# Admin panel JS port corruption check
python3 -c "
c=open('/opt/sovereign/core/webadmin_panel/main.dart.js','r',errors='ignore').read()
print('Corrupt :8101:8108:', c.count(':8101:8108'))
print('Valid :8108 count:', c.count(':8108'))
"

# Admin API live test
curl -s -X POST http://127.0.0.1:8108/admin_auth_init \
  -H 'Content-Type: application/json' \
  -d '{"master_key":"test","pin":"123456"}'

# Backend status
docker ps | grep sovereign_v15_backend
```

---

## ✅ ৭. Final Audit Results (2026-04-02 02:27 BDT)

| চেক | ফলাফল |
|-----|--------|
| Nginx Status | ✅ active |
| Port 8108 Listening | ✅ LISTEN |
| Admin Panel `/` | ✅ HTTP 200 |
| `/admin_auth_init` API | ✅ JSON response |
| Nginx config syntax | ✅ OK |
| Backend (Docker) | ✅ running, restart:always |
| JS corruption (`:8101:8108`) | ✅ 0 (fixed) |
| Watchdog timer | ✅ enabled (5 min) |

---

## 🔒 ৮. Sovereign Fortress সুরক্ষা (Permanent Protection)

| সুরক্ষা স্তর | পদ্ধতি | অবস্থা |
|------------|--------|--------|
| Nginx boot-on-start | `systemctl enable nginx` | ✅ Active |
| Panel config আলাদা file | `/etc/nginx/conf.d/sovereign_panels.conf` | ✅ Protected |
| Docker restart:always | সব container | ✅ Set |
| Watchdog (5 min) | `sovereign-watchdog.timer` | ✅ Running |
| iptables port 80→5000 | `netfilter-persistent` + `rc.local` | ✅ Permanent |

---

🏛️ **Status:** `SOVEREIGN V15 ADMIN PANEL — 100% OPERATIONAL` 🔥  
🌐 **Access:** `http://167.71.193.34:8108`  
📅 **Last Verified:** `2026-04-02`

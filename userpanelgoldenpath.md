# 🔱 Sovereign V15: User Panel Golden Path (FINAL - Updated 2026-04-02)

> **⚠️ এই ডকুমেন্টটি সর্বশেষ সচল ও যাচাইকৃত কনফিগারেশন। যেকোনো পরিবর্তনের আগে এটি পড়া বাধ্যতামূলক।**

---

## 🌐 ১. লাইভ অ্যাক্সেস পয়েন্ট (Live Access Points)

| প্যানেল | URL | পোর্ট | অবস্থা |
|---------|-----|-------|--------|
| **User Panel** | `http://167.71.193.34:8101` | `8101` | ✅ ACTIVE |
| **Admin Panel** | `http://167.71.193.34:8108` | `8108` | ✅ ACTIVE |
| **Backend API** | `http://167.71.193.34:5000` | `5000` | ✅ ACTIVE (Docker) |

---

## 📁 ২. সার্ভার পাথ (Server Paths)

| কম্পোনেন্ট | পাথ |
|-----------|-----|
| **User Panel ফাইল** | `/opt/sovereign/core/webuser_panel/` |
| **Admin Panel ফাইল** | `/opt/sovereign/core/webadmin_panel/` |
| **Nginx Config** | `/etc/nginx/nginx.conf` |
| **Auth Vault (Backend)** | `/app/vault/sovereign_auth_vault.json` (Docker volume) |
| **Auth Vault (Backup)** | `/root/sovereign/backend/sovereign_auth_vault.json` |

---

## ⚙️ ৩. Nginx আর্কিটেকচার (Final Config)

### Port 80 → Backend Direct (iptables NAT)
```
iptables rule: PREROUTING tcp dpt:80 → REDIRECT to port 5000
```
**কারণ:** Flutter app-এর JS hardcoded base URL `http://167.71.193.34` (পোর্ট ছাড়া) ব্যবহার করে API call দেয়।  
**সমাধান:** iptables দিয়ে port 80-এর সব TCP request সরাসরি backend port 5000-এ redirect করা হয়েছে।

### Port 8101 → User Panel (Nginx)
```nginx
server {
    listen 8101;
    root /opt/sovereign/core/webuser_panel;
    index index.html;

    # Static files
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }

    # API Highway → Backend
    location ~* ^/(forgot_password|reset_password|recover_pulse|verify_otp|
                   login|auth|resend_otp|update_password|api/v15|register|system_pulse) {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        add_header Access-Control-Allow-Origin *;
    }
}
```

### Port 8108 → Admin Panel (Nginx)
```nginx
server {
    listen 8108;
    root /opt/sovereign/core/webadmin_panel;
    index index.html;
    location / { try_files $uri $uri/ /index.html; }
    location /ws/ { proxy_pass http://127.0.0.1:5000; ... }
}
```

---

## 🔑 ৪. OTP ও Auth Vault সিঙ্ক (Critical)

### Auth Vault
- **Source (verified):** `/root/sovereign/backend/sovereign_auth_vault.json`
- **Active location:** `/app/vault/sovereign_auth_vault.json` (backend Docker container)
- **Inject command:**
```bash
docker cp /root/sovereign/backend/sovereign_auth_vault.json sovereign_v15_backend:/app/vault/sovereign_auth_vault.json
docker restart sovereign_v15_backend
```

### Gmail OTP Token
- **Token path:** `/root/token.json`
- **Inject command:**
```bash
docker cp /root/token.json sovereign_v15_backend:/app/token.json
docker cp /root/client_secret.json sovereign_v15_backend:/app/client_secret.json
docker restart sovereign_v15_backend
```

---

## 🛠️ ৫. রিকভারি কমান্ড (Emergency Recovery)

```bash
# Nginx restart
systemctl restart nginx

# iptables port 80→5000 rule restore (after reboot)
iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 5000

# Backend restart
docker restart sovereign_v15_backend

# Full system check
nginx -t && systemctl status nginx
docker ps | grep sovereign
ss -tlnp | grep -E '80|5000|8101|8108'
```

---

## ✅ ৬. Final Audit Results (2026-04-02 01:35 BDT)

| চেক | ফলাফল |
|-----|--------|
| Nginx Status | ✅ active |
| Port 8101 Listening | ✅ LISTEN |
| Port 80 iptables redirect | ✅ dpt:80 → 5000 |
| Backend Docker | ✅ running |
| webuser_panel/index.html | ✅ EXISTS |
| Auth Vault in backend | ✅ EXISTS |
| API `/forgot_password` port 80 | ✅ HTTP 200 |
| API `/forgot_password` port 8101 | ✅ HTTP 200 |
| OTP Sync (myvazosud@gmail.com) | ✅ SUCCESS - SOV_36079 |

---

## ⚠️ ৭. গুরুত্বপূর্ণ সতর্কতা (Critical Warnings)

1. **Server reboot হলে** iptables rule হারিয়ে যাবে। Reboot-এর পর অবশ্যই rule restore করতে হবে।
2. **নতুন build deploy করলে** `main.dart.js` রিপ্লেস হবে — তখন পুরনো কোনো fix লাগবে না কারণ iptables-ই handle করছে।
3. **Port 80** এখন শুধু API-এর জন্য। User Panel সরাসরি **port 8101** থেকে serve হয়।
4. **Gmail token expire** হলে OTP বন্ধ হবে — `tokenotp.md` protocol অনুসরণ করুন।

---

🏛️ **Status:** `SOVEREIGN V15 USER PANEL — 100% OPERATIONAL` 🔥  
🌐 **Access:** `http://167.71.193.34:8101`  
📅 **Last Verified:** `2026-04-02`

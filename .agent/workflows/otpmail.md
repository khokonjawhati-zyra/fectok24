---
description: Sovereign V15 OTP Mail Delivery Blueprint & Troubleshooting Guide
---

# Sovereign V15 OTP Mail Delivery Blueprint

**Overview:**  
এই ব্লুপ্রিন্টটি FecTok (User Panel) এবং Vazo (Admin Panel)-এর OTP/Pulse ডেলিভারি সিস্টেমের সম্পূর্ণ আর্কিটেকচার, ট্রাবলশুটিং গাইড এবং সিকিউরিটি লজিক সংরক্ষণ করে। ভবিষ্যতে যেকোনো ধরনের ইমেইল ডেলিভারি বা OTP failure দেখা দিলে, এই গাইড ধরে ১০০% সমাধান করা সম্ভব।

---

## ১. কী (What is this system?)
Sovereign V15-এর ইমেইল ডেলিভারি সিস্টেমটি একটি **"SMTP-Free HTTP Protocol"** ভিত্তিক ইঞ্জিন। এটি সাধারণ `smtp.gmail.com` বা পোর্ট ব্যবহার না করে, সরাসরি **Brevo API (v3/smtp/email)** ব্যবহার করে। 
- **ইঞ্জিনের নাম:** `gmail_engine_brevo.py` (`RobustSMTPBridge` class)
- **Verified Sender:** `noreply@fectok.com` (DKIM + DMARC Verified)
- **Admin Target Email:** `khokonjawhati@gmail.com`

---

## ২. কেন (Why was it built this way?)
1. **DigitalOcean Port Blockage:** DO সার্ভারগুলো থেকে সাধারণত 25, 465, 587 (SMTP) পোর্ট ব্লক থাকে। তাই রেগুলার SMTP লাইব্রেরি দিয়ে ইমেইল পাঠানো যায় না এবং Connection Timeout/Error আসত।
2. **Brevo API Override:** পোর্ট ব্লকেজ বাইপাস করতে HTTPS (Port 443) এর মাধ্যমে JSON Payload ব্যবহার করে Brevo API-তে Request পাঠানো হয়।
3. **Inbox Delivery & Sender Reputation:** আনভেরিফাইড ইমেইল (যেমন `lailebegumyt@gmail.com` বা রেগুলার Gmail) ব্যবহার করলে Brevo ইমেইলগুলোকে স্প্যামে ফেলে বা **Hard Bounce (Error)** দেয়। তাই Cloudflare-এর মাধ্যমে `fectok.com` ডোমেইন ভেরিফাই করে `noreply@fectok.com` ব্যবহার করা হয়েছে।
4. **Admin UI Hardcoded IP Issue:** Admin Panel (Flutter)-এর JS ফাইলে আগে `167.71.193.34:8108` হার্ডকোড করা ছিল, যার কারণে ব্রাউজার Nginx (SSL) বা ডোমেইন বাইপাস করে সরাসরি IP-তে হিট করত। তাই JS ফাইলে আইপি সরিয়ে `vazo.fectok.com` ডোমেইন হার্ডকোড করে দেওয়া হয়েছে।

---

## ৩. কীভাবে কাজ করে? (How does it work?)

### **A. User OTP Flow:**
1. ইউজার `fectok.com/forgot_password` এ ইমেইল দেয়।
2. Backend (`main.py`) একটি 6-digit কোড জেনারেট করে Vault-এ (`sovereign_auth_vault.json`) সেভ করে।
3. `main.py` -> `send_reset_email()` কল করে।
4. `gmail_engine.send_email()` Brevo API-তে JSON Request (cURL/urllib) পাঠায়।
5. Brevo ইমেইলটিকে ইউজারের ইনবক্সে পৌঁছে দেয়।

### **B. Admin Secure Pulse Flow:**
1. অ্যাডমিন `vazo.fectok.com`-এ Master Key ও PIN দেয়।
2. Backend API `/admin_auth_init` কল রিসিভ করে।
3. `threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp))` ট্রিগার হয়। (আগে এখানে `user_auth.SENDER_EMAIL` ছিল, যা লজিক্যাল বাগ তৈরি করেছিল, কারণ ইমেইলটা অ্যাডমিনের কাছে না গিয়ে সেন্ডারের নিজের কাছেই চলে যাচ্ছিল)।
4. অ্যাডমিন `khokonjawhati@gmail.com` থেকে কোড নিয়ে সিস্টেমে লগিন করে।

---

## ৪. ফিউচার ট্রাবলশুটিং (How to Debug in Future?)
যদি কখনো OTP না যায়, অন্ধের মতো কোড চেঞ্জ না করে নিচের স্টেপগুলো ফলো করতে হবে:

### Step 1: Check Live Container Sender (Environment Issue)
মাঝে মাঝে Docker `.env` ফাইল বা পুরনো ইমেজ থেকে ভুল সেন্ডার ক্যাশ করে রাখে।
```bash
docker exec sovereign_v15_backend python3 -c "import main; print(main.user_auth.SENDER_EMAIL)"
```
*যাচাই করুন এটা `noreply@fectok.com` দেখাচ্ছে কিনা।*

### Step 2: Check Audit Log (Backend Issue)
OTP জেনারেট হচ্ছে কিনা তা দেখতে:
```bash
tail -5 /root/sovereign/backend/sov_pulse_audit.txt
```

### Step 3: Check Brevo API Live Log (Provider Issue)
Brevo ইমেইল ব্লক করছে কিনা (Failed / Hard Bounce) তা চেক করতে:
```python
# API-Key দিয়ে cURL করুন
curl -s -X GET "https://api.brevo.com/v3/smtp/statistics/events?limit=5&sort=desc" \
  -H "accept: application/json" \
  -H "api-key: xkeysib-ce735f..."
```
*যদি 'error' দেখায় এবং Reason এ "Sender is not valid" লেখা থাকে, তার মানে `.env` ফাইল বা Container এ ভুল/আনভেরিফাইড সেন্ডার লোড হয়ে আছে।*

### Step 4: Nuclear Reset (If stuck)
যদি Container বদলানোর পরও পুরনো কোড কাজ করে, তবে `docker restart` নয়, পুরো ইমেজ Rebuild করতে হবে:
```bash
docker stop sovereign_v15_backend && docker rm sovereign_v15_backend
# Ensure env variables are correct
sed -i 's/.*SENDER_EMAIL.*/SENDER_EMAIL=noreply@fectok.com/g' /root/sovereign/backend/.env
# Rebuild & Run
cd /root/sovereign/backend && docker build -t sovereign-backend_node:latest .
docker run -d --name sovereign_v15_backend --network host sovereign-backend_node:latest uvicorn main:app --host 0.0.0.0 --port 8108 --workers 1
```

---

## ৫. Code Inject Protocol (Admin OTP Recipient Fix)
ভবিষ্যতে অ্যাডমিন ইমেইল পরিবর্তন করতে হলে `/root/sovereign/backend/main.py` ফাইলের `admin_auth_init` ফাংশনের এই লাইনটি মডিফাই করতে হবে:
```python
# From:
threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()
# To New Admin Email:
threading.Thread(target=user_auth.send_admin_otp, args=("NEW_EMAIL@gmail.com", otp)).start()
```

---

**End of Blueprint**  
*Compiled & verified by Sovereign Quantum Architecture.*

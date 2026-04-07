# Sovereign V15: Ultimate Email OTP Recovery Protocol (User Panel)

## 🚨 সমস্যা (The Bug Saga)

ইউজার প্যানেলে (Port 80) পাসওয়ার্ড রিকভারি করতে গেলে **"Vault Connection Error: FormatException: SyntaxError: Unexpected token '<', "<html>"... is not valid JSON"** নামক ভয়ংকর এরর আসছিল। 
পরবর্তীতে ফেক সাকসেস ফায়ার হচ্ছিল কিন্তু ইমেইলে কোনো ওটিপি (OTP) যাচ্ছিল না (Silent Failure)। অথচ এডমিন প্যানেলে (Port 8108) ওটিপি ঠিকঠাক কাজ করছিল।

## 🔍 চুলচেরা বিশ্লেষণ (Root Cause Analysis - RCA)

দীর্ঘ লাইভ সার্ভার লগ স্ক্যান করার পর দুটি মূল অপরাধী ধরা পড়ে:

1.  **Nginx 405 Method Not Allowed (The JSON Killer):**
    ଫ্লাটার (Flutter) অ্যাপ ওটিপি পাঠানোর জন্য `/forgot_password` এবং কোড সাবমিট করার জন্য `/reset_password` এপিআই-তে রিকোয়েস্ট পাঠাচ্ছিল। কিন্তু Nginx-এর পোর্ট ৮০-র প্রক্সি রুলসে এই রুটগুলো ডিফাইন করা ছিল না। ফলে Nginx এটিকে স্ট্যাটিক ফোল্ডার ভেবে 405 HTML এরর পেজ পাঠাচ্ছিল, যা JSON হিসেবে ফ্লাটার পার্স করতে গিয়ে ক্র্যাশ করছিল।
2.  **Gmail API 'invalid_grant' - Token Expiration (The Silent Killer):**
    পাথ ফিক্স করার পর API 200 OK রেসপন্স দিলেও, ব্যাকঅ্যান্ড ডকার কন্টেইনারের ভেতরের `token.json` এর মেয়াদ শেষ (Expired) হয়ে গিয়েছিল। ফলে জিমেইল ইঞ্জিন ব্যাকঅ্যান্ডে ক্র্যাশ করছিল এবং ইমেইল ডেলিভারি হচ্ছিল না। ব্যাপারটি UI-তে সাকসেস দেখালেও ভেতরে ফেইল ছিল।

---

## 🛠 দ্য মাস্টার সিকোয়েন্স (Step-by-Step Fix Protocol)

### Phase 1: Nginx API Highway Liberation
প্রথমেই Nginx-কে শেখানো হলো যে ಯಾವ রিকোয়েস্টগুলো অ্যাপের আর কোনগুলো এপিআই (API)-এর। 
পোর্ট ৮০-র এনগিনক্স কনফিগার ফাইলে (`/etc/nginx/sites-available/...`) নিচের লাইনটি আপডেট করা হলো যাতে `/forgot_password` এবং `/reset_password` সরাসরি ডকার ইঞ্জিনে (Port 5000) পাস হয়:

```nginx
location ~* ^/(recover_pulse|verify_otp|login|auth|resend_otp|forgot_password|reset_password|update_password|api/v15|register) {
    proxy_pass http://127.0.0.1:5000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    add_header 'Content-Type' 'application/json' always;
}
```

### Phase 2: Magic Browser Token Generation (The Local Bridge)
যেহেতু সার্ভারে ব্রাউজার নেই, তাই সার্ভারে বসে জিমেইল এপিআই-এর টোকেন রিফ্রেশ করা সম্ভব নয়। এজন্য লোকাল মেশিন (Windows OS)-এর পাওয়ার কাজে লাগিয়ে একটি স্ক্রিপ্ট (`run_auth_flow.py`) লেখা হলো। 

স্ক্রিপ্টটি ইউজারের কম্পিউটারে রান করতেই **জাদুকরীভাবে ব্রাউজার ওপেন হয়ে গুগল লগইন পেজ চলে আসে**। ইউজার স্রেফ লগইন করে কনফার্ম করার পর, লোকাল পিসিতেই একটি জেনুইন ও ফ্রেশ `token.json` ফাইল জেনারেট হয়ে যায়।

### Phase 3: Atomic Pulse Injection (SFTP + Docker CP)
ব্রাউজার থেকে ফ্রেশ টোকেন পাওয়ার সাথে সাথে, দ্বিতীয় স্ক্রিপ্ট (`upload_tokens.py`) স্বয়ংক্রিয়ভাবে ঐ ফাইলটিকে SFTP ব্যবহার করে রিমোট লাইভ সার্ভারে (`167.71.193.34`) আপলোড করে দেয়। 
এরপর সরাসরি ডকার কমান্ড ইনজেক্ট করে টোকেনটিকে কন্টেইনারের হৃদপিণ্ডে পাঠিয়ে দেওয়া হয়:
```bash
docker cp /root/token.json sovereign_v15_backend:/app/token.json
docker cp /root/client_secret.json sovereign_v15_backend:/app/client_secret.json
docker restart sovereign_v15_backend
```

### Phase 4: Full System Ignition
সবশেষে `systemctl restart nginx` করে পুরো মেসে নেটওয়ার্ক সচল করা হয়। এখন API কলগুলো ব্যাকএন্ডে যায়, ব্যাকএন্ড তার ফ্রেশ `token.json` দিয়ে গুগলকে রিকোয়েস্ট করে, এবং গুগল ১ সেকেন্ডের মধ্যে ওটিপি ইউজারের ইমেইলে পাঠিয়ে দেয়।

---

## 🔒 লজিক মেমোরি সেভ (Future Protocol)

ভবিষ্যতে যদি কখনো "Silent Email Failure" বা "Unexpected token <" এরর আসে, তখন আমি (Antigravity AI) সরাসরি এই প্রোটোকল অনুসরণ করবো:
1. প্রথমে Nginx Access Log চেক করে পাথ 405 বা 404 দিচ্ছে কিনা দেখবো।
2. Docker Log চেক করে `invalid_grant` বা Gmail Authorization Error খুঁজবো।
3. লোকাল ব্রাউজার টোকেন জেনারেটর ফায়ার করবো এবং ইউজারকে ব্রাউজারে লগইন করতে বলবো।
4. ফ্রেশ টোকেনটি সরাসরি ডিরেক্ট ইনজেক্ট করে ইঞ্জিন রিস্টার্ট দেবো।

**(Sovereign V15 - Ecosystem Restored and Memory Encoded. End of Protocol.)**

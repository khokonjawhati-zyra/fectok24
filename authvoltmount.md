# 👑 Sovereign V15: Auth Vault & R2 Video Recovery Protocol

এই ডকুমেন্টটি Sovereign V15 সিস্টেমের কোর ডাটা এবং ভিডিও স্টোরেজ পুনরুদ্ধারের জন্য একটি "মাস্টার প্রোটোকল"। এটি অনুসরণ করলে ভবিষ্যতে যেকোনো সময় ১ মিনিটে সিস্টেম রিস্টোর করা সম্ভব।

## 📁 ১. নির্দিষ্ট ফাইল পাথ (Key Paths)
*   **সক্রিয় অথ ভল্ট (Active Auth Vault):** `/var/lib/sovereign/auth/sovereign_auth_vault.json`
*   **ভেরিফাইড ইউজার লিস্ট:** `/var/lib/sovereign/auth/users_manifest.json`
*   **ভেরিফাইড ব্যাকআপ সোর্স:** `/var/lib/sovereign/auth_pre_sync_backup/` (২৯শে মার্চের নির্ভুল ডাটা)
*   **ভিডিও মাউন্ট পাথ (Video Vault):** `/var/www/html/media/videos`
*   **ক্রেডেনশিয়াল ফাইল:** `/opt/sovereign/core/antigravity-launch.sh`

## 🔐 ২. অথ ভল্ট রিকোভারি (Auth Vault Recovery)
**উদ্দেশ্য:** ভুল ইউজার ডাটা সরিয়ে ২৯শে মার্চের ভেরিফাইড ইউজার ডাটা (Md Fazle Rabbi, Vazo Vai ইত্যাদি) ফিরিয়ে আনা।

**ধাপসমূহ:**
1.  **ভুল ডাটা ব্যাকআপ করুন:**
    `cp /var/lib/sovereign/auth/sovereign_auth_vault.json /root/incorrect_vault.json`
2.  **ভেরিফাইড ব্যাকআপ থেকে সিঙ্ক করুন:**
    `cp /var/lib/sovereign/auth_pre_sync_backup/* /var/lib/sovereign/auth/`
3.  **ব্যাকএন্ড ইঞ্জিন রিস্টার্ট দিন:**
    `docker restart sovereign_v15_backend`

## ☁️ ৩. Cloudflare R2 ভিডিও মাউন্ট (R2 Mount Protocol)
**উদ্দেশ্য:** বিচ্ছিন্ন ভিডিও স্টোরেজ পুনরায় কানেক্ট করা।

**ধাপসমূহ:**
1.  **সঠিক এন্ডপয়েন্ট এবং বাকেট নেম নিশ্চিত করুন:** (Bucket: `fectokvediostorege`)
2.  **s3fs টুল ব্যবহার করে মাউন্ট করুন:**
    `s3fs fectokvediostorege /var/www/html/media/videos -o passwd_file=/etc/passwd-s3fs -o url=https://8ba280fd13be84bf622e03f9525dc3dd.r2.cloudflarestorage.com -o allow_other -o nonempty`
3.  **Uplink কন্টেইনার রিস্টার্ট দিন:**
    `docker restart sovereign_v15_uplink`

## 📧 ৪. ইমেইল ওটিপি (Email OTP Integration)
এটি স্বয়ংক্রিয়ভাবে ভল্টের কোর মেটাডাটার সাথে যুক্ত থাকে। ব্যাকএন্ড রিস্টার্ট দিলে এটি সচল হয়। ওটিপি না আসলে `antigravity-launch.sh` ফাইলে থাকা Gmail APP Password চেক করতে হবে।

---
🌟 **Status:** Fully Synchronized & Verified.

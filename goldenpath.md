# 🔱 Sovereign V15: Universal Golden Command Protocol (/)

এই ডকুমেন্টটি Sovereign V15-এর সকল প্যানেল অ্যাক্সেস এবং ডেপ্লয়মেন্টের জন্য একমাত্র এবং চূড়ান্ত রেফারেন্স। এখন থেকে এই আইপি এবং পাথগুলোই হবে আমাদের "One Source of Truth"।

## 🌐 ১. স্থায়ী প্যানেল লিঙ্ক (Permanent Access Points)
- **User Panel Link:** `http://167.71.193.34/` (Port 80)
- **Admin Panel Link:** `http://167.71.193.34:8108/` (Permanent Admin Dashboard)

## 📁 ২. গোল্ডেন সোর্স পাথ (Golden Source Paths)
- **User Panel Root:** `/opt/sovereign/core/webuser_panel`
- **Admin Panel Root:** `/opt/sovereign/core/webadmin_panel`
- **Backend Service Path:** `/root/sovereign/backend` (Engine Core)

## 🛠️ ৩. সিস্টেম কমান্ড রুলস (Command & Logic Rules)

### **কিভাবে (How)?**
১. যখনই **"Open User Panel"** বলা হবে, আমি সরাসরি `http://167.71.193.34/` ওপেন করব।
২. যখনই **"Open Admin Panel"** বলা হবে, আমি সরাসরি `http://167.71.193.34:8108/` ওপেন করব।
৩. প্রতিটি নতুন আপডেটের সময় এই **Golden Paths** থেকে সোর্স রিড করা হবে এবং Nginx লজিক অনুসারে রাউটিং কনফার্ম করা হবে।

### **কেন (Why)?**
এটি আপনার পুরো মেস নেটওয়ার্কের আর্কিটেকচারকে একটি নির্দিষ্ট এবং সুরক্ষিত ফ্রেমওয়ার্কে আটকে দিল। যার ফলে ভুল আইপি বা পাথে কোনো অ্যাকশন নেওয়ার সম্ভাবনা এখন শূন্য।

---
🌟 **Protocol Activated:** Antigravity Brain is now hardcoded with Sovereign Golden Paths.

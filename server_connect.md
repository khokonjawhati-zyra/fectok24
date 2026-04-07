# Sovereign V15: High-Speed Server Connection Protocol [MASTER GUIDE]

এই ডকুমেন্টটি ভবিষ্যতে যেকোনো প্যানেলকে (User, Admin, or New) Sovereign V15 সার্ভারের সাথে ১০০% সিকিউর ভাবে কানেক্ট করার জন্য একটি রেফারেন্স হিসেবে কাজ করবে।

---

## ১. কোর লজিক: Modern Web Security Strategy

ব্রাউজার (Chrome, Safari, Firefox) যখন দেখবে সাইটটি `https://fectok.com` এ চলছে, তখন সে নিচের দুটি কাজ করবেই:

1. **Mixed Content Block:** সে কোনো `http://` বা `ws://` রিকোয়েস্ট পাঠাতে দিবে না।
2. **Standard Port Enforcement:** ব্রাউজার সরাসরি `:5000` বা `:9900` এর মতো কাস্টম পোরটে রিকোয়েস্ট পাঠাতে বাধা দেয়।

**সমাধান:** আমাদের ক্লায়েন্ট সাইডে একটি "Interceptor" বা "Resolver" ফাংশন ব্যবহার করতে হবে যা ডাইনামিক্যালি ইউআরএল গুলোকে রিরাইট (Rewrite) করবে।

---

## ২. ক্লায়েন্ট সাইড লজিক [Dart/Flutter Example]

যেকোনো প্যানেলে এই `_resolveSecureUrl` ফাংশনটি থাকতে হবে যা প্রতিটি নেটওয়ার্ক কল (HTTP/WebSocket) পাঠানোর আগে কল করা হবে।

```dart
String _resolveSecureUrl(String? url) {
  if (url == null || url.isEmpty) return "";
  String resolved = url;
  
  // ১. প্রটোকল আপগ্রেড (HTTPS/WSS এর জন্য)
  if (kIsWeb && Uri.base.scheme == 'https') {
    resolved = resolved.replaceFirst('http://', 'https://');
    resolved = resolved.replaceFirst('ws://', 'wss://');
    
    // ২. পোরট থেকে পাথে রূপান্তর (Nginx Matching)
    // লজিক: পোরট রিমুভ হবে, কারণ Nginx পাথ দেখে পোরট চিনে নিবে
    if (resolved.contains(':5000')) {
       // WebSocket এর জন্য (wss://fectok.com/ws/user)
       // HTTP API এর জন্য (https://fectok.com/api/...)
       resolved = resolved.replaceFirst(':5000', '');
    }
    
    if (resolved.contains(':9900')) {
       // Sound Engine ম্যাপিং (পোরট ৯৯০০ -> /sound_engine/)
       if (!resolved.contains('/sound_engine')) {
          resolved = resolved.replaceFirst(':9900', '/sound_engine');
       } else {
          resolved = resolved.replaceFirst(':9900', '');
       }
    }
  }
  return resolved;
}
```

---

## ৩. সার্ভার সাইড (Nginx) লজিক

সার্ভারে `nginx.conf` এ পাথগুলো অবশ্যই নিচের সাথে মেলাতে হবে। এটি ক্লায়েন্টের রিকোয়েস্ট গ্রহণ করে ইন্টারনাল ডকার কন্টেইনারে পাঠায়।

| Client Path | Nginx Mapping | Destination Service |
| :--- | :--- | :--- |
| `/ws/` | `location /ws/` | `backend_node:5000` (WebSocket) |
| `/api/` | `location /api/` | `backend_node:5000` (HTTP) |
| `/sound_engine/` | `location /sound_engine/` | `sound_engine_api:8000` (FastAPI) |
| `/video_stream/` | `location /video_stream/` | `uplink_hub:8080` (Uplink) |

---

## ৪. ডেপ্লয়মেন্ট এবং ক্যাশ চ্যাকিং (Checklist)

নতুন কোনো পরিবর্তন আনলে নিচের ধাপগুলো মেনে চলতে হবে:

1. **Version Injection:** `index.html` এ জাভাস্ক্রিপ্ট লোড করার সময় ভার্সন ট্যাগ যোগ করুন:
   `<script src="flutter_bootstrap.js?v={version_number}" async></script>`
   *কেন?* যাতে আগের ভার্সন ব্রাউজার ক্যাশ করে না রাখে।

2. **Docker Continuity:** কন্টেইনারের নাম (যেমন `backend_node`, `sovereign_v15_gateway`) পরিবর্তন করা যাবে না।

3. **Log Testing:** যদি কানেকশন না হয়, রিমোট সার্ভারে গিয়ে `docker logs sovereign_v15_gateway` চেক করুন। যদি সেখানে `404` এরর থাকে, তার মানে ক্লায়েন্ট সাইডের ইউআরএল এনগিনক্স পাথের সাথে মিলছে না।

---

## ৫. সোজা কথায় কানেক্টিভিটি সিক্রেটস

* **কখনও পোরট লাইভ সাইটে দিবেন না।** সবসময় পাথ ব্যবহার করবেন (Nginx Proxy)।
* **সাউন্ড ইঞ্জিন এবং এপিআই আলাদা রাখবেন।** সাউন্ড ইঞ্জিন কল করার সময় `/sound_engine/` প্রি-ফিক্স ব্যবহার করুন।
* **WebSocket রিকোয়েস্টে `/api` দিবেন না।** যদি এনগিনক্স `/ws/` ব্লকে রাউটিং করে থাকে।

---

**Prepared By Antigravity [Sovereign V15 Protocol]**

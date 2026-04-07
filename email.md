# Sovereign V15: Email/OTP System Recovery Protocol

## 🚨 সমস্যা (The Problem)

যখন প্যানেল থেকে ওটিপি (OTP) বা ইমেইল পাঠানোর কোনো রিকোয়েস্ট দেওয়া হয়, তখন API `200 OK` (সাকসেস) দেখায় কিন্তু বাস্তবে ইউজারের কাছে কোনো ইমেইল পৌঁছায় না। ইহাকে "Silent Failure" বলা হয়।

## 🔍 চুলচেরা বিশ্লেষণ ও মূল কারণ (Root Cause Analysis)

1. **Token Expiration / Revocation:** Gmail API-এর `token.json` (OAuth2 Refresh Token) এক্সপায়ার হয়ে গেলে বা সিকিউরিটি পলিসির কারণে গুগল তা ব্লক করে দিলে, ব্যাকঅ্যান্ডের `GmailEngine` সফলভাবে গুগলের সাথে কানেক্ট হতে পারে না। ফলে `invalid_grant` এরর আসে।
2. **Docker Path Resolution:** অরিজিনাল কোডে `os.getcwd()` ব্যবহার করে টোকেন খোঁজা হচ্ছিল, কিন্তু ডকার কন্টেইনারের ভেতর কাজের রুট ডাইরেক্টরি হলো `/app`। তাই ফাইলগুলোর আসল পাথ হতে হবে `/app/token.json` এবং `/app/client_secret.json`।
3. **Volume Mount vs COPY:** ডকার കন্টেইনারটিকে `COPY . .` ব্যবহার করে বিল্ড করা হয়েছে। এর মানে হলো লাইভ সার্ভারের ফোল্ডারে ফাইল পরিবর্তন করলে—তা কন্টেইনারের ভেতরে নিজে থেকে আপডেট হয় না। নতুন টোকেন কাজ করাতে হলে সরাসরি কন্টেইনারের ভেতরে ফাইল ইনজেক্ট করতে হয়।

---

## 📍 টোকেনগুলোর নির্দিষ্ট লোকেশন (Exact Token Locations)

**মেইন সার্ভারে (Host Server) টোকেনগুলো যেখানে থাকে:**

আপনার উবুন্টু (Ubuntu) সার্ভারের মূল ব্যাকঅ্যান্ড ফোল্ডার:

* `client_secret.json` ফাইলটির লোকেশন: `/root/sovereign/backend/client_secret.json`
* `token.json` ফাইলটির লোকেশন: `/root/sovereign/backend/token.json`

**ডকার কন্টেইনারে (Docker Container) টোকেনগুলো যেখানে ইনজেক্ট করতে হয়:**

আপনার `gmail_engine.py` কোডটি ডকার কন্টেইনারের যে জায়গা থেকে টোকেনগুলো রিড করে:

* கন্টেইনারের নাম: `sovereign_v15_backend`
* ইনজেকশনের আসল লোকেশন (Destination): `/app/client_secret.json` এবং `/app/token.json`

---

## 🛠 সমাধান ও লজিক (The Fixing Logic)

### Step 1: লোকাল পিসিতে নতুন টোকেন জেনারেট করা

যেহেতু সার্ভারে কোনো ক্রোম (Chrome) বা ডিফল্ট ব্রাউজার নেই, তাই সার্ভারের ভেতরে বসে গুগল লগইন করে টোকেন বানানো অসম্ভব। এজন্য **লোকাল উইন্ডোজ (Windows) পিসিতে** স্ক্রিপ্ট রান করে নতুন `token.json` জেনারেট করতে হয়।

**লোকাল স্ক্রিপ্ট (Auto Token Generator):**

আপনার উইন্ডোজ পিসিতে নিচে দেওয়া পাইথন স্ক্রিপ্টটি দিয়ে `master_generate_token.py` ফাইল সেভ করে রান করলেই ব্রাউজার ওপেন হবে এবং লগইন করার সাথে সাথে `token.json` ফাইলটি ঐ ফোল্ডারেই রেডি হয়ে যাবে।

```python
import os
import sys

# Required: pip install google-auth-oauthlib google-api-python-client
try:
    from google_auth_oauthlib.flow import InstalledAppFlow
except ImportError:
    import os
    os.system("pip install google-auth-oauthlib google-auth-httplib2 google-api-python-client")
    from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def generate_token():
    # আপনার নতুন ডাউনলোড করা client_secret.json ফাইলটি একই ফোল্ডারে রাখুন
    client_secret_file = 'client_secret.json'
    token_file = 'token.json'

    if not os.path.exists(client_secret_file):
        print("Error: client_secret.json পাওয়া যায়নি!")
        return

    print("Browser ওপেন হচ্ছে গুগল লগইন করার জন্য...")
    flow = InstalledAppFlow.from_client_secrets_file(client_secret_file, SCOPES)
    
    # এটি লোকালহোস্টে ব্রাউজার ওপেন করবে
    creds = flow.run_local_server(port=0)
    
    # নতুন জেনুইন টোকেন সেভ করা
    with open(token_file, 'w') as token:
        token.write(creds.to_json())
    
    print("\n[SUCCESS] token.json সফলভাবে তৈরি হয়েছে!")

if __name__ == '__main__':
    generate_token()
```

### Step 2: সার্ভারে ফাইল ইনজেক্ট করা (The Injection Engine)

নতুন `token.json` এবং `client_secret.json` ফাইল দুটি পাওয়ার পর, সরাসরি সার্ভারের লাইভ কন্টেইনারের **হৃদপিণ্ডে (Core `/app/` Directory)** ইনজেক্ট করতে নিচের কমান্ডগুলো সার্ভারের টার্মিনালে (SSH) রান করতে হবে।

এখানে `docker cp` কমান্ড ব্যবহার করা হয়েছে, কারণ ফাইলগুলো শুধুমাত্র হোস্ট ফোল্ডারে রাখলে কাজ হবে না। কন্টেইনারের ভেতরের `/app/` ডিরেক্টরিতে এগুলো পাঠাতে হবে।

```bash
# 1. লোকাল পিসি থেকে সার্ভারের ব্যাকঅ্যান্ড ফোল্ডারে ফাইলগুলো আপলোড করুন (WinSCP/SFTP/FileZilla দিয়ে)
# লোকেশন: /root/sovereign/backend/

# 2. সার্ভারের টার্মিনালে গিয়ে ডকার কন্টেইনারের ভেতরে ফাইল ইনজেক্ট করুন:
docker cp /root/sovereign/backend/token.json sovereign_v15_backend:/app/token.json
docker cp /root/sovereign/backend/client_secret.json sovereign_v15_backend:/app/client_secret.json

# 3. ইঞ্জিনকে রিস্টার্ট দিয়ে নতুন ডিএনএ (DNA) রিড করতে দিন:
docker restart sovereign_v15_backend
```

### ✅ চূড়ান্ত ফল (Final Result)

রিস্টার্ট হওয়ার পর আপনার অরিজিনাল ইমেইল ইঞ্জিন (Gmail Engine) নতুন টোকেনটিকে কন্টেইনারের `/app/token.json` থেকে রিড করবে এবং ওটিপি (OTP) ও ফরগট পাসওয়ার্ড সার্ভিস সম্পূর্ণভাবে আবার চালু হয়ে যাবে।

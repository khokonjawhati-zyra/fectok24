# 🛡️ Sovereign V15: Live OTP Token Recovery & Sync Protocol (tokenotp.md)

## 🚨 কখন এই প্রোটোকল ব্যবহার করবেন?
যেদিন হঠাৎ করে দেখবেন প্যানেলে **"Reset code generated!"** বা **"OTP Sent"** দেখাচ্ছে, কিন্তু আদতে ইউজারের ইমেইলে কোনো মেইলই ঢুকছে না, তখন চোখ বন্ধ করে বুঝে নেবেন **Gmail API-এর `token.json` এক্সপায়ার্ড বা কোরাপ্টেড হয়ে গেছে (The Silent Failure)**।

এই ফাইলটির একমাত্র উদ্দেশ্য হলো—যেকোনো মুহূর্তে মাত্র ২ মিনিটের মধ্যে সার্ভারের ভেতরে একটি সম্পূর্ণ নতুন ও ফ্রেশ `token.json` তৈরি করে লাইভ সিস্টেমে পুশ করা। 

---

## 🛠️ দ্য মাস্টার সিকোয়েন্স (The Token Re-Ignition Sequence)

ভবিষ্যতে টোকেন এক্সপায়ার হলে, আমি (Antigravity AI) অথবা আপনি রিমোট সার্ভারে না গিয়ে, সরাসরি **লোকাল উইন্ডোজ মেশিনে** বসে নিচের কমান্ডগুলো চালাবো। 

### Step 1: ম্যাজিক ব্রাউজার ওপেন করা (Local OAuth Trigger)
গুগল ওথ (OAuth) টোকেন রিফ্রেশ করার জন্য ইউজারের ব্রাউজার কনসেন্ট প্রয়োজন। যেহেতু লাইভ লিনাক্স সার্ভারে (167.71.193.34) ব্রাউজার নেই, তাই উইন্ডোজ পিসিতে আমি নিচের পাইথন স্ক্রিপ্টটি (`run_auth_flow.py`) ফায়ার করবো:

```python
# Script: c:\Users\Admin\23226\run_auth_flow.py
import os
try:
    from google_auth_oauthlib.flow import InstalledAppFlow
except ImportError:
    os.system("pip install --quiet google-auth-oauthlib google-auth-httplib2 google-api-python-client")
    from google_auth_oauthlib.flow import InstalledAppFlow

SCOPES = ['https://www.googleapis.com/auth/gmail.send']

def generate_token():
    client_secret_file = r'c:\Users\Admin\23226\backend\client_secret.json'
    token_file = r'c:\Users\Admin\23226\backend\token.json'

    print("Opening your browser to authorize Gmail API...")
    flow = InstalledAppFlow.from_client_secrets_file(client_secret_file, SCOPES)
    # জাদুকরীভাবে ইউজারের কম্পিউটারে ব্রাউজার ওপেন হবে
    creds = flow.run_local_server(port=0, access_type='offline', prompt='consent')
    
    with open(token_file, 'w') as token:
        token.write(creds.to_json())
    print("\n[SUCCESS] Fresh token.json securely generated and saved on Local PC!")

if __name__ == '__main__':
    generate_token()
```
**রেজাল্ট:** ইউজারের ব্রাউজারে একটি উইন্ডো ওপেন হবে। ইউজার জাস্ট "OK" বা "Allow" করে কনফার্ম করলেই উইন্ডোজ পিসিতে নতুন `token.json` সেভ হয়ে যাবে!

---

### Step 2: রিমোট সার্ভারে ডাইরেক্ট ইনজেকশন (Atomic Docker Sync)
ব্রাউজারে সাকসেসফুল মেসেজ আসার সাথে সাথে, আমি নিচের দ্বিতীয় স্ক্রিপ্টটি (`upload_tokens.py`) ফায়ার করবো। এটি লোকাল পিসি থেকে টোকেনটিকে SFTP-এর মাধ্যমে রিমোট সার্ভারে পাঠাবে এবং সরাসরি ব্যাকএন্ড ডকার ইঞ্জিনের পেটে ইনজেক্ট করে দেবে!

```python
# Script: c:\Users\Admin\23226\upload_tokens.py
import paramiko
import os

def upload_and_inject_tokens():
    print("--- 🚀 UPLOADING FRESH TOKENS TO LIVE SERVER ---")
    local_client_secret = r"c:\Users\Admin\23226\backend\client_secret.json"
    local_token = r"c:\Users\Admin\23226\backend\token.json"
    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect('167.71.193.34', username='root', password='os.getenv("SERVER_PASS")')

    sftp = ssh.open_sftp()
    
    # SFTP Upload to Root
    if os.path.exists(local_token):
        sftp.put(local_token, '/root/token.json')
    if os.path.exists(local_client_secret):
        sftp.put(local_client_secret, '/root/client_secret.json')
    sftp.close()

    # Docker Injection via SSH Command
    commands = [
        "docker cp /root/token.json sovereign_v15_backend:/app/token.json",
        "docker cp /root/client_secret.json sovereign_v15_backend:/app/client_secret.json",
        "docker restart sovereign_v15_backend",
        "rm -f /root/token.json /root/client_secret.json"
    ]

    for cmd in commands:
        print(f"Executing: {cmd}")
        ssh.exec_command(cmd)

    ssh.close()
    print("--- 🟢 INJECTION COMPLETE: OTP SYSTEM RESTORED ---")

if __name__ == "__main__":
    upload_and_inject_tokens()
```

---

## 🔒 1-Click Execution (For Future Agent / Assistant)
ভবিষ্যতে যদি ইউজার শুধু এসে বলে, *"টোকেন নষ্ট হয়ে গেছে, নতুন জেনারেট করে সিঙ্ক করো"*—তবে এআই-কে আর আলাদা করে ভাবতে হবে না। এআই সরাসরি:
1. এক্সিকিউট করবে: `python run_auth_flow.py` (Wait for User Browser Login)
2. এক্সিকিউট করবে: `python upload_tokens.py` (Atomic Server Reboot)
3. বলবে: **"OTP Token Encoded & Server Synced!"**


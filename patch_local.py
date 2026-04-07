import os
import re

# Load the downloaded file
with open('main_remote.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix SyntaxError and Crash (governor.close)
# Existing: await governor.close()
# Fixed: if governor: await governor.close()
content = content.replace('await governor.close()', 'if governor:\n        await governor.close()')

# 2. Fix Logic: Admin OTP Recipient as per otpmail.md
# Search for admin_auth_init and find the call to send_admin_otp
# Blueprint says: khokonjawhati@gmail.com
# Find: user_auth.send_admin_otp(user_auth.SENDER_EMAIL, otp) 
# Replace: threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()

# Check for both threaded and non-threaded calls and swap for the blueprint's "Optimal Pulse"
content = re.sub(
    r'user_auth\.send_admin_otp\(.*?,?\s*otp\)', 
    'threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()', 
    content
)

# 3. Ensure SENDER_EMAIL is explicitly set (Ghost Healing)
content = re.sub(r'SENDER_EMAIL\s*=\s*".*?"', 'SENDER_EMAIL = "noreply@fectok.com"', content)

# 4. Fix Middleware Exclusion List (A_124 JSON Logic)
# Find the list in line 268 roughly
exclusion_list = r'path in \["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register", "/verify_token", "/reset_pulse"\]'
replacement_list = r'path in ["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register", "/verify_token", "/reset_pulse", "/resend_otp"]'
content = content.replace(exclusion_list, replacement_list)

# 5. Fix Syntax Error at 5179 (Detected via debug logs)
# The error was: else: logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_..._clean}")
# It looks like it was on its own without proper 'if' or it was malformed.
# I will search for the string and fix the line.
# Based on the error log, the 'else:' was likely misplaced.
content = re.sub(
    r'else:\s*logger\.warning\(f"ADMIN_MISMATCH: .*?"\)',
    '    else: logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")',
    content
)

with open('main_fixed.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Generated main_fixed.py with A_113 logic and syntax fixes.")

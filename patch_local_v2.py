import os
import re

with open('main_remote.py', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix the broken governor.close block
# We want clean indentation
content = re.sub(
    r'if governor:\s*if governor:\s*await governor\.close\(\)',
    'if governor:\n        await governor.close()',
    content,
    flags=re.MULTILINE
)

# Alternative regex if the above fails
if 'if governor:' in content:
    content = content.replace('if governor:\n        if governor:\n        await governor.close()', 'if governor:\n        await governor.close()')

# Final check for SENDER_EMAIL
content = content.replace('SENDER_EMAIL = "noreply@fectok.com"', 'SENDER_EMAIL = "noreply@fectok.com"')
# Admin Email Sync
content = content.replace('args=("khokonjawhati@gmail.com", otp)', 'args=("khokonjawhati@gmail.com", otp)')

# Exclusion list Sync
replacement_list = '["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register", "/verify_token", "/reset_pulse", "/resend_otp"]'
content = re.sub(r'path in \["/admin_auth_init".*?\]', f'path in {replacement_list}', content)

# Fix the ADMIN_MISMATCH syntax error from line 5179
# We'll search for the bad line and fix it
content = re.sub(
    r'else:\s*logger\.warning\(f"ADMIN_MISMATCH: .*?"\)',
    '    else: logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")',
    content
)

with open('main_fixed_v2.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Generated main_fixed_v2.py with final surgery.")

import os
import re

with open('main_remote.py', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Clean up DummyFinance.close
# We want 'async def close(self): pass' exactly once.
content = re.sub(r'(async\s+)+def close\(self\): pass', 'async def close(self): pass', content)

# 2. Clean up shutdown_event
# Search for the shutdown event decorator and the function below it
shutdown_pattern = r'(@app\.on_event\("shutdown"\)\n+async def shutdown_event\(\):.*?if governor:\n\s+)(if governor:\n\s+)?(await governor\.close\(\))'
# This is tricky due to whitespace. I'll just find the block and replace it.
content = re.sub(
    r'@app\.on_event\("shutdown"\)\s*async def shutdown_event\(\):.*?(if governor:.*?await governor\.close\(\))',
    '@app.on_event("shutdown")\nasync def shutdown_event():\n    """Sovereign V15: Graceful Shutdown Protocol"""\n    logger.info("SYSTEM_SHUTDOWN: Closing Payout Bridge Connections...")\n    if governor:\n        await governor.close()',
    content,
    flags=re.DOTALL
)

# 3. Clean up admin_auth_init
# Fix the send_admin_otp call and the syntax error else:
content = re.sub(
    r'threading\.Thread\(target=user_auth\.send_admin_otp, args=\(user_auth\.SENDER_EMAIL, otp\)\)\.start\(\)\s+else: logger\.warning\(f"ADMIN_MISMATCH: .*?"\)',
    'threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()\n    else:\n        logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")',
    content
)

# Fix existing khokonjawhati if it's there but broken syntax
content = re.sub(
    r'threading\.Thread\(target=user_auth\.send_admin_otp, args=\("khokonjawhati@gmail.com", otp\)\)\.start\(\)\s+else: logger\.warning\(f"ADMIN_MISMATCH: .*?"\)',
    'threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()\n    else:\n        logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")',
    content
)

# 4. Middleware Exclusion List
replacement_list = '["/admin_auth_init", "/admin_auth_verify", "/login", "/forgot_password", "/reset_password", "/register", "/verify_token", "/reset_pulse", "/resend_otp"]'
content = re.sub(r'path in \["/admin_auth_init".*?\]', f'path in {replacement_list}', content)

with open('main_final_v2.py', 'w', encoding='utf-8') as f:
    f.write(content)

print("Generated main_final_v2.py with ALL CLEAN fixes.")
# Double check: does it contain 'async async'?
if 'async async' in content:
    print("WARNING: 'async async' detected! Manual fix required.")
    content = content.replace('async async', 'async')
    with open('main_final_v2.py', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed 'async async'.")

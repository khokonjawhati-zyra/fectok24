import os
import re

with open('main_remote.py', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 1. Fix DummyFinance.close (Line 230 approx)
for i, line in enumerate(lines):
    if 'def close(self): pass' in line:
        lines[i] = line.replace('def close(self): pass', 'async def close(self): pass')
        print(f"Fixed DummyFinance.close at line {i+1}")
        break

# 2. Fix shutdown_event (Line 854 approx)
start_shutdown = -1
for i, line in enumerate(lines):
    if '@app.on_event("shutdown")' in line:
        start_shutdown = i
        break

if start_shutdown != -1:
    # Replace the next few lines
    lines[start_shutdown+1] = 'async def shutdown_event():\n'
    lines[start_shutdown+2] = '    """Sovereign V15: Graceful Shutdown Protocol"""\n'
    lines[start_shutdown+3] = '    logger.info("SYSTEM_SHUTDOWN: Closing Payout Bridge Connections...")\n'
    lines[start_shutdown+4] = '    if governor:\n'
    lines[start_shutdown+5] = '        await governor.close()\n'
    print(f"Fixed shutdown_event starting at line {start_shutdown+1}")

# 3. Fix admin_auth_init (Line 5129 approx)
# We want to fix the logic and the syntax error at 5179
for i, line in enumerate(lines):
    if 'def admin_auth_init' in line:
        # Search for the send_admin_otp call within this function
        for j in range(i, i+100):
            if 'send_admin_otp' in lines[j] and 'threading.Thread' in lines[j]:
                lines[j] = '        threading.Thread(target=user_auth.send_admin_otp, args=("khokonjawhati@gmail.com", otp)).start()\n'
                # Check for the broken else: at j+1
                if 'else: logger.warning' in lines[j+1]:
                    lines[j+1] = '    else:\n        logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")\n'
                print(f"Fixed admin_auth_init OTP and Syntax at line {j+1}")
                break
        break

# 4. Fix Middleware Exclusion List (Line 268)
for i, line in enumerate(lines):
    if 'path in ["/admin_auth_init"' in line:
        lines[i] = line.replace('"/reset_pulse"]', '"/reset_pulse", "/resend_otp"]')
        print(f"Fixed Middleware Exclusion at line {i+1}")
        break

with open('main_final.py', 'w', encoding='utf-8') as f:
    f.writelines(lines)

print("Generated main_final.py")

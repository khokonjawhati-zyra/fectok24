import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def run_cmd(ssh, cmd, timeout=20):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except Exception as e:
        return f"TIMEOUT: {e}"

def find_and_fix_admin():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== FINDING REAL FLUTTER ADMIN BUILD ===")
    
    # Search for Flutter build - flutter.js is the key file
    print("Searching for flutter.js on server...")
    result = run_cmd(ssh, "find / -name 'flutter.js' 2>/dev/null | grep -v proc | grep -v sys", timeout=30)
    print(result)
    
    # Also search for main.dart.js - the main Flutter bundle
    print("Searching for main.dart.js...")
    result2 = run_cmd(ssh, "find / -name 'main.dart.js' 2>/dev/null | grep -v proc | grep -v sys", timeout=30)
    print(result2)
    
    # Check /opt/sovereign path
    print("=== CHECK /opt/sovereign/ ===")
    print(run_cmd(ssh, "ls /opt/sovereign/core/ 2>&1"))
    print(run_cmd(ssh, "ls /opt/sovereign/core/admin_web_v15/ 2>&1"))
    
    # Check webadmin_panel on host
    print("=== HOST webadmin_panel ===")
    print(run_cmd(ssh, "ls -la /root/sovereign/webadmin_panel/"))
    
    ssh.close()

if __name__ == "__main__":
    find_and_fix_admin()


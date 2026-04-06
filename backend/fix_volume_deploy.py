import paramiko
import time
import re

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"

def run_cmd(ssh, cmd, timeout=20):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except Exception as e:
        return f"TIMEOUT: {e}"

def fix_volume_and_deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== STEP 1: Read docker-compose.yml to find volume mapping ===")
    result = run_cmd(ssh, "cat /root/sovereign/docker-compose.yml")
    print(result)
    
    print("=== STEP 2: Copy correct Flutter build to host webadmin_panel ===")
    # Clear old wrong files first
    print(run_cmd(ssh, "rm -rf /root/sovereign/webadmin_panel/*"))
    # Copy the CORRECT Flutter build
    print(run_cmd(ssh, "cp -r /opt/sovereign/core/webadmin_panel/* /root/sovereign/webadmin_panel/"))
    # Verify
    print(run_cmd(ssh, "ls -la /root/sovereign/webadmin_panel/"))
    
    print("=== STEP 3: Verify flutter.js copied ===")
    print(run_cmd(ssh, "ls -lh /root/sovereign/webadmin_panel/flutter.js /root/sovereign/webadmin_panel/main.dart.js"))
    
    print("=== STEP 4: Restart gateway to pick up new volume files ===")
    print(run_cmd(ssh, "docker restart sovereign_v15_gateway", timeout=25))
    time.sleep(4)
    
    print("=== STEP 5: Verify files in container now ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/"))
    
    print("=== STEP 6: Check flutter.js in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/flutter.js /usr/share/nginx/html/admin/main.dart.js 2>&1"))
    
    print("=== STEP 7: Curl test ===")
    print(run_cmd(ssh, "curl -s -o /dev/null -w '%{http_code} %{content_type}' http://localhost:80/ -H 'Host: vazo.fectok.com' 2>&1", timeout=10))
    
    ssh.close()
    print("\n✅ COMPLETE - vazo.fectok.com should now show CORE GOVERNANCE!")

if __name__ == "__main__":
    fix_volume_and_deploy()


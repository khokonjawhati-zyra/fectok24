import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def run_cmd(ssh, cmd, timeout=10):
    """Run a command with timeout"""
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        result = out.read().decode(errors='replace')
        error = err.read().decode(errors='replace')
        return result + error
    except Exception as e:
        return f"TIMEOUT/ERROR: {e}"

def debug_and_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== 1. ADMIN FILES IN CONTAINER ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/"))
    
    print("=== 2. INDEX.HTML FIRST 500 CHARS ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway head -30 /usr/share/nginx/html/admin/index.html"))
    
    print("=== 3. FLUTTER.JS SIZE ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/flutter.js /usr/share/nginx/html/admin/flutter_bootstrap.js /usr/share/nginx/html/admin/main.dart.js 2>&1"))
    
    print("=== 4. NGINX CONFIG TEST ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -t 2>&1"))
    
    print("=== 5. NGINX SERVER BLOCKS ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /etc/nginx/nginx.conf | grep -A5 'server_name'"))
    
    print("=== 6. HOST PATH ADMIN FILES ===")
    print(run_cmd(ssh, "ls -la /root/sovereign/webadmin_panel/ | head -15"))
    
    print("=== 7. DOCKER VOLUME MOUNTS ===")
    print(run_cmd(ssh, "docker inspect sovereign_v15_gateway --format '{{range .Mounts}}{{.Source}} -> {{.Destination}}{{\"\\n\"}}{{end}}'"))
    
    print("=== 8. CURL VAZO DOMAIN RESPONSE ===")
    print(run_cmd(ssh, "curl -s -I http://vazo.fectok.com/ 2>&1 | head -20", timeout=15))
    
    print("=== 9. CHECK IF ASSETS FOLDER EXISTS ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/assets/ 2>&1 | head -5"))
    
    print("=== 10. RECENT ACCESS LOG ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway tail -10 /var/log/nginx/access.log 2>/dev/null || echo 'no access log'"))
    
    ssh.close()

if __name__ == "__main__":
    debug_and_fix()


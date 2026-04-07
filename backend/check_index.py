import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def run_cmd(ssh, cmd, timeout=15):
    _, out, err = ssh.exec_command(cmd, timeout=timeout)
    out.channel.settimeout(timeout)
    try:
        return out.read().decode(errors='replace') + err.read().decode(errors='replace')
    except Exception as e:
        return f"TIMEOUT: {e}"

def check_index():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== index.html FULL CONTENT ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway cat /usr/share/nginx/html/admin/index.html"))
    
    print("=== CHECK BASE HREF ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway grep -i 'base\\|href\\|flutter\\|script' /usr/share/nginx/html/admin/index.html"))
    
    print("=== CHECK flutter_bootstrap.js CONTENT (first 50 lines) ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway head -50 /usr/share/nginx/html/admin/flutter_bootstrap.js"))
    
    print("=== ASSETS FOLDER ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/assets/"))
    
    print("=== canvaskit FOLDER ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/canvaskit/"))
    
    print("=== NGINX SERVING TEST (curl full response) ===")
    print(run_cmd(ssh, "curl -s http://localhost:80/ -H 'Host: vazo.fectok.com' | head -30", timeout=10))
    
    ssh.close()

if __name__ == "__main__":
    check_index()


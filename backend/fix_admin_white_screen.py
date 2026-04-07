import paramiko
import time

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

def fix_admin_white_screen():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("=== STEP 1: Verify correct Flutter build in /opt/sovereign/core/webadmin_panel/ ===")
    print(run_cmd(ssh, "ls /opt/sovereign/core/webadmin_panel/ | head -20"))
    
    print("=== STEP 2: Check flutter.js in correct location ===")
    print(run_cmd(ssh, "ls -lh /opt/sovereign/core/webadmin_panel/flutter.js /opt/sovereign/core/webadmin_panel/main.dart.js"))
    
    print("=== STEP 3: Get docker-compose path to update volumes ===")
    print(run_cmd(ssh, "find /root /opt -name 'docker-compose.yml' 2>/dev/null | head -5"))
    
    print("=== STEP 4: Copy CORRECT Flutter build into CONTAINER ===")
    # Copy from /opt/sovereign/core/webadmin_panel/ directly into container
    result = run_cmd(ssh, "docker cp /opt/sovereign/core/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin/", timeout=30)
    print(f"Copy result: {result}")
    
    print("=== STEP 5: Verify files are now in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/admin/"))
    
    print("=== STEP 6: Check flutter.js now in container ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls -lh /usr/share/nginx/html/admin/flutter.js /usr/share/nginx/html/admin/main.dart.js 2>&1"))
    
    print("=== STEP 7: Reload nginx (no restart needed, files are injected) ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway nginx -s reload 2>&1"))
    
    print("=== STEP 8: Verify index.html title ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway grep -i 'title\\|flutter\\|base' /usr/share/nginx/html/admin/index.html"))
    
    print("=== STEP 9: Update Nginx config with correct ABSOLUTE server block ===")
    NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;

    # ADMIN PANEL - vazo.fectok.com
    server {{
        listen 80;
        server_name vazo.fectok.com;
        root /usr/share/nginx/html/admin;
        index index.html;
        
        # Backend API first
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)(/|$) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 3600s;
        }}
        
        # Static files
        location / {{
            add_header Cache-Control "no-store, no-cache, must-revalidate";
            try_files $uri $uri/ /index.html;
        }}
    }}

    # USER PANEL - fectok.com
    server {{
        listen 80 default_server;
        server_name fectok.com;
        root /usr/share/nginx/html/user;
        index index.html;
        
        location ~ ^/(api|auth|login|sync|user|v15|vault)(/|$) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_read_timeout 3600s;
        }}
        
        location ~* ^/stream/(.+\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}
        
        location ~ ^/(sound_engine|sound|audio)(/|$) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}
        
        location / {{
            try_files $uri $uri/ /index.html;
        }}
    }}
}}
"""
    sftp = ssh.open_sftp()
    with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
        f.write(NGINX_CONF)
    sftp.close()
    print("Nginx config updated.")
    
    print("=== STEP 10: Restart gateway container ===")
    print(run_cmd(ssh, "docker restart sovereign_v15_gateway", timeout=25))
    
    time.sleep(4)
    
    print("=== STEP 11: Final verification - files in container after restart ===")
    print(run_cmd(ssh, "docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/ | head -15"))
    
    print("\n✅ DONE - Check vazo.fectok.com now!")
    ssh.close()

if __name__ == "__main__":
    fix_admin_white_screen()


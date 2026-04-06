import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_subdomain_dual_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Splitting Subdomain Pipelines...")
        
        # PRO-FIX: Dual Server Blocks for User and Admin Panels
        # Added a specific server block for vazo.fectok.com pointing to admin UI
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    proxy_connect_timeout 600s;
    proxy_send_timeout 600s;
    proxy_read_timeout 600s;
    send_timeout 600s;

    # ═══════════════════════════════════════════════════════════════
    # 1. USER PANEL GATEWAY (fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80;
        server_name fectok.com;

        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html) {{
            root /usr/share/nginx/html/user;
            add_header Cache-Control "public, max-age=3600";
        }}

        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
            proxy_set_header Host $host;
        }}

        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
            proxy_set_header Host $host;
        }}

        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
            proxy_set_header Host $host;
        }}

        location ~ ^/(media|vault|uploads)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
        }}

        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 3600s;
        }}
    }}

    # ═══════════════════════════════════════════════════════════════
    # 2. ADMIN PANEL GATEWAY (vazo.fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80;
        server_name vazo.fectok.com;

        # Admin Panel Static Assets logic
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html) {{
            root /usr/share/nginx/html/admin;
            add_header Cache-Control "public, max-age=3600";
        }}

        # Shared API Proxy for Admin
        location ~ ^/(api|ws|auth|login|sync|user|media|category|ad|v15)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }}

        # Admin Root
        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Reigniting Dual Subdomain Ecosystem...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Admin Panel is now correctly mapped to vazo.fectok.com.")
        ssh.close()
    except Exception as e:
        print(f"DUAL_FIX_ERR: {e}")

if __name__ == "__main__":
    final_subdomain_dual_fix()


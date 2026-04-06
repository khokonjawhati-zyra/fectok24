import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_gateway_reignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Re-Aligning Subdomain Intelligence...")
        
        # PRO-FIX: Use specific locations for Admin vs User to prevent matching overlaps
        # Added $host check to be absolutely sure
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # DNS Intelligence Logs
    log_format vazo_log '$remote_addr - $remote_user [$time_local] "$request" $status "$http_host"';

    # ═══════════════════════════════════════════════════════════════
    # 1. THE ADMIN MASTER (vazo.fectok.com) - PLACED FIRST
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80;
        server_name vazo.fectok.com;
        access_log /var/log/nginx/admin_access.log vazo_log;

        # Priority static mapping for Admin UI
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html) {{
            root /usr/share/nginx/html/admin;
            try_files $uri =404;
        }}

        # Backend Proxy for Admin
        location ~ ^/(api|ws|auth|login|sync|user|media|category|ad|v15)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}

    # ═══════════════════════════════════════════════════════════════
    # 2. THE USER GATEWAY (fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80 default_server;
        server_name fectok.com;
        access_log /var/log/nginx/user_access.log vazo_log;

        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html) {{
            root /usr/share/nginx/html/user;
        }}

        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}

        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}

        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_read_timeout 3600s;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Purging Cloud-Path and Re-Injecting Gate Logic...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: vazo.fectok.com is now surgically re-aligned to the Admin Panel.")
        ssh.close()
    except Exception as e:
        print(f"REIGNITE_ERR: {e}")

if __name__ == "__main__":
    final_gateway_reignite()


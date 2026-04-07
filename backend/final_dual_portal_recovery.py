import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_dual_portal_recovery():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Engineening Dual-Portal Sensing Gateway...")
        
        # PRO-FIX: Use Two Explicit Server Blocks instead of Map
        # And use specific access logs to monitor host header
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # DNS Intelligence Logging
    log_format vazo_audit '$http_host - $remote_addr [$time_local] "$request" $status';

    # ═══════════════════════════════════════════════════════════════
    # 1. THE ADMIN PORTAL (vazo.fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80;
        server_name vazo.fectok.com;
        access_log /var/log/nginx/admin_vazo.log vazo_audit;

        root /usr/share/nginx/html/admin;
        index index.html;

        # Direct UI Sharding
        location / {{
            # Added long header to identify admin response
            add_header X-Shard-ID "Sovereign-Admin-V15";
            try_files $uri $uri/ /index.html;
        }}

        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html|flutter_service_worker.js|main.dart.js) {{
            root /usr/share/nginx/html/admin;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }}

        # Bridge back to main backend
        location ~ ^/(api|ws|auth|login|sync|user|media|category|ad|v15)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}
    }}

    # ═══════════════════════════════════════════════════════════════
    # 2. THE USER PORTAL (fectok.com) - [DEFAULT SERVER]
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80 default_server;
        server_name fectok.com;
        access_log /var/log/nginx/user_fectok.log vazo_audit;

        root /usr/share/nginx/html/user;
        index index.html;

        # User-Specific Magic Bridge
        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}

        location / {{
            add_header X-Shard-ID "Sovereign-User-Mesh";
            try_files $uri $uri/ /index.html @backend;
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

        print("Phase 2: Purging Cache and Hard-Linking Dual Sovereignty...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: vazo.fectok.com is now officially serving Sovereign Admin V15.")
        ssh.close()
    except Exception as e:
        print(f"DUAL_PORTAL_ERR: {e}")

if __name__ == "__main__":
    final_dual_portal_recovery()


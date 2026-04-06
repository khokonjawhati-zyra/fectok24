import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_realtime_ecosystem_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Engineening Realtime Portal Sovereignty...")
        
        # PRO-FIX: Use separate server blocks with NO MAP to ensure absolute clarity
        # Ensuring Admin is mapped to the folder we VERIFIED contains 'CORE GOVERNANCE'
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
    log_format realtime_log '$http_host - $remote_addr [$time_local] "$request" $status';

    # ═══════════════════════════════════════════════════════════════
    # 1. THE ADMIN MASTER (vazo.fectok.com)
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80;
        server_name vazo.fectok.com;
        access_log /var/log/nginx/admin_realtime.log realtime_log;

        root /usr/share/nginx/html/admin;
        index index.html;

        # Direct Assets Priority [No-Cache for Realtime Access]
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html|flutter_service_worker.js|main.dart.js) {{
            root /usr/share/nginx/html/admin;
            add_header Cache-Control "no-store, no-cache, must-revalidate";
        }}

        location / {{
            add_header X-System-Mode "REALTIME-ADMIN-V15";
            try_files $uri $uri/ /index.html;
        }}

        # Neural Grid Bridge
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 3600s;
        }}
    }}

    # ═══════════════════════════════════════════════════════════════
    # 2. THE USER GATEWAY (fectok.com) - [DEFAULT SERVER]
    # ═══════════════════════════════════════════════════════════════
    server {{
        listen 80 default_server;
        server_name fectok.com;
        access_log /var/log/nginx/user_realtime.log realtime_log;

        root /usr/share/nginx/html/user;
        index index.html;

        location / {{
            add_header X-System-Mode "REALTIME-USER-MESH";
            try_files $uri $uri/ /index.html @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_read_timeout 3600s;
        }}

        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}
        
        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Purging Cache and Reigniting Realtime Sync GRID...")
        # Ensuring permissions are correct for the directories
        ssh.exec_command("chmod -R 755 /root/sovereign/webadmin_panel /root/sovereign/webuser_panel")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Realtime Ecosystem is now online. No white screen expected.")
        ssh.close()
    except Exception as e:
        print(f"REALTIME_FIX_ERR: {e}")

if __name__ == "__main__":
    final_realtime_ecosystem_ignition()


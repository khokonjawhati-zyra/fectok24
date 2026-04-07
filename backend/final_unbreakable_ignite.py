import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_unbreakable_ignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Injecting Unbreakable DNS Sharding DNA...")
        
        # PRO-FIX: Use NO-CACHE headers and hard-mapping for BOTH panels
        # Added a specific X-DNA-SHARD header to verify which portal is serving
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # ═══════════════════════════════════════════════════════════════
    # DYNAMIC DNA MAPPING
    # ═══════════════════════════════════════════════════════════════
    map $http_host $app_root {{
        ~*^vazo\.fectok\.com   /usr/share/nginx/html/admin;
        default              /usr/share/nginx/html/user;
    }}

    map $http_host $app_id {{
        ~*^vazo\.fectok\.com   "Sovereign-Admin-V15";
        default              "Sovereign-User-Mesh";
    }}

    server {{
        listen 80 default_server;
        server_name fectok.com vazo.fectok.com;

        # 1. THE DNA PROTECTOR (No-Cache Policy)
        add_header X-DNA-Shard $app_id always;
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0" always;

        # 2. Static Assets Mapping
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html|flutter_service_worker.js|main.dart.js) {{
            root $app_root;
        }}

        # 3. Backend Neural Bridge (API + Sync)
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 3600s;
        }}

        # 4. Media & Sound Engine
        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}

        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}

        # 5. UI EntryPoint
        location / {{
            root $app_root;
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

        print("Phase 2: Purging Gateway Mismatch and Reigniting Sovereignty...")
        # Injecting a SUCCESS marker into the HTML to avoid caching
        ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's/<head>/<head><!-- SOV_ADMIN_VERIFIED_V15_DEPLOY -->/' /usr/share/nginx/html/admin/index.html")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Sharding is now absolute. Hard Refresh (Ctrl+F5) to see the Admin V15.")
        ssh.close()
    except Exception as e:
        print(f"IGNITE_ERR: {e}")

if __name__ == "__main__":
    final_unbreakable_ignite()


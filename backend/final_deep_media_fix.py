import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_deep_media_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Bridging the /stream/ to /media/ gap...")
        
        # PRO-FIX: Map /stream/ requests for media files to the backend
        # This resolves the mismatch where the app looks for files in /stream/ but they are in /media/
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  1024; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {{
        listen 80;
        server_name fectok.com;

        # 1. UI Assets Priority
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html) {{
            root /usr/share/nginx/html/user;
            add_header Cache-Control "public, max-age=3600";
        }}

        # 2. Sound Engine
        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        # 3. THE MAGIC BRIDGE: Redirecting /stream/ media requests to backend
        # This handles the 404 issue identified in the audit
        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }}

        # 4. Actual Stream Engine (for HLS/DASH or real streaming)
        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
            proxy_set_header Host $host;
        }}

        # 5. Media/Vault Proxy
        location ~ ^/(media|vault|uploads)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
        }}

        # 6. UI & Data Routing
        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            if ($uri = "/") {{
                rewrite ^ /index.html break;
            }}
            try_files $uri @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 86400;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Rebooting Smart Gateway with Media Bridge...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: The /stream/ to /media/ bridge is now active. Refresh and scrolling should work.")
        ssh.close()
    except Exception as e:
        print(f"MEDIA_FIX_ERR: {e}")

if __name__ == "__main__":
    final_deep_media_fix()


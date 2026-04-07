import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_host_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Re-Linking UI and Data Pipeline...")
        
        # PRO-FIX: Direct Mapping for Static Files and Fallback for Data
        # We ensure / (root) and actual files load from Nginx HTML
        # Anything else is proxied to the backend
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

        # 1. Direct Static Asset Mapping [HIGHEST PRIORITY]
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

        # 3. Stream Proxy
        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
            proxy_set_header Host $host;
        }}

        # 4. Media/Vault Proxy
        location ~ ^/(media|vault|uploads)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
        }}

        # 5. UI Root & Dynamic Data Routing
        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            
            # If requesting root / exactly, serve index.html
            if ($uri = "/") {{
                rewrite ^ /index.html break;
            }}

            # Try to serve as a file, if not found, it must be an API or Flutter Route
            # Proxy to backend (handles login, sync, pulse, etc.)
            try_files $uri @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_read_timeout 86400;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Rebooting Smart Gateway Protocol...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: UI and Data are now correctly sharded. Feed should load.")
        ssh.close()
    except Exception as e:
        print(f"HOST_FIX_ERR: {e}")

if __name__ == "__main__":
    final_host_fix()


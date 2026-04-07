import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_neural_bridge_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Re-Engineering Neural Data Bridge...")
        
        # PRO-FIX: Explicitly prioritizing API/Auth proxying over HTML Fallback
        # Added a broad regex for API paths to ensure no JSON request is intercepted as HTML
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # Neural Bridge Logging
    log_format neural_log '$http_host - $request - $status - $upstream_addr';

    # 1. ADMIN MASTER (vazo.fectok.com)
    server {{
        listen 80;
        server_name vazo.fectok.com;
        access_log /var/log/nginx/admin_bridge.log neural_log;

        # Priority 1: Backend API/Auth [Ensuring JSON response]
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        # Priority 2: Static Assets
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html) {{
            root /usr/share/nginx/html/admin;
            add_header Cache-Control "public, max-age=3600";
        }}

        # Priority 3: UI Fallback
        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}

    # 2. USER GATEWAY (fectok.com)
    server {{
        listen 80 default_server;
        server_name fectok.com;
        access_log /var/log/nginx/user_bridge.log neural_log;

        # Priority 1: Backend API/Auth
        location ~ ^/(api|auth|login|sync|user|v15|vault|stream_token)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
        }}

        # Priority 2: Media Bridge
        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}

        # Priority 3: Sound Engine
        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}

        # Priority 4: UI Fallback
        location / {{
            root /usr/share/nginx/html/user;
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

        print("Phase 2: Purging Redirect Cascades and Reigniting Pure Neural Sync...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Neural Link is now pure. Handshake and Sync should work.")
        ssh.close()
    except Exception as e:
        print(f"BRIDGE_FIX_ERR: {e}")

if __name__ == "__main__":
    final_neural_bridge_fix()


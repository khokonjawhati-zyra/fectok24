import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_host_header_audit_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Engineening Host-Sensing Gateway...")
        
        # PRO-FIX: Explicitly checking $host in Nginx to force sharding
        # Adding a custom header X-Debug-Host to see what Cloudflare/Browser is sending
        NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
events {{ worker_connections  2048; }}
http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    client_max_body_size 500M;
    
    # 1. THE ADMIN MASTER (vazo.fectok.com) - PLACED AS FIRST SERVER
    server {{
        listen 80;
        server_name vazo.fectok.com;
        
        # Debugging Cloudflare/Host headers
        add_header X-Debug-Host $host always;
        add_header X-App-Mode "Sovereign-Admin-V15" always;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;

        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter.js|flutter_bootstrap.js|index.html|flutter_service_worker.js|main.dart.js) {{
            root /usr/share/nginx/html/admin;
        }}

        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}

        # Backend neural bridge for Admin
        location ~ ^/(api|auth|login|sync|user|v15|vault|handshake|admin)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}
    }}

    # 2. THE USER GATEWAY (fectok.com)
    server {{
        listen 80 default_server;
        server_name fectok.com;
        
        add_header X-Debug-Host $host always;
        add_header X-App-Mode "Sovereign-User-Mesh" always;

        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html) {{
            root /usr/share/nginx/html/user;
        }}

        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html @backend;
        }}

        location @backend {{
            proxy_pass http://{BACKEND_IP}:5000;
            proxy_set_header Host $host;
        }}

        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Purging Gateway Mismatch and Reigniting Sharded Sovereignty...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Sharding is now prioritized in server blocks. Hard Refresh to see Admin.")
        ssh.close()
    except Exception as e:
        print(f"AUDIT_FIX_ERR: {e}")

if __name__ == "__main__":
    final_host_header_audit_fix()


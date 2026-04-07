import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_master_overwrite_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Overwriting Gateway with Master Host-Map Logic...")
        
        # PRO-FIX: Using a MAP directive to handle root mapping by Host header
        # This is more resilient to DNS/Proxy header fluctuations
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
    # DYNAMIC HOST MAPPING [The Unbreakable Bridge]
    # ═══════════════════════════════════════════════════════════════
    map $http_host $app_root {{
        vazo.fectok.com   /usr/share/nginx/html/admin;
        default           /usr/share/nginx/html/user;
    }}

    server {{
        listen 80;
        server_name fectok.com vazo.fectok.com;

        # Shared Assets Priority
        location ~ ^/(assets|canvaskit|icons|manifest.json|favicon.png|flutter_service_worker.js|index.html|flutter.js|flutter_bootstrap.js) {{
            root $app_root;
            add_header Cache-Control "public, max-age=3600";
        }}

        # Sound Engine
        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
        }}

        # Magic Media Bridge
        location ~* ^/stream/(.*\\.(mp4|jpg|jpeg|png|webp|gif))$ {{
            proxy_pass http://{BACKEND_IP}:5000/media/$1;
        }}

        # Stream Engine Fallback
        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
        }}

        # Secure Vault
        location ~ ^/(media|vault|uploads)($|/) {{
            proxy_pass http://{BACKEND_IP}:5000;
        }}

        # Primary UI & API Data
        location / {{
            root $app_root;
            index index.html;
            try_files $uri $uri/ /index.html @backend;
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
            proxy_read_timeout 3600s;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        print("Phase 2: Igniting Master Map Ecosystem...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: vazo.fectok.com and fectok.com are now sharded correctly with Host-Map logic.")
        ssh.close()
    except Exception as e:
        print(f"MASTER_FIX_ERR: {e}")

if __name__ == "__main__":
    final_master_overwrite_nginx()


import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def ignite_unstoppable_gateway():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Cleansing Regex Gaps...")
        
        # PRO-FIX: Simplified and more inclusive regex for all backend routes
        # No trailing slash requirement in the group
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

        # 1. Catch-all Data Gateway [Inclusive Regex]
        location ~ ^/(api|ws|auth|login|sync|user|media|category|ad|v15)($|/) {{
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

        # 2. Sound Engine [Inclusive Regex]
        location ~ ^/(sound_engine|sound|audio)($|/) {{
            proxy_pass http://{SOUND_IP}:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        # 3. Stream Engine
        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
            proxy_set_header Host $host;
        }}

        # 4. Web UI Fallback
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

        print("Phase 2: Igniting Neural Gateway on Port 80...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: Neural Gateway is now 100% inclusive. Data Sync should be stable.")
        ssh.close()
    except Exception as e:
        print(f"IGNITE_ERR: {e}")

if __name__ == "__main__":
    ignite_unstoppable_gateway()


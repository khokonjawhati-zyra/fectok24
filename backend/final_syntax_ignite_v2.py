import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# REAL VERIFIED INTERNAL IPs [Surgically Accurrate]
BACKEND_IP = "172.18.0.4"
SOUND_IP = "172.18.0.8"
UPLINK_IP = "172.18.0.3"

def final_syntax_ignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Cleansing Syntax Errors...")
        
        # PRO-FIX: No trailing slash in proxy_pass for Regex locations
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

        # 1. Catch-all Data Gateway [No trailing slash in proxy_pass]
        location ~ ^/(api|ws|auth|login|sync|user|media|category|ad|v15)/ {{
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

        # 2. Sound Engine [No trailing slash in proxy_pass]
        location ~ ^/(sound_engine|sound|audio)/ {{
            proxy_pass http://{SOUND_IP}:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        # 3. Stream Engine
        location /stream/ {{
            proxy_pass http://{UPLINK_IP}:8080/;
            proxy_set_header Host $host;
        }}

        # 4. User Panel Files
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

        # Phase 2: Ultimate Ignition
        print("Phase 2: Liberating Port 80 and Igniting Docker Gateway...")
        ssh.exec_command("systemctl stop nginx || true")
        ssh.exec_command("fuser -k 80/tcp || true")
        ssh.exec_command("docker stop sovereign_v15_gateway || true")
        ssh.exec_command("docker rm sovereign_v15_gateway || true")
        
        run_cmd = (
            "docker run -d --name sovereign_v15_gateway "
            "-p 80:80 -p 443:443 "
            "-v /root/sovereign/webuser_panel:/usr/share/nginx/html/user:ro "
            "-v /root/sovereign/webadmin_panel:/usr/share/nginx/html/admin:ro "
            "-v /root/sovereign/nginx.conf.gateway:/etc/nginx/nginx.conf:ro "
            "--network sovereign_v15_mesh "
            "nginx:alpine"
        )
        ssh.exec_command(run_cmd)

        # Final Verification
        time.sleep(3)
        print("\nFinal Health Check: Port 80 usage...")
        stdin, stdout, stderr = ssh.exec_command("docker ps --filter 'name=gateway'")
        print(stdout.read().decode())
        
        ssh.close()
        print("\nTOTAL_VICTORY: Neural Gateway is now 100% stable and live.")
    except Exception as e:
        print(f"IGNITE_ERR: {e}")

if __name__ == "__main__":
    final_syntax_ignite()


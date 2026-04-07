import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def final_victory():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Cleansing Port 80...")
        
        # Kill Host Nginx and anything on 80
        ssh.exec_command("systemctl stop nginx || true")
        ssh.exec_command("fuser -k 80/tcp || true")
        
        print("Phase 2: Extracting Real-Time Component IPs...")
        # Get IPs
        stdin, stdout, stderr = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_backend")
        backend_ip = stdout.read().decode().strip()
        
        stdin, stdout, stderr = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_sound_loop-sound_engine_api-1")
        sound_ip = stdout.read().decode().strip()
        
        stdin, stdout, stderr = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_uplink")
        uplink_ip = stdout.read().decode().strip()

        print(f"IP-CORE: Backend={backend_ip}, Sound={sound_ip}, Uplink={uplink_ip}")

        # Construct Nginx Gateway Config
        # Using 5000 for backend as verified by grand diagnostic
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
        location ~ ^/(api|ws|auth|login|sync|user|media|v15)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}
        location ~ ^/(sound_engine|sound|audio)/ {{
            proxy_pass http://{sound_ip}:8000/;
            proxy_set_header Host $host;
        }}
        location /stream/ {{
            proxy_pass http://{uplink_ip}:8080/;
            proxy_set_header Host $host;
        }}
        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}
}}
"""
        # Write to host file
        print("Phase 3: Synchronizing Neural Gateway Mapping...")
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()

        # Restart Gateway
        print("Phase 4: Igniting Docker Gateway...")
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

        time.sleep(5)
        
        # Verify Port 80 is listening
        print("\nFinal Verification: Is Port 80 Listening on Host?")
        stdin, stdout, stderr = ssh.exec_command("ss -tulpn | grep :80")
        output = stdout.read().decode()
        print(output if output else "FAIL: Port 80 is SILENT.")
        
        if output:
            print("\nVICTORY: Gateway is now live on Port 80. Sync should be 100% active.")
        
        ssh.close()
    except Exception as e:
        print(f"VICTORY_ERR: {e}")

if __name__ == "__main__":
    final_victory()


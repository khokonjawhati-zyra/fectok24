import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def digital_wall_ignite_p31():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. HARD-CODING PORT 81 INTO DOCKER COMPOSE ---")
    # Surgically adding "81:81" to the ports list of sovereign_v15_gateway
    # We find the line "80:80" and add "81:81" right below it
    ssh.exec_command("sed -i '/80:80/a \      - \"81:81\"' /root/sovereign_v15/docker-compose.yml")
    
    print("\n--- 3. NUCLEAR STACK REBIRTH (Applying Port 81) ---")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose down && docker compose up -d")
    # Wait for containers to breathe
    import time
    time.sleep(5)

    print("\n--- 4. INJECTING DUAL-PORT STERILE NGINX ---")
    # Explicit Port 80 (User) and Port 81 (Admin) separation
    nginx_sterile = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    
    # Port 80: The TikTok User Face
    server {
        listen 80 default_server;
        server_name _;
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
    }

    # Port 81: The Sovereign Admin Command Center
    server {
        listen 81 default_server;
        server_name _;
        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        
        # Admin Proxy Neural Link
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
"""
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_sterile}\nEOF\""
    ssh.exec_command(cmd)

    print("\n--- 5. FINAL MISSION REBIRTH ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    # Ensure Port 81 is open in UFW
    ssh.exec_command("ufw allow 81/tcp")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ADMIN IS NOW OPERATIONAL AT PORT 81 ---")

if __name__ == "__main__":
    digital_wall_ignite_p31()


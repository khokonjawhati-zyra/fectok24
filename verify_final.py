import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def manual_path_reconstruction():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. SURGICAL DOCKER-COMPOSE REBUILD ---")
    # Using hardcoded relative paths for reliability
    compose_v15 = """
version: '3.8'
services:
  sovereign_v15_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
    volumes:
      - /root/sovereign_v15/webuser_panel:/usr/share/nginx/html/user_face:ro
      - /root/sovereign_v15/webadmin_panel:/usr/share/nginx/html/admin_vault:ro
      - /root/sovereign_v15/nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose.yml << 'EOF'\n{compose_v15}\nEOF")

    print("\n--- 3. SURGICAL NGINX LOGIC (Dual Path Isolated) ---")
    nginx_v15 = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80;
        server_name _;
        
        # User UI
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Admin UI (Isolated)
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # API Link to Backend
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_v15}\nEOF")

    print("\n--- 4. FINAL NUCLEAR IGNITION ---")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION STATUS: PATHS ARE RECONSTRUCTED AND LIVE ---")

if __name__ == "__main__":
    manual_path_reconstruction()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sovereign_final_resurrection_v2():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. EMERGENCY GATEWAY RESTORATION ---")
    # Nuking possibly corrupted nginx.conf and docker-compose.yml on server
    ssh.exec_command("rm -f /root/sovereign_v15/nginx.conf /root/sovereign_v15/docker-compose.yml")

    print("\n--- 3. INJECTING GUARANTEED DOCKER-COMPOSE ---")
    # Minimalist compose on Port 80
    compose_simple = """
version: '3.8'
services:
  sovereign_v15_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
    volumes:
      - ./webuser_panel:/usr/share/nginx/html/user_face:ro
      - ./webadmin_panel:/usr/share/nginx/html/admin_vault:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose.yml << 'EOF'\n{compose_simple}\nEOF")

    print("\n--- 4. INJECTING GUARANTEED NGINX (Dual Path) ---")
    # Standard Nginx for separated User (root) and Admin (/admin/)
    nginx_pure = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80;
        server_name _;
        
        # User Panel (The Public Face)
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Admin Panel (The Internal Vault)
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # API Shield to Backend Port 5000
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
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_pure}\nEOF")

    print("\n--- 5. FINAL MISSION IGNITION ---")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION STATUS: SOVEREIGN IS LIVE ---")

if __name__ == "__main__":
    sovereign_final_resurrection_v2()


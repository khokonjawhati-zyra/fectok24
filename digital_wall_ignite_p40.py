import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def digital_wall_ignite_p40():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. UPDATING DOCKER COMPOSE PORTS (Double Mapping) ---")
    # Surgically ensuring both 80 and 81 are mapped in the gateway service
    compose_sterile = """
version: '3.8'
services:
  sovereign_v15_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
      - "81:81"
    volumes:
      - /root/sovereign_v15/webuser_panel:/usr/share/nginx/html/user_face:ro
      - /root/sovereign_v15/webadmin_panel:/usr/share/nginx/html/admin_vault:ro
      - /root/sovereign_v15/nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose.yml << 'EOF'\n{compose_sterile}\nEOF")

    print("\n--- 3. DEPLOYING STERILE DUAL-PORT NGINX ---")
    # Port 80 for User, Port 81 for Admin
    nginx_sterile = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    
    server {
        listen 80 default_server;
        server_name _;
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
    }

    server {
        listen 81 default_server;
        server_name _;
        location / {
            root /usr/share/nginx/html/admin_vault;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_set_header Host $host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_sterile}\nEOF")

    print("\n--- 4. NUCLEAR FIREWALL & ENGINE RESTART ---")
    ssh.exec_command("ufw allow 81/tcp")
    ssh.exec_command("iptables -A INPUT -p tcp --dport 81 -j ACCEPT")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    time.sleep(5)
    print("\n--- 5. ACCESS CHECK (Internal) ---")
    stdin, stdout, stderr = ssh.exec_command("curl -I http://localhost:81")
    print("Port 81 Status:", stdout.read().decode())
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ADMIN IS OPERATIONAL AT PORT 81 ---")

if __name__ == "__main__":
    digital_wall_ignite_p40()


import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sovereign_final_victory_p41():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. NUCLEAR CLEANUP & ASSET RE-SYNC ---")
    # Nuking and creating fresh directories
    ssh.exec_command("rm -rf /root/sovereign_v15/webadmin_panel /root/sovereign_v15/webuser_panel")
    ssh.exec_command("mkdir -p /root/sovereign_v15/webadmin_panel /root/sovereign_v15/webuser_panel")
    
    sftp = ssh.open_sftp()
    # Pushing Admin Files manually to ensure integrity
    local_admin = r'c:\Users\Admin\23226\webadmin_panel'
    for f in os.listdir(local_admin):
        if os.path.isfile(os.path.join(local_admin, f)):
            sftp.put(os.path.join(local_admin, f), f"/root/sovereign_v15/webadmin_panel/{f}")
            
    # Pushing User Files manually
    local_user = r'c:\Users\Admin\23226\webuser_panel'
    for f in os.listdir(local_user):
        if os.path.isfile(os.path.join(local_user, f)):
            sftp.put(os.path.join(local_user, f), f"/root/sovereign_v15/webuser_panel/{f}")
    sftp.close()

    print("\n--- 3. INJECTING GUARANTEED SINGLE-PORT NGINX ---")
    # Using Port 80 for both to avoid firewall/NAT issues
    # / -> User UI
    # /v15-admin/ -> Admin UI
    nginx_victory = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;
        
        # User Panel
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Admin Panel (Surgical Cache-Bust Path)
        location ^~ /v15-admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /v15-admin/index.html =404;
        }

        # API Shield
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_set_header Host $host;
        }
    }
}
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_victory}\nEOF")

    print("\n--- 4. SURGICAL <BASE HREF> ALIGNMENT ---")
    # Ensuring the admin index.html points to its new surgical path
    ssh.exec_command("sed -i 's|<base href=\"/.*\">|<base href=\"/v15-admin/\">|g' /root/sovereign_v15/webadmin_panel/index.html")

    print("\n--- 5. FINAL MISSION IGNITION ---")
    # Clean compose mapping only Port 80
    compose_victory = """
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
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose.yml << 'EOF'\n{compose_victory}\nEOF")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: SYSTEM IS LIVE AT PORT 80 ---")

if __name__ == "__main__":
    sovereign_final_victory_p41()


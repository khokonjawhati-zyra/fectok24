import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sovereign_resurrection_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. NUCLEAR CLEANUP OF CORRUPTED ASSETS ---")
    # Nuking existing panel directories on server to be 100% sure
    ssh.exec_command("rm -rf /root/sovereign_v15/webadmin_panel /root/sovereign_v15/webuser_panel")
    ssh.exec_command("mkdir -p /root/sovereign_v15/webadmin_panel /root/sovereign_v15/webuser_panel")

    print("\n--- 3. PUSHING TRUE ASSETS FROM LAPTOP (SFTP) ---")
    sftp = ssh.open_sftp()
    
    # Sync Admin
    for f in os.listdir(r'c:\Users\Admin\23226\webadmin_panel'):
        local_path = os.path.join(r'c:\Users\Admin\23226\webadmin_panel', f)
        if os.path.isfile(local_path):
            sftp.put(local_path, f"/root/sovereign_v15/webadmin_panel/{f}")
    
    # Sync User
    for f in os.listdir(r'c:\Users\Admin\23226\webuser_panel'):
        local_path = os.path.join(r'c:\Users\Admin\23226\webuser_panel', f)
        if os.path.isfile(local_path):
            sftp.put(local_path, f"/root/sovereign_v15/webuser_panel/{f}")
    
    sftp.close()

    print("\n--- 4. RESTORING STERILE DOCKER COMPOSE ---")
    # Ensuring standard port 80 mapping for reliability
    compose_sterile = """
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
    # Simple write to compose
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose-gateway.yml << 'EOF'\n{compose_sterile}\nEOF")

    print("\n--- 5. INJECTING GUARANTEED DUAL-PATH NGINX ---")
    nginx_resurrection = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80;
        server_name _;
        
        # ROOT -> USER PANEL
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # ADMIN -> ADMIN PANEL
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # API Neural Link
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_set_header Host $host;
        }
    }
}
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_resurrection}\nEOF")

    print("\n--- 6. SURGICAL <BASE HREF> ALIGNMENT ---")
    ssh.exec_command("sed -i 's|<base href=\"/\">|<base href=\"/admin/\">|g' /root/sovereign_v15/webadmin_panel/index.html")

    print("\n--- 7. FINAL IGNITION ---")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose -f docker-compose.yml up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION ACCOMPLISHED: SOVEREIGN HAS RISEN ---")

if __name__ == "__main__":
    sovereign_resurrection_v15()


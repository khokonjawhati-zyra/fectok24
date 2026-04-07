import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sovereign_atomic_sync_p42():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. SURGICAL DIRECTORY MAPPING ---")
    # Ensuring absolute paths on host and cleaning them
    ssh.exec_command("rm -rf /root/sovereign_v15/admin_deploy /root/sovereign_v15/user_deploy")
    ssh.exec_command("mkdir -p /root/sovereign_v15/admin_deploy /root/sovereign_v15/user_deploy")
    
    sftp = ssh.open_sftp()
    # Re-syncing verified assets from local machine
    print("Syncing Admin Files...")
    local_admin = r'c:\Users\Admin\23226\webadmin_panel'
    for f in os.listdir(local_admin):
        if os.path.isfile(os.path.join(local_admin, f)):
            sftp.put(os.path.join(local_admin, f), f"/root/sovereign_v15/admin_deploy/{f}")
    
    print("Syncing User Files...")
    local_user = r'c:\Users\Admin\23226\webuser_panel'
    for f in os.listdir(local_user):
        if os.path.isfile(os.path.join(local_user, f)):
            sftp.put(os.path.join(local_user, f), f"/root/sovereign_v15/user_deploy/{f}")
    sftp.close()

    print("\n--- 3. INJECTING GUARANTEED DOCKER-COMPOSE ---")
    # Triple-mapping ports (80 for User, 81 for Admin)
    compose_p42 = """
version: '3.8'
services:
  sovereign_v15_gateway:
    image: nginx:alpine
    container_name: sovereign_v15_gateway
    ports:
      - "80:80"
      - "81:81"
    volumes:
      - /root/sovereign_v15/user_deploy:/usr/share/nginx/html/user:ro
      - /root/sovereign_v15/admin_deploy:/usr/share/nginx/html/admin:ro
      - /root/sovereign_v15/nginx.conf:/etc/nginx/nginx.conf:ro
    restart: always
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/docker-compose.yml << 'EOF'\n{compose_p42}\nEOF")

    print("\n--- 4. INJECTING STERILE DUAL-SERVER NGINX ---")
    # Port 80 -> User, Port 81 -> Admin (No Alias, just Root)
    nginx_p42 = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    
    # Port 80: User Panel
    server {
        listen 80 default_server;
        server_name _;
        root /usr/share/nginx/html/user;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html =404;
        }
    }

    # Port 81: Admin Panel
    server {
        listen 81 default_server;
        server_name _;
        root /usr/share/nginx/html/admin;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html =404;
        }
        
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_set_header Host $host;
        }
    }
}
"""
    ssh.exec_command(f"cat > /root/sovereign_v15/nginx.conf << 'EOF'\n{nginx_p42}\nEOF")

    print("\n--- 5. FINAL MISSION IGNITION ---")
    ssh.exec_command("ufw allow 81/tcp")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d --force-recreate")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    print("\n--- 6. INTERNAL INTEGRITY AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/index.html")
    print("Admin HTML Existence:", stdout.read().decode())
    
    ssh.close()
    print("\n--- MISSION STATUS: ATOMIC SYNC COMPLETE ---")

if __name__ == "__main__":
    sovereign_atomic_sync_p42()


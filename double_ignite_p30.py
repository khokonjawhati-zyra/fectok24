import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def double_ignite_p30():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. OPENING PORT 81 VAULT (Firewall & Compose) ---")
    # Opening 81 in UFW just in case
    ssh.exec_command("ufw allow 81/tcp")
    # Ensuring 81 is mapped in docker-compose.yml
    ssh.exec_command("sed -i '/80:80/a \      - 81:81' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d")

    print("\n--- 3. RE-INJECTING CLEAN ADMIN ASSETS ---")
    # Nuking and re-copying verified admin assets
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/admin_vault/*")
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin_vault/")
    # Fixing base href ONLY for port 81 (root is enough there)
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's|<base href=\"/admin/\">|<base href=\"/\">|g' /usr/share/nginx/html/admin_vault/index.html")

    print("\n--- 4. INJECTING DUAL-PORT NGINX CONFIG ---")
    # Multi-server block: Port 80 for User, Port 81 for Admin
    nginx_dual = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    
    # Port 80: USER FACE
    server {
        listen 80;
        server_name _;
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
    }

    # Port 81: ADMIN COMMAND CENTER
    server {
        listen 81 default_server;
        server_name _;
        location / {
            root /usr/share/nginx/html/admin_vault;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        
        # PROXY FOR ADMIN AUTH
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
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_dual}\nEOF\""
    ssh.exec_command(cmd)

    print("\n--- 5. FINAL REBIRTH & LOCK ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ADMIN IS NOW AT PORT 81 (NO COLLISION) ---")

if __name__ == "__main__":
    double_ignite_p30()


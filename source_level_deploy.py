import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def source_level_deployment():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. CLEANING GHOST ASSETS FROM GATEWAY ---")
    # Nuking all existing html files to prevent asset mixing
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/*")
    ssh.exec_command("docker exec sovereign_v15_gateway mkdir -p /usr/share/nginx/html/admin /usr/share/nginx/html/user")
    
    print("\n--- 3. SURGICAL FILE INJECTION (Separating Admin vs User) ---")
    # Injecting Admin Panel to /admin/
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin/")
    # Injecting User Panel to /user/ (which serves the root)
    ssh.exec_command("docker cp /root/sovereign_v15/webuser_panel/. sovereign_v15_gateway:/usr/share/nginx/html/user/")

    print("\n--- 4. NGINX ROUTING STERILIZATION (Strict Matching) ---")
    # Using 'alias' for admin to ensure local file resolution is precise
    nginx_stereo = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;

        # ROOT -> USER PANEL
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # /admin -> ADMIN PANEL
        location /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # API & WS PROXY
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
    ssh.exec_command(f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_stereo}\nEOF\"")

    print("\n--- 5. FINAL MISSION REBIRTH (Hard Restart) ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ADMIN AND USER PANELS ARE SURGICALLY DEPLOYED ---")

if __name__ == "__main__":
    source_level_deployment()


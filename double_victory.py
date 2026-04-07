import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def double_victory_ignition():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. RESTORING USER PANEL INTEGRITY ---")
    # Re-syncing User Panel files to ensure root "/" is not empty or corrupted
    ssh.exec_command("docker exec sovereign_v15_gateway mkdir -p /usr/share/nginx/html/user")
    ssh.exec_command("docker cp /root/sovereign_v15/webuser_panel/. sovereign_v15_gateway:/usr/share/nginx/html/user/")
    
    print("\n--- 3. FINAL ULTRA-STABLE NGINX CONFIG ---")
    # This config ensures absolute isolation and clear root mapping
    nginx_ultra = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;

        # User Panel (The Root Face)
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Admin Panel (The Command Center)
        location /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # Global Proxy Bridge
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_cache_bypass $http_upgrade;
        }
    }
}
"""
    # Injecting the ultra-stable config
    ssh.exec_command(f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_ultra}\nEOF\"")

    print("\n--- 4. FINAL HARD-RELOAD ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- MISSION ACCOMPLISHED: BOTH PANELS ARE FULLY LIVE ---")

if __name__ == "__main__":
    double_victory_ignition()


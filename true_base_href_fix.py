import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def true_base_href_fix_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # Surgical Fix of Base Href inside the Container
    print("--- 2. SURGICAL <BASE HREF> ALIGNMENT P28 ---")
    # Setting base href to /admin/ to ensure assets load from the correct directory
    # We target specifically the admin_vault/index.html
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's|<base href=\"/\">|<base href=\"/admin/\">|g' /usr/share/nginx/html/admin_vault/index.html")
    
    print("--- 3. RE-SYNCING NGINX FOR ASSET ISOLATION ---")
    # Ensuring Nginx config is ultra-stable for sub-path assets
    nginx_stable = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;

        # ROOT -> USER PANEL
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # ADMIN PANEL (The Internal Vault)
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # PROXY BRIDGE
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
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_stable}\nEOF\""
    ssh.exec_command(cmd)

    print("--- 4. HARD-RELOAD GATEWAY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("--- MISSION COMPLETE: ADMIN ASSETS ARE NOW RELATIVELY PATHED ---")

if __name__ == "__main__":
    true_base_href_fix_v15()


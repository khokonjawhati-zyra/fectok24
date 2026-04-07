import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def functional_admin_deploy():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. RESTORING FULL ADMIN PROXY GATEWAYS ---")
    # This config ensures both static files AND backend logic (Auth/Mesh) work for the Admin Panel
    nginx_functional = """
    server {
        listen 80 default_server;
        server_name _;

        # Admin Panel Static Assets
        location /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # User Panel Static Face
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Global API & Neural Handshake Proxy
        location ~* ^/(api|ws|admin_auth_init|admin_auth_verify|login|register|reset_pulse|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
    """
    # Injecting the full functional config
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\nevents {{ worker_connections 1024; }} http {{ {nginx_functional} }}\nEOF\""
    ssh.exec_command(cmd)

    print("\n--- 3. RESTARTING FOR FUNCTIONAL MESH ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ADMIN PANEL IS FULLY FUNCTIONAL ---")

if __name__ == "__main__":
    functional_admin_deploy()


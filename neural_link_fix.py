import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def neural_link_fix_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. SURGICAL <BASE HREF> ALIGNMENT FOR ADMIN ---")
    # Setting base href to /admin/ to ensure JS assets load correctly
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's|<base href=\"/\">|<base href=\"/admin/\">|g' /usr/share/nginx/html/admin/index.html")
    
    print("--- 3. INJECTING ROBUST NEURAL PROXY CONFIG ---")
    nginx_neural = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    server {
        listen 80 default_server;
        server_name _;

        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        location /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # NEURAL LINK PROXY (Catching all backend traffic)
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream|vazo) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_read_timeout 86400;
        }
    }
}
"""
    # Escaping for shell injection
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_neural}\nEOF\""
    ssh.exec_command(cmd)

    print("--- 4. HARD-RELOAD GATEWAY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("--- MISSION COMPLETE: NEURAL LINK IS ESTABLISHED ---")

if __name__ == "__main__":
    neural_link_fix_v15()


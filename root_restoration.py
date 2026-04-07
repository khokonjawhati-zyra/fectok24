import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def root_access_restoration():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. VERIFYING FILE EXISTENCE (The Root Audit) ---")
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls -la /usr/share/nginx/html/user/index.html")
    print("User Index Check:", stdout.read().decode())
    
    print("\n--- 3. FIXING NGINX ROOT MAPPING (Redundant Root Fix) ---")
    # Sometimes 'root' inside a location block can be tricky with base href. 
    # Moving root to the server level for default handling.
    nginx_root_fix = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;
        
        root /usr/share/nginx/html/user;
        index index.html;

        # ADMIN PANEL (Priority Alias)
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # ROOT -> USER PANEL (Catch-all)
        location / {
            try_files $uri $uri/ /index.html =404;
        }

        # PROXY GATEWAY
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
    ssh.exec_command(f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_root_fix}\nEOF\"")

    print("\n--- 4. FINAL HARD-RELOAD ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- MISSION COMPLETE: ROOT ACCESS IS RESTORED ---")

if __name__ == "__main__":
    root_access_restoration()


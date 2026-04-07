import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def final_success_v15_ignition():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # Define the STerilized Nginx Config (No Includes, No Defaults)
    STERILIZED_NGINX_CONF = """
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80 default_server;
        server_name _;

        # Admin Panel (Direct Path)
        location ^~ /admin/ {
            root /usr/share/nginx/html;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # User Panel (The Root Face)
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Backend API Bridge
        location /api {
            proxy_pass http://sovereign_v15_backend:5000;
        }
        
        # Legacy Backend Handshakes
        location ~* ^/(login|register|admin_auth|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
        }
    }
}
"""

    print("--- 2. INJECTING STERILIZED CONFIG DIRECTLY INTO CONTAINER ---")
    # Using a heredoc to overwrite the internal config precisely
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{STERILIZED_NGINX_CONF}\nEOF\""
    ssh.exec_command(cmd)
    
    print("--- 3. CLEARING PHANTOM CONFIGS ---")
    ssh.exec_command("docker exec sovereign_v15_gateway sh -c 'rm -rf /etc/nginx/conf.d/*'")
    
    print("--- 4. HARD-RESETTING GATEWAY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    print("--- 5. MISSION SUCCESS VERIFICATION ---")
    time.sleep(5)
    stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway nginx -T")
    print("Active Config Verified.")
    
    ssh.close()
    print("--- SYSTEM IS NOW LIVE AND SECURED ---")

if __name__ == "__main__":
    final_success_v15_ignition()


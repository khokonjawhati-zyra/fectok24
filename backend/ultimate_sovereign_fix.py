import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_sovereign_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- 1. MASTER PORT LIBERATION ---")
    # Force kill anything on 80 and 443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('systemctl stop nginx')
    ssh.exec_command('ufw allow 80/tcp')
    ssh.exec_command('ufw allow 443/tcp')
    
    print("--- 2. MASTER NGINX DNA REPAIR ---")
    # Writing a robust, error-proof nginx config
    NGINX_CONF = """
user  nginx;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        
        # User UI
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # Auth & OTP Bridges
        location ~ ^/(login|register|reset_password|forgot_password|recover_pulse|verify_token|admin_auth_init|admin_auth_verify|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;

        # Admin UI
        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # Admin API & Auth Bridges
        location ~ ^/(admin_auth_init|admin_auth_verify|verify_token|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    print("--- 3. TOTAL ECOSYSTEM RE-IGNITION ---")
    # Wipe and recreate to ensure volume binding is fresh
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    
    import time
    time.sleep(10) # Wait for startup
    
    print("--- 4. PULSE VERIFICATION ---")
    _, out, _ = ssh.exec_command('docker ps --filter "name=sovereign_v15_gateway" --format "{{.Status}}"')
    status = out.read().decode().strip()
    print(f"GATEWAY STATUS: {status if status else 'FAILED'}")
    
    if not status:
        _, err, _ = ssh.exec_command('docker logs sovereign_v15_gateway')
        print(f"ERROR LOGS:\n{err.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    ultimate_sovereign_fix()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def ultimate_gateway_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Gateway DNA ---")
    
    # 1. Master Nginx Configuration [PHASE 10: TOTAL SEPARATION]
    MASTER_CONF = """
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
        
        # API Routes (Bypass Static)
        location ~ ^/(login|register|reset_password|forgot_password|recover_pulse|verify_token|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # UI Static Files
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;

        # Admin API Routes
        location ~ ^/(admin_auth_init|admin_auth_verify|verify_token|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # Admin Static Files
        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(MASTER_CONF)
    sftp.close()
    
    # 2. Re-ignite the Mesh
    print("--- System Ignition in 3... 2... 1... ---")
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('cd /root/sovereign && docker-compose up -d --force-recreate stream_gateway')
    
    # 3. Final Pulse Check
    _, out, _ = ssh.exec_command('docker ps --filter "name=sovereign_v15_gateway" --format "{{.Status}}"')
    print(f"GATEWAY PULSE: {out.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    ultimate_gateway_ignition()


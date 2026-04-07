import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_sovereign_v15():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=15)
        print("Connected to Sovereign V15 Server.")
        
        # 1. Audit current ports
        print("Checking ports...")
        stdin, stdout, stderr = ssh.exec_command('netstat -tulpn | grep 5000')
        print(f"Port 5000: {stdout.read().decode()}")
        
        stdin, stdout, stderr = ssh.exec_command('netstat -tulpn | grep 8108')
        print(f"Port 8108: {stdout.read().decode()}")

        # 2. Deploy a UNIFIED Nginx Configuration
        # Fixing the 'vazo' block to point to 'admin' and ensuring all auth routes are proxied to the correct backend port (5000 in V15).
        NGINX_CONF = """
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    # --- USER PANEL (fectok.com) ---
    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        root /opt/sovereign/core/webuser_panel;
        index index.html;

        # Auth & API Tunnel
        location ~* ^/(login|register|forgot_password|reset_password|verify_otp|auth|api|ws) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }

    # --- ADMIN PANEL (vazo.fectok.com) ---
    server {
        listen 80;
        server_name vazo.fectok.com;
        root /opt/sovereign/core/webadmin_panel;
        index index.html;

        # Admin Auth & API Tunnel
        location ~* ^/(admin_auth_init|admin_auth|admin_auth_verify|verify_token|api/v15|ws/|reset_pulse|login) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }

    # --- BACKWARD COMPATIBILITY (Port 8108) ---
    server {
        listen 8108;
        server_name _;
        root /opt/sovereign/core/webadmin_panel;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
"""
        print("Uploading fixed Nginx config...")
        sftp = ssh.open_sftp()
        with sftp.file('/etc/nginx/active_nginx_v15.conf', 'w') as f:
             f.write(NGINX_CONF)
        
        # Apply the config
        print("Applying Nginx configuration...")
        ssh.exec_command('cp /etc/nginx/active_nginx_v15.conf /etc/nginx/nginx.conf')
        ssh.exec_command('systemctl restart nginx')
        
        print("Restarting Sovereign Backend...")
        ssh.exec_command('cd /root/sovereign && docker-compose restart backend_node')
        
        time.sleep(5)
        print("System Restoration Complete.")
        
        ssh.close()
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    fix_sovereign_v15()


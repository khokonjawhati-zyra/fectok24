import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# The Master Nginx Guardian Config
NGINX_CONF = """
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/log/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    # MIME FIX for WASM
    types {
        application/wasm wasm;
    }

    sendfile        on;
    keepalive_timeout  65;

    # SHARD 1: User Panel (fectok.com)
    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        location /api/ {
            proxy_pass http://172.18.0.4:5000/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /ws/ {
            proxy_pass http://172.18.0.4:5000/ws/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
        
        location ~ ^/(media|stream|payout|revenue|sponsor|impression)/ {
            proxy_pass http://172.18.0.4:5000;
            proxy_set_header Host $host;
        }
    }

    # SHARD 2: Master Admin Panel (vazo.fectok.com)
    server {
        listen 80;
        server_name vazo.fectok.com;

        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # IMPORTANT: Master Admin Needs API Access
        location /api/ {
            proxy_pass http://172.18.0.4:5000/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location /ws/ {
            proxy_pass http://172.18.0.4:5000/ws/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
        
        location ~ ^/(media|stream)/ {
            proxy_pass http://172.18.0.4:5000;
            proxy_set_header Host $host;
        }
    }
}
"""

def update_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    print("Restarting gateway...")
    ssh.exec_command('docker restart sovereign_v15_gateway')
    ssh.close()
    print("✅ DEPLOYMENT SUCCESSFUL: Subdomain Routing Fixed.")

if __name__ == "__main__":
    update_nginx()


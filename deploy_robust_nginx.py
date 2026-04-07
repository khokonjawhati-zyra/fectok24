import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def deploy_robust_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Define the robust Nginx configuration
    nginx_conf = """
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 500M;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml application/wasm;

    # Sovereign V15: WebSocket Connection Map
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    # Internal Backend Upstream
    upstream backend_node {
        server 127.0.0.1:5000;
        keepalive 32;
    }

    # Redirect HTTP to HTTPS (with Cloudflare SSL loop protection)
    server {
        listen 80;
        server_name fectok.com vazo.fectok.com;
        
        if ($http_x_forwarded_proto != "https") {
            # Redirect if not already HTTPS (Cloudflare flexible SSL sends x-forwarded-proto)
            # return 301 https://$host$request_uri;
        }
        
        # If Cloudflare is handled correctly, use the following:
        location / {
            return 301 https://$host$request_uri;
        }
    }

    # Main HTTPS Server: fectok.com (User Panel)
    server {
        listen 443 ssl http2;
        server_name fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        # 0 Latency Caching for static assets
        location ~* \\.(js|css|wasm|png|jpg|jpeg|gif|ico|svg|woff2)$ {
            root /opt/sovereign/core/webuser_panel;
            expires 30d;
            add_header Cache-Control "public, no-transform, immutable";
            access_log off;
        }

        # Proxy for API/WS/Auth
        location ~* ^/(api/v15|ws/|stream|media|login|register|resend_otp|auth) {
            proxy_pass http://backend_node;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeout optimizations
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
        }

        location / {
            root /opt/sovereign/core/webuser_panel;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }

    # Admin HTTPS Server: vazo.fectok.com
    server {
        listen 443 ssl http2;
        server_name vazo.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        # 0 Latency Caching
        location ~* \\.(js|css|wasm|png|jpg|jpeg|gif|ico|svg|woff2)$ {
            root /opt/sovereign/core/webadmin_panel;
            expires 30d;
            add_header Cache-Control "public, no-transform, immutable";
            access_log off;
        }

        location ~* ^/(api/v15|ws/|stream|media|login|register|resend_otp|auth) {
            proxy_pass http://backend_node;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            root /opt/sovereign/core/webadmin_panel;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
"""
    # Write to temp file on server
    sftp = ssh.open_sftp()
    with sftp.file('/tmp/nginx_v15_robust.conf', 'w') as f:
        f.write(nginx_conf)
    sftp.close()
    
    # Apply the config
    print("Applying robust Nginx configuration...")
    ssh.exec_command('cp /tmp/nginx_v15_robust.conf /etc/nginx/nginx.conf')
    stdin, stdout, stderr = ssh.exec_command('nginx -t')
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.exec_command('systemctl reload nginx')
    ssh.close()
    print("Nginx reloaded.")

if __name__ == "__main__":
    deploy_robust_nginx()


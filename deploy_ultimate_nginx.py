import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

NEW_NGINX_CONFIG = """
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 2048;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # Performance DNA
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    # Gzip Compression [0-Latency Accelerator]
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript application/wasm;

    map $http_x_forwarded_proto $fastapi_proto {
        default $http_x_forwarded_proto;
        ''      $scheme;
    }

    # Sovereign V15: User Panel (fectok.com)
    server {
        listen 80;
        server_name fectok.com www.fectok.com vazo.fectok.com;

        # Cloudflare Flexible SSL Fix: Only redirect if explicitly HTTP
        if ($http_x_forwarded_proto = "http") {
             return 301 https://$host$request_uri;
        }

        location / {
            root /opt/sovereign/core/webuser_panel;
            try_files $uri $uri/ /index.html;
        }
    }

    server {
        listen 443 ssl http2;
        server_name fectok.com www.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        # Optimization for Flutter Web
        root /opt/sovereign/core/webuser_panel;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
            expires 1h;
            add_header Cache-Control "public, no-transform";
        }

        # API & Pulse Gateway
        location ~* ^/(api/v15|ws/|stream|media|login|register|resend_otp|auth) {
            proxy_pass http://127.0.0.1:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $fastapi_proto;
            proxy_read_timeout 86400;
        }
        
        # Static Assets 0-Latency
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|wasm)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
            access_log off;
        }
    }

    # Sovereign V15: Admin Panel (vazo.fectok.com)
    server {
        listen 443 ssl http2;
        server_name vazo.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        root /opt/sovereign/core/webadmin_panel;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
            expires 1h;
        }

        # Admin Gateway [Ghost Protocol]
        location ~* ^/(admin_auth|api/v15|ws/|verify_token|reset_pulse|admin|resend_otp|login) {    
            proxy_pass http://127.0.0.1:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $fastapi_proto;
            proxy_read_timeout 86400;
        }
        
        # Static Assets 0-Latency
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|wasm)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
            access_log off;
        }
    }
}
"""

def deploy_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("Writing new Nginx config...")
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/nginx.conf', 'w') as f:
        f.write(NEW_NGINX_CONFIG.strip())
    sftp.close()
    
    print("Testing Nginx...")
    stdin, stdout, stderr = ssh.exec_command('nginx -t')
    out = stdout.read().decode() + stderr.read().decode()
    print(out)
    
    if "successful" in out:
        print("Reloading Nginx...")
        ssh.exec_command('systemctl restart nginx')
        print("System Online!")
    else:
        print("FAIL!")
        
    ssh.close()

if __name__ == "__main__":
    deploy_nginx()


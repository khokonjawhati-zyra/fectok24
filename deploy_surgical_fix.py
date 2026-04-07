import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

NEW_CONFIG = """
user www-data;
worker_processes auto;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    map $http_x_forwarded_proto $fastapi_proto {
        default $http_x_forwarded_proto;
        '' $scheme;
    }

    # Fixed Port 80 - Support Cloudflare Flexible SSL (Redirect only if not https)
    server {
        listen 80;
        server_name fectok.com www.fectok.com vazo.fectok.com;
        
        if ($http_x_forwarded_proto != "https") {
            return 301 https://$host$request_uri;
        }
        
        # If already SSL (proxied), serve directly
        location / {
             root /opt/sovereign/core/webuser_panel;
             try_files $uri $uri/ /index.html;
        }
        
        # Special case: vazo on port 80 (if proxied as https)
        location /admin/ {
             alias /opt/sovereign/core/webadmin_panel/;
             try_files $uri $uri/ /admin/index.html;
        }
    }

    # USER PANEL (SSL)
    server {
        listen 443 ssl http2;
        server_name fectok.com www.fectok.com;
        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        location ~* ^/(admin_auth_init|admin_auth|admin_auth_verify|verify_token|api/v15|ws/|reset_pulse|login|resend_otp|register|verify_registration|check_referral|all|stream) {
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
        
        location / {
             root /opt/sovereign/core/webuser_panel;
             try_files $uri $uri/ /index.html;
        }
        
        # Static Admin Path on main domain as backup
        location /admin/ {
             alias /opt/sovereign/core/webadmin_panel/;
             try_files $uri $uri/ /admin/index.html;
        }
    }

    # ADMIN PANEL (Dedicated Subdomain)
    server {
        listen 443 ssl http2;
        server_name vazo.fectok.com;
        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        location ~* ^/(admin_auth_init|admin_auth|admin_auth_verify|verify_token|api/v15|ws/|reset_pulse|login|resend_otp) {
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
        
        location / {
             root /opt/sovereign/core/webadmin_panel;
             try_files $uri $uri/ /index.html;
        }
    }
}
"""

def deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("Backing up...")
    ssh.exec_command('cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak_v2')
    
    print("Uploading new config...")
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/nginx.conf', 'w') as f:
        f.write(NEW_CONFIG.strip())
    sftp.close()
    
    print("Testing...")
    stdin, stdout, stderr = ssh.exec_command('nginx -t')
    out = stdout.read().decode() + stderr.read().decode()
    print(out)
    
    if "successful" in out:
        print("Reloading...")
        ssh.exec_command('systemctl reload nginx')
        print("Success.")
    else:
        print("Failed! Reverting...")
        ssh.exec_command('cp /etc/nginx/nginx.conf.bak_v2 /etc/nginx/nginx.conf')
        
    ssh.close()

if __name__ == "__main__":
    deploy()


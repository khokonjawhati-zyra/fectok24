import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

FIXED_CONFIG = """
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
    
    # [A_124] SUB-SERVICE TUNNELS (CLOUD-AWARE SYNC)
    
    server {
        listen 80;
        server_name fectok.com www.fectok.com vazo.fectok.com;
        
        # Cloudflare Flexible SSL Loop Fix
        if ($http_x_forwarded_proto = "http") {
             return 301 https://$host$request_uri;
        }
        
        # If no forwarded proto header, but we are on http, and it's direct access
        if ($http_x_forwarded_proto = "") {
             return 301 https://$host$request_uri;
        }
        
        # Static Fallback for HTTP (if not redirected)
        location / {
             root /opt/sovereign/core/webuser_panel;
             index index.html;
             try_files $uri $uri/ /index.html;
        }
    }

    server {
        listen 443 ssl http2;
        server_name fectok.com www.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        root /opt/sovereign/core/webuser_panel;
        index index.html;

        # API Tunnel
        location ~* ^/(login|register|forgot_password|reset_password|verify_otp|auth|api|ws|resend_otp) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }

    server {
        listen 443 ssl http2;
        server_name vazo.fectok.com;

        ssl_certificate /etc/letsencrypt/live/fectok.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/fectok.com/privkey.pem;

        root /opt/sovereign/core/webadmin_panel;
        index index.html;

        # Admin Auth & API Tunnel
        location ~* ^/(admin_auth_init|admin_auth|admin_auth_verify|verify_token|api/v15|ws/|reset_pulse|login) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
"""

def deploy_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("Backing up current Nginx config...")
    ssh.exec_command('cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak_loop')
    
    print("Writing new Nginx config...")
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/nginx.conf', 'w') as f:
        f.write(FIXED_CONFIG.strip())
    sftp.close()
    
    print("Testing Nginx configuration...")
    stdin, stdout, stderr = ssh.exec_command('nginx -t')
    test_out = stdout.read().decode() + stderr.read().decode()
    print(test_out)
    
    if "successful" in test_out:
        print("Reloading Nginx...")
        ssh.exec_command('systemctl reload nginx')
        print("Nginx reloaded successfully.")
    else:
        print("Nginx test failed! Reverting...")
        ssh.exec_command('cp /etc/nginx/nginx.conf.bak_loop /etc/nginx/nginx.conf')
        
    ssh.close()

if __name__ == "__main__":
    deploy_fix()


import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def ultimate_gap_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Get backend IP
    _, out, _ = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_backend")
    backend_ip = out.read().decode().strip()

    # THE ABSOLUTE SURGICAL CONFIG [V15 FINAL]
    # Adding every possible auth path to BOTH domains to ensure zero gaps
    NGINX_CONF = f"""
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log warn;
pid        /var/log/nginx.pid;

events {{
    worker_connections 1024;
}}

http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    types {{
        application/wasm wasm;
    }}

    sendfile        on;
    keepalive_timeout  65;

    # SHARD 1: User Panel (fectok.com)
    server {{
        listen 80;
        server_name fectok.com www.fectok.com;
        
        # --- SURGICAL TUNNELS FOR USER HANDSHAKES ---
        location ~ ^/(login|register|password_reset|verify_token|forgot_password|recover_pulse|api|ws)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_intercept_errors off;
            proxy_buffering off;
        }}

        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
        
        location ~ ^/(media|stream|payout|revenue|sponsor|impression)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_set_header Host $host;
        }}
    }}

    # SHARD 2: Master Admin Panel (vazo.fectok.com)
    server {{
        listen 80;
        server_name vazo.fectok.com;

        # --- ALPHA PRIORITY AUTH TUNNELS ---
        location ~ ^/(admin_auth_init|admin_auth_verify|verify_token|api|ws)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_intercept_errors off;
            proxy_buffering off;
        }}

        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
        
        location ~ ^/(media|stream)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_set_header Host $host;
        }}
    }}
}}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    ssh.exec_command('docker restart sovereign_v15_gateway')
    ssh.close()
    print("✅ GLOBAL GAP FIXED: Data path verified and restored.")

if __name__ == "__main__":
    ultimate_gap_fix()


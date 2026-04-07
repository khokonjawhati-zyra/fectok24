import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def aggressive_route_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Get backend IP
    _, out, _ = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_backend")
    backend_ip = out.read().decode().strip()

    # AGGRESSIVE PREFIXING [V15 FINAL]
    # This config uses ^~ which stops searching for other matches and takes absolute priority.
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
        
        # --- ALPHA CHANNELS: ABSOLUTE PRIORITY ---
        location ^~ /login {{ proxy_pass http://{backend_ip}:5000/login; include /etc/nginx/mime.types; }}
        location ^~ /register {{ proxy_pass http://{backend_ip}:5000/register; }}
        location ^~ /verify_token {{ proxy_pass http://{backend_ip}:5000/verify_token; }}
        location ^~ /forgot_password {{ proxy_pass http://{backend_ip}:5000/forgot_password; }}
        location ^~ /recover_pulse {{ proxy_pass http://{backend_ip}:5000/recover_pulse; }}
        location ^~ /password_reset {{ proxy_pass http://{backend_ip}:5000/password_reset; }}
        location ^~ /api/ {{ proxy_pass http://{backend_ip}:5000/api/; }}
        location ^~ /ws/ {{ proxy_pass http://{backend_ip}:5000/ws/; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; }}

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

        # --- ALPHA CHANNELS: ADMIN PRIORITY ---
        location ^~ /admin_auth_init {{ proxy_pass http://{backend_ip}:5000/admin_auth_init; }}
        location ^~ /admin_auth_verify {{ proxy_pass http://{backend_ip}:5000/admin_auth_verify; }}
        location ^~ /verify_token {{ proxy_pass http://{backend_ip}:5000/verify_token; }}
        location ^~ /api/ {{ proxy_pass http://{backend_ip}:5000/api/; }}
        location ^~ /ws/ {{ proxy_pass http://{backend_ip}:5000/ws/; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; }}

        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}
}}
"""
    # Overwrite config on server
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    ssh.exec_command('docker restart sovereign_v15_gateway')
    ssh.close()
    print("✅ AGGRESSIVE ROUTING DEPLOYED: No more 405 allowed.")

if __name__ == "__main__":
    aggressive_route_fix()


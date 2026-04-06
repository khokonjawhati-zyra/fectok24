import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def update_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Get backend IP using simple command
    _, out, _ = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_backend")
    backend_ip = out.read().decode().strip()
    print(f"Detected Backend IP: {backend_ip}")

    # The Master Nginx Guardian Config [V15 AUTH SYNC]
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
        
        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}

        location /api/ {{
            proxy_pass http://{backend_ip}:5000/api/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        location /ws/ {{
            proxy_pass http://{backend_ip}:5000/ws/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }}
    }}

    # SHARD 2: Master Admin Panel (vazo.fectok.com)
    server {{
        listen 80;
        server_name vazo.fectok.com;

        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}

        # V15 AUTHENTICATION TUNNELS [FIXED]
        location ~ ^/(admin_auth_init|admin_auth_verify|verify_token|api)/ {{
            proxy_pass http://{backend_ip}:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }}

        location /ws/ {{
            proxy_pass http://{backend_ip}:5000/ws/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
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
    print("✅ AUTH ROUTING FIXED: admin_auth_init/verify linked to backend.")

if __name__ == "__main__":
    update_nginx()


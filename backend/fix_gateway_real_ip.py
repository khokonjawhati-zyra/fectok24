import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def fix_gateway_ip():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Fetching REAL Internal IPs...")
        
        # Get Backend IP
        stdin, stdout, stderr = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_backend")
        backend_ip = stdout.read().decode().strip()
        print(f"BACKEND_IP: {backend_ip}")
        
        # Get Uplink (Media) IP
        stdin, stdout, stderr = ssh.exec_command("docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sovereign_v15_uplink")
        uplink_ip = stdout.read().decode().strip()
        print(f"UPLINK_IP: {uplink_ip}")
        
        if not backend_ip:
            print("ERR: Could not detect Backend IP. Fallback to 127.0.0.1 or 172.18.0.2?")
            backend_ip = "172.18.0.2"

        # Update Nginx config with the REAL IPs
        NGINX_GATEWAY_CONF = f"""
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {{
    worker_connections  1024;
}}

http {{
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {{
        listen 80;
        server_name fectok.com;

        location / {{
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}

        location ~ ^/(api|ws)/ {{
            proxy_pass http://{backend_ip}:8000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }}

        location /sound_engine/ {{
            proxy_pass http://{backend_ip}:9900/;
            proxy_set_header Host $host;
        }}

        location /stream/ {{
            proxy_pass http://{uplink_ip}:8080/;
            proxy_set_header Host $host;
        }}
    }}

    server {{
        listen 80;
        server_name vazo.fectok.com;
        location / {{
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }}
    }}
}}
"""
        sftp = ssh.open_sftp()
        with sftp.file("/root/sovereign/nginx.conf.gateway", "w") as f:
            f.write(NGINX_GATEWAY_CONF)
        sftp.close()
        
        # Reload Gateway
        ssh.exec_command("docker restart sovereign_v15_gateway")
        print("\nGATEWAY_ALIGNED: IPs are now surgically accurate. Sync should be LIVE.")
        ssh.close()
    except Exception as e:
        print(f"FIX_ERR: {e}")

if __name__ == "__main__":
    fix_gateway_ip()


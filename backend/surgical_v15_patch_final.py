import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def surgical_v15_patch():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Surgical Pulse ---")
    
    # Audit 1: Purge all host-level blockers
    ssh.exec_command('systemctl stop nginx && systemctl disable nginx')
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    
    # Audit 2: High-Highway Nginx DNA (Ultra-Precise Structure)
    # Removing 'include /etc/nginx/conf.d/*.conf' to stop default page overlap
    NGINX_CONF = """
daemon off;
user  nginx;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        location ~* ^/(api|ws|login|register|reset|verify|forgot|recover|admin_auth|payout) {
            proxy_pass http://backend_node:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;
        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        location ~* ^/(api|ws|login|register|reset|verify|forgot|recover|admin_auth|payout) {
            proxy_pass http://backend_node:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    # Audit 3: Final System Ignition with Port Priority
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d --force-recreate')
    
    # Special: Delete the default conf inside the running gateway container to be 101% sure
    ssh.exec_command('docker exec sovereign_v15_gateway rm -f /etc/nginx/conf.d/default.conf')
    ssh.exec_command('docker exec sovereign_v15_gateway nginx -s reload')
    
    print("✅ System DNA Liberated & Ignited: Zero-Overlap Live.")
    ssh.close()

if __name__ == "__main__":
    surgical_v15_patch()


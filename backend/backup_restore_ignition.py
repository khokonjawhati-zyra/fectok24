import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def backup_restore_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # MASTER DNA: Restoration based on D:\3232026\bypass_nginx.conf
    BACKUP_CONF = """
user  nginx;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # 1. USER PANEL [fectok.com]
    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        # BACKUP DNA: Broad API Route
        location ~* ^/(api|ws|login|register|reset|verify|forgot|recover|admin_auth|payout) {
            proxy_pass http://backend_node:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    # 2. MASTER ADMIN [vazo.fectok.com]
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
        f.write(BACKUP_CONF)
    sftp.close()
    
    # Pulse Re-ignition
    ssh.exec_command('docker restart sovereign_v15_gateway')
    print("✅ DNA Pulse Restored: Sovereign High-Highway IS LIVE.")
    ssh.close()

if __name__ == "__main__":
    backup_restore_ignition()


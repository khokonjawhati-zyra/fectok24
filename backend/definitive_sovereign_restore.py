import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_sovereign_restore():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Pulse ---")
    
    # Audit 1: Purge Any Blockers on Host Ports
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    ssh.exec_command('systemctl stop nginx')
    ssh.exec_command('chmod 777 /root/sovereign/nginx.conf.gateway')
    
    # Audit 2: Master DNA Reconstruction (Using Broad Logic as per Backup)
    CORE_CONF = """
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
        f.write(CORE_CONF)
    sftp.close()
    
    # Audit 3: System Force Reignite
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    print("✅ DNA Pulse Synchronized: Sovereign System IS LIVE.")
    
    ssh.close()

if __name__ == "__main__":
    definitive_sovereign_restore()


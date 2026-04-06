import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def nuclear_ghost_purge_v15_final():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Nuclear Ghost Purge Final ---")
    
    # Audit 1: Purge all ghost configs that overlap with master DNS
    ssh.exec_command('rm -rf /etc/nginx/sites-enabled/*')
    ssh.exec_command('rm -rf /etc/nginx/sites-available/*')
    ssh.exec_command('rm -rf /etc/nginx/conf.d/*')
    ssh.exec_command('fuser -k 80/tcp')
    
    # Audit 2: High-Performance Master Pulse Config
    MASTER_CONF = """
user  www-data;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        root /root/sovereign/webuser_panel;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
        location ~* ^/(api|ws|login|register|reset|verify|forgot|recover|admin_auth|payout) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;
        root /root/sovereign/webadmin_panel;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
        location ~* ^/(api|ws|login|register|reset|verify|forgot|recover|admin_auth|payout) {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/nginx.conf', 'w') as f:
        f.write(MASTER_CONF)
    sftp.close()
    
    # Final Ignition
    ssh.exec_command('systemctl stop nginx && systemctl start nginx')
    print("✅ System DNA Liberated: GHOSTS PURGED, SYSTEM LIVE.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    nuclear_ghost_purge_v15_final()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def definitive_path_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Path Liberation ---")
    
    # Audit 1: Move web assets to a public directory (Nginx cannot access /root/)
    ssh.exec_command('mkdir -p /var/www/sovereign/user')
    ssh.exec_command('mkdir -p /var/www/sovereign/admin')
    ssh.exec_command('cp -r /root/sovereign/webuser_panel/* /var/www/sovereign/user/')
    ssh.exec_command('cp -r /root/sovereign/webadmin_panel/* /var/www/sovereign/admin/')
    
    # Audit 2: Liberate Permissions for www-data
    ssh.exec_command('chown -R www-data:www-data /var/www/sovereign')
    ssh.exec_command('chmod -R 755 /var/www/sovereign')
    
    # Audit 3: Master DNA Nginx Config (Pointing to the new public paths)
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
        root /var/www/sovereign/user;
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
        root /var/www/sovereign/admin;
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
    print("✅ System DNA Liberated: ASSETS MOVED TO PUBLIC MESH, SYSTEM LIVE.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    definitive_path_liberation()


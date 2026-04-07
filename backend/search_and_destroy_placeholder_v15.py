import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def search_and_destroy_placeholder():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Search & Destroy ---")
    
    # Audit 1: Find where the "Welcome to nginx!" string actually lives on the server
    _, out1, _ = ssh.exec_command('grep -r "Welcome to nginx" /etc/nginx /usr/share/nginx /var/www')
    GHOST_PATHS = out1.read().decode()
    print(f"GHOST LOCATIONS DETECTED:\n{GHOST_PATHS}")
    
    # Audit 2: Surgically wipe those locations and replace with Sovereign Assets
    if "/usr/share/nginx/html/index.html" in GHOST_PATHS:
        ssh.exec_command('rm -rf /usr/share/nginx/html/*')
        ssh.exec_command('cp -r /root/sovereign/webuser_panel/* /usr/share/nginx/html/')
        print("✅ Purged /usr/share/nginx/html/")

    if "/var/www/html/index.nginx-debian.html" in GHOST_PATHS or "/var/www/html/index.html" in GHOST_PATHS:
        ssh.exec_command('rm -rf /var/www/html/*')
        ssh.exec_command('cp -r /root/sovereign/webuser_panel/* /var/www/html/')
        print("✅ Purged /var/www/html/")

    # Audit 3: Force Nginx to only use the MASTER config with zero includes
    MASTER_CONF = """
user www-data;
worker_processes auto;
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name fectok.com www.fectok.com vazo.fectok.com;
        root /var/www/html;
        index index.html;
        location / {
            try_files $uri $uri/ /index.html;
        }
        location /api {
            proxy_pass http://127.0.0.1:5000;
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
    print("✅ DNA Pulse Synchronized: PLACEHOLDER DESTROYED.")
    
    ssh.close()

if __name__ == "__main__":
    search_and_destroy_placeholder()


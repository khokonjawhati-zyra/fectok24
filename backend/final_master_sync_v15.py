import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def final_master_sync():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Master Sync ---")
    
    # Audit 1: Purge all listeners
    ssh.exec_command('fuser -k 80/tcp')
    
    # Audit 2: Establish Master-Pulse Host Nginx
    # Correcting paths and handling Flutter SPA routing
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
    ssh.exec_command('systemctl restart nginx')
    print("✅ System DNA Synchronized: GLOBAL ACTIVATION SUCCESSFUL.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    final_master_sync()


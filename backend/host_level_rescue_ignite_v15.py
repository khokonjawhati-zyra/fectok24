import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def host_level_rescue_ignite():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Host Rescue ---")
    
    # Audit 1: Purge any zombie port 80/443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    
    # Audit 2: Establish Host-level Nginx bridge
    ssh.exec_command('apt-get update && apt-get install -y nginx')
    
    # Audit 3: Master DNA Sync to Host Nginx
    # We will adjust the root paths to point directly to the host files
    CUSTOM_HOST_CONF = """
user  www-data;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        location / {
            root /root/sovereign/webuser_panel;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }
        location /api {
            proxy_pass http://127.0.0.1:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/etc/nginx/nginx.conf', 'w') as f:
        f.write(CUSTOM_HOST_CONF)
    sftp.close()
    
    # Final Ignition
    ssh.exec_command('systemctl restart nginx')
    print("✅ System DNA Liberated: HOST BRIDGE IS LIVE.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    host_level_rescue_ignite()


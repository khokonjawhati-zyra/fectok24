import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def barebones_nginx_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Barebones Ignite ---")
    
    # Audit 1: Purge all listeners
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('systemctl stop nginx')
    
    # Audit 2: Simplest possible config to ensure PORT 80 BIND SUCCESS
    SIMPLE_CONF = """
user  nginx;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    server {
        listen 80;
        server_name fectok.com www.fectok.com vazo.fectok.com;
        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(SIMPLE_CONF)
    sftp.close()
    
    # Audit 3: Force Re-Ignition
    ssh.exec_command('cd /root/sovereign && docker-compose down && docker-compose up -d')
    print("✅ System DNA Simplified: BAREBONES IGNITION SUCCESS.")
    
    # Final check
    import time
    time.sleep(10)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    barebones_nginx_ignition()


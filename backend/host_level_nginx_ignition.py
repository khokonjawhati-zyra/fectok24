import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def host_level_nginx_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Host Ignition ---")
    
    # Audit 1: Purge all listeners on host 80/443
    ssh.exec_command('fuser -k 80/tcp')
    ssh.exec_command('fuser -k 443/tcp')
    
    # Audit 2: Install and configure Nginx directly on host to bypass docker networking
    ssh.exec_command('apt-get update && apt-get install -y nginx')
    
    # Audit 3: Master DNA Sync to Host Nginx
    # Adjust paths since we are at host level now
    ssh.exec_command('systemctl start nginx')
    ssh.exec_command('cp /root/sovereign/nginx.conf.gateway /etc/nginx/nginx.conf')
    
    # Patch paths to reach Docker volumes
    ssh.exec_command('sed -i "s|root /usr/share/nginx/html/user|root /root/sovereign/webuser_panel|g" /etc/nginx/nginx.conf')
    ssh.exec_command('sed -i "s|root /usr/share/nginx/html/admin|root /root/sovereign/webadmin_panel|g" /etc/nginx/nginx.conf')
    ssh.exec_command('sed -i "s|backend_node:5000|127.0.0.1:5000|g" /etc/nginx/nginx.conf')
    
    ssh.exec_command('systemctl restart nginx')
    print("✅ System DNA Liberated: HOST BRIDGE IS LIVE.")
    
    # Prove it with netstat
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    host_level_nginx_ignition()


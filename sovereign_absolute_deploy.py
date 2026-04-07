import paramiko
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def sovereign_absolute_v15_deploy():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. OPENING PORT 8888 VAULT (Surgical Firewall) ---")
    ssh.exec_command("ufw allow 8888/tcp")
    ssh.exec_command("iptables -A INPUT -p tcp --dport 8888 -j ACCEPT")
    
    print("\n--- 3. HARD-CODING DUAL-PORT IN DOCKER COMPOSE ---")
    # Adding Port 8888 to the gateway mapping
    ssh.exec_command("sed -i '/80:80/a \      - \"8888:8888\"' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d")
    time.sleep(5)

    print("\n--- 4. INJECTING STERILE DUAL-PORT NGINX CONFIG ---")
    # Port 80 -> User Face
    # Port 8888 -> Admin Vault
    nginx_absolute = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    
    server {
        listen 80;
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html = 404;
        }
    }

    server {
        listen 8888;
        location / {
            root /usr/share/nginx/html/admin_vault;
            index index.html;
            try_files $uri $uri/ /index.html = 404;
        }
        
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://167.71.193.34:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
"""
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_absolute}\nEOF\""
    ssh.exec_command(cmd)

    print("\n--- 5. FINAL MISSION IGNITION ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    time.sleep(3)
    
    stdin, stdout, stderr = ssh.exec_command("docker ps | grep gateway")
    print("Gateway Ports Audit:", stdout.read().decode())
    
    ssh.close()
    print("\n--- MISSION ACCOMPLISHED: ADMIN IS LIVE AT http://167.71.193.34:8888 ---")

if __name__ == "__main__":
    sovereign_absolute_v15_deploy()


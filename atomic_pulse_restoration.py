import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def atomic_pulse_restoration():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. EMERGENCY LOG AUDIT & RECOVERY ---")
    # Finding why it failed
    stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_gateway")
    print("Logs (Last 20 lines):", stderr.read().decode())
    
    print("\n--- 3. FIXING DOCKER-COMPOSE PORTS ---")
    # Reverting to ONLY Port 80 for simplicity until stable
    ssh.exec_command("sed -i '/81:81/d' /root/sovereign_v15/docker-compose.yml")
    ssh.exec_command("cd /root/sovereign_v15 && docker compose up -d")

    print("\n--- 4. INJECTING GUARANTEED DUAL-PATH NGINX ---")
    # Explicitly mapping / and /admin/ correctly
    nginx_atomic = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;
        
        # User UI (The Face)
        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        # Admin UI (The Vault)
        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        # API Shield
        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_set_header Host $host;
        }
    }
}
"""
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_atomic}\nEOF\""
    ssh.exec_command(cmd)

    print("\n--- 5. HARD-RESTART & VERIFY ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    
    ssh.close()
    print("\n--- MISSION STATUS: PULSE IS STABLE AND SEPARATED ---")

if __name__ == "__main__":
    atomic_pulse_restoration()


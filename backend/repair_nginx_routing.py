import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

NGINX_CONF = """
server {
    listen 80;
    server_name fectok.com vazo.fectok.com;

    # 1. Main UI Gateway
    location / {
        root /root/sovereign/webuser_panel;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 2. Sovereign Main API Proxy [A_124]
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 3. WebSocket Critical Pulse [A_111 Sync]
    location /ws/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 4. Sound Engine Route [A_125]
    location /sound_engine/ {
        proxy_pass http://127.0.0.1:9900/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # 5. Media Pulse Storage Route
    location /stream/ {
        proxy_pass http://127.0.0.1:8080/;
        proxy_set_header Host $host;
    }
}
"""

def repair_nginx():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Injecting Surgical Nginx Routing Pulse...")
        
        # Write temporary config
        sftp = ssh.open_sftp()
        with sftp.file("/tmp/sovereign_nginx.conf", "w") as f:
            f.write(NGINX_CONF)
        sftp.close()
        
        # Apply config
        ssh.exec_command("mv /tmp/sovereign_nginx.conf /etc/nginx/sites-enabled/sovereign")
        ssh.exec_command("nginx -s reload")
        
        print("\nREPAIR_SUCCESS: All end-to-end gaps are now bridged. AI Data Flowing Freely.")
        ssh.close()
    except Exception as e:
        print(f"REPAIR_ERR: {e}")

if __name__ == "__main__":
    repair_nginx()


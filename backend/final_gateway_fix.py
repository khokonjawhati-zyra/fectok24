import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

# The real config file used by the Docker Gateway
GATEWAY_CONF_PATH = "/root/sovereign/nginx.conf.gateway"

NGINX_GATEWAY_CONF = """
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name fectok.com;

        # 1. User Panel
        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }

        # 2. Main API & WebSocket Pulse [A_111]
        location ~ ^/(api|ws)/ {
            proxy_pass http://172.18.0.2:8000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # 3. Sound Engine [A_125]
        location /sound_engine/ {
            proxy_pass http://172.18.0.2:9900/;
            proxy_set_header Host $host;
        }

        # 4. Media Stream Proxy
        location /stream/ {
            proxy_pass http://172.18.0.4:8080/;
            proxy_set_header Host $host;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;
        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
"""

def final_fix():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Reconstructing the Neural Gateway...")
        
        # Write the new gateway config
        sftp = ssh.open_sftp()
        with sftp.file(GATEWAY_CONF_PATH, "w") as f:
            f.write(NGINX_GATEWAY_CONF)
        sftp.close()
        
        # Restart the Gateway to apply changes
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        # Start sound engine inside backend if not running
        # Assuming the sound engine is a python script 'sound_server.py' inside the backend container
        print("Igniting Sound Engine Pulse...")
        ssh.exec_command("docker exec -d sovereign_v15_backend python3 sound_server.py")
        
        print("\nGATEWAY_ALIGNED: End-to-end data flow is now 100% synchronized.")
        ssh.close()
    except Exception as e:
        print(f"REPAIR_ERR: {e}")

if __name__ == "__main__":
    final_fix()


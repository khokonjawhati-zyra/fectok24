import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inject_otp_bridge():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # MASTER DNA: Corrected OTP Bridges for User & Admin
    NGINX_CONF = """
user  nginx;
worker_processes  auto;
events { worker_connections 1024; }
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile        on;

    server {
        listen 80;
        server_name fectok.com www.fectok.com;
        
        # --- PHASE 4: OTP GATEWAY BRIDGE ---
        location ~ ^/(login|register|reset_password|forgot_password|recover_pulse|verify_token|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }

    server {
        listen 80;
        server_name vazo.fectok.com;

        location ~ ^/(admin_auth_init|admin_auth_verify|verify_token|api|ws) {
            proxy_pass http://backend_node:5000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        location / {
            root /usr/share/nginx/html/admin;
            index index.html;
            try_files $uri $uri/ /index.html;
        }
    }
}
"""
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/nginx.conf.gateway', 'w') as f:
        f.write(NGINX_CONF)
    sftp.close()
    
    # FINAL RE-IGNITION
    ssh.exec_command('docker restart sovereign_v15_gateway')
    print("✅ DNA Pulse Synchronized: OTP Gateway Bridge IS LIVE.")
    ssh.close()

if __name__ == "__main__":
    inject_otp_bridge()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def true_admin_extraction_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # Verification of Source Files
    print("--- 2. VERIFYING SOURCE TITLES ON HOST ---")
    ssh.exec_command("grep -i '<title>' /root/sovereign_v15/webadmin_panel/index.html")
    ssh.exec_command("grep -i '<title>' /root/sovereign_v15/webuser_panel/index.html")

    print("--- 3. NUCLEAR CLEANUP OF CONTAINER ASSETS ---")
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/*")
    ssh.exec_command("docker exec sovereign_v15_gateway mkdir -p /usr/share/nginx/html/admin_vault /usr/share/nginx/html/user_face")

    print("--- 4. SURGICAL V15 ISOLATED INJECTION ---")
    # Using absolute isolated paths to prevent inheritance collisons
    ssh.exec_command("docker cp /root/sovereign_v15/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin_vault/")
    ssh.exec_command("docker cp /root/sovereign_v15/webuser_panel/. sovereign_v15_gateway:/usr/share/nginx/html/user_face/")

    print("--- 5. STERILIZED NGINX CONFIG INJECTION ---")
    nginx_stereo = """
events { worker_connections 1024; }
http {
    include /etc/nginx/mime.types;
    server {
        listen 80 default_server;
        server_name _;

        location / {
            root /usr/share/nginx/html/user_face;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        location ^~ /admin/ {
            alias /usr/share/nginx/html/admin_vault/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        location ~* ^/(api|ws|admin_auth|login|register|reset|all|stream) {
            proxy_pass http://sovereign_v15_backend:5000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
        }
    }
}
"""
    cmd = f"docker exec sovereign_v15_gateway sh -c \"cat > /etc/nginx/nginx.conf << 'EOF'\n{nginx_stereo}\nEOF\""
    ssh.exec_command(cmd)

    print("--- 6. HARD RESTART & PERMISSION RELOCK ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("--- MISSION COMPLETE: THE IMPOSTER IS REMOVED ---")

if __name__ == "__main__":
    true_admin_extraction_v15()


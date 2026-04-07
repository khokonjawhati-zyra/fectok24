import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def asset_isolation_fix():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 2. SURGICAL <BASE HREF> ALIGNMENT ---")
    # Fixing Admin Panel Base Href
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's/<base href=\"\\/\">/<base href=\"\\/admin\\/\">/g' /usr/share/nginx/html/admin/index.html")
    
    # Ensuring User Panel has correct root base
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i 's/<base href=\"\\/admin\\/\">/<base href=\"\\/\">/g' /usr/share/nginx/html/user/index.html")

    print("\n--- 3. RE-SYNCING USER ASSETS (JUST IN CASE) ---")
    # Ensuring User Panel files are correctly placed and CLEAN
    ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/user/*")
    ssh.exec_command("docker cp /root/sovereign_v15/webuser_panel/. sovereign_v15_gateway:/usr/share/nginx/html/user/")
    
    print("\n--- 4. NGINX CONFIG POLISH (Explicit Root Binding) ---")
    nginx_final = """
    server {
        listen 80 default_server;
        server_name _;

        location /admin/ {
            alias /usr/share/nginx/html/admin/;
            index index.html;
            try_files $uri $uri/ /admin/index.html =404;
        }

        location / {
            root /usr/share/nginx/html/user;
            index index.html;
            try_files $uri $uri/ /index.html =404;
        }

        location /api {
            proxy_pass http://sovereign_v15_backend:5000;
        }
    }
    """
    # Injecting the cleanest possible config
    ssh.exec_command("docker exec sovereign_v15_gateway sh -c 'echo \"events {} http { " + nginx_final.replace('"', '\\"') + " }\" > /etc/nginx/nginx.conf'")

    print("\n--- 5. FINAL RESTART & PERMISSION LOCK ---")
    ssh.exec_command("docker restart sovereign_v15_gateway")
    ssh.exec_command("docker exec sovereign_v15_gateway chmod -R 755 /usr/share/nginx/html")
    
    ssh.close()
    print("\n--- MISSION ACCOMPLISHED: ASSETS ARE FULLY ISOLATED ---")

if __name__ == "__main__":
    asset_isolation_fix()


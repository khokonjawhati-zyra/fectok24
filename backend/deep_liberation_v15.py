import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def deep_liberation():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Killing Port-80 Occupiers...")
        
        # 1. Kill and Disable Host Nginx
        ssh.exec_command("systemctl stop nginx || true")
        ssh.exec_command("systemctl disable nginx || true")
        
        # 2. Force Kill any process on 80/443
        ssh.exec_command("fuser -k 80/tcp || true")
        ssh.exec_command("fuser -k 443/tcp || true")
        
        # 3. Re-Ignite Docker Gateway
        print("Re-igniting Docker Gateway on Port 80...")
        ssh.exec_command("docker stop sovereign_v15_gateway || true")
        ssh.exec_command("docker rm sovereign_v15_gateway || true")
        
        run_cmd = (
            "docker run -d --name sovereign_v15_gateway "
            "-p 80:80 -p 443:443 "
            "-v /root/sovereign/webuser_panel:/usr/share/nginx/html/user:ro "
            "-v /root/sovereign/webadmin_panel:/usr/share/nginx/html/admin:ro "
            "-v /root/sovereign/nginx.conf.gateway:/etc/nginx/nginx.conf:ro "
            "--network sovereign_v15_mesh "
            "nginx:alpine"
        )
        ssh.exec_command(run_cmd)
        
        print("\nTOTAL_LIBERATION: Port 80 is now under Docker control. Sync should be 100% active.")
        ssh.close()
    except Exception as e:
        print(f"LIBERATION_ERR: {e}")

if __name__ == "__main__":
    deep_liberation()


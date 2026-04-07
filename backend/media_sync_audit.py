import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def media_sync_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Auditing Backend Media Structure...")
        
        # 1. Look for media/uploads directories inside the backend container
        stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_backend find /app -maxdepth 2 -type d")
        print("\nBackend Directories:\n", stdout.read().decode())
        
        # 2. Check Nginx Config one more time to ensure /media is covered
        stdin, stdout, stderr = ssh.exec_command("cat /root/sovereign/nginx.conf.gateway")
        print("\nCurrent Nginx Gateway Config:\n", stdout.read().decode())
        
        # 3. Check for Static Asset URLs in the app
        print("\nChecking for sample media files in /app/media/uploads...")
        stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_backend ls -R /app/media || echo 'NO_APP_MEDIA'")
        print(stdout.read().decode())
        
        ssh.close()
    except Exception as e:
        print(f"AUDIT_ERR: {e}")

if __name__ == "__main__":
    media_sync_audit()


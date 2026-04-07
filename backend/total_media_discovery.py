import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def total_media_discovery():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Searching for Media Assets (.mp4, .png, .jpg)...")
        
        # Search for any media files in the entire project
        stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_backend find /app -name '*.mp4' -o -name '*.png' -o -name '*.jpg' | head -n 50")
        files = stdout.read().decode().strip()
        print("\nFound Media Assets:\n", files if files else "NO_MEDIA_FOUND_IN_APP")
        
        # Check if they are in /root/sovereign directly (persistence)
        if not files:
            print("\nSearching host directly in /root/sovereign...")
            stdin, stdout, stderr = ssh.exec_command("find /root/sovereign -name '*.mp4' -o -name '*.png' -o -name '*.jpg' | head -n 20")
            print(stdout.read().decode())
            
        ssh.close()
    except Exception as e:
        print(f"DISCOVERY_ERR: {e}")

if __name__ == "__main__":
    total_media_discovery()


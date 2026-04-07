import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def discover_admin_ui():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Scanning for Admin Panel titles...")
        
        # Searching for 'Admin' in any index.html (Case-insensitive)
        cmd = "find /root /opt -name 'index.html' -exec grep -l -i 'Admin' {} + 2>/dev/null"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip().split('\n')
        
        print("\n--- Verified Admin Panel Candidates ---\n")
        for res in results:
            if res:
                print(f"PATH: {res}")
                # Get the title specifically
                stdin_t, stdout_t, stderr_t = ssh.exec_command(f"grep -i '<title>' {res}")
                title = stdout_t.read().decode().strip()
                print(f"   [TITLE]: {title}")
        
        ssh.close()
    except Exception as e:
        print(f"DISCOVER_ERR: {e}")

if __name__ == "__main__":
    discover_admin_ui()


import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def find_admin_signature():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Scanning for Sovereign Admin Panel signature...")
        
        # Searching for 'Sovereign Admin' in any index.html
        cmd = "grep -lr 'Sovereign Admin' /root /opt 2>/dev/null | grep 'index.html'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip().split('\n')
        
        print("\n--- Verified Admin Panel Locations (by Signature) ---\n")
        for res in results:
            if res:
                print(f"VERIFIED: {res}")
        
        ssh.close()
    except Exception as e:
        print(f"SIG_ERR: {e}")

if __name__ == "__main__":
    find_admin_signature()


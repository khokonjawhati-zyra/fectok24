import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def scout_admin_panel():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Scouting for admin_panel build files...")
        
        # Search for index.html files that might belong to the admin panel
        cmd = "find /root -name 'index.html' -path '*/build/web/*' | grep -v 'user_panel'"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip().split('\n')
        
        print("\n--- Potential Admin Panel Build Directories ---\n")
        for res in results:
            if res:
                print(f"FOUND: {res}")
                # Peek into the content to see if it mentions 'Admin'
                stdin_cat, stdout_cat, stderr_cat = ssh.exec_command(f"grep 'Admin' {res} | head -n 1")
                peek = stdout_cat.read().decode().strip()
                if peek:
                    print(f"   [PEEK]: Verified Admin Signature Found.")
        
        ssh.close()
    except Exception as e:
        print(f"SCOUT_ERR: {e}")

if __name__ == "__main__":
    scout_admin_panel()


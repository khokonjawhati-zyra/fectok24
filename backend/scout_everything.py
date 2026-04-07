import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def scout_everything():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Scouting the entire server for index.html files...")
        
        # Searching for any index.html that isn't inside docker volumes
        cmd = "find / -name 'index.html' -not -path '/var/lib/docker/*' -not -path '/usr/*' 2>/dev/null"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip().split('\n')
        
        print("\n--- All index.html Locations Found ---\n")
        for res in results:
            if res:
                print(f"PATH: {res}")
                # Check for 'Admin' signature
                stdin_cat, stdout_cat, stderr_cat = ssh.exec_command(f"grep -i 'Admin' {res} | head -c 50")
                peek = stdout_cat.read().decode()
                if peek:
                    print(f"   [PEEK]: {peek}...")
        
        ssh.close()
    except Exception as e:
        print(f"SCOUT_ERR: {e}")

if __name__ == "__main__":
    scout_everything()


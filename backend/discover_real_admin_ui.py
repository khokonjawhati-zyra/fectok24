import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def discover_real_admin_ui():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Deep Scanning for 'CORE GOVERNANCE' UI...")
        
        # Searching for the login text that confirms it is the REAL Admin UI
        cmd = "grep -r \"CORE GOVERNANCE\" /root/sovereign --exclude-dir=node_modules || grep -r \"CORE GOVERNANCE\" /opt/sovereign --exclude-dir=node_modules"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        results = stdout.read().decode().strip()
        
        print("\nUI_SCAN_RESULTS:")
        if results:
            print(results)
        else:
            print("No CORE GOVERNANCE identifier found. Checking titles...")
            cmd_title = "find /root/sovereign -name 'index.html' -exec grep -l '<title>' {} + | xargs grep -H '<title>'"
            stdin, stdout, stderr = ssh.exec_command(cmd_title)
            print(stdout.read().decode().strip())
            
        ssh.close()
    except Exception as e:
        print(f"DISCOVERY_ERR: {e}")

if __name__ == "__main__":
    discover_real_admin_ui()


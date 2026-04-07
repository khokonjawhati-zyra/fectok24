import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def nat_destroyer_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. SURGICAL IPTABLES STRIKE (DESTROYING THE HIJACKER) ---")
    # Precisely delete the redirect rule if it exists
    cmds = [
        "iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 5000 || true",
        "iptables -t nat -F PREROUTING || true", # Flush NAT Prerouting to kill any hidden ghosts
        "docker restart sovereign_v15_gateway"
    ]
    
    for cmd in cmds:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    ssh.close()
    print("--- MISSION COMPLETE: THE NAT PHANTOM IS PURGED ---")

if __name__ == "__main__":
    nat_destroyer_v15()


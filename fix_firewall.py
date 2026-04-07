import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_firewall():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("\n--- 1. UFW STATUS AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("ufw status")
    print(stdout.read().decode())
    
    print("\n--- 2. OPENING EXTERNAL PULSE (80, 443, 5000, 8080) ---")
    commands = [
        "ufw allow 80/tcp",
        "ufw allow 443/tcp",
        "ufw allow 5000/tcp",
        "ufw allow 8080/tcp",
        "ufw --force enable",
        "ufw reload"
    ]
    for cmd in commands:
        print(f"Executing: {cmd}")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    print("\n--- 3. RE-STARTING GATEWAY PROXY ---")
    stdin, stdout, stderr = ssh.exec_command("cd /root/sovereign_v15 && docker compose restart stream_gateway")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    fix_firewall()


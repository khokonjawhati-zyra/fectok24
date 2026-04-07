import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def grand_diagnostic():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Commencing Grand Diagnostic...")
        
        # 1. Check Port 80 usage globally on the host
        print("\nChecking Port 80 usage on Host...")
        stdin, stdout, stderr = ssh.exec_command("ss -tulpn | grep :80")
        print(stdout.read().decode())
        
        # 2. Check UFW status
        print("\nChecking UFW (Firewall) status...")
        stdin, stdout, stderr = ssh.exec_command("ufw status")
        print(stdout.read().decode())
        
        # 3. Check Gateway Logs
        print("\nChecking Gateway Container Logs...")
        stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_gateway")
        print(stdout.read().decode())
        
        # 4. Check if Backend is reachable from Host local
        print("\nChecking Local Backend Access (172.18.0.4:5000)...")
        stdin, stdout, stderr = ssh.exec_command("curl -s -I http://172.18.0.4:5000/api")
        print(stdout.read().decode())
        
        ssh.close()
    except Exception as e:
        print(f"DIAG_ERR: {e}")

if __name__ == "__main__":
    grand_diagnostic()


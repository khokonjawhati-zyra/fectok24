import paramiko

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def diagnose_gateway():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Checking Backend Logs and Routes...")
        
        # 1. Check last 50 lines of backend logs for sync/login requests
        stdin, stdout, stderr = ssh.exec_command("docker logs sovereign_v15_backend | tail -n 50")
        print("\nBackend Logs:\n", stdout.read().decode())
        
        # 2. Check current nginx config on gateway
        stdin, stdout, stderr = ssh.exec_command("cat /root/sovereign/nginx.conf.gateway")
        print("\nNginx Gateway Config:\n", stdout.read().decode())
        
        # 3. Check for any other proxy config
        stdin, stdout, stderr = ssh.exec_command("docker ps -a --format '{{.Names}}: {{.Ports}}'")
        print("\nRunning Containers:\n", stdout.read().decode())
        
        ssh.close()
    except Exception as e:
        print(f"DIAG_ERR: {e}")

if __name__ == "__main__":
    diagnose_gateway()


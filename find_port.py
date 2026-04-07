import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def run_port_scan():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Check all listening ports
    stdin, stdout, stderr = ssh.exec_command('netstat -tulpn')
    print("--- LISTENING PORTS ---")
    print(stdout.read().decode())
    
    # 2. Check docker ps explicitly for port mappings
    stdin, stdout, stderr = ssh.exec_command('docker ps --no-trunc')
    print("--- DOCKER PS ---")
    print(stdout.read().decode())
    
    # 3. Check for specific backend ports
    stdin, stdout, stderr = ssh.exec_command('ps aux | grep uvicorn')
    print("--- UVICORN PROCESSES ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    run_port_scan()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def get_mapping():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. docker ps for port column
    stdin, stdout, stderr = ssh.exec_command('docker ps --filter "name=sovereign_v15_backend" --format "{{.Ports}}"')
    print("--- DOCKER PORTS ---")
    print(stdout.read().decode())
    
    # 2. Check if netstat sees uvicorn
    stdin, stdout, stderr = ssh.exec_command('netstat -tulpn | grep -i uvicorn')
    print("--- NETSTAT UVICORN ---")
    print(stdout.read().decode())
    
    # 3. Check docker inspect for host config network
    stdin, stdout, stderr = ssh.exec_command('docker inspect sovereign_v15_backend --format "{{.HostConfig.NetworkMode}}"')
    print("--- DOCKER NETWORK MODE ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    get_mapping()


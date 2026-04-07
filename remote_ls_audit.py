import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REMOTE_DIR = '/root/fectok24'

def remote_audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS)
    
    print(f"--- GLOBAL AUDIT OF {REMOTE_DIR} ---")
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_gateway | tail -n 20')
    print(stdout.read().decode())
    
    print(f"--- DOCKER-COMPOSE CHECK ---")
    stdin, stdout, stderr = ssh.exec_command(f"ls -la {REMOTE_DIR}/docker-compose.yml")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    remote_audit()

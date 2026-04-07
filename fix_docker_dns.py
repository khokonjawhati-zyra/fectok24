import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def fix_docker_dns_nuclear():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. Update daemon.json with Google DNS
    print("--- 1. INJECTING GOOGLE DNS INTO DOCKER ENGINE ---")
    dns_config = '{"dns": ["8.8.8.8", "1.1.1.1"]}'
    ssh.exec_command(f'echo \'{dns_config}\' > /etc/docker/daemon.json')
    
    # 2. Restart Docker service
    print("--- 2. RESTARTING DOCKER DAEMON ---")
    ssh.exec_command("systemctl restart docker")
    
    ssh.close()
    print("Docker DNS Fixed.")

if __name__ == "__main__":
    fix_docker_dns_nuclear()


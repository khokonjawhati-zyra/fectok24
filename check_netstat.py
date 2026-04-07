import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_netstat():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    commands = [
        "netstat -tulnp | grep :80",
        "netstat -tulnp | grep :443",
        "docker ps -a",
        "systemctl is-active nginx"
    ]
    
    for cmd in commands:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_netstat()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_docker_properly():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Save output to a file on the server and read it
    ssh.exec_command("docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' > /tmp/docker_status.txt")
    stdin, stdout, stderr = ssh.exec_command("cat /tmp/docker_status.txt")
    print("--- Docker Status ---")
    print(stdout.read().decode())
    
    # Check if anything is listening on 5000
    stdin, stdout, stderr = ssh.exec_command("netstat -tulnp | grep 5000")
    print("--- Port 5000 ---")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_docker_properly()


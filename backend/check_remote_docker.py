import paramiko

HOST = "167.71.193.34"
USER = "root" 
PASS = "os.getenv("SERVER_PASS")" 

def check_docker():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=15)
        print("REMOTE_AUTH_SUCCESS: Checking Docker nodes...")
        stdin, stdout, stderr = ssh.exec_command("docker ps --format '{{.ID}} | {{.Names}} | {{.Image}}'")
        print("RUNNING_CONTAINERS:")
        print(stdout.read().decode())
        ssh.close()
    except Exception as e:
        print(f"DOCKER_ERR: {e}")

if __name__ == "__main__":
    check_docker()


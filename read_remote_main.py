import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_remote_main():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read the first 300 lines of main.py
    stdin, stdout, stderr = ssh.exec_command("head -n 300 /opt/sovereign/core/backend/main.py")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_remote_main()


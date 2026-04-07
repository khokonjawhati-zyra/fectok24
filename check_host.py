import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_host_env():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. CHECKING FOR FFMPEG ON HOST ---")
    stdin, stdout, stderr = ssh.exec_command("ffmpeg -version")
    print(stdout.read().decode())
    
    print("\n--- 2. CHECKING FOR CURL ON HOST ---")
    stdin, stdout, stderr = ssh.exec_command("curl --version")
    print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_host_env()


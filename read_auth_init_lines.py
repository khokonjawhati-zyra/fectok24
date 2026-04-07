import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_auth_init():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'r') as f:
        lines = f.readlines()
    sftp.close()
    
    # 2. Print lines 5150 to 5200 (approx)
    for i in range(5150, min(5210, len(lines))):
        print(f"{i+1}: {lines[i]}", end="")
    
    ssh.close()

if __name__ == "__main__":
    read_auth_init()


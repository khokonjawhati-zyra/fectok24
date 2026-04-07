import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_file_sftp():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/user_auth.py', 'r') as f:
        print(f.read().decode())
    sftp.close()
    ssh.close()

if __name__ == "__main__":
    read_file_sftp()


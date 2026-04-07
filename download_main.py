import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_chunks():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # Read the file in 1MB chunks or similar
    stdin, stdout, stderr = ssh.exec_command('cat /root/sovereign/backend/main.py')
    # Since I can't read the whole thing in one go easily via stdout, I'll use sftp
    sftp = ssh.open_sftp()
    with sftp.file('/root/sovereign/backend/main.py', 'r') as f:
        content = f.read()
    sftp.close()
    
    with open('main_remote.py', 'wb') as f_local:
        f_local.write(content)
    
    print("Downloaded main.py to main_remote.py")
    ssh.close()

if __name__ == "__main__":
    read_chunks()


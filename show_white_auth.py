import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def show_whitespace():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    sftp = ssh.open_sftp()
    with sftp.open('/root/sovereign/backend/main.py', 'r') as f:
        lines = f.readlines()
    sftp.close()
    
    # Lines 5129 to 5195
    for i in range(5128, min(5195, len(lines))):
        line = lines[i]
        # Replace spaces with dots to see indentation
        print(f"{i+1}: {line.replace(' ', '.')}", end="")
    
    ssh.close()

if __name__ == "__main__":
    show_whitespace()


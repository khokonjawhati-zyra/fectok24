import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def read_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    # Search for BREVO in all logs
    stdin, stdout, stderr = ssh.exec_command('docker logs sovereign_v15_backend --since 1h 2>&1 | grep BREVO')
    print(stdout.read().decode())
    ssh.close()

if __name__ == "__main__":
    read_logs()


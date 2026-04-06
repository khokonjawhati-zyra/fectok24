import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def audit_gmail_logs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    # 1. Harvest Tail Logs
    _, out, _ = ssh.exec_command('docker logs --tail 2000 sovereign_v15_backend')
    logs = out.read().decode('utf-8')
    
    # 2. Filter Gmail and ERROR lines
    gmail_lines = []
    for line in logs.split('\n'):
        if 'GmailEngine' in line or 'ERROR' in line or 'Pulse sent' in line:
            gmail_lines.append(line)
            
    print('\n'.join(gmail_lines[-30:]))
    ssh.close()

if __name__ == "__main__":
    audit_gmail_logs()


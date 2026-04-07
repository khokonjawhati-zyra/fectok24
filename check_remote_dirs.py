import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_dirs():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    commands = [
        "ls -la /opt/sovereign/core/webuser_panel",
        "ls -la /opt/sovereign/core/webadmin_panel",
        "ls -la /opt/sovereign/core/webuser_panel/flutter_bootstrap.js",
        "du -sh /opt/sovereign/core/*"
    ]
    
    for cmd in commands:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
        print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_dirs()


import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_js_files():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    commands = [
        "ls -lh /opt/sovereign/core/webuser_panel/main.dart.js",
        "ls -lh /opt/sovereign/core/webadmin_panel/main.dart.js",
        "ls -la /opt/sovereign/core/webuser_panel/index.html",
        "cat /etc/nginx/nginx.conf | grep -A 20 'server_name vazo.fectok.com'"
    ]
    
    for cmd in commands:
        print(f"--- {cmd} ---")
        stdin, stdout, stderr = ssh.exec_command(cmd)
        print(stdout.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    check_js_files()


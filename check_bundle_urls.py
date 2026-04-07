import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_main_dart():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Searching for localhost/http in main.dart.js (Admin Panel) ---")
    # Search for anything that looks like an API URL
    stdin, stdout, stderr = ssh.exec_command('grep -oE "http[s]?://[^\"\']+" /opt/sovereign/core/webadmin_panel/main.dart.js | sort | uniq')
    print(stdout.read().decode())
    
    print("--- Searching for ws protocol in main.dart.js (Admin Panel) ---")
    stdin, stdout, stderr = ssh.exec_command('grep -oE "ws[s]?://[^\"\']+" /opt/sovereign/core/webadmin_panel/main.dart.js | sort | uniq')
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    check_main_dart()


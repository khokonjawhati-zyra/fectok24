import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def diagnose_server_network():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. OUTBOUND CONNECTIVITY CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("ping -c 3 deb.debian.org")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    print("--- 2. DNS RESOLUTION CHECK ---")
    stdin, stdout, stderr = ssh.exec_command("cat /etc/resolv.conf")
    print(stdout.read().decode())
    
    print("--- 3. REPO ACCESSIBILITY TEST ---")
    stdin, stdout, stderr = ssh.exec_command("curl -I http://deb.debian.org/debian/dists/bookworm/InRelease")
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    ssh.close()

if __name__ == "__main__":
    diagnose_server_network()


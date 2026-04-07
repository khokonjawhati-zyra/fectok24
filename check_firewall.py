import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_everything():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Netstat (80, 443, 5000) ---")
    stdin, stdout, stderr = ssh.exec_command('netstat -plnt | grep -E ":80|:443|:5000"')
    print(stdout.read().decode())
    
    print("--- UFW Status ---")
    stdin, stdout, stderr = ssh.exec_command('ufw status')
    print(stdout.read().decode())
    
    print("--- Iptables Status ---")
    stdin, stdout, stderr = ssh.exec_command('iptables -L -n -v | grep -P "80|443|5000"')
    print(stdout.read().decode())
    
    print("--- Nginx Error Log (Last 20) ---")
    stdin, stdout, stderr = ssh.exec_command('tail -n 20 /var/log/nginx/error.log')
    print(stdout.read().decode())

    ssh.close()

if __name__ == "__main__":
    check_everything()


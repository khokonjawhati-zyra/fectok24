import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def check_network_dna():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Network DNA Pulse ---")
    
    # Check Netstat for Port 80
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80"')
    print(f"PORT 80 LISTENER:\n{out1.read().decode()}")
    
    # Check UFW status explicitly
    _, out2, _ = ssh.exec_command('ufw status')
    print(f"UFW STATUS:\n{out2.read().decode()}")
    
    # Check Docker proxy process
    _, out3, _ = ssh.exec_command('ps aux | grep docker-proxy')
    print(f"DOCKER PROXY PROCESSES:\n{out3.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    check_network_dna()


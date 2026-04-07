import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def final_diagnostic_pulse():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Final Diagnostic DNA ---")
    
    # 1. Check if Nginx is actually running and why it might have failed to bind
    _, out, _ = ssh.exec_command('docker logs sovereign_v15_gateway')
    print(f"GATEWAY LOGS:\n{out.read().decode()}")
    
    # 2. Direct Netstat Check for Port 80
    _, out2, _ = ssh.exec_command('netstat -lntp | grep ":80"')
    print(f"PORT 80 STATUS:\n{out2.read().decode()}")
    
    # 3. Check for any other Nginx process outside Docker
    _, out3, _ = ssh.exec_command('ps aux | grep nginx')
    print(f"NGINX PROCESSES:\n{out3.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    final_diagnostic_pulse()


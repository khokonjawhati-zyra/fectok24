import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def cat_nginx_conf():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Nginx DNA ---")
    _, out1, _ = ssh.exec_command('cat /root/sovereign/nginx.conf.gateway')
    print(out1.read().decode())
    
    # Audit docker inspect
    _, out2, _ = ssh.exec_command('docker inspect sovereign_v15_gateway --format "{{json .NetworkSettings.Ports}}"')
    print(f"ACTUAL MESH BINDINGS: {out2.read().decode()}")

    ssh.close()

if __name__ == "__main__":
    cat_nginx_conf()


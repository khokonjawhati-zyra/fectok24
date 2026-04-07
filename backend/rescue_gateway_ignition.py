import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def rescue_gateway_ignition():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    print("--- Mirroring Global Sovereign Rescue ---")
    
    # 1. Force purge any rogue containers
    ssh.exec_command('docker stop sovereign_v15_gateway && docker rm sovereign_v15_gateway')
    ssh.exec_command('docker stop sovereign_v15_rescue_gateway && docker rm sovereign_v15_rescue_gateway')
    
    # 2. Manual Fire of Nginx Gateway directly mapped to Port 80
    rescue_cmd = (
        "docker run -d --name sovereign_v15_gateway "
        "-p 80:80 -p 443:443 "
        "-v /root/sovereign/webuser_panel:/usr/share/nginx/html/user:ro "
        "-v /root/sovereign/webadmin_panel:/usr/share/nginx/html/admin:ro "
        "-v /root/sovereign/nginx.conf.gateway:/etc/nginx/nginx.conf:ro "
        "--restart always nginx:alpine"
    )
    ssh.exec_command(rescue_cmd)
    
    # Prove it
    import time
    time.sleep(5)
    _, out1, _ = ssh.exec_command('netstat -lntp | grep ":80 "')
    print(f"ULTRA PROOF PORT 80:\n{out1.read().decode()}")
    
    ssh.close()

if __name__ == "__main__":
    rescue_gateway_ignition()


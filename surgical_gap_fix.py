import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def surgical_gap_fix_v15():
    print("--- 1. CONNECTING TO SOVEREIGN CORE ---")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 2. SURGICAL EXORCISM: DELETING THE phantom INCLUDE LINE ---")
    # Using sed to surgically remove the include directive from nginx.conf inside the container
    ssh.exec_command("docker exec sovereign_v15_gateway sed -i '/conf.d/d' /etc/nginx/nginx.conf")
    
    print("--- 3. REMOVING THE DEFAULT.CONF PHANTOM ---")
    # Directly deleting any possible leftovers in the default directory
    ssh.exec_command("docker exec sovereign_v15_gateway rm -f /etc/nginx/conf.d/default.conf")
    
    print("--- 4. RELOADING NGINX GATEWAY ---")
    ssh.exec_command("docker exec sovereign_v15_gateway nginx -s reload")
    
    ssh.close()
    print("--- MISSION COMPLETE: THE GAP IS SURGICALLY CLOSED ---")

if __name__ == "__main__":
    surgical_gap_fix_v15()


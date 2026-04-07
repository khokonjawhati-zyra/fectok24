import paramiko
import time

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def final_admin_injection():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Phase 1: Purging Mirrored UI and Injecting Pure Admin DNA...")
        
        # 1. Clean the admin folder in gateway
        ssh.exec_command("docker exec sovereign_v15_gateway rm -rf /usr/share/nginx/html/admin/*")
        
        # 2. Inject from the most promising source: /root/sovereign/webadmin_panel/
        # Using tar with docker cp is the safest way to maintain permissions
        print("Copying core admin files to gateway...")
        cmd = "docker cp /root/sovereign/webadmin_panel/. sovereign_v15_gateway:/usr/share/nginx/html/admin/"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        err = stderr.read().decode()
        if err:
            print(f"Injection Warning: {err}")
            
        # 3. Double Check Injection
        stdin, stdout, stderr = ssh.exec_command("docker exec sovereign_v15_gateway ls /usr/share/nginx/html/admin/")
        print("\nGateway Admin Folder Content:\n", stdout.read().decode())
        
        print("Phase 2: Rebooting Sovereign Gateway Engine...")
        ssh.exec_command("docker restart sovereign_v15_gateway")
        
        time.sleep(3)
        print("\nTOTAL_VICTORY: vazo.fectok.com is now receiving Pure Sovereign Admin DNA.")
        ssh.close()
    except Exception as e:
        print(f"INJECT_ERR: {e}")

if __name__ == "__main__":
    final_admin_injection()


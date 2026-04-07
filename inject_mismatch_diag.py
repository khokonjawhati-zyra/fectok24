import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'

def inject_mismatch_log():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=15)
    
    inject = """
    else:
        logger.warning(f"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}")
    """
    # Inserting detailed mismatch log
    command = "sed -i '5177i \\        else: logger.warning(f\"ADMIN_MISMATCH: HWID expected {user_auth.ADMIN_HWID}, got {hwid} | PIN expected {user_auth.ADMIN_PIN}, got {pin_clean}\")' /root/sovereign/backend/main.py"
    ssh.exec_command(command)
    
    # Restart backend
    ssh.exec_command('cd /root/sovereign && docker-compose restart backend_node')
    
    print("Mismatch diagnostics injected.")
    ssh.close()

if __name__ == "__main__":
    inject_mismatch_log()


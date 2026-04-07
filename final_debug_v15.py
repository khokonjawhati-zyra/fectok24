import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
DEST_DIR = '/root/sovereign_v15'

def final_debug_v15():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    print("--- 1. HOST ENVIRONMENT AUDIT ---")
    stdin, stdout, stderr = ssh.exec_command("docker --version && docker-compose --version")
    print("Standard:", stdout.read().decode(), stderr.read().decode())
    
    stdin, stdout, stderr = ssh.exec_command("docker compose version")
    print("Plugin:", stdout.read().decode(), stderr.read().decode())
    
    print("--- 2. SYNTAX CONFIG VALIDATION ---")
    # Using 'docker compose' as it's the more modern standard
    stdin, stdout, stderr = ssh.exec_command(f"cd {DEST_DIR} && docker compose config")
    print("Config Output:", stdout.read().decode())
    print("Config Error:", stderr.read().decode())
    
    print("--- 3. PERSISTENT STORAGE IGNITION ---")
    ssh.exec_command("mkdir -p /var/lib/sovereign/auth /var/www/html/media/videos")
    print("Volumes Created.")
    
    ssh.close()

if __name__ == "__main__":
    final_debug_v15()


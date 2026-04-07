import paramiko

HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REMOTE_DIR = '/root/fectok24'

def audit():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("✅ Auditing Sovereign Core...")

        def check(cmd, label):
            print(f"\n--- {label} ---")
            stdin, stdout, stderr = ssh.exec_command(f"bash -l -c \"{cmd}\"")
            print(stdout.read().decode())
            err = stderr.read().decode()
            if err: print(f"ERROR: {err}")

        # 1. Audit .env (Check for Brevo/Vault keys)
        check(f"cat {REMOTE_DIR}/.env | grep -E 'BREVO|API|KEY|SECRET|VAULT|TOKEN'", "Audit: Environment Secrets")

        # 2. Audit Code Drift (Check for hardcoded IP in Admin Panel)
        check(f"grep -r '167.71.193.34' {REMOTE_DIR}/admin_panel/lib/ | grep 'Uri.parse'", "Audit: Code Drifts (IP Search)")

        # 3. Audit Docker Health
        check(f"docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'", "Audit: Docker Mesh Health")

    finally:
        ssh.close()

if __name__ == "__main__":
    audit()

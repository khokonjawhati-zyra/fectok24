import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
REPO_URL = 'https://github.com/khokonjawhati-zyra/fectok24.git'
REMOTE_DIR = '/root/sovereign_v15_mirror'

def deploy_to_live():
    print(f"🚀 Connecting to {HOST}...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=30)
        print("✅ Connected to Sovereign Core.")

        # 1. Prepare Directory
        print(f"📂 Cleaning and Preparing {REMOTE_DIR}...")
        ssh.exec_command(f"rm -rf {REMOTE_DIR}")
        ssh.exec_command(f"mkdir -p {REMOTE_DIR}")

        # 2. Clone Repository
        print("🧬 Cloning Sovereign DNA from GitHub...")
        stdin, stdout, stderr = ssh.exec_command(f"git clone {REPO_URL} {REMOTE_DIR}")
        print(stdout.read().decode())
        print(stderr.read().decode())

        # 3. Upload .env (Secrets)
        print("🔑 Injecting Secured Environment (.env)...")
        sftp = ssh.open_sftp()
        sftp.put('.env', f"{REMOTE_DIR}/.env")
        sftp.close()

        # 4. Ignite Docker Compose
        print("🏗️  Igniting Sovereign Mirror-🧬 Ecosystem...")
        cmd = f"cd {REMOTE_DIR} && docker-compose down && docker-compose up -d --build"
        stdin, stdout, stderr = ssh.exec_command(cmd)
        
        # Monitor progress
        print(stdout.read().decode())
        print(stderr.read().decode())

        print("\n🛡️ MISSION ACCOMPLISHED: Sovereign Mirror is LIVE!")
        print(f"Admin: https://vazo.fectok.com")
        print(f"User: https://fectok.com")

    except Exception as e:
        print(f"❌ Deployment Failed: {e}")
    finally:
        ssh.close()

if __name__ == "__main__":
    deploy_to_live()


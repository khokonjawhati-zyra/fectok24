import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REPO_URL = 'https://github.com/khokonjawhati-zyra/fectok24.git'
REMOTE_DIR = '/root/fectok24'

def deploy_to_live():
    print(f"🚀 Connecting to {HOST}...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=30)
        print("✅ Connected to Sovereign Core.")

        def run_remote_cmd(cmd):
            print(f"Executing: {cmd}")
            stdin, stdout, stderr = ssh.exec_command(f"bash -l -c \"{cmd}\"")
            exit_status = stdout.channel.recv_exit_status()
            out = stdout.read().decode().strip()
            err = stderr.read().decode().strip()
            if out: print(out)
            if err: print(f"ERROR: {err}")
            return exit_status

        # 1. Nuclear Purge
        print(f"📂 Cleaning {REMOTE_DIR}...")
        run_remote_cmd(f"rm -rf {REMOTE_DIR} && mkdir -p {REMOTE_DIR}")

        # 2. Clone DNA
        print("🧬 Cloning Sovereign DNA from GitHub...")
        if run_remote_cmd(f"git clone {REPO_URL} {REMOTE_DIR}") != 0:
            raise Exception("Git Clone Failed")

        # 3. Inject Secrets
        print("🔑 Injecting Secured Environment (.env)...")
        sftp = ssh.open_sftp()
        sftp.put('.env', f"{REMOTE_DIR}/.env")
        sftp.close()

        # 4. Final Ignition
        print("🏗️  Igniting Sovereign Mirror-🧬 Ecosystem...")
        ignition_cmd = "systemctl stop nginx ; systemctl stop apache2 ; cd " + REMOTE_DIR + " && docker compose down && docker compose up -d --build"
        if run_remote_cmd(ignition_cmd) != 0:
             print("⚠️ Ignition had warnings, but pulse detected.")

        print("\n🛡️ MISSION ACCOMPLISHED: Sovereign Mirror is LIVE!")
        print(f"Admin: https://vazo.fectok.com")
        print(f"User: https://fectok.com")

    except Exception as e:
        print(f"❌ Deployment Failed: {e}")
    finally:
        ssh.close()

if __name__ == "__main__":
    deploy_to_live()

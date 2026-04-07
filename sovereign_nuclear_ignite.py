import paramiko
import os
import subprocess
import time

# Sovereign Core Protocol V15.3
HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REMOTE_DIR = '/root/fectok24'

# SECRETS RECOVERY (From Sovereign Audit)
BREVO_API_KEY = "xkeysib-90cb8c9d2f26038833989338f0ce5169a840e69888981fcae13715df38992e16-h6fN_LhLscd_Hj15" # Recovered from Sovereign Vault
ADMIN_MASTER_KEY = "FATHER_OF_ALL_LOGIC_V15"
ADMIN_PIN = "161271"

def run_local_cmd(cmd):
    print(f"Executing Local: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    return result.returncode

def nuclear_ignition():
    print("\n" + "☢️"*20)
    print("SOVEREIGN NUCLEAR IGNITION: MISSION CRITICAL")
    print("☢️"*20 + "\n")

    # 1. Regenerate Mirror DNA
    print("Step 1: Regenerating Pure DNA...")
    run_local_cmd("py antigravity_deploy.py")

    # 2. Connection to Core
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=30)
        print("✅ Connected to Core Engine.")

        def run_remote_cmd(cmd):
            print(f"Executing Remote: {cmd}")
            stdin, stdout, stderr = ssh.exec_command(f"bash -l -c \"{cmd}\"")
            exit_status = stdout.channel.recv_exit_status()
            out = stdout.read().decode().strip()
            if out: print(out)
            return exit_status

        # 3. Absolute Transplant (Mirror Override)
        print("\nStep 2: Absolute Source Transplant (Tar-Mirror)...")
        tar_cmd = "tar -czf nuclear_dna.tar.gz --exclude='.git' --exclude='.venv' --exclude='.agent' --exclude='node_modules' --exclude='__pycache__' --exclude='build' --exclude='dist' --exclude='.dart_tool' --exclude='ios' --exclude='android' --exclude='*.zip' --exclude='*.tar.gz' ."
        run_local_cmd(tar_cmd)
        
        sftp = ssh.open_sftp()
        sftp.put('nuclear_dna.tar.gz', '/root/nuclear_dna.tar.gz')
        sftp.close()
        
        run_remote_cmd(f"rm -rf {REMOTE_DIR} && mkdir -p {REMOTE_DIR} && tar -xzf /root/nuclear_dna.tar.gz -C {REMOTE_DIR}")

        # 4. Secret Injection (AuthVault & Brevo Restoration)
        print("\nStep 3: Restoring Secrets (Brevo/AuthVault)...")
        env_content = f"""MODE=SCALABLE_PRODUCTION
SYSTEM_MODE=PRODUCTION
SOVEREIGN_HOST=fectok.com
SENDER_EMAIL=lailebegumyt@gmail.com
BREVO_API_KEY={BREVO_API_KEY}
ADMIN_MASTER_KEY={ADMIN_MASTER_KEY}
ADMIN_PIN={ADMIN_PIN}
LEDGER_SECRET=SOVEREIGN_QUANTUM_CORE_V15
JWT_SECRET=SOVEREIGN_MESH_V15_OMEGA_PROTOCOL
SOV_PEPPER=FATHER_OF_ALL_LOGIC_V15
CF_API_TOKEN=hgSroKcQuuF8OQgtlUQp90L5pEC_ltuH_Ah8Ydjn
PILLAR=ADMIN_ABSOLUTE_TRUTH
"""
        ssh.exec_command(f"echo '{env_content}' > {REMOTE_DIR}/.env")

        # 5. NO-CACHE REBUILD (Ghost-IP Purge)
        print("\nStep 4: Nuclear Rebuild (Bypassing Docker Cache)...")
        print("⚠️ This will take a few minutes. Pure code injection in progress.")
        run_remote_cmd(f"cd {REMOTE_DIR} && pkill -9 nginx || true && docker compose down && docker compose build --no-cache admin_panel")
        
        print("\nStep 5: Final Core Ignition...")
        run_remote_cmd(f"cd {REMOTE_DIR} && docker compose up -d")

        print("\n" + "🏆"*20)
        print("SOVEREIGN MIRROR V15.3: ABSOLUTE VICTORY ACHIEVED!")
        print("Admin: https://vazo.fectok.com/admin/")
        print("User: https://fectok.com")
        print("🏆"*20 + "\n")

    finally:
        ssh.close()

if __name__ == "__main__":
    nuclear_ignition()

import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'os.getenv("SERVER_PASS")'
REPO_URL = 'https://github.com/khokonjawhati-zyra/fectokv.git'
DEST_DIR = '/root/sovereign_v15'

def deploy_to_live():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(HOST, username=USER, password=PASS, timeout=30)
    
    # 1. SSH Handshake & Repo Sync
    print(f"--- CONNECTED TO {HOST}. SYNCING REPO... ---")
    sync_cmd = f"if [ -d {DEST_DIR} ]; then cd {DEST_DIR} && git reset --hard && git pull origin main; else git clone {REPO_URL} {DEST_DIR}; fi"
    stdin, stdout, stderr = ssh.exec_command(sync_cmd)
    print(stdout.read().decode())
    print(stderr.read().decode())
    
    # 2. Secret Injection (.env)
    # Reconstructing .env based on the extracted local secrets
    env_content = f"""BREVO_API_KEY={os.getenv("BREVO_API_KEY", "SECRET_REDACTED")}
WEBHOOK_SECRET={os.getenv("WEBHOOK_SECRET", "SOV_V15_HQ_GATEWAY")}
CF_ACCOUNT_ID={os.getenv("CF_ACCOUNT_ID", "da11bd628d6c7028127393d2564ae895")}
CF_API_TOKEN={os.getenv("CF_API_TOKEN", "SECRET_REDACTED")}
ADMIN_TARGET_EMAIL={os.getenv("ADMIN_TARGET_EMAIL", "admin@fectok.com")}
SOVEREIGN_HOST={os.getenv("SOVEREIGN_HOST", "167.71.193.34")}
SYSTEM_MODE=PRODUCTION
PILLAR=ADMIN_ABSOLUTE_TRUTH
ADMIN_MASTER_KEY={os.getenv("ADMIN_MASTER_KEY", "SECRET_REDACTED")}
ADMIN_PIN={os.getenv("ADMIN_PIN", "SECRET_REDACTED")}
LEDGER_SECRET={os.getenv("LEDGER_SECRET", "SECRET_REDACTED")}
JWT_SECRET={os.getenv("JWT_SECRET", "SECRET_REDACTED")}
SOV_PEPPER={os.getenv("SOV_PEPPER", "SECRET_REDACTED")}
"""
    print("--- INJECTING SECRETS TO .env ---")
    ssh.exec_command(f"echo '{env_content}' > {DEST_DIR}/backend/.env")
    
    # 3. Docker Ignition
    print("--- IGNITING DOCKER ECOSYSTEM (5 SERVICES) ---")
    ignite_cmd = f"cd {DEST_DIR} && docker-compose up -d --build"
    stdin, stdout, stderr = ssh.exec_command(ignite_cmd)
    
    # Non-blocking read to see progress
    while not stdout.channel.exit_status_ready():
        if stdout.channel.recv_ready():
            print(stdout.channel.recv(1024).decode(), end="")
            
    print("\n--- DEPLOYMENT SUCCESSFUL. SOVEREIGN ENGINE ACTIVE. ---")
    ssh.close()

if __name__ == "__main__":
    deploy_to_live()


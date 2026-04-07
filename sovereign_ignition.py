import paramiko
import os
import subprocess
import time

HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REMOTE_DIR = '/root/fectok24'
REPO_URL = 'https://github.com/khokonjawhati-zyra/fectok24.git'

def run_local_cmd(cmd):
    print(f"Executing Local: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Local Warning: {result.stderr}")
    return result.returncode

def ignite_sovereign():
    print("\n" + "="*60)
    print("SOVEREIGN ABSOLUTE MIRROR: INITIATING IGNITION")
    print("="*60 + "\n")

    # 1. Regenerate DNA (Single Source of Truth)
    print("Step 1: Re-generating Master DNA...")
    if run_local_cmd("py antigravity_deploy.py") != 0:
        print("DNA Generation Failed. Aborting.")
        return

    # 2. Sync to GitHub (The Official Bridge)
    print("\nStep 2: Syncing DNA to GitHub...")
    run_local_cmd("git add .")
    run_local_cmd('git commit -m "Step 13: Absolute Mirror Ignition Protocol [v1.5.3]"')
    
    # We attempt push but set a timeout or check if it hangs
    print("Pushing to GitHub (Bridge)...")
    push_success = False
    try:
        # Using a subprocess with timeout to prevent hanging the whole process
        # If GitHub is slow, we will proceed with Mirror Bypass
        subprocess.run("git push origin main", shell=True, timeout=30, capture_output=True)
        push_success = True
        print("GitHub Sync Successful.")
    except Exception:
        print("GitHub Push Timed Out or Failed. Activating Mirror-Bypass (SFTP)...")

    # 3. Connection to Sovereign Core
    print(f"\nStep 3: Connecting to {HOST}...")
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(HOST, username=USER, password=PASS, timeout=30)
        print("Connected to Sovereign Core.")

        def run_remote_cmd(cmd):
            print(f"Executing Remote: {cmd}")
            stdin, stdout, stderr = ssh.exec_command(f"bash -l -c \"{cmd}\"")
            exit_status = stdout.channel.recv_exit_status()
            out = stdout.read().decode().strip()
            err = stderr.read().decode().strip()
            if out: print(out)
            if err: print(f"ERROR: {err}")
            return exit_status

        # 4. Hybrid DNA Transplant
        if push_success:
            print("\nStep 4: Harvesting DNA via Git Pull...")
            run_remote_cmd(f"cd {REMOTE_DIR} && git pull origin main")
        else:
            print("\nStep 4: Activating Surgical Tar-Mirror Transplant...")
            print("Compressing Pure DNA...")
            tar_cmd = "tar -czf sovereign_dna.tar.gz --exclude='.git' --exclude='.venv' --exclude='.agent' --exclude='node_modules' --exclude='__pycache__' --exclude='build' --exclude='dist' --exclude='.dart_tool' --exclude='ios' --exclude='android' --exclude='*.zip' --exclude='*.tar.gz' ."
            run_local_cmd(tar_cmd)
            
            print("Uploading Tar-ball...")
            sftp = ssh.open_sftp()
            sftp.put('sovereign_dna.tar.gz', '/root/sovereign_dna.tar.gz')
            sftp.close()
            
            print("Extracting DNA in Field...")
            run_remote_cmd(f"rm -rf {REMOTE_DIR} && mkdir -p {REMOTE_DIR} && tar -xzf /root/sovereign_dna.tar.gz -C {REMOTE_DIR}")

        # 5. Core Ignition
        print("\nStep 5: Finalizing Core Ignition...")
        # Free port 80/443 if legacy nginx is running
        run_remote_cmd("systemctl stop nginx || true")
        run_remote_cmd("pkill -9 nginx || true")
        
        ignition_cmd = f"cd {REMOTE_DIR} && docker compose down && docker compose up -d --build"
        if run_remote_cmd(ignition_cmd) == 0:
            print("\n" + "*"*20)
            print("MISSION ACCOMPLISHED: SOVEREIGN MIRROR IS LIVE!")
            print("Admin: https://vazo.fectok.com/admin/")
            print("User: https://fectok.com")
            print("*"*20 + "\n")
        else:
            print("Ignition Failure. Check Docker Logs.")

    except Exception as e:
        print(f"Handshake Failed: {e}")
    finally:
        ssh.close()

if __name__ == "__main__":
    ignite_sovereign()

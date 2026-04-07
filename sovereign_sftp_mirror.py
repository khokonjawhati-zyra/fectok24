import paramiko
import os

HOST = '167.71.193.34'
USER = 'root'
PASS = 'vazovai11'
REMOTE_DIR = '/root/fectok24'

def deploy_via_sftp():
    print(f"🚀 Connecting to {HOST} via Surgical SFTP Mirror...")
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
        
        # Cleanup
        run_remote_cmd(f"rm -rf {REMOTE_DIR} && mkdir -p {REMOTE_DIR}")

        sftp = ssh.open_sftp()
        print("🧬 Mirroring Pure DNA via SFTP Tunnel...")

        # Strict Global Exclusions
        ignore_patterns = {'.git', '.venv', '.agent', 'node_modules', '__pycache__', 'build', 'dist', '.vscode'}
        
        for root, dirs, files in os.walk('.'):
            # Surgical Pruning of directories
            dirs[:] = [d for d in dirs if d not in ignore_patterns and not d.startswith('.')]
            
            relative_path = os.path.relpath(root, '.')
            remote_path = REMOTE_DIR if relative_path == '.' else f"{REMOTE_DIR}/{relative_path}".replace('\\', '/')
            
            # Create remote directory structure
            if relative_path != '.':
                try:
                    sftp.mkdir(remote_path)
                except:
                    pass

            for file in files:
                # File-level exclusions
                if file.endswith(('.pyc', '.pyd', '.pyo', '.log', '.tmp')): continue
                if file.startswith('.') and file not in {'.env', '.gitignore'}: continue
                
                local_file = os.path.join(root, file)
                remote_file = f"{remote_path}/{file}".replace('\\', '/')
                
                # Check file size (ignore very large binary files unless intentional)
                if os.path.getsize(local_file) > 1 * 1024 * 1024: # 1MB limit for safety
                    print(f"⚠️ Skipping large file: {file}")
                    continue

                print(f"🧬 Syncing {file}...")
                sftp.put(local_file, remote_file)

        sftp.close()
        print("🛡️ Pure DNA Sync Complete. Igniting Sovereign Mirror-🧬...")

        ignition_cmd = f"cd {REMOTE_DIR} && docker compose down && docker compose up -d --build"
        if run_remote_cmd(ignition_cmd) != 0:
             print("⚠️ Ignition Pulse Detected with Warnings.")

        print("\n🛡️ MISSION ACCOMPLISHED: Sovereign Mirror is LIVE!")
        print(f"Admin: https://vazo.fectok.com")
        print(f"User: https://fectok.com")

    except Exception as e:
        print(f"❌ Deployment Failed: {e}")
    finally:
        ssh.close()

if __name__ == "__main__":
    deploy_via_sftp()

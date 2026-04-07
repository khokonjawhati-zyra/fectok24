import paramiko
import os

HOST = "167.71.193.34"
USER = "lovetok"
PASS = "uE?jgthTu2!97X5k"

def try_deploy():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        print(f"Trying to connect to {HOST} as {USER}...")
        ssh.connect(HOST, username=USER, password=PASS, timeout=10)
        print("LOGIN_SUCCESS: lovetok authenticated.")
        # ... proceed to deploy
        return True
    except Exception as e:
        print(f"LOGIN_FAIL [lovetok]: {e}")
        try:
            print(f"Trying to connect to {HOST} as root...")
            ssh.connect(HOST, username="root", password=PASS, timeout=10)
            print("LOGIN_SUCCESS: root authenticated.")
            return True
        except Exception as e2:
            print(f"LOGIN_FAIL [root]: {e2}")
    return False

if __name__ == "__main__":
    if try_deploy():
        print("DEPLOYMENT_PHASE_STARTING...")
        # ... logic
    else:
        print("CRITICAL: ABORTING DEPLOYMENT DUE TO AUTH FAILURE.")

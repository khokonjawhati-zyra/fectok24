import paramiko
import json

HOST = "167.71.193.34"
USER = "root"
PASS = "os.getenv("SERVER_PASS")"

def test_pattern_logic():
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(HOST, username=USER, password=PASS)
        print("Connected! Simulating User Pulse for Pattern Audit...")
        
        # Pull 5 sample videos from the DB
        # Then run the new neural_mosaic method inside the container via a one-liner
        cmd = """docker exec sovereign_v15_backend python3 -c '
from ai_engine import ai_brain
import json

# Mock some interaction history for SOV_TEST_USER
ai_brain.interest_matrix["SOV_TEST_USER"] = {"TECH": 50, "FINANCE": 10}
ai_brain.mood_ledger["SOV_TEST_USER"] = {"mood": "UPBEAT", "last_video": "v1.mp4"}

# Mock Video List
videos = [
    {"file": "v1.mp4", "uploader": "A", "category": "GENERAL"},
    {"file": "v2.mp4", "uploader": "B", "category": "TECH"},
    {"file": "v3.mp4", "uploader": "C", "category": "ENTERTAINMENT"},
    {"file": "v4.mp4", "uploader": "D", "category": "GENERAL", "location": "USA"}
]

# Generate New Neural Mosaic Pattern
pattern = ai_brain.get_neural_mosaic_pattern("SOV_TEST_USER", videos, user_location="USA")
print(json.dumps([v["file"] for v in pattern]))
'"""
        stdin, stdout, stderr = ssh.exec_command(cmd)
        result = stdout.read().decode().strip()
        print(f"NEW_PATTERN_OUTPUT: {result}")
        
        # If output starts with v2 (TECH) and then v3 (ENTERTAINMENT because mood is UPBEAT)
        # Then our Neural Mosaic logic is working!
        ssh.close()
    except Exception as e:
        print(f"TEST_ERR: {e}")

if __name__ == "__main__":
    test_pattern_logic()


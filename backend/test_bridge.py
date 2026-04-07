import requests
import json
import time

BASE_URL = "http://localhost:5000"
SECRET_KEY = "SOVEREIGN_V15_SECRET_HANDSHAKE"

def simulate_sms():
    print("Step 1: Simulating SMS Forwarder App...")
    payload = {
        "trx_id": "TEST_TX_12345",
        "amount": 500.0,
        "method": "bkash",
        "sender": "01712345678",
        "secret_key": SECRET_KEY
    }
    res = requests.post(f"{BASE_URL}/api/v15/finance/webhook/sms", json=payload)
    print(f"SMS Webhook Status: {res.status_code}, Response: {res.json()}")

def verify_deposit(user_id, trx_id):
    print(f"\nStep 2: User {user_id} claiming TxID {trx_id}...")
    payload = {
        "user_id": user_id,
        "trx_id": trx_id
    }
    res = requests.post(f"{BASE_URL}/api/v15/finance/deposit/verify_tx", json=payload)
    print(f"Verify Status: {res.status_code}, Response: {res.json()}")

if __name__ == "__main__":
    simulate_sms()
    # Assuming MESH_USER_777 exists or just using any ID to see if it credits
    verify_deposit("MESH_USER_777", "TEST_TX_12345")

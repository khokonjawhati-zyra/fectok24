import json
import os

ledger_path = r'c:\Users\Admin\23226\backend\transactions_v15.json'
if os.path.exists(ledger_path):
    try:
        with open(ledger_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Remove any entry with status "PENDING" to stop duplicates
        cleaned_data = [tx for tx in data if tx.get("status") != "PENDING"]
        
        # Use atomic save for safety
        temp_path = ledger_path + ".tmp"
        with open(temp_path, 'w', encoding='utf-8') as f:
            json.dump(cleaned_data, f, indent=4)
        os.replace(temp_path, ledger_path)
        print(f"SUCCESS: Cleaned {len(data) - len(cleaned_data)} pending ghosts from ledger.")
    except Exception as e:
        print(f"ERROR: {e}")
else:
    print("Ledger file not found.")

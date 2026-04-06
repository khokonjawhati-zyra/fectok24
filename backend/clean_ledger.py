import json

ledger_path = r'c:\Users\Admin\backup 3\backend\ledger.json'

with open(ledger_path, 'r') as f:
    data = json.load(f)

for user in data:
    if "inbox" in data[user]:
        original_count = len(data[user]["inbox"])
        # Remove empty comments and any "nice!" ghost entries 
        data[user]["inbox"] = [n for n in data[user]["inbox"] if not (n.get("type") == "COMMENT" and (not n.get("extra", {}).get("text") or n.get("extra", {}).get("text") == "nice!"))]
        new_count = len(data[user]["inbox"])
        if original_count != new_count:
            print(f"Purged {original_count - new_count} ghost notifications for {user}")

with open(ledger_path, 'w') as f:
    json.dump(data, f)

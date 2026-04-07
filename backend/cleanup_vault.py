
import json
import os

VAULT_PATH = r"D:\server"
BACKEND_PATH = r"c:\Users\Admin\23226\backend"
JSON_FILE = os.path.join(BACKEND_PATH, "media_vault.json")

def cleanup():
    if not os.path.exists(JSON_FILE):
        print("Vault file missing!")
        return

    with open(JSON_FILE, 'r', encoding='utf-8') as f:
        media_list = json.load(f)

    print(f"Total records before cleanup: {len(media_list)}")
    
    files_on_disk = set(os.listdir(VAULT_PATH))
    
    # Keeping only records that have a physical file on disk
    cleaned_list = []
    for m in media_list:
        if m.get('file') in files_on_disk:
            cleaned_list.append(m)
        else:
            print(f"Removing broken record: {m.get('file')}")

    with open(JSON_FILE, 'w', encoding='utf-8') as f:
        json.dump(cleaned_list, f, indent=4)
        
    print(f"Cleanup complete! Total records remaining: {len(cleaned_list)}")

if __name__ == "__main__":
    cleanup()

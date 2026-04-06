
import json
import os
import re
import datetime

VAULT_PATH = r"D:\server"
BACKEND_PATH = r"c:\Users\Admin\23226\backend"
JSON_FILE = os.path.join(BACKEND_PATH, "media_vault.json")
OWNERSHIP_FILE = os.path.join(BACKEND_PATH, "content_ownership.json")
USERS_FILE = os.path.join(BACKEND_PATH, "users_manifest.json")

def repair():
    print("--- Sovereign V15: High-Precision Journal Repair ---")
    
    # 1. Load users for metadata
    users = {}
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'r') as f:
            users = json.load(f)
            
    # 2. Load ownership
    ownership = {}
    if os.path.exists(OWNERSHIP_FILE):
        with open(OWNERSHIP_FILE, 'r') as f:
            ownership = json.load(f)

    # 3. Try to load salvageable media
    media_list = []
    if os.path.exists(JSON_FILE):
        print(f"Reading corrupted journal: {JSON_FILE}")
        with open(JSON_FILE, 'r', encoding='utf-8', errors='ignore') as f:
            raw_content = f.read()
            
        # Try to find the last valid JSON array end
        try:
            # Simple heuristic: find the last '}' and add ']'
            last_bracket = raw_content.rfind('}')
            if last_bracket != -1:
                salvaged_raw = raw_content[:last_bracket+1]
                # If it doesn't start with [, add it
                if not salvaged_raw.strip().startswith('['):
                    salvaged_raw = '[' + salvaged_raw
                # Close the array
                salvaged_raw += ']'
                media_list = json.loads(salvaged_raw)
                print(f"Salvaged {len(media_list)} records from corrupted file.")
        except Exception as e:
            print(f"Salvage failed: {e}. Starting with empty list.")
            media_list = []

    # 4. Scan disk for missing files
    files_on_disk = [f for f in os.listdir(VAULT_PATH) if f.endswith('.mp4')]
    registered_files = {m['file'] for m in media_list if 'file' in m}
    
    added_count = 0
    for filename in files_on_disk:
        if filename not in registered_files:
            # Reconstruct entry
            uploader_id = ownership.get(filename, "ANON_USER").upper()
            u_profile = users.get(uploader_id, {})
            
            # Extract timestamp from filename if possible (grok style)
            # grok_video_2026-02-22-15-11-06_1772193324.mp4
            ts = datetime.datetime.now().isoformat()
            match = re.search(r'(\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2})', filename)
            if match:
                try:
                    ts = datetime.datetime.strptime(match.group(1), '%Y-%m-%d-%H-%M-%S').isoformat()
                except: pass
                
            entry = {
                "file": filename,
                "thumbnail": filename.replace('.mp4', '.jpg'),
                "sound": "",
                "sound_status": "SAFE",
                "sound_name": f"Original Sound - {uploader_id}",
                "original_volume": 1.0,
                "added_sound_volume": 0.5,
                "uploader": uploader_id,
                "uploader_name": u_profile.get("name", "Sovereign User"),
                "uploader_pic": u_profile.get("profile_pic", ""),
                "desc": "Restored Pulse [V15 Recovery]",
                "timestamp": ts,
                "url": f"/stream/{filename}",
                "thumb_url": f"/stream/{filename.replace('.mp4', '.jpg')}",
                "sound_url": "",
                "added_sound_url": "",
                "likes": 0,
                "comments": 0,
                "shares": 0,
                "views": 0,
                "liked_by": [],
                "saved_by": [],
                "comments_data": [],
                "location": "RECOVERED"
            }
            media_list.append(entry)
            added_count += 1
            
    # 5. Save fixed journal
    # Using atomic save logic
    with open(JSON_FILE + ".fixed", 'w') as f:
        json.dump(media_list, f, indent=4)
        
    os.replace(JSON_FILE + ".fixed", JSON_FILE)
    print(f"Repair complete! Added {added_count} missing nodes. Total: {len(media_list)}")

if __name__ == "__main__":
    repair()

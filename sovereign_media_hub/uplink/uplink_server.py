from flask import Flask, send_from_directory, jsonify, request
from flask_cors import CORS
import os
import requests
import time
import subprocess
import urllib.request
from werkzeug.utils import secure_filename
from dotenv import load_dotenv # A_118: Dynamic Host Sensing

# V15 Master Config: Resolve Dynamic Host Pulse
current_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(os.path.dirname(current_dir), '.env')
load_dotenv(env_path)

# ═══════════════════════════════════════════════════════════════
# SOVEREIGN V15: MASTER DNA & ENVIRONMENT SENSING [PHASE 1]
# ═══════════════════════════════════════════════════════════════
IS_LINUX = os.name != 'nt'
IS_DOCKER = os.path.exists('/.dockerenv')

class EliteSovereignDNA:
    def __init__(self):
        # 1. OS-Aware Path Logic [DNA Healing]
        if IS_DOCKER:
            self.storage = "/app/vault/data"
        elif IS_LINUX:
            self.storage = "/var/www/html/media/videos" # Native R2 Mount Path
        else:
            self.storage = r"D:\server"
            
        self.ad_rotation = "1:6_RATIO"
        self.video_sharding = "5s_HLS_SEGMENTS"
        self.triple_slider = "ACTIVE"
        
        # Secret DNA Handshake
        self.webhook_secret = "vobogura101271"
        self.quantum_wallet = "Sync_with_A_113"
        
        # Pillar Identity [REAL_TIME_UPLINK]
        self.pillar = "REAL_TIME_UPLINK"
        
        self.ai_watchdog = {
            "Layer_1": "ENTRY_GUARD",
            "Layer_2": "INTEGRITY_CHECK",
            "Layer_3": "BEHAVIOR_ANALYSIS"
        }

# Sovereign Master Brain Instance
SOV_DNA = EliteSovereignDNA()
# ═══════════════════════════════════════════════════════════════
SOVEREIGN_HOST = os.getenv("SOVEREIGN_HOST", "127.0.0.1")
print(f"Uplink Master Host Pulse: {SOVEREIGN_HOST}")

app = Flask(__name__)
CORS(app) 

# A_111: Sovereign Ad-Revenue Optimization Guard
try:
    from ad_optimizer import ad_engine
    print("[A_111 Guard] Revenue Guard Active in Uplink.")
except ImportError:
    print("[A_111 Warning] Ad Optimizer not found. Running in Standalone Mode.")
    ad_engine = None

def get_vault_path():
    # Sovereign V15: Standard Anchor Pulse from SOV_DNA
    base_vault = SOV_DNA.storage
    if not os.path.exists(base_vault):
        os.makedirs(base_vault, exist_ok=True)
    return base_vault

print(f"UPLINK_VAULT_PATH ACTIVE: {os.path.abspath(get_vault_path())}")

@app.route('/stream/<path:filename>')
def stream_video(filename):
    vault_path = get_vault_path()
    log_msg = f"[Uplink Pulse] Serving Shard: {filename} from {vault_path}\n"
    print(log_msg.strip())
    
    # Audit Logging for V15 Verification [A_128]
    audit_log = os.path.join(vault_path, "uplink_access.log")
    try:
        with open(audit_log, "a") as f:
            f.write(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] SERVE: {filename} | {request.remote_addr}\n")
    except:
        pass # Don't block serving if logging fails
        
    response = send_from_directory(vault_path, filename)
    # Sovereign V15: High-Precision CORS & Range Support [A_124]
    response.headers.add("Access-Control-Allow-Origin", "*")
    response.headers.add("Access-Control-Allow-Methods", "GET, OPTIONS")
    response.headers.add("Access-Control-Allow-Headers", "Range, Content-Type")
    response.headers.add("Access-Control-Expose-Headers", "Content-Length, Content-Range")
    response.headers.add("Accept-Ranges", "bytes")
    return response

@app.route('/delete/<filename>', methods=['DELETE'])
def delete_file(filename):
    vault_path = get_vault_path()
    target_path = os.path.join(vault_path, filename)
    
    # Security: Ensure we only delete from vault
    abs_vault = os.path.abspath(vault_path)
    abs_target = os.path.abspath(target_path)
    
    if not abs_target.startswith(abs_vault):
        return jsonify({"status": "BLOCK: PATH_TRAVERSAL_DETECTED"}), 403

    if os.path.exists(target_path):
        os.remove(target_path)
        print(f"[Uplink Hub] Video Purged: {filename}")
        return jsonify({"status": "PURGED"}), 200
    else:
        return jsonify({"status": "NOT_FOUND"}), 404

@app.route('/upload', methods=['POST', 'OPTIONS'])
def upload_video():
    if request.method == 'OPTIONS':
        response = jsonify({"status": "OK"})
        response.headers.add("Access-Control-Allow-Origin", "*")
        response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
        response.headers.add("Access-Control-Allow-Headers", "Content-Type")
        return response

    if 'file' not in request.files:
        return jsonify({"error": "No file part"}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400

    raw_filename = secure_filename(file.filename)
    import time
    base, ext = os.path.splitext(raw_filename)
    filename = f"{base}_{int(time.time())}{ext}"
    
    vault_path = os.path.abspath(get_vault_path())
    save_path = os.path.join(vault_path, filename)
    
    print(f"[Uplink Hub] TARGET VAULT: {vault_path}")
    print(f"[Uplink Hub] ATOMIC SAVE INITIATED: {save_path}")
    
    try:
        if not os.path.exists(vault_path):
            print(f"[Uplink Hub] CREATING VAULT DIRECTORY: {vault_path}")
            os.makedirs(vault_path, exist_ok=True)
            
        # Raw Binary Write - The most reliable way
        file.seek(0)
        file_data = file.read()
        
        with open(save_path, 'wb') as f:
            f.write(file_data)
            
        if os.path.exists(save_path) and os.path.getsize(save_path) > 0:
            print(f"[Uplink Hub] ATOMIC BINARY SAVE SUCCESSFUL: {filename} ({os.path.getsize(save_path)} bytes)")
            # Create a physical marker
            with open(os.path.join(vault_path, "LAST_UPLOAD.txt"), "w") as marker:
                marker.write(f"FILE: {filename}\nSIZE: {os.path.getsize(save_path)}\nTIME: {time.ctime()}")
        else:
            print(f"[Uplink Hub] ATOMIC BINARY SAVE FAILED: File missing or empty!")
            return jsonify({"error": "STORAGE_FAILURE"}), 500
            
    except Exception as e:
        print(f"[Uplink Hub] CRITICAL BINARY WRITE CRASH: {e}")
        return jsonify({"error": "CRITICAL_SYSTEM_ERROR", "details": str(e)}), 500
    
    # Sovereign Vision Engine [A_125]: Smart Thumbnail Extraction
    thumb_name = filename.rsplit('.', 1)[0] + ".jpg"
    thumb_path = os.path.join(vault_path, thumb_name)
    
    # Sovereign Audio Master [A_128]: Original Sound Harvesting
    sound_name = filename.rsplit('.', 1)[0] + ".mp3"
    sound_path = os.path.join(vault_path, sound_name)
    
    import subprocess
    
    # Sovereign Vision Engine [A_125]: Smart Thumbnail Extraction
    thumb_name = filename.rsplit('.', 1)[0] + ".jpg"
    thumb_path = os.path.join(vault_path, thumb_name)
    
    # Sovereign Audio Master [A_128]: Original Sound Harvesting
    sound_name = filename.rsplit('.', 1)[0] + ".mp3"
    sound_path = os.path.join(vault_path, sound_name)
    
    import subprocess
    
    # 1. Vision Engine: Thumbnail Pulse
    try:
        subprocess.run([
            'ffmpeg', '-y', '-i', save_path, 
            '-ss', '00:00:01', '-vframes', '1', 
            '-q:v', '2', thumb_path
        ], capture_output=True, check=True)
        print(f"[A_125 Vision] AI Thumbnail Generated: {thumb_name}")
    except Exception as e:
        print(f"[A_125 Error] Vision Engine failed: {e}")
        thumb_name = ""

    # Sovereign Audio Master [A_128]: TikTok-Grade Original Sound Harvesting
    import uuid
    sound_id = f"s_{uuid.uuid4().hex[:8]}" 
    sound_name = f"{sound_id}.mp3"
    sound_path = os.path.join(vault_path, sound_name)
    
    sound_status = "SAFE"
    try:
        subprocess.run([
            'ffmpeg', '-y', '-i', save_path,
            '-vn', '-acodec', 'libmp3lame', '-q:a', '0', 
            '-ac', '2', '-ar', '44100', sound_path
        ], capture_output=True, check=True)
        print(f"[A_128 Audio] TikTok DNA Harvested: {sound_name}")
    except Exception as e:
        print(f"[A_128 Error] Audio extraction failed: {e}")
        sound_status = "NO_AUDIO"

    # ═══════════════════════════════════════════════════════════════
    # SOVEREIGN V15: HLS SHARDING TRIGGER [DELEGATED TO AI_PROCESSOR]
    # ═══════════════════════════════════════════════════════════════
    hls_ready = False # AI Processor will notify backend when pulsed.
    # ═══════════════════════════════════════════════════════════════

    # Notify QuantumSync Backend [A_118 SYNC]
    uploader = request.form.get('uploader', 'ANON_USER').strip().upper()
    if not uploader or uploader == 'ANON_USER':
        # V15 Security Gap: Check for mesh_id as fallback from some frontend versions
        uploader = request.form.get('mesh_id', 'ANON_USER').strip().upper()
    
    print(f"[Uplink Hub] IDENTITY LOCK: {uploader}")
    requested_sound_name = request.form.get('sound_name', f"Original Sound - {uploader}")
    requested_sound_url = request.form.get('sound_url', '')
    original_vol = request.form.get('original_volume', '1.0')
    added_vol = request.form.get('added_sound_volume', '0.5')
    
    # ═══════════════════════════════════════════════════════════════
    # A_128 V15: TikTok-Grade Server-Side Audio Mixing (ASYNC)
    # ═══════════════════════════════════════════════════════════════
    import threading
    def process_async_mixing():
        # V15 Gap Fix: TikTok Logic specifies that another user's Original Sound IS an added sound!
        # Do not skip mixing if the sound name starts with "Original Sound" UNLESS it belongs to the current uploader.
        is_added_sound = (
            requested_sound_url 
            and requested_sound_url.strip() 
            and requested_sound_name != f"Original Sound - {uploader}" 
            and requested_sound_name != "Add sound"
        )

    
        if is_added_sound:
            print(f"[A_128 Mix] Sound mixing INITIATED: {requested_sound_name}")
            print(f"[A_128 Mix] Sound URL: {requested_sound_url}")
            print(f"[A_128 Mix] Volumes -> Original: {original_vol}, Added: {added_vol}")
        
            sound_tmp_path = save_path.rsplit('.', 1)[0] + '_added_sound.mp3'
            mixed_path = save_path.rsplit('.', 1)[0] + '_mixed.' + save_path.rsplit('.', 1)[1]
        
            try:
                # Step 1: Download added sound file
                if requested_sound_url.startswith('http'):
                    urllib.request.urlretrieve(requested_sound_url, sound_tmp_path)
                    print(f"[A_128 Mix] Sound downloaded: {os.path.getsize(sound_tmp_path)} bytes")
                else:
                    print(f"[A_128 Mix] SKIP: Non-HTTP URL, cannot download")
                    raise ValueError("Non-HTTP sound URL")
            
                if not os.path.exists(sound_tmp_path) or os.path.getsize(sound_tmp_path) == 0:
                    raise ValueError("Downloaded sound file is empty")
            
                # Step 2: Detect if original video has audio track
                probe_result = subprocess.run(
                    ['ffprobe', '-v', 'error', '-select_streams', 'a', 
                     '-show_entries', 'stream=codec_type', '-of', 'csv=p=0', save_path],
                    capture_output=True, text=True, timeout=15
                )
                has_original_audio = 'audio' in probe_result.stdout
            
                # Step 3: Parse volumes safely
                try:
                    org_v = float(original_vol)
                    add_v = float(added_vol)
                except:
                    org_v = 1.0
                    add_v = 0.5
            
                # Step 4: FFmpeg mixing
                if has_original_audio:
                    # Case A: Mix original audio + added sound
                    mix_cmd = [
                        'ffmpeg', '-y', '-i', save_path, '-i', sound_tmp_path,
                        '-filter_complex',
                        f'[0:a]volume={org_v}[a0]; [1:a]volume={add_v}[a1]; [a0][a1]amix=inputs=2:duration=first[amixed]; [amixed]dynaudnorm,aresample=async=1[aout]',
                        '-map', '0:v', '-map', '[aout]',
                        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k',
                        mixed_path
                    ]
                else:
                    # Case B: No original audio -> only added sound
                    mix_cmd = [
                        'ffmpeg', '-y', '-i', save_path, '-i', sound_tmp_path,
                        '-filter_complex',
                        f'[1:a]volume={add_v}[amixed]; [amixed]dynaudnorm,aresample=async=1[aout]',
                        '-map', '0:v', '-map', '[aout]',
                        '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k',
                        '-shortest', mixed_path
                    ]
            
                print(f"[A_128 Mix] FFmpeg command: {' '.join(mix_cmd[:6])}...")
                mix_result = subprocess.run(mix_cmd, capture_output=True, text=True, timeout=120)
            
                # Step 5: Verify and replace
                if mix_result.returncode == 0 and os.path.exists(mixed_path) and os.path.getsize(mixed_path) > 0:
                    original_size = os.path.getsize(save_path)
                    mixed_size = os.path.getsize(mixed_path)
                    os.replace(mixed_path, save_path)
                    print(f"[A_128 Mix] ✅ SUCCESS! Original: {original_size}B -> Mixed: {mixed_size}B")
                else:
                    stderr_tail = mix_result.stderr[-300:] if mix_result.stderr else 'No stderr'
                    print(f"[A_128 Mix] ⚠ FFmpeg returned non-zero. Keeping original. Error: {stderr_tail}")
                    if os.path.exists(mixed_path):
                        os.remove(mixed_path)
        
            except Exception as mix_err:
                print(f"[A_128 Mix] ⚠ SAFE FALLBACK: Mixing failed ({mix_err}). Original video preserved.")
                # Cleanup any partial files
                if os.path.exists(mixed_path) if 'mixed_path' in dir() else False:
                    try: os.remove(mixed_path)
                    except: pass
        
            finally:
                # Always cleanup temp sound file
                if os.path.exists(sound_tmp_path):
                    try: os.remove(sound_tmp_path)
                    except: pass
        else:
            print(f"[A_128 Mix] No added sound detected. Skipping audio mixing.")
    
        # V15: Dynamic Backend Resolver [Docker-Aware Service Discovery]
        backend_ip = "127.0.0.1"
        if IS_DOCKER:
            # In Production Docker, containers talk via service names
            backend_ip = "backend_node"
        elif (os.path.exists('/.dockerenv') or os.environ.get('KUBERNETES_SERVICE_HOST')):
            backend_ip = "host.docker.internal"

        # --- Sovereign V15: AI Content Guard Injection [Phase 9 & 11] ---
        print(f"[A_125 Guard] AI Neural Scan INITIATED: {filename}")
        try:
            scan_res = requests.post(
                f"http://{backend_ip}:5000/api/ai/scan",
                json={"file_path": save_path, "user_id": uploader},
                timeout=10
            )
            if scan_res.status_code == 200:
                scan_data = scan_res.json()
                if scan_data.get("status") == "REJECTED":
                    print(f"[A_125 Guard] ❌ REJECTED: {scan_data.get('reason')}")
                    # Purge suspicious content
                    if os.path.exists(save_path): os.remove(save_path)
                    if os.path.exists(thumb_path): os.remove(thumb_path)
                    if os.path.exists(sound_path): os.remove(sound_path)
                    return # Terminate registration
                else:
                    print(f"[A_125 Guard] ✅ SAFE: Neural signature verified.")
        except Exception as e:
            print(f"[A_125 Guard] ⚠ Scan Failure (Bypass Mode): {e}")

        try:
            sync_url = f"http://{backend_ip}:5000/api/v15/register_media"
            print(f"[Uplink Hub] SYNCING TO BACKEND: {sync_url} | Uploader: {uploader}")
            
            reg_response = requests.post(
                sync_url,
                json={
                    "file": filename,
                    "uploader": uploader,
                    "desc": description,
                    "thumbnail": thumb_name,
                    "sound": sound_name,
                    "sound_status": sound_status,
                    "sound_name": requested_sound_name,
                    "sound_url": requested_sound_url,
                    "original_volume": original_vol,
                    "added_sound_volume": added_vol,
                    "location": os.getenv("SOVEREIGN_ZONE", "GLOBAL"),
                    "hls_ready": hls_ready # Phase 2.1 Sync
                },
                timeout=10
            )
            if reg_response.status_code == 200:
                print(f"[Uplink Hub] ✅ BACKEND SYNC SUCCESSFUL: {filename}")
            else:
                print(f"[Uplink Hub] ❌ BACKEND SYNC FAILED [{reg_response.status_code}]: {reg_response.text}")
        except Exception as e:
            print(f"Backend Sync Warning (CRITICAL_GAP): {e}")

        # V15 Gap Fix S4: Register Original Sound with Sound Loop API
        # Only register if: (a) audio was extracted successfully, and (b) user used their own "Original Sound" or no pre-selected sound
        is_original_sound = (not requested_sound_url) or requested_sound_name == f"Original Sound - {uploader}" or requested_sound_name == "Add sound"
        if sound_status == "SAFE" and is_original_sound and os.path.exists(sound_path):
            try:
                sound_loop_host = os.getenv("SOUND_LOOP_HOST", "127.0.0.1")
                # Copy extracted audio to Sound Loop vault for independent serving
                sound_vault_dir = os.getenv("SOUND_VAULT_DIR", r"C:\Users\Admin\server 17226")
                if os.path.exists(sound_vault_dir):
                    import shutil
                    dest_sound = os.path.join(sound_vault_dir, sound_name)
                    if not os.path.exists(dest_sound):
                        shutil.copy2(sound_path, dest_sound)
                        print(f"[A_128] Sound copied to Sound Vault: {sound_name}")

                # Register in Sound Loop ledger via API
                with open(sound_path, 'rb') as sf:
                    reg_response = requests.post(
                        f"http://{sound_loop_host}:9900/register_original",
                        files={"file": (sound_name, sf, "audio/mpeg")},
                        data={
                            "title": f"Original Sound - {uploader}",
                            "artist": uploader,
                            "uploader": uploader,
                        },
                        timeout=5
                    )
                    if reg_response.status_code == 200:
                        reg_data = reg_response.json()
                        print(f"[A_128] Sound Registered in Loop: {reg_data.get('status')} -> {sound_name}")
                    else:
                        print(f"[A_128] Sound Loop Registration Failed: {reg_response.status_code}")
            except Exception as e:
                print(f"[A_128] Sound Loop Sync Warning: {e}")

        # V15 Gap Fix S5: Track Sound Usage [TikTok Trending DNA]
        if is_added_sound and requested_sound_url:
            try:
                # Extract sound ID from URL (e.g., /stream/s_xxxx.mp3)
                import re
                m_sid = re.search(r'(s_[a-f0-9]+)', requested_sound_url)
                if m_sid:
                    track_sid = m_sid.group(1)
                    sound_loop_host = os.getenv("SOUND_LOOP_HOST", "127.0.0.1")
                    requests.post(
                        f"http://{sound_loop_host}:9900/track_usage",
                        params={"s_id": track_sid, "v_id": filename},
                        timeout=3
                    )
                    print(f"[A_108] Sound Usage Tracked: {track_sid} for video {filename}")
            except Exception as e:
                print(f"[A_108] Sound Tracking Warning: {e}")

    threading.Thread(target=process_async_mixing).start()

    response = jsonify({
        "status": "UPLOAD_SUCCESS",
        "file": filename,
        "vault_path": save_path,
        "msg": "V15 Processor notified & Video Processing Async"
    })
    response.headers.add("Access-Control-Allow-Origin", "*")
    return response

@app.route('/latest')
def get_latest_video():
    vault_path = get_vault_path()
    mp4_files = [f for f in os.listdir(vault_path) if f.endswith('.mp4')]
    if not mp4_files:
        return jsonify({"error": "No videos found"}), 404
    
    # Sort by modification time to get the freshest upload
    latest_file = max(mp4_files, key=lambda x: os.path.getmtime(os.path.join(vault_path, x)))
    return jsonify({"file": latest_file, "url": f"http://{SOVEREIGN_HOST}:8080/stream/{latest_file}"})

if __name__ == '__main__':
    print(f"Sovereign Uplink Server: UPLOAD GATEWAY ACTIVE [V15]")
    print(f"VAULT_HUB: {os.path.abspath(get_vault_path())}")
    app.run(host='0.0.0.0', port=8080, threaded=True)

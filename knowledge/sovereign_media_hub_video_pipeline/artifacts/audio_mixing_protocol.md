# Sovereign V15 Audio Mixing & Neural Sound Hub Logic

## 1. Neural Audio Mixing Protocol (A_128)

The mixing logic resides in the `processor_engine.py` and is designed to mimic TikTok's professional audio handling. It uses a **High-Context Mixing Strategy** to avoid FFmpeg stream collisions.

### Key Strategies

* **REPLACEMENT (Force 100% Added):** Triggered when `original_volume <= 0.01`. It surgically removes the original audio stream and injects the added sound. This prevents "silent amix" errors.
* **ORIGINAL_ONLY:** Triggered when `added_vol <= 0.01`. It simply adjusts the volume of the original track.
* **NEURAL_AMIX (TikTok DNA):** Loops the added sound (`-stream_loop -1`) to match the video duration and mixes it with the original audio using a smoothed dropout transition (`dropout_transition=2`).

### Atomic Overwrite Protocol

To ensure absolute compatibility with Flutter's `video_player` (which often plays raw MP4s), the processor now:

1. Processes the video and creates a `_merged.mp4`.
2. **Surgically Overwrites** the original `.mp4` file with the merged version.
3. This ensures that whether a user plays the raw file or the HLS shards, the mixed audio is preserved.

---

## 2. Sound Master Hub (A_108)

The Sound Master Hub is a standalone Docker service (`Sovereign_Sound_Loop`) that serves as the central vault for all audio assets.

### Universal Sound Resolver (Flutter)

The `MainNavigation` in Flutter uses a dual-priority resolution logic:

1. **Priority 1: Global Sound Registry** (Studio/Vault Tracks). Fetches from `http://localhost:8000/all`.
2. **Priority 2: Mesh Ledger** (Harvested Original Sounds). Resolves sounds extracted from user-uploaded videos.

### Semantic Sound Normalization

When a user uploads a video without selecting a manual sound, the `uplink_server.py` automatically aliases the audio as:
`Original Sound - [UploaderMeshID]`
This sound is then federated to the global sound registry, making it searchable for other creators.

---

## 3. Metadata State Synchronization

The system uses a **JSON Sidecar Protocol** to pass instructions from the UI to the background engines:

* `filename.mp4.json` contains the mix levels (`original_volume`, `added_sound_volume`) and the source `sound_url`.
* The `processor_engine.py` waits for this file before starting the audio-reactive pulse.

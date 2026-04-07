# Sovereign Media Hub: Video Pipeline & Sharding System [V15 Pro Standard]

## Overview

This Knowledge Item (KI) documents the end-to-end video upload, processing, and playback architecture. In V15 Pro, we have integrated a high-fidelity **Neural Audio Mixer** and an **Atomic Overwrite** protocol to ensure 100% audio compatibility across all feed types (HLS and raw MP4).

## Key Components

1. **Uplink Server (`uplink_server.py`)**:
   - Port: 8080
   - Function: Entry point for files. Extracts the original audio from uploaded videos to create a new "Harvested" sound asset.
   - **Normalize Logic**: Automatically converts "Add sound" labels to "Original Sound - @[User]" metadata.

2. **Neural Processor Engine (`processor_engine.py`)**:
   - Function: Multi-vault asset resolution.
   - **A_128 Audio Mixing**: Implements three strategies (Replacement, Original-Only, Neural Amix) based on user-defined volume sliders.
   - **Atomic Overwrite**: Instead of keeping merged files separate, it replaces the original `.mp4` with the audio-mixed version to guarantee audio on raw playback.

3. **Sound Master Hub (`Sovereign_Sound_Loop`)**:
   - Port: 8000
   - Function: Global asset repository. Serving audio files and maintaining the usage ledger for the "Sound Detail" screens.

4. **Quantum Post Hub (Flutter/Dart)**:
   - **Neural Lock**: Captures `sound_name` and `sound_url` state before the upload pulse to prevent race conditions.
   - **Direct Hub Link**: Tapping the sound bar opens the full Global Sound Hub with real-time vault syncing.

## Communication & Mixing Flow

1. **User Panel** -> POST `upload` (Includes MP4 + Mixing Metadata).
2. **Uplink Server** -> saves `vault/data/{file}.mp4` AND `{file}.mp4.json`.
3. **Processor Engine** -> Wakes on `.mp4`, waits for `.json`.
4. **Resolution** -> Locates sound in either Local Vault or Global Sound Hub.
5. **Mixing** -> Runs FFmpeg with `amix` or `replacement` logic.
6. **Persistence** -> Overwrites original `.mp4` with mixed version -> Generates HLS Shards.
7. **Broadcast** -> Backend notifies all panels that content is live.

## V15 Pro Audio Standards

- **Sample Rate**: 44100Hz (Resampled during mix for compatibility).
- **Encoder**: AAC (libfdk_aac or native aac).
- **Fade Logic**: Auto 2s fade-out at the end of every video.

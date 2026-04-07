from fastapi import FastAPI
import redis
import json
import os

app = FastAPI()
# Using redis as a shared state for persistent tracking [V15 Standard]
r = redis.Redis(host='redis', port=6379, decode_responses=True)

@app.post("/update_weights")
async def update_weights(l: int, c: int, s: int):
    r.set("like_weight", l)
    r.set("comment_weight", c)
    r.set("share_weight", s)
    return {"status": "success", "weights": {"L": l, "C": c, "S": s}}

@app.post("/track")
async def track_interaction(c_id: str, act: str, ip: str = "127.0.0.1"):
    # Atomically increment the count for this content's specific action
    key = f"stats:{c_id}:{act}"
    new_val = r.incr(key)
    
    # Global Total for this content (Generic counter)
    r.incr(f"stats:{c_id}:total")
    
    return {"status": "tracked", "content": c_id, "action": act, "new_count": new_val}

@app.get("/counts")
async def get_counts(c_id: str):
    # Fetch all interaction types for this content
    likes = int(r.get(f"stats:{c_id}:like") or 0)
    comments = int(r.get(f"stats:{c_id}:comment") or 0)
    shares = int(r.get(f"stats:{c_id}:share") or 0)
    views = int(r.get(f"stats:{c_id}:view") or 0)
    
    return {
        "content_id": c_id,
        "likes": likes,
        "comments": comments,
        "shares": shares,
        "views": views
    }

@app.get("/")
async def root():
    return {"module": "Sovereign Impression Engine", "status": "online"}

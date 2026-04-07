from fastapi import FastAPI
import redis
import os

app = FastAPI()
# Dockerized redis host
r = redis.Redis(host='redis', port=6379, decode_responses=True)

# A_111: Sponsor Revenue Tracking
@app.post("/add_coins")
async def add_coins(amount: int):
    # Atomic increment of admin revenue
    new_bal = r.incrby("admin_coins_balance", amount)
    return {"status": "success", "added": amount, "new_balance": new_bal}

@app.get("/stats")
async def get_stats():
    # Fetch all sponsor system metrics
    admin_coins = r.get("admin_coins_balance")
    if admin_coins is None:
        # Initialize with V15 Default if empty
        r.set("admin_coins_balance", 12450)
        admin_coins = 12450
    
    return {
        "admin_coins": int(admin_coins),
        "active_templates": 5, # Simulated for UI
        "total_reach": "1.2M",
        "moderation_status": "OPTIMAL"
    }

@app.post("/view_check")
async def view_check(v_id: str):
    r.incr(f"video_views:{v_id}")
    return {"status": "view_accounted", "v_id": v_id}

@app.get("/")
async def root():
    return {"module": "Sovereign Sponsor System", "status": "online"}

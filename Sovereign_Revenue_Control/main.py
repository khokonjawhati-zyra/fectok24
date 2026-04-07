from fastapi import FastAPI
import redis
import os

app = FastAPI()
r = redis.Redis(host='redis', port=6379, decode_responses=True)

@app.post("/update_shares")
async def update_shares(p: int, c: int, u: int):
    r.set("platform_share", p)
    r.set("creator_share", c)
    r.set("user_share", u)
    return {"status": "success", "shares": {"Platform": p, "Creator": c, "User": u}}

@app.get("/")
async def root():
    return {"module": "Sovereign Revenue Control", "status": "online"}

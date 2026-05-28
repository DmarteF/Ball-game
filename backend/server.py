from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import datetime
import os
from dotenv import load_dotenv
from bson import ObjectId

load_dotenv()

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB
MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")
client = AsyncIOMotorClient(MONGO_URL)
db = client.neon_idle_game

# Models
class Player(BaseModel):
    playerId: str
    coins: int = 0
    gems: int = 0
    currentPhase: int = 1
    unlockedPhases: List[int] = [1]
    permanentUpgrades: Dict[str, int] = {}
    ballTransformation: str = "neon_blue"
    stats: Dict[str, float] = {
        "baseDamage": 10.0,
        "baseSpeed": 100.0,
        "critChance": 5.0,
        "critMultiplier": 2.0,
        "coinMultiplier": 1.0,
        "xpMultiplier": 1.0
    }
    createdAt: datetime = Field(default_factory=datetime.utcnow)
    lastPlayed: datetime = Field(default_factory=datetime.utcnow)

class GameSession(BaseModel):
    playerId: str
    phase: int
    currentXP: int = 0
    level: int = 1
    temporaryUpgrades: List[str] = []
    score: int = 0
    coinsEarned: int = 0
    startedAt: datetime = Field(default_factory=datetime.utcnow)

class AdReward(BaseModel):
    playerId: str
    adType: str
    rewardType: str
    rewardAmount: int

# Endpoints
@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "Neon Idle Game API"}

@app.post("/api/player/create")
async def create_player(player: Player):
    player_dict = player.model_dump()
    result = await db.players.insert_one(player_dict)
    player_dict["_id"] = str(result.inserted_id)
    return player_dict

@app.get("/api/player/{player_id}")
async def get_player(player_id: str):
    player = await db.players.find_one({"playerId": player_id})
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    player["_id"] = str(player["_id"])
    return player

@app.put("/api/player/{player_id}/update")
async def update_player(player_id: str, updates: dict):
    updates["lastPlayed"] = datetime.utcnow()
    result = await db.players.update_one(
        {"playerId": player_id},
        {"$set": updates}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Player not found")
    return {"success": True, "message": "Player updated"}

@app.get("/api/phases")
async def get_phases():
    phases = [
        {
            "id": 1,
            "name": "Arena Circular Neon",
            "description": "Uma arena circular com obstáculos rotativos",
            "difficulty": "easy",
            "color": "#00f0ff",
            "shape": "circle",
            "targetHP": 100,
            "requiredPhase": 0
        },
        {
            "id": 2,
            "name": "Labirinto Hexagonal",
            "description": "Labirinto hexagonal com paredes móveis",
            "difficulty": "medium",
            "color": "#b000ff",
            "shape": "hexagon",
            "targetHP": 250,
            "requiredPhase": 1
        },
        {
            "id": 3,
            "name": "Núcleo Tecnológico",
            "description": "Núcleo quadrado com obstáculos tecnológicos",
            "difficulty": "medium-hard",
            "color": "#00ff88",
            "shape": "square",
            "targetHP": 500,
            "requiredPhase": 2
        },
        {
            "id": 4,
            "name": "Dimensão Glitch",
            "description": "Dimensão instável com forma irregular",
            "difficulty": "hard",
            "color": "#ff0055",
            "shape": "irregular",
            "targetHP": 1000,
            "requiredPhase": 3
        },
        {
            "id": 5,
            "name": "Reactor Cósmico",
            "description": "Reactor com múltiplos anéis concêntricos",
            "difficulty": "very-hard",
            "color": "#ffd700",
            "shape": "multi-ring",
            "targetHP": 2000,
            "requiredPhase": 4
        }
    ]
    return phases

@app.post("/api/session/start")
async def start_session(session: GameSession):
    session_dict = session.model_dump()
    result = await db.sessions.insert_one(session_dict)
    session_dict["_id"] = str(result.inserted_id)
    return session_dict

@app.put("/api/session/{session_id}/update")
async def update_session(session_id: str, updates: dict):
    result = await db.sessions.update_one(
        {"_id": ObjectId(session_id)},
        {"$set": updates}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Session not found")
    return {"success": True, "message": "Session updated"}

@app.post("/api/ads/reward")
async def claim_ad_reward(reward: AdReward):
    # Simulated ad reward
    player = await db.players.find_one({"playerId": reward.playerId})
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    
    update_field = "coins" if reward.rewardType == "coins" else "gems"
    await db.players.update_one(
        {"playerId": reward.playerId},
        {"$inc": {update_field: reward.rewardAmount}}
    )
    
    return {
        "success": True,
        "message": f"Reward claimed: {reward.rewardAmount} {reward.rewardType}"
    }

@app.post("/api/player/{player_id}/unlock-phase")
async def unlock_phase(player_id: str, phase_id: int):
    result = await db.players.update_one(
        {"playerId": player_id},
        {"$addToSet": {"unlockedPhases": phase_id}}
    )
    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Player not found")
    return {"success": True, "message": f"Phase {phase_id} unlocked"}

@app.post("/api/player/{player_id}/purchase-upgrade")
async def purchase_upgrade(player_id: str, upgrade_name: str, cost: int):
    player = await db.players.find_one({"playerId": player_id})
    if not player:
        raise HTTPException(status_code=404, detail="Player not found")
    
    if player["coins"] < cost:
        raise HTTPException(status_code=400, detail="Not enough coins")
    
    current_level = player["permanentUpgrades"].get(upgrade_name, 0)
    
    await db.players.update_one(
        {"playerId": player_id},
        {
            "$inc": {"coins": -cost},
            "$set": {f"permanentUpgrades.{upgrade_name}": current_level + 1}
        }
    )
    
    return {
        "success": True,
        "message": f"Upgrade purchased: {upgrade_name}",
        "newLevel": current_level + 1
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)

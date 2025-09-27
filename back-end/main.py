import os
from dotenv import load_dotenv
from fastapi import FastAPI, APIRouter

load_dotenv()

from database import db

app = FastAPI(
    title="CarbonFootPrinters Backend",
    version="1.0.0"
)

router_v1 = APIRouter(prefix="/v1")

@app.get("/")
def read_root():
    """Simple health check endpoint."""
    return {"message": "Welcome to the CarbonFootPrinters API!", "status": "online"}

@app.get("/users/{user_id}")
async def get_user_info(user_id: str):
    if not db:
        return {"error": "Database connection is not available."}
    
    try:
        doc_ref = db.collection("users").document(user_id)
        doc = doc_ref.get()
        if doc.exists:
            return {"user_id": user_id, "data": doc.to_dict()}
        else:
            return {"user_id": user_id, "data": "User not found"}
    except Exception as e:
        return {"error": f"An error occured: {e}"}

import os

from dotenv import load_dotenv
#loading environment variables
load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

import firebase_admin
from firebase_admin import credentials, firestore
#firebase initialize
CREDENTIALS_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH")

if CREDENTIALS_PATH and not firebase_admin._apps:
    try:
        cred = credentials.Certificate(CREDENTIALS_PATH)
        firebase_admin.initialize_app(cred)
        #reusable client object for Firestore
        db = firestore.client()
        print('Firebase Admin SDK initialized successfully.')
    except Exception as e:
        print(f"Could not initialize firebase. Error: {e}")
        exit(1)
else:
    print("firebase already initialized or credentials missing from .env")

from fastapi import FastAPI
#fastAPI setup
app = FastAPI(
    title="CarbonFootPrinters Backend",
    version="1.0.0"
)

@app.get("/")
def read_root():
    """Simple health check endpoint."""
    return {"message": "Welcome to the CarbonFootPrinters API!", "status": "online"}

@app.get("/users/{user_id}")
async def get_user_info(user_id: str):
    try:
        doc_ref = db.collection("users").document(user_id)
        doc = doc_ref.get()
        if doc.exists:
            return {"user_id": user_id, "data": doc.to_dict()}
        else:
            return {"user_id": user_id, "data": "User not found"}
    except Exception as e:
        return {"error": f"An error occured: {e}"}

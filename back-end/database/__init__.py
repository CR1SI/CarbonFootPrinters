import os
from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore

load_dotenv()

CREDENTIALS_PATH = os.getenv("FIREBASE_CREDENTIALS_PATH")

db = None

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

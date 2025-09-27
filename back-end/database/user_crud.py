import firebase_admin
from firebase_admin import firestore
from . import db

USERS_COLLECTION = "users"

def get_user(user_id: str) -> dict or None:
    """
    Retrieves a user document from Firestore by user_id.
    Args:
        user_id: The ID of the user document to retrieve.
    Returns:
        The user data dictionary if the document exists, otherwise None.
    """
    if not db:
        print("Error: Database connection not established.")
        return None
    
    try:
        doc_ref = db.collection(USERS_COLLECTION).document(user_id)
        doc = doc_ref.get()

        if doc.exists:
            return {"id": doc.id, **doc.to_dict()}
        else:
            return None
    except Exception as e:
        print(f"Error reading user {user_id}: {e}")
        return None

def create_user(user_id: str, data: dict) -> bool:
    """
    Creates or overwrites a user document in Firestore.
    Args:
        user_id: The ID for the new user document.
        data: A dictionary containing the user data (e.g., first_name, email).
    Returns:
        True if the operation was successful, False otherwise.
    """
    if not db:
        print("Error: Database connection not established.")
        return False
    
    try:
        doc_ref = db.collection(USERS_COLLECTION).document(user_id)
        doc_ref.set(data)
        print(f"Successfully created/updated user: {user_id}")
        return True
    except Exception as e:
        print(f"Error creating user {user_id}: {e}")
        return False

def update_user(user_id: str, data: dict) -> bool:
    """
    Updates specific fields in an existing user document.
    Note: Uses set(..., merge=True) to update without overwriting the entire document.
    Args:
        user_id: The ID of the user document to update.
        data: A dictionary containing the fields and values to update.
    Returns:
        True if the operation was successful, False otherwise.
    """
    if not db:
        print("Error: Database connection not established.")
        return False
    try:
        doc_ref = db.collection(USERS_COLLECTION).document(user_id)
        doc_ref.set(data, merge=True)
        print(f"Successfully updated user: {user_id}")
        return True
    except Exception as e:
        print(f"Error updating user {user_id}: {e}")
        return False

def delete_user(user_id: str) -> bool:
    """
    Deletes a user document from Firestore.
    Args:
        user_id: The ID of the user document to delete.
    Returns:
        True if the operation was successful, False otherwise.
    """
    if not db:
        print("Error: Database connection not established.")
        return False
    try:
        doc_ref = db.collection(USERS_COLLECTION).document(user_id)
        doc_ref.delete()
        print(f"Successfully deleted user: {user_id}")
        return True
    except Exception as e:
        print(f"Error deleting user {user_id}: {e}")
        return False
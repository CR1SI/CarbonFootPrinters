import os
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from uuid import uuid4

load_dotenv()

from database import user_crud

app = FastAPI(
    title="CarbonFootPrinters Backend",
    version="1.0.0"
)

@app.get("/")
def read_root():
    """Simple health check endpoint."""
    return {"message": "Welcome to the CarbonFootPrinters API!", "status": "online"}

#pydantic model
class User(BaseModel):
    name:str
    email:str
    password:str
    pfp:int = 0
    country:str
    transportation:str
    carbonEmission:float = 0.0
    user_id: str = Field(default_factory = lambda: uuid4().hex)
    notiFlag:bool = False

#endpoints
@app.post("/users/")
async def create_user(user: User):
    try:
        success = user_crud.create_user(user.user_id, user.dict())
        if success:
            return {"message": "User created successfully", "user": user.dict()}
        raise HTTPException(status_code=500, detail="Failed to create user")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@app.get("/users/{user_id}")
async def get_user_info(user_id: str):
    try:
        user = user_crud.get_user(user_id)
        if user:
            return user
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        return {"error": f"An error occurred: {e}"}

@app.put("/users/{user_id}")
async def update_user_info(user_id: str, update_data: dict):
    """
    Update user fields. Example body:
    {
      "name": "New Name",
      "country": "New Country"
    }
    """
    try:
        success = user_crud.update_user(user_id, update_data)
        if success:
            return {"message": "User updated successfully"}
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")

@app.delete("/users/{user_id}")
async def delete_user_info(user_id: str):
    try:
        success = user_crud.delete_user(user_id)
        if success:
            return {"message": "User deleted successfully"}
        raise HTTPException(status_code=404, detail="User not found")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")


#local test
testUser = User(
    name="Kyle",
    email="kyle@gmail.com",
    password="12344",
    pfp=2,
    country="Brazil",
    transportation="Eletric",
)


# Create user
print("---- Creating user ----")
created = user_crud.create_user(testUser.user_id, testUser.dict())
print("Created:", created)

# Get user
print("---- Getting user ----")
fetched = user_crud.get_user(testUser.user_id)
print("Fetched:", fetched)

# Update user
print("---- Updating user ----")
update_data = {"country": "Argentina", "notiFlag": True}
updated = user_crud.update_user(testUser.user_id, update_data)
print("Updated:", updated)

# Get updated user
print("---- Getting updated user ----")
fetched_updated = user_crud.get_user(testUser.user_id)
print("Fetched after update:", fetched_updated)

# Delete user
print("---- deleting ----")
delete = user_crud.delete_user(testUser.user_id)
print("Deleted:", delete)

# Try fetching again
print("---- Getting user after delete ----")
fetched_after_delete = user_crud.get_user(testUser.user_id)
print("Fetched after delete:", fetched_after_delete)

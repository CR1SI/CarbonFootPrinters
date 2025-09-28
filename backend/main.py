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
# testUser = User(
#     name="Kyle",
#     email="kyle@gmail.com",
#     password="12344",
#     pfp=2,
#     country="Brazil",
#     transportation="Eletric",
# )


# # Create user
# print("---- Creating user ----")
# created = user_crud.create_user(testUser.user_id, testUser.dict())
# print("Created:", created)

# # Get user
# print("---- Getting user ----")
# fetched = user_crud.get_user(testUser.user_id)
# print("Fetched:", fetched)

# # Update user
# print("---- Updating user ----")
# update_data = {"country": "Argentina", "notiFlag": True}
# updated = user_crud.update_user(testUser.user_id, update_data)
# print("Updated:", updated)

# # Get updated user
# print("---- Getting updated user ----")
# fetched_updated = user_crud.get_user(testUser.user_id)
# print("Fetched after update:", fetched_updated)

# # Delete user
# print("---- deleting ----")
# delete = user_crud.delete_user(testUser.user_id)
# print("Deleted:", delete)

# # Try fetching again
# print("---- Getting user after delete ----")
# fetched_after_delete = user_crud.get_user(testUser.user_id)
# print("Fetched after delete:", fetched_after_delete)
import os
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from uuid import uuid4

load_dotenv()

from database import user_crud

from services.emission_service import EmissionService

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
    
@app.get("/users/{user_id}/movements")
async def get_user_movements(user_id: str):
    try:
        movements = user_crud.get_user_movements(user_id)
        if not movements:
            return {"message": "No movement points found", "movements": []}
        return {"movements": movements}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")


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

@app.post("/users/{user_id}/emissions/add")
async def add_user_emissions(user_id: str, emission: float):
    try:
        # Fetch current user
        user = user_crud.get_user(user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        current_emission = user.get("carbonEmission", 0.0)
        new_emission = current_emission + emission

        success = user_crud.update_user(user_id, {"carbonEmission": new_emission})
        if success:
            return {"message": f"Added {emission} kg CO₂. Total is now {new_emission} kg."}
        raise HTTPException(status_code=500, detail="Failed to update emissions")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"An error occurred: {e}")
    

@app.post("/users/{user_id}/calculate_emission")
async def calculate_user_emission(user_id: str, input_data: dict):
    """
    Calculate CO2 emissions for a user and update their Firebase record.
    input_data should contain whatever the agent expects (e.g. activity_id, amount).
    """
    try:
        updated_user = EmissionService.calculate_and_store_emission(user_id, input_data)
        return {
            "message": "Carbon emission calculated and stored successfully",
            "user": updated_user
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {e}")
    
@app.post("/admin/recalculate_all_emissions")
async def recalculate_all_emissions():
    try:
        updated_users = EmissionService.recalculate_all_users()
        return {
            "message": f"Recalculated emissions for {len(updated_users)} users.",
            "users": updated_users
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch error: {e}")




#local test
# testUser = User(
#     name="Kyle",
#     email="kyle@gmail.com",
#     password="12344",
#     pfp=2,
#     country="Brazil",
#     transportation="Eletric",
# )


# # Create user
# print("---- Creating user ----")
# created = user_crud.create_user(testUser.user_id, testUser.dict())
# print("Created:", created)

# # Get user
# print("---- Getting user ----")
# fetched = user_crud.get_user(testUser.user_id)
# print("Fetched:", fetched)

# # Update user
# print("---- Updating user ----")
# update_data = {"country": "Argentina", "notiFlag": True}
# updated = user_crud.update_user(testUser.user_id, update_data)
# print("Updated:", updated)

# # Get updated user
# print("---- Getting updated user ----")
# fetched_updated = user_crud.get_user(testUser.user_id)
# print("Fetched after update:", fetched_updated)

# # Delete user
# print("---- deleting ----")
# delete = user_crud.delete_user(testUser.user_id)
# print("Deleted:", delete)

# # Try fetching again
# print("---- Getting user after delete ----")
# fetched_after_delete = user_crud.get_user(testUser.user_id)
# print("Fetched after delete:", fetched_after_delete)


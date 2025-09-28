# services/emission_service.py

from agents.co2_agent import co2_agent   # your agent
from database import user_crud           # your Firebase CRUD

class EmissionService:
    @staticmethod
    def calculate_and_store_emission(user_id: str, input_data: dict) -> dict:


        """
        Runs the CO2 agent, extracts emission, and stores it in Firebase for the given user.
        """
        # 1. Run the agent with input_data
        agent_output = co2_agent.run(input_data)  # depends how your agent is invoked
        # Example return: {"carbon_emission_kg": 120.5, "activity_id": "...", "amount": 500}

        if "carbon_emission_kg" not in agent_output:
            raise ValueError("Agent did not return carbon_emission_kg")

        emission_value = agent_output["carbon_emission_kg"]

        # 2. Update user in Firebase
        success = user_crud.update_user(user_id, {"carbonEmission": emission_value})

        if not success:
            raise RuntimeError(f"Failed to update user {user_id} in Firebase")

        # 3. Return the final updated user record
        updated_user = user_crud.get_user(user_id)
        return updated_user

    @staticmethod
    def recalculate_all_users():
        """
        Go through all users in Firebase and recalculate emissions for each.
        """
        users = user_crud.get_all_users()
        updated_users = []

        for user in users:
            try:
                user_id = user["user_id"]
                # Send the fields your agent expects
                input_data = {
                    "transportation": user.get("transportation"),
                    "country": user.get("country"),
                    "amount": user.get("amount", 0)  # or whatever your model uses
                }
                updated = EmissionService.calculate_and_store_emission(user_id, input_data)
                updated_users.append(updated)
            except Exception as e:
                print(f"Error recalculating emissions for {user['user_id']}: {e}")

        return updated_users
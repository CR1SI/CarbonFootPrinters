from google.adk.agents import Agent
from backend.database import user_crud

root_agent = Agent(
    name="notification_agent",
    model="gemini-2.0-flash",
    description="Gathers user CO2 emission data",
    instruction="""
    You are the notification agent who gather data and organizes it.
    2. with the input get back only the time created and the co2 emission
    3. add to the database the session with the information retrieved and organize it so more sessions can be made later on and added.

    you have access to the tools:
    - user_crud functions: get_user, create_user, update_user, delete_user

    and you have the subagent coach_agent under you
    """,
    tools=[
        user_crud.get_user,
        user_crud.create_user,
        user_crud.update_user,
        user_crud.delete_user,
    ],
)


from google.adk.agents import Agent
from google.adk.sessions import InMemorySessionService
from database import user_crud
from .. import coach_agent

session_service = InMemorySessionService()

# create new session tool
def create_session(user_id: str):
    """Create an in-memory session for a given user id and return session metadata."""
    return session_service.create_session(user_id)


root_agent = Agent(
    name="notification_agent",
    model="gemini-2.0-flash",
    description="Gathers user CO2 emission data",
    instruction="""
    You are the notification agent who gather data and organizes it.
    1. Start a new session with one of your tools
    2. with the input get back only the time created and the co2 emission
    3. add to the database the session with the information retrieved and organize it so more sessions can be made later on and added.
    4. Call your sub agent to push a notification to the user.

    you have access to the tools:
    - create_session(user_id)
    - user_crud functions: get_user, create_user, update_user, delete_user

    and you have the subagent coach_agent under you
    """,
    tools=[
        create_session,
        user_crud.get_user,
        user_crud.create_user,
        user_crud.update_user,
        user_crud.delete_user,
    ],
    sub_agents=[coach_agent.agent.root_agent],
)


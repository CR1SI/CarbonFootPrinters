from google.adk.agents import Agent
from ...database import user_crud


root_agent = Agent(
    name="coach_agent",
    model="gemini-2.0-flash",
    description="Co2 emission coach agent",
    instruction="""
    You are a Co2 coach.
    You will look at input and based on previous saved co2 emission and time created in the database you will create a timeline.
    your tools are as follow:
    - user_crud functions: get_user, create_user, update_user, delete_user
    based on the timeline you will return a helpful tip or coach like response return a string with under 50 characters.
    """,
    tools=[
        user_crud.get_user,
        user_crud.create_user,
        user_crud.update_user,
        user_crud.delete_user,
    ],

)
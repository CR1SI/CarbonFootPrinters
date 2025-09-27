from google.adk.agents import Agent

root_agent = Agent(
    name="coach_agent",
    model="gemini-2.0-flash",
    description="Co2 emission coach agent",
    instruction="""
    You are a Co2 coach. 
    Your job is to send helpful messages based on user data from your tool.
    make sure your also save 
    """

)
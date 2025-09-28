from google.adk.agents import Agent, ParallelAgent

from pydantic import BaseModel
import json
from typing import List, Optional

class Transaction(BaseModel):
    date: str
    amount: float
    merchant_name: Optional[str] = None
    category: Optional[List[str]] = None

def getJSON():
    with open("./back-end/testUserTransactions.json", "r") as f:
        return json.load(f)
    
def verify_transactions():
    """
    Load JSON, validate against the Transaction model,
    and drop any fields that are not in the model.
    """
    raw_data = getJSON()
    cleaned_data = [Transaction(**txn).dict() for txn in raw_data["transactions"]]
    return cleaned_data


verification_bank_agent = Agent(
    name="verification_bank_agent",
    model="gemini-2.0-flash",
    description="Agent that verifies and sorts banking transaction data",
    instruction="""
    Only return data that matches the Transaction schema: 
    {date, amount, merchant_name, category}.""",
    tools= [verify_transactions]
)


bank_transaction_agent = Agent(
    name = "bank_transaction_agent",
    model="gemini-2.0-flash",
    description = "Agent that retrieves data from a JSON file",
    instruction="""
    You retrieve raw JSON banking transactions from file and forward them
    to your sub-agent (verification_bank_agent) for cleaning.
    """,
    sub_agents= [verification_bank_agent],
    tools = [getJSON]
)

root_agent = ParallelAgent(
    name = "manager",
    sub_agents = [bank_transaction_agent],
    description = """
    The manager_agent is responsible for supervising two specialized sub_agents, the banker_agent and the location_agent.
    It receives user requests, determines whether the task requires financial actions, location-based actions, or both, and then delegates the work accordingly.
    When both sub-agents are needed, the manager executes them in parallel, waits for their responses, and combines the outputs into a single, coherent result before returning it to the user.
    This allows the manager to act as a decision-maker and coordinator, ensuring that requests are routed efficiently to the appropriate agents and that the user receives one unified response regardless of whether one or both sub-agents were used.
    """,
)
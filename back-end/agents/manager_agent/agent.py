from google.adk.agents import Agent, ParallelAgent
from google.adk.tools import google_search
import requests
import os
import asyncio

from pydantic import BaseModel
import json
from typing import List, Optional


import os
import json
import requests




# Example usage:
#result = call_climatiq_from_file("input.json")
#print(result)
co2_agent = Agent(
    name="carbon_emission_agent",
    model="gemini-2.0-flash",
    description="You are an agent that determines the carbon emission of a person using their given data.",
    instruction="""
    You are a carbon emissions estimation agent. 
Your job is to take structured JSON data about an activity (travel, energy use, or purchases) and return an estimated carbon emission in kilograms of CO₂ (carbon_emission_kg).

Rules:
1. Always return valid JSON with the original input plus the new key "carbon_emission_kg".
2. Base your estimates on widely known emission factors:
   - Flights: ~0.25 kg CO₂ per passenger-km (short-haul), ~0.15 kg CO₂ per passenger-km (long-haul).
   - Car travel: ~0.12 kg CO₂ per passenger-km (average gasoline car).
   - Public transit (bus/train): ~0.05 kg CO₂ per passenger-km.
   - Electricity: ~0.4 kg CO₂ per kWh (adjust if renewable).
   - Food:
     - Beef: ~27 kg CO₂ per kg.
     - Chicken: ~6.9 kg CO₂ per kg.
     - Vegetables/grains: ~2 kg CO₂ per kg.
   - Money-based purchases: assume ~0.5 kg CO₂ per $ spent unless specified.

3. If distance is given, multiply distance × emission factor.
4. If money spent is given, use the money factor.
5. If weight of food is given, use the food factor.
6. If information is missing, make a reasonable assumption and explain it in a field called "assumptions".
7. Do not return text explanations outside of the JSON — only return JSON.

Example input:
{
  "activity": "flight",
  "distance_km": 800,
  "class": "economy"
}

Example output:
{
  "activity": "flight",
  "distance_km": 800,
  "class": "economy",
  "carbon_emission_kg": 200,
}

    """,
)

class Transaction(BaseModel):
    date: str
    amount: float
    merchant_name: Optional[str] = None
    category: Optional[List[str]] = None
    
def verify_transactions():
    """
    Load JSON, validate against the Transaction model,
    and drop any fields that are not in the model.
    """
    raw_data = getJSON()
    cleaned_data = [Transaction(**txn).dict() for txn in raw_data["transactions"]]
    return cleaned_data


emission_type_agent = Agent(
    name="determines_emission_type",
    model="gemini-2.0-flash",
    description="You are an agent that determines the emission type of a purchase based on its category.",
    instruction="""
    Add a {activity_id: str} data value to the JSON and you have to determine it for each transaction based on its category. These are the options you can choose from. Make the value Null if none of them match:
    [transport_services-type_air_transport-basis_industry, accommodation-type_all_other_traveler_accommodation, consumer_services-type_mobile_food_services, health_care-type_pharmacies_and_drug_stores, general_retail-type_electronics_stores]
    Do not invent fields. Always include activity_id, 'Null' is not an option. Afterwards, always pass to your co2_agent for adding a new data type of the JSON. The events cannot end here under any circumstance, it must pass to your sub agent.
    """,
    sub_agents = [co2_agent]

)

verification_bank_agent = Agent(
    name="verification_bank_agent",
    model="gemini-2.0-flash",
    description="Agent that verifies and sorts banking transaction data",
    instruction="""
    Ensure transaction data strictly follows this schema:
    {date: str, amount: float, merchant_name: str, category: List[str]}.
    Always include category, even if 'Other'. Afterwards, always pass to your emission_type_agent for adding a new data type of the JSON.
    """,
    sub_agents= [emission_type_agent],
)


bank_transaction_agent = Agent(
    name = "bank_transaction_agent",
    model="gemini-2.0-flash",
    description = "Agent that retrieves data from a JSON file",
    instruction = """
    If categorization fails, do not return null.
Always return the closest match from: 
["Groceries", "Dining", "Transportation", "Entertainment", "Shopping", "Healthcare", "Bills & Utilities", "Other"].
Afterwards, always pass to your verification_bank_agent sub agent for cleaning up the JSON.
    """,
    sub_agents= [verification_bank_agent],
    
)

root_agent = ParallelAgent(
    name = "manager",
    sub_agents = [bank_transaction_agent],
    description = """
    The manager_agent is responsible for supervising two specialized sub_agents, the banker_agent and the location_agent.
    It receives user data, determines whether the data is financial related, location related, or both, and then delegates the work accordingly.
    When both sub-agents are needed, the manager executes them in parallel, waits for their responses, and combines the outputs into a single, coherent result before returning it to the user.
    This allows the manager to act as a decision-maker and coordinator, ensuring that requests are routed efficiently to the appropriate agents and that the user receives one unified response regardless of whether one or both sub-agents were used.
    """,
)
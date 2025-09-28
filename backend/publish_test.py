# backend/publish_test.py
import json
from google.cloud import pubsub_v1

PROJECT = "carbonfootprinters"
TOPIC = "pinger"       # not subscription; publish to topic
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT, TOPIC)

payload = {
  "fcm_token": "<device-fcm-token>",
  "event": {"saved_kg": 2.5, "summary": "You saved 2.5 kg CO2 today"},
  "title": "Daily Carbon Summary",
  "user_name": "Alex"
}

future = publisher.publish(topic_path, json.dumps(payload).encode("utf-8"))
print("Published message id:", future.result())
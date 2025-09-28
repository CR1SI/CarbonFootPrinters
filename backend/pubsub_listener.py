"""Minimal Pub/Sub -> ADK -> FCM listener.

This is a compact, single-file subscriber you can run locally. Use --dry-run
to test without installing or configuring firebase_admin.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def _local_format(payload: Dict[str, Any]) -> str:
    ev = payload.get("event", {}) if isinstance(payload.get("event"), dict) else payload
    saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
    user = payload.get("user_name") or ev.get("user_name") or "You"
    if saved is not None:
        return f"{user}: You saved {saved} kg CO2 today — great job!"
    summary = ev.get("summary") or ev.get("message")
    return (str(summary)[:200]) if summary else "New carbon report available — check the app."


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    try:
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            return _local_format(payload)

        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                result = method(payload)
                if hasattr(result, "__await__"):
                    import asyncio

                    result = asyncio.get_event_loop().run_until_complete(result)
                if isinstance(result, dict):
                    for k in ("text", "message", "result", "output"):
                        if k in result:
                            return str(result[k])[:200]
                    return str(result)[:200]
                return str(result)[:200]
        return _local_format(payload)
    except Exception:
        logger.exception("ADK invocation failed; falling back to local formatter")
        return _local_format(payload)


def send_fcm(token: str, title: str, body: str, dry_run: bool = False) -> str:
    if dry_run:
        logger.info("DRY RUN FCM -> token=%s title=%s body=%s", token, title, body)
        print(f"DRY RUN FCM -> token={token} title={title} body={body}")
        return "DRY_RUN"

    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
    except Exception:
        raise RuntimeError("firebase_admin is required to send FCM messages")

    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

    message = messaging.Message(token=token, notification=messaging.Notification(title=title, body=body))
    return messaging.send(message)


def handle_message(dry_run: bool):
    def _cb(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            payload = json.loads(message.data.decode("utf-8"))
        except Exception:
            logger.exception("Invalid message payload; acking")
            message.ack()
            return

        fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
        if not fcm_token:
            logger.warning("Missing fcm_token; acking message")
            message.ack()
            return

        text = try_run_adk_agent(payload)
        title = payload.get("title") or "Carbon Footprinter"

        try:
            send_fcm(fcm_token, title, text, dry_run=dry_run)
        except Exception:
            logger.exception("Failed to send FCM")
        finally:
            message.ack()

    return _cb


def run(subscription: str, dry_run: bool = False) -> None:
    client = pubsub_v1.SubscriberClient()
    callback = handle_message(dry_run)
    future = client.subscribe(subscription, callback=callback)
    logger.info("Subscribed to %s", subscription)
    try:
        future.result()
    except KeyboardInterrupt:
        logger.info("Stopping subscriber")
        future.cancel()
    except Exception:
        logger.exception("Subscriber error")
        future.cancel()


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("subscription", nargs="?", help="projects/PROJECT/subscriptions/SUB")
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not set and no arg provided")

    run(subscription, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
"""
Clean Pub/Sub -> ADK -> FCM listener implementation.

This file intentionally minimal: dry-run supported, firebase_admin lazy-imported.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    """Call in-repo ADK agent or fall back to a local formatter."""
    def local_format(p: Dict[str, Any]) -> str:
        ev = p.get("event", {}) if isinstance(p.get("event"), dict) else p
        saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
        user = p.get("user_name") or ev.get("user_name") or "You"
        if saved is not None:
            return f"{user}: You saved {saved} kg CO2 today — great job!"
        summary = ev.get("summary") or ev.get("message")
        return (str(summary)[:200]) if summary else "New carbon report available — check the app."

    try:
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            return local_format(payload)

        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                try:
                    result = method(payload)
                    if hasattr(result, "__await__"):
                        import asyncio

                        result = asyncio.get_event_loop().run_until_complete(result)
                    if isinstance(result, dict):
                        for k in ("text", "message", "result", "output"):
                            if k in result:
                                return str(result[k])[:200]
                        return str(result)[:200]
                    return str(result)[:200]
                except Exception:
                    logger.exception("ADK agent method %s failed", method_name)

        return local_format(payload)
    except Exception:
        logger.exception("ADK invocation failed; using local formatter")
        return local_format(payload)


def send_fcm(token: str, title: str, body: str, dry_run: bool = False, max_retries: int = 3) -> str:
    if dry_run:
        logger.info("DRY RUN: FCM -> token=%s title=%s body=%s", token, title, body)
        print(f"DRY RUN FCM -> token={token} title={title} body={body}")
        return "DRY_RUN"

    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
    except Exception:
        raise RuntimeError("firebase_admin is required to send FCM messages")

    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

    message = messaging.Message(token=token, notification=messaging.Notification(title=title, body=body))

    last_exc = None
    for attempt in range(1, max_retries + 1):
        try:
            msg_id = messaging.send(message)
            logger.info("FCM sent, id=%s", msg_id)
            return msg_id
        except Exception:
            logger.exception("FCM send failed (attempt %d)", attempt)
            last_exc = Exception("fcm-failed")
            time.sleep(attempt)
    raise last_exc


def handle_message(dry_run: bool):
    def _cb(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            payload = json.loads(message.data.decode("utf-8"))
        except Exception:
            logger.exception("Invalid message payload")
            message.ack()
            return

        fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
        if not fcm_token:
            logger.warning("Missing fcm_token; acking message")
            message.ack()
            return

        text = try_run_adk_agent(payload)
        title = payload.get("title") or "Carbon Footprinter"

        try:
            send_fcm(fcm_token, title, text, dry_run=dry_run)
        except Exception:
            logger.exception("Failed to send FCM")
        finally:
            message.ack()

    return _cb


def run(subscription: str, dry_run: bool = False) -> None:
    client = pubsub_v1.SubscriberClient()
    callback = handle_message(dry_run)
    future = client.subscribe(subscription, callback=callback)
    logger.info("Subscribed to %s", subscription)
    try:
        future.result()
    except KeyboardInterrupt:
        logger.info("Stopping subscriber")
        future.cancel()
    except Exception:
        logger.exception("Subscriber error")
        future.cancel()


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("subscription", nargs="?", help="projects/PROJECT/subscriptions/SUB")
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not set and no arg provided")

    run(subscription, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
"""
Pub/Sub -> ADK -> FCM listener (clean single-file implementation).

Run with --dry-run to avoid requiring firebase_admin during testing.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    """Attempt to call an ADK agent in the repo to generate a short message.

    If the ADK agent isn't available or fails, return a local formatted message.
    """
    def local_format(p: Dict[str, Any]) -> str:
        ev = p.get("event", {}) if isinstance(p.get("event"), dict) else p
        saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
        user = p.get("user_name") or ev.get("user_name") or "You"
        if saved is not None:
            return f"{user}: You saved {saved} kg CO2 today — great job!"
        summary = ev.get("summary") or ev.get("message")
        return (str(summary)[:200]) if summary else "New carbon report available — check the app."

    try:
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            return local_format(payload)

        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                try:
                    result = method(payload)
                    if hasattr(result, "__await__"):
                        import asyncio

                        result = asyncio.get_event_loop().run_until_complete(result)
                    if isinstance(result, dict):
                        for k in ("text", "message", "result", "output"):
                            if k in result:
                                return str(result[k])[:200]
                        return str(result)[:200]
                    return str(result)[:200]
                except Exception:
                    logger.exception("ADK agent method %s failed", method_name)

        return local_format(payload)
    except Exception:
        logger.exception("Error invoking ADK agent; using fallback")
        return local_format(payload)


def send_fcm(token: str, title: str, body: str, dry_run: bool = False, max_retries: int = 3) -> str:
    if dry_run:
        logger.info("DRY RUN: FCM -> token=%s title=%s body=%s", token, title, body)
        print(f"DRY RUN FCM -> token={token} title={title} body={body}")
        return "DRY_RUN"

    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
    except Exception:
        raise RuntimeError("firebase_admin is required to send FCM messages")

    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)

    message = messaging.Message(token=token, notification=messaging.Notification(title=title, body=body))

    last_exc = None
    for attempt in range(1, max_retries + 1):
        try:
            msg_id = messaging.send(message)
            logger.info("FCM sent, id=%s", msg_id)
            return msg_id
        except Exception:
            logger.exception("FCM send failed (attempt %d)", attempt)
            last_exc = Exception("fcm-failed")
            time.sleep(attempt)
    raise last_exc


def handle_message(dry_run: bool):
    def _cb(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            payload = json.loads(message.data.decode("utf-8"))
        except Exception:
            logger.exception("Invalid message payload")
            message.ack()
            return

        fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
        if not fcm_token:
            logger.warning("Missing fcm_token; acking message")
            message.ack()
            return

        text = try_run_adk_agent(payload)
        title = payload.get("title") or "Carbon Footprinter"

        try:
            send_fcm(fcm_token, title, text, dry_run=dry_run)
        except Exception:
            logger.exception("Failed to send FCM")
        finally:
            message.ack()

    return _cb


def run(subscription: str, dry_run: bool = False) -> None:
    client = pubsub_v1.SubscriberClient()
    callback = handle_message(dry_run)
    future = client.subscribe(subscription, callback=callback)
    logger.info("Subscribed to %s", subscription)
    try:
        future.result()
    except KeyboardInterrupt:
        logger.info("Stopping subscriber")
        future.cancel()
    except Exception:
        logger.exception("Subscriber error")
        future.cancel()


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("subscription", nargs="?", help="projects/PROJECT/subscriptions/SUB")
    p.add_argument("--dry-run", action="store_true")
    args = p.parse_args()

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not set and no arg provided")

    run(subscription, dry_run=args.dry_run)


if __name__ == "__main__":
    main()

"""
Pub/Sub subscriber loop that receives JSON messages, uses an ADK agent
to generate a short notification text, and sends the text to a Flutter app
via Firebase Cloud Messaging (FCM).

Usage:
  python backend/pubsub_listener.py [projects/PROJECT/subscriptions/SUB] [--dry-run]

The script supports a --dry-run flag so you can test without firebase_admin.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    """Try to run the ADK agent in the repo to generate a short notification.

    Falls back to a local formatter if agent is not available or fails.
    """
    def local_format(p: Dict[str, Any]) -> str:
        ev = p.get("event", {}) if isinstance(p.get("event"), dict) else p
        saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
        user = p.get("user_name") or ev.get("user_name") or "You"
        if saved is not None:
            return f"{user}: You saved {saved} kg CO2 today — great job!"
        summary = ev.get("summary") or ev.get("message")
        if summary:
            return str(summary)[:200]
        return "New carbon report available — check the app for details."

    try:
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            logger.debug("No ADK agent imported; using local formatter")
            return local_format(payload)

        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                logger.info("Calling ADK agent method: %s", method_name)
                try:
                    result = method(payload)
                    if hasattr(result, "__await__"):
                        import asyncio

                        result = asyncio.get_event_loop().run_until_complete(result)
                    if isinstance(result, dict):
                        for k in ("text", "message", "result", "output"):
                            if k in result:
                                return str(result[k])[:200]
                        return str(result)[:200]
                    return str(result)[:200]
                except Exception:
                    logger.exception("ADK agent method %s failed", method_name)

        logger.debug("Agent present but no supported method succeeded; using local formatter")
        return local_format(payload)
    except Exception:
        logger.exception("ADK check failed, using local formatter")
        return local_format(payload)


def send_fcm(token: str, title: str, body: str, dry_run: bool = False, max_retries: int = 3) -> str:
    """Send a notification via FCM. If dry_run is True, only print the message."""
    if dry_run:
        logger.info("DRY RUN: FCM -> token=%s title=%s body=%s", token, title, body)
        print(f"DRY RUN FCM -> token={token} title={title} body={body}")
        return "DRY_RUN"

    # Lazy import firebase_admin to avoid hard dependency in dry-run tests
    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
    except Exception as e:
        raise RuntimeError("firebase_admin is required to send FCM messages") from e

    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        logger.info("Initialized Firebase Admin SDK using %s", cred_path)

    message = messaging.Message(
        token=token,
        notification=messaging.Notification(title=title, body=body),
    )

    last_exc = None
    for attempt in range(1, max_retries + 1):
        try:
            msg_id = messaging.send(message)
            logger.info("FCM message sent: %s", msg_id)
            return msg_id
        except Exception:
            logger.exception("FCM send attempt %d failed", attempt)
            last_exc = Exception("fcm-send-failed")
            time.sleep(attempt)
    raise last_exc


def handle_message(dry_run: bool):
    """Return a callback capturing dry_run flag for Pub/Sub subscriber."""

    def _callback(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            data = message.data.decode("utf-8")
            logger.info("Received message: %s", data)
            payload = json.loads(data)
        except Exception:
            logger.exception("Failed to decode/parse Pub/Sub message")
            message.ack()
            return

        fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
        if not fcm_token:
            logger.warning("Message missing fcm_token; dropping: %s", payload)
            message.ack()
            return

        try:
            notif_text = try_run_adk_agent(payload)
        except Exception:
            logger.exception("ADK agent failed, using fallback text")
            notif_text = "You have a new carbon report — open the app to view details."

        title = payload.get("title") or "Carbon Footprinter"

        try:
            send_fcm(fcm_token, title, notif_text, dry_run=dry_run)
        except Exception:
            logger.exception("Failed to send FCM notification")
        finally:
            # Ack message to avoid redelivery loops; change if you want retry behavior
            message.ack()

    return _callback


def run(subscription: str, dry_run: bool = False) -> None:
    logger.info("Starting Pub/Sub subscriber for: %s", subscription)
    subscriber = pubsub_v1.SubscriberClient()
    callback = handle_message(dry_run)
    streaming_pull_future = subscriber.subscribe(subscription, callback=callback)
    logger.info("Listening for messages on %s...", subscription)

    try:
        streaming_pull_future.result()
    except KeyboardInterrupt:
        logger.info("KeyboardInterrupt received; closing subscriber")
        streaming_pull_future.cancel()
    except Exception:
        logger.exception("Subscriber encountered an error; shutting down")
        streaming_pull_future.cancel()


def main() -> None:
    parser = argparse.ArgumentParser(description="Pub/Sub listener for sending FCM notifications")
    parser.add_argument("subscription", nargs="?", help="Full subscription name: projects/PROJECT/subscriptions/SUB")
    parser.add_argument("--dry-run", action="store_true", help="Do not send FCM, just print what would be sent")
    args = parser.parse_args()

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not provided as env var or CLI arg")

    run(subscription, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
"""
Pub/Sub subscriber loop that receives JSON messages, uses an ADK agent
to generate a short notification text, and sends the text to a Flutter app
via Firebase Cloud Messaging (FCM).

Usage:
  python backend/pubsub_listener.py [projects/PROJECT/subscriptions/SUB] [--dry-run]

The script supports a --dry-run flag so you can test without firebase_admin.
"""
from __future__ import annotations

import argparse
import json
import logging
import os
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
from dotenv import load_dotenv

load_dotenv()

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    """Try to run the ADK agent in the repo to generate a short notification.

    Falls back to a local formatter if agent is not available or fails.
    """
    def local_format(p: Dict[str, Any]) -> str:
        ev = p.get("event", {}) if isinstance(p.get("event"), dict) else p
        saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
        user = p.get("user_name") or ev.get("user_name") or "You"
        if saved is not None:
            return f"{user}: You saved {saved} kg CO2 today — great job!"
        summary = ev.get("summary") or ev.get("message")
        if summary:
            return str(summary)[:200]
        return "New carbon report available — check the app for details."

    try:
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            logger.debug("No ADK agent imported; using local formatter")
            return local_format(payload)

        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                logger.info("Calling ADK agent method: %s", method_name)
                try:
                    result = method(payload)
                    if hasattr(result, "__await__"):
                        import asyncio

                        result = asyncio.get_event_loop().run_until_complete(result)
                    if isinstance(result, dict):
                        for k in ("text", "message", "result", "output"):
                            if k in result:
                                return str(result[k])[:200]
                        return str(result)[:200]
                    return str(result)[:200]
                except Exception:
                    logger.exception("ADK agent method %s failed", method_name)

        logger.debug("Agent present but no supported method succeeded; using local formatter")
        return local_format(payload)
    except Exception:
        logger.exception("ADK check failed, using local formatter")
        return local_format(payload)


def send_fcm(token: str, title: str, body: str, dry_run: bool = False, max_retries: int = 3) -> str:
    """Send a notification via FCM. If dry_run is True, only print the message."""
    if dry_run:
        logger.info("DRY RUN: FCM -> token=%s title=%s body=%s", token, title, body)
        print(f"DRY RUN FCM -> token={token} title={title} body={body}")
        return "DRY_RUN"

    # Lazy import firebase_admin to avoid hard dependency in dry-run tests
    try:
        import firebase_admin
        from firebase_admin import credentials, messaging
    except Exception as e:
        raise RuntimeError("firebase_admin is required to send FCM messages") from e

    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        logger.info("Initialized Firebase Admin SDK using %s", cred_path)

    message = messaging.Message(
        token=token,
        notification=messaging.Notification(title=title, body=body),
    )

    last_exc = None
    for attempt in range(1, max_retries + 1):
        try:
            msg_id = messaging.send(message)
            logger.info("FCM message sent: %s", msg_id)
            return msg_id
        except Exception:
            logger.exception("FCM send attempt %d failed", attempt)
            last_exc = Exception("fcm-send-failed")
            time.sleep(attempt)
    raise last_exc


def handle_message(dry_run: bool):
    """Return a callback capturing dry_run flag for Pub/Sub subscriber."""

    def _callback(message: pubsub_v1.subscriber.message.Message) -> None:
        try:
            data = message.data.decode("utf-8")
            logger.info("Received message: %s", data)
            payload = json.loads(data)
        except Exception:
            logger.exception("Failed to decode/parse Pub/Sub message")
            message.ack()
            return

        fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
        if not fcm_token:
            logger.warning("Message missing fcm_token; dropping: %s", payload)
            message.ack()
            return

        try:
            notif_text = try_run_adk_agent(payload)
        except Exception:
            logger.exception("ADK agent failed, using fallback text")
            notif_text = "You have a new carbon report — open the app to view details."

        title = payload.get("title") or "Carbon Footprinter"

        try:
            send_fcm(fcm_token, title, notif_text, dry_run=dry_run)
        except Exception:
            logger.exception("Failed to send FCM notification")
        finally:
            # Ack message to avoid redelivery loops; change if you want retry behavior
            message.ack()

    return _callback


def run(subscription: str, dry_run: bool = False) -> None:
    logger.info("Starting Pub/Sub subscriber for: %s", subscription)
    subscriber = pubsub_v1.SubscriberClient()
    callback = handle_message(dry_run)
    streaming_pull_future = subscriber.subscribe(subscription, callback=callback)
    logger.info("Listening for messages on %s...", subscription)

    try:
        streaming_pull_future.result()
    except KeyboardInterrupt:
        logger.info("KeyboardInterrupt received; closing subscriber")
        streaming_pull_future.cancel()
    except Exception:
        logger.exception("Subscriber encountered an error; shutting down")
        streaming_pull_future.cancel()


def main() -> None:
    parser = argparse.ArgumentParser(description="Pub/Sub listener for sending FCM notifications")
    parser.add_argument("subscription", nargs="?", help="Full subscription name: projects/PROJECT/subscriptions/SUB")
    parser.add_argument("--dry-run", action="store_true", help="Do not send FCM, just print what would be sent")
    args = parser.parse_args()

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not provided as env var or CLI arg")

    run(subscription, dry_run=args.dry_run)


if __name__ == "__main__":
    main()
"""
Pub/Sub subscriber loop that receives JSON messages, uses an ADK agent
to generate a short notification text, and sends the text to a Flutter app
via Firebase Cloud Messaging (FCM).

Requirements satisfied:
- No web server used (direct Pub/Sub subscriber loop)
- Uses firebase_admin for FCM
- Attempts to use google.adk Agent objects (if available in runtime)

Environment variables expected in backend/.env or environment:
- PUBSUB_SUBSCRIPTION : full subscription name, e.g. projects/PROJECT/subscriptions/SUB
- FIREBASE_CREDENTIALS_PATH : path to service account JSON (already used elsewhere)
"""
from __future__ import annotations

import os
import json
import logging
import time
from typing import Any, Dict

from google.cloud import pubsub_v1
import argparse
from dotenv import load_dotenv

# Load .env variables if present
load_dotenv()

# firebase_admin is in requirements.txt; initialize lazily
DRY_RUN = False
import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger("pubsub_listener")
logging.basicConfig(level=logging.INFO)


def init_firebase():
    """Initialize firebase_admin app using FIREBASE_CREDENTIALS_PATH if not already initialized."""
    if not firebase_admin._apps:
        cred_path = os.environ.get("FIREBASE_CREDENTIALS_PATH")
        if not cred_path:
            raise RuntimeError("FIREBASE_CREDENTIALS_PATH is not set in environment")
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        logger.info("Initialized Firebase Admin SDK using %s", cred_path)
    else:
        logger.info("Firebase Admin SDK already initialized")


def try_run_adk_agent(payload: Dict[str, Any]) -> str:
    """
    Attempt to run the ADK agent defined in the repo to generate a short
    notification text from the given payload.

    This function tries a few common runtime method names on the Agent
    instance so it works even if the ADK API surface differs slightly.
    If ADK isn't available or the call fails, it falls back to a safe
    local formatting.
    """
    # Local fallback formatter
    def local_format(p: Dict[str, Any]) -> str:
        # Example: event contains 'saved_kg' or 'emission_saved' and 'user_name'
        ev = p.get("event", {}) if isinstance(p.get("event"), dict) else p
        saved = ev.get("saved_kg") or ev.get("emission_saved") or ev.get("saved")
        user = p.get("user_name") or ev.get("user_name") or "You"
        if saved is not None:
            return f"{user}: You saved {saved} kg CO2 today — great job!"
        # generic summary
        summary = ev.get("summary") or ev.get("message")
        if summary:
            return str(summary)[:200]
        return "New carbon report available — check the app for details."

    try:
        # Try importing the agent defined in the project
        # common locations in this project: backend.agents.notification_agent.agent
        try:
            from backend.agents.notification_agent.agent import root_agent as notification_agent
        except Exception:
            try:
                from backend.agents.coach_agent.agent import root_agent as notification_agent
            except Exception:
                notification_agent = None

        if notification_agent is None:
            logger.info("No ADK agent found in repository; using local formatter")
            return local_format(payload)

        # Try common method names
        for method_name in ("run", "respond", "call", "execute", "generate"):
            method = getattr(notification_agent, method_name, None)
            if callable(method):
                logger.info("Calling ADK agent method: %s", method_name)
                try:
                    result = method(payload)
                    # If coroutine, run it
                    if hasattr(result, "__await__"):
                        import asyncio

                        result = asyncio.get_event_loop().run_until_complete(result)
                    # If agent returns dict-like or object with text field
                    if isinstance(result, dict):
                        # try common keys
                        for k in ("text", "message", "result", "output"):
                            if k in result:
                                return str(result[k])[:200]
                        # fallthrough to string conversion
                        return str(result)[:200]
                    return str(result)[:200]
                except Exception as e:
                    logger.exception("ADK agent method %s failed: %s", method_name, e)

        logger.info("ADK agent found but no supported call method succeeded; using local formatter")
        return local_format(payload)
    except Exception as e:
        logger.exception("Error while running ADK agent: %s", e)
        return local_format(payload)


def send_fcm(token: str, title: str, body: str, max_retries: int = 3) -> str:
    """Send a notification via Firebase Cloud Messaging. Returns the message id on success."""
    init_firebase()
    message = messaging.Message(
        token=token,
        notification=messaging.Notification(title=title, body=body),
    )

    last_exc = None
    for attempt in range(1, max_retries + 1):
        try:
            msg_id = messaging.send(message)
            logger.info("FCM message sent: %s", msg_id)
            return msg_id
        except Exception as e:
            logger.exception("FCM send attempt %d failed", attempt)
            last_exc = e
            time.sleep(1 * attempt)
    raise last_exc


def handle_message(message: pubsub_v1.subscriber.message.Message) -> None:
    """Callback to handle incoming Pub/Sub messages."""
    try:
        data = message.data.decode("utf-8")
        logger.info("Received message: %s", data)
        payload = json.loads(data)
    except Exception as e:
        logger.exception("Failed to decode/parse Pub/Sub message: %s", e)
        message.ack()
        return

    # Expect an fcm_token at top-level or inside payload['notification']
    fcm_token = payload.get("fcm_token") or (payload.get("notification") or {}).get("fcm_token")
    if not fcm_token:
        logger.warning("Message missing fcm_token; dropping: %s", payload)
        message.ack()
        return

    # Generate notification text via ADK agent (with fallback)
    try:
        notif_text = try_run_adk_agent(payload)
    except Exception as e:
        logger.exception("Failed to generate notification text: %s", e)
        # If running in dry-run mode, just log/print what would be sent
        if DRY_RUN:
            logger.info("DRY RUN: would send FCM to %s -> %s: %s", fcm_token, payload.get('title', 'Carbon Footprinter'), "N/A")
            print(f"DRY RUN FCM -> token={fcm_token} title={payload.get('title', 'Carbon Footprinter')} body=N/A")
            return "DRY_RUN"

        notif_text = "You have a new carbon report — open the app to view details."

    title = payload.get("title") or "Carbon Footprinter"

    try:
        send_fcm(fcm_token, title, notif_text)
    except Exception as e:
        logger.exception("Failed to send FCM notification: %s", e)
        # decide whether to ack or not. We ack to avoid redelivery loops in this example.
    finally:
        message.ack()


def run(subscription: str) -> None:
    """Start a Pub/Sub subscriber and run forever.

    subscription must be the full subscription name: projects/<proj>/subscriptions/<sub>
    """
    logger.info("Starting Pub/Sub subscriber for: %s", subscription)
    subscriber = pubsub_v1.SubscriberClient()
    parser = argparse.ArgumentParser(description="Pub/Sub listener for sending FCM notifications")
    parser.add_argument("subscription", nargs="?", help="Full subscription name: projects/PROJECT/subscriptions/SUB")
    parser.add_argument("--dry-run", action="store_true", help="Do not send FCM, just print what would be sent")
    args = parser.parse_args()
    if args.dry_run:
        DRY_RUN = True

    subscription = args.subscription or os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        raise SystemExit("PUBSUB_SUBSCRIPTION not provided as env var or CLI arg")


if __name__ == "__main__":
    # Allow subscription to be passed by environment or CLI
    subscription = os.environ.get("PUBSUB_SUBSCRIPTION")
    if not subscription:
        import sys

        if len(sys.argv) > 1:
            subscription = sys.argv[1]
        else:
            raise SystemExit("PUBSUB_SUBSCRIPTION not provided as env var or CLI arg")

    run(subscription)

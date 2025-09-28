#!/usr/bin/env bash
# Small helper to install backend requirements into the existing venv
# and run the Pub/Sub listener in dry-run mode so you can test the flow
# without sending real FCM messages.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [ ! -d ".venv" ]; then
  echo ".venv not found in $ROOT_DIR — creating one"
  python3 -m venv .venv
fi

echo "Activating venv..."
# shellcheck source=/dev/null
source .venv/bin/activate

echo "Installing requirements (this may take a few minutes)..."
pip install --upgrade pip
pip install -r requirements.txt

echo "Installed. Running pubsub_listener in dry-run mode (will not send FCM)."
echo "You still need to provide a subscription name (or set PUBSUB_SUBSCRIPTION in .env)."
echo "Example: ./setup_and_run.sh projects/YOUR_PROJECT/subscriptions/YOUR_SUB --dry-run"

if [ $# -ge 1 ]; then
  SUB=$1
  shift
  exec python3 pubsub_listener.py "$SUB" --dry-run "$@"
else
  exec python3 pubsub_listener.py --dry-run
fi

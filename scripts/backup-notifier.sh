#!/bin/bash

# ==============================
# Slack Notification Script
# ==============================

# Replace this with your own Slack Incoming Webhook URL
WEBHOOK_URL="https://hooks.slack.com/services/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"

# Accept message as first argument
FILE_NAME="$1"

# Use default if no message provided
MESSAGE="$FILE_NAME backup has been uploaded to s3! 👋"

# Send to Slack
curl -s -X POST "$WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  --data "{
    \"text\": \"${MESSAGE}\"
  }"
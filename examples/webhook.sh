#!/usr/bin/env bash
# Cadlens API — upload with webhook callback
# Cadlens POSTs job completion events to your webhookUrl instead of you polling.
# Docs: https://cadlens.co/docs
# Usage: CADLENS_API_KEY=cadl_xxx WEBHOOK_URL=https://your-server.com/hook ./webhook.sh drawing.dwg

set -euo pipefail

API_BASE="https://api.cadlens.co"
FILE="${1:-drawing.dwg}"
API_KEY="${CADLENS_API_KEY:?Set CADLENS_API_KEY}"
WEBHOOK_URL="${WEBHOOK_URL:?Set WEBHOOK_URL to your endpoint}"

echo "Uploading $FILE with webhook: $WEBHOOK_URL"

curl -s -X POST "$API_BASE/v1/parse" \
  -H "Authorization: Bearer $API_KEY" \
  -F "file=@$FILE" \
  -F "webhookUrl=$WEBHOOK_URL" | python3 -m json.tool

# ─── Expected webhook payload on completion ────────────────────────────────────
#
# POST https://your-server.com/hook
# Content-Type: application/json
# X-CADLens-Signature: sha256=<hmac-sha256-of-body>
#
# {
#   "eventId": "550e8400-e29b-41d4-a716-446655440000",
#   "sequence": 1,
#   "event": "job.completed",
#   "jobId": "job_lH9k2c",
#   "status": "COMPLETED",
#   "timestamp": "2026-05-15T12:01:30.000Z",
#   "result": {
#     "entityCount": 142,
#     "layerCount": 8,
#     "imageUrl": "https://s3.amazonaws.com/...",
#     "vectorJson": [...],
#     "layersJson": [...],
#     "metadata": { "version": "AC1021", "units": "mm", "width": 500, "height": 400 }
#   }
# }
#
# Events: job.processing | job.completed | job.failed

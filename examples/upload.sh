#!/usr/bin/env bash
# Cadlens API — upload a CAD file, poll for completion, retrieve result
# Docs: https://cadlens.co/docs
# Usage: CADLENS_API_KEY=cadl_xxx ./upload.sh drawing.dwg

set -euo pipefail

API_BASE="https://api.cadlens.co"
FILE="${1:-drawing.dwg}"
API_KEY="${CADLENS_API_KEY:?Set CADLENS_API_KEY to your Cadlens API key}"

echo "Uploading $FILE..."

UPLOAD=$(curl -s -X POST "$API_BASE/v1/parse" \
  -H "Authorization: Bearer $API_KEY" \
  -F "file=@$FILE")

JOB_ID=$(echo "$UPLOAD" | grep -o '"job_id":"[^"]*"' | cut -d'"' -f4)

if [ -z "$JOB_ID" ]; then
  echo "Upload failed:"
  echo "$UPLOAD"
  exit 1
fi

echo "Job ID: $JOB_ID — polling for completion..."

while true; do
  STATUS_JSON=$(curl -s "$API_BASE/v1/jobs/$JOB_ID" \
    -H "Authorization: Bearer $API_KEY")

  STATUS=$(echo "$STATUS_JSON" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
  echo "  status: $STATUS"

  if [ "$STATUS" = "COMPLETED" ]; then
    break
  elif [ "$STATUS" = "FAILED" ]; then
    echo "Job failed:"
    echo "$STATUS_JSON"
    exit 1
  fi

  sleep 3
done

echo ""
echo "Fetching result..."

curl -s "$API_BASE/v1/jobs/$JOB_ID/result" \
  -H "Authorization: Bearer $API_KEY" | python3 -m json.tool

echo ""
echo "Fetching preview image URL..."

curl -s "$API_BASE/v1/jobs/$JOB_ID/image" \
  -H "Authorization: Bearer $API_KEY" | python3 -m json.tool

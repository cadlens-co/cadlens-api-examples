# Cadlens API Examples

[Cadlens](https://cadlens.co) is a developer API for parsing CAD files such as DWG, DXF, and DWF into preview images, structured JSON, layer metadata, and vector entities — without installing AutoCAD or any desktop software.

- Website: [cadlens.co](https://cadlens.co)
- API Docs: [cadlens.co/docs](https://cadlens.co/docs)
- Pricing: [cadlens.co/pricing](https://cadlens.co/pricing)
- Dashboard: [cadlens.co/dashboard](https://cadlens.co/dashboard)

---

## What you can build with Cadlens

- CAD file preview inside your web app — [CAD file preview API](https://cadlens.co)
- DWG/DXF to structured JSON extraction — [DWG to JSON API](https://cadlens.co)
- Layer and entity inspection for automation workflows
- AI-assisted CAD interpretation with LLMs
- Webhook-based async CAD processing pipelines

---

## Prerequisites

1. Sign up at [cadlens.co](https://cadlens.co) and create an account
2. Go to the dashboard and generate an API key (starts with `cadl_`)
3. Export your key: `export CADLENS_API_KEY=cadl_your_key_here`

---

## Examples

| File | Description |
|------|-------------|
| [`examples/upload.sh`](examples/upload.sh) | Upload a CAD file, poll for completion, retrieve result |
| [`examples/webhook.sh`](examples/webhook.sh) | Upload with a webhook URL and example webhook payload |
| [`examples/node.js`](examples/node.js) | Node.js upload using native `fetch` |
| [`examples/python.py`](examples/python.py) | Python upload using `requests` |

---

## Basic Flow

1. **Upload** — POST a CAD file to `/v1/parse`; receive a `job_id`
2. **Poll** — GET `/v1/jobs/:job_id` until `status` is `COMPLETED` or `FAILED`
3. **Retrieve** — GET `/v1/jobs/:job_id/result` for vector JSON, layers, and metadata
4. **Preview** — GET `/v1/jobs/:job_id/image` for a presigned PNG preview URL

---

## Supported File Formats

DWG · DXF · DWF · DWFx · DGN · PDF

---

## Quick Response Preview

**Job status response (`GET /v1/jobs/:job_id`):**
```json
{
  "id": "job_lH9k2c",
  "status": "COMPLETED",
  "fileName": "drawing.dwg",
  "fileSize": 2048576,
  "createdAt": "2026-05-15T12:00:00.000Z",
  "completedAt": "2026-05-15T12:01:30.000Z",
  "imageUrl": "https://s3.amazonaws.com/..."
}
```

**Result response (`GET /v1/jobs/:job_id/result`):**
```json
{
  "jobId": "job_lH9k2c",
  "status": "COMPLETED",
  "vectorJson": [
    { "type": "line", "layer": "0", "x1": 0, "y1": 0, "x2": 100, "y2": 100 }
  ],
  "layersJson": [
    { "name": "0", "color": 7, "isVisible": true }
  ],
  "metadata": {
    "version": "AC1021",
    "units": "mm",
    "width": 500,
    "height": 400
  },
  "imageUrl": "https://s3.amazonaws.com/..."
}
```

---

## Webhook Payload

When you supply a `webhookUrl` on upload, Cadlens POSTs this to your endpoint on completion:

```json
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",
  "sequence": 1,
  "event": "job.completed",
  "jobId": "job_lH9k2c",
  "status": "COMPLETED",
  "timestamp": "2026-05-15T12:01:30.000Z",
  "result": {
    "entityCount": 142,
    "layerCount": 8,
    "imageUrl": "https://s3.amazonaws.com/...",
    "vectorJson": [...],
    "layersJson": [...]
  }
}
```

Webhook events: `job.processing` · `job.completed` · `job.failed`

---

## Links

- [Cadlens official website](https://cadlens.co)
- [Cadlens API documentation](https://cadlens.co/docs)
- [Cadlens pricing](https://cadlens.co/pricing)
- [Contact Cadlens](https://cadlens.co/contact)

---

## GitHub Topics

Add these topics to this repo for discovery:
`cad` `dwg` `dxf` `cad-parser` `dwg-parser` `cad-api` `engineering-api` `aec` `developer-tools` `construction-tech`

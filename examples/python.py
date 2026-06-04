#!/usr/bin/env python3
"""
Cadlens API — Python example
CAD file preview API: https://cadlens.co
Docs: https://cadlens.co/docs

Usage:
    pip install requests
    CADLENS_API_KEY=cad_xxx python upload.py drawing.dwg
"""

import os
import sys
import time

import requests

API_BASE = "https://api.cadlens.co"
API_KEY = os.environ.get("CADLENS_API_KEY", "")
FILE_PATH = sys.argv[1] if len(sys.argv) > 1 else "drawing.dwg"

if not API_KEY:
    raise SystemExit("Set the CADLENS_API_KEY environment variable")

headers = {"Authorization": f"Bearer {API_KEY}"}


def parse_cad_file(file_path: str) -> dict:
    # 1. Upload
    print(f"Uploading {file_path}...")
    with open(file_path, "rb") as f:
        resp = requests.post(
            f"{API_BASE}/v1/parse",
            headers=headers,
            files={"file": (os.path.basename(file_path), f)},
        )
    resp.raise_for_status()
    job_id = resp.json()["job_id"]
    print(f"Job ID: {job_id}")

    # 2. Poll for completion
    while True:
        status_resp = requests.get(f"{API_BASE}/v1/jobs/{job_id}", headers=headers)
        status_resp.raise_for_status()
        job = status_resp.json()
        print(f"  status: {job['status']}")

        if job["status"] == "COMPLETED":
            break
        if job["status"] == "FAILED":
            raise RuntimeError(f"Job failed: {job.get('errorMsg')}")

        time.sleep(3)

    # 3. Fetch result
    result_resp = requests.get(f"{API_BASE}/v1/jobs/{job_id}/result", headers=headers)
    result_resp.raise_for_status()
    result = result_resp.json()

    print("\n=== Result ===")
    print(f"Layers:   {len(result['layersJson'])}")
    print(f"Entities: {len(result['vectorJson'])}")
    print(f"Metadata: {result['metadata']}")
    print(f"Preview:  {result['imageUrl']}")

    return result


if __name__ == "__main__":
    parse_cad_file(FILE_PATH)

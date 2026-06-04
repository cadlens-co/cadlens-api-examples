// Cadlens API — Node.js example (native fetch, Node 18+)
// DWG to JSON API: https://cadlens.co
// Docs: https://cadlens.co/docs

import { readFileSync } from 'fs';

const API_BASE = 'https://api.cadlens.co';
const API_KEY = process.env.CADLENS_API_KEY ?? '';
const FILE_PATH = process.argv[2] ?? 'drawing.dwg';

if (!API_KEY) throw new Error('Set CADLENS_API_KEY environment variable');

async function parseCADFile(filePath) {
  // 1. Upload the CAD file
  const form = new FormData();
  form.append('file', new Blob([readFileSync(filePath)]), filePath.split('/').pop());

  const uploadRes = await fetch(`${API_BASE}/v1/parse`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${API_KEY}` },
    body: form,
  });

  if (!uploadRes.ok) throw new Error(`Upload failed: ${await uploadRes.text()}`);
  const { job_id: jobId } = await uploadRes.json();
  console.log('Job ID:', jobId);

  // 2. Poll until complete
  let job;
  while (true) {
    const res = await fetch(`${API_BASE}/v1/jobs/${jobId}`, {
      headers: { Authorization: `Bearer ${API_KEY}` },
    });
    job = await res.json();
    console.log('Status:', job.status);

    if (job.status === 'COMPLETED') break;
    if (job.status === 'FAILED') throw new Error(`Job failed: ${job.errorMsg}`);

    await new Promise((r) => setTimeout(r, 3000));
  }

  // 3. Fetch the parsed result
  const resultRes = await fetch(`${API_BASE}/v1/jobs/${jobId}/result`, {
    headers: { Authorization: `Bearer ${API_KEY}` },
  });
  const result = await resultRes.json();

  console.log('\n=== Result ===');
  console.log('Layers:', result.layersJson.length);
  console.log('Entities:', result.vectorJson.length);
  console.log('Metadata:', result.metadata);
  console.log('Preview URL:', result.imageUrl);

  return result;
}

parseCADFile(FILE_PATH).catch(console.error);

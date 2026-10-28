// Optional local-only browser QA server. Run after a real Jekyll build:
// node scripts/qa-preview.mjs
// /__preview?width=390&anchor=publications embeds the actual site at that width.
import http from 'node:http';
import fs from 'node:fs/promises';
import path from 'node:path';
const root = path.resolve('_site');
const types = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.png': 'image/png', '.webp': 'image/webp', '.jpg': 'image/jpeg', '.pdf': 'application/pdf', '.xml': 'application/xml', '.txt': 'text/plain' };
http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://127.0.0.1:4001');
  if (url.pathname === '/__preview') {
    const width = Math.min(1440, Math.max(320, Number(url.searchParams.get('width')) || 390));
    const anchor = (url.searchParams.get('anchor') || 'about-me').replace(/[^a-z-]/g, '');
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(`<!doctype html><html lang="en"><meta name="viewport" content="width=device-width, initial-scale=1"><title>Responsive preview — ${width}px</title><style>body{margin:0;background:#edf0f2;font:13px system-ui;color:#45515b}header{height:40px;display:flex;align-items:center;justify-content:center;gap:18px}a{color:#245d87}iframe{display:block;width:${width}px;height:calc(100vh - 44px);margin:auto;border:1px solid #d4dce1;background:white}</style><header><span>Responsive preview · ${width}px</span><a href="/">Desktop</a><a href="/__preview?width=390">Mobile</a><a href="/__preview?width=768">Tablet</a></header><iframe id="preview" title="Academic homepage at ${width}px" src="/#${anchor}"></iframe></html>`);
    return;
  }
  try {
    const relative = decodeURIComponent(url.pathname).replace(/^\/+/, '');
    let filename = path.resolve(root, relative || 'index.html');
    if (!filename.startsWith(root + path.sep) && filename !== root) throw new Error('Invalid path');
    if ((await fs.stat(filename)).isDirectory()) filename = path.join(filename, 'index.html');
    const body = await fs.readFile(filename);
    res.writeHead(200, { 'Content-Type': types[path.extname(filename)] || 'application/octet-stream', 'Cache-Control': 'no-store' });
    res.end(body);
  } catch {
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('Not found');
  }
}).listen(4001, '127.0.0.1', () => console.log('Local QA preview: http://127.0.0.1:4001/'));

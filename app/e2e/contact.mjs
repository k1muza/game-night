// Builds contact sheets (6 screens per sheet) from shots/<vp>/ for review.
import { chromium } from '@playwright/test';
import { readdirSync, readFileSync } from 'node:fs';
const vp = process.argv[2] || '390x844';
const files = readdirSync(`shots/${vp}`).filter((f) => f.endsWith('.png') && !f.startsWith('sheet')).sort();
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1800, height: 1000 } });
for (let i = 0; i < files.length; i += 6) {
  const chunk = files.slice(i, i + 6);
  const imgs = chunk.map((f) => `<figure><img src="data:image/png;base64,${readFileSync(`shots/${vp}/${f}`).toString('base64')}"><figcaption>${f}</figcaption></figure>`).join('');
  await page.setContent(`<style>body{margin:0;background:#000;display:flex;gap:10px;padding:10px;font:14px sans-serif;color:#fff}figure{margin:0;width:290px}img{width:290px;display:block}</style>${imgs}`);
  await page.screenshot({ path: `shots/${vp}/sheet-${String(i / 6 + 1).padStart(2, '0')}.png`, fullPage: true });
}
await browser.close();

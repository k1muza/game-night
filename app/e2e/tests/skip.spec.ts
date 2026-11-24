import { expect, test } from '@playwright/test';
import { boot, btn, startGame, startTurn } from './helpers';
test.use({ viewport: { width: 390, height: 844 } });
test('Sprint: skip card once per turn, before ticking', async ({ page }) => {
  await boot(page);
  await startGame(page, /30-Second Sprint/);
  await startTurn(page);
  const firstTerm = await page.getByRole('switch').first().getAttribute('aria-label');
  await page.screenshot({ path: 'shots/390x844/06b-sprint-skip.png' });
  await btn(page, /^Skip this card/).click();
  await expect(page.getByRole('switch').first()).not.toHaveAttribute('aria-label', firstTerm!);
  await expect(btn(page, /^Skip this card/)).toHaveCount(0);
});

test('full screen: toggle on Home, restored by Start after the browser exits it', async ({ page }) => {
  await boot(page);
  const isFull = () => page.evaluate(() => document.fullscreenElement !== null);
  await btn(page, 'Full screen').click();
  await expect.poll(isFull).toBe(true);
  await expect(btn(page, 'Exit full screen')).toBeVisible();
  await page.evaluate(() => document.exitFullscreen()); // e.g. Android back gesture
  await expect.poll(isFull).toBe(false);
  await startGame(page, /Charades/); // the Start tap brings it back
  await expect.poll(isFull).toBe(true);
});

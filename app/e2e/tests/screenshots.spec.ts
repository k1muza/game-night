// Captures the representative screens at phone size for visual review against
// design/screens/*. Output: e2e/shots/<viewport>/*.png
import { expect, Page, test } from '@playwright/test';
import { boot, btn, tap, endTurnViaPause, startGame, startTurn } from './helpers';

const viewports = [
  { name: '390x844', width: 390, height: 844 },
  { name: '360x740', width: 360, height: 740 },
];

for (const vp of viewports) {
  test.describe(vp.name, () => {
    test.use({ viewport: { width: vp.width, height: vp.height } });
    const shot = (page: Page, n: string) => page.screenshot({ path: `shots/${vp.name}/${n}.png` });

    test('sprint + shared screens', async ({ page }) => {
      await boot(page, { showRules: true });
      await shot(page, '01-home');
      await btn(page, /30-Second Sprint/).click();
      await expect(btn(page, 'Got it')).toBeVisible();
      await page.waitForTimeout(400);
      await shot(page, '02-how-to-play');
      await btn(page, 'Got it').click();
      await page.waitForTimeout(400);
      await shot(page, '03-setup');
      for (let i = 0; i < 4; i++) await btn(page, 'Fewer turns').click(); // 1 round → reach final quickly
      await btn(page, 'Start game').click();
      await page.waitForTimeout(400);
      await shot(page, '04-handover');
      await tap(page, 'Start the clock');
      await page.waitForTimeout(300);
      await shot(page, '05-countdown');
      await expect(btn(page, 'Pause')).toBeVisible();
      const terms = page.getByRole('switch');
      await terms.nth(0).click();
      await terms.nth(2).click();
      await page.waitForTimeout(300);
      await shot(page, '06-sprint-play');
      // Let the real clock expire once (30 s) to capture the Time! moment.
      await expect(page.getByText('Time!', { exact: false })).toBeVisible({ timeout: 40_000 }).catch(() => {});
      await expect(btn(page, 'See the scores')).toBeVisible({ timeout: 40_000 });
      await page.waitForTimeout(1000);
      await shot(page, '07-time-up');
      await tap(page, 'See the scores');
      await page.waitForTimeout(400);
      await shot(page, '08-turn-results');
      await tap(page, 'Next team');
      await startTurn(page);
      for (let i = 0; i < 5; i++) await page.getByRole('switch').nth(i).click();
      await expect(btn(page, 'See the scores')).toBeVisible();
      await page.waitForTimeout(1000);
      await shot(page, '09-all-five');
      await tap(page, 'See the scores');
      await tap(page, 'See final results');
      await page.waitForTimeout(1200);
      await shot(page, '10-final-results');
      await page.waitForTimeout(2500);
      await shot(page, '10b-final-results-settled');
    });

    test('charades', async ({ page }) => {
      await boot(page);
      await startGame(page, /Charades/);
      await startTurn(page);
      await page.waitForTimeout(300);
      await shot(page, '11-charades-play');
      await btn(page, 'Correct, got it').click();
      await page.waitForTimeout(150);
      await shot(page, '12-charades-feedback');
      await btn(page, 'Pass').click();
      await btn(page, 'Correct, got it').click();
      await btn(page, 'Pause').click();
      await page.waitForTimeout(200);
      await shot(page, '13-paused');
      await btn(page, 'End this turn now').click();
      await btn(page, 'End turn').click();
      await page.waitForTimeout(400);
      await btn(page, /This turn/).click();
      await page.waitForTimeout(200);
      await shot(page, '14-charades-results');
    });

    test('trivia', async ({ page }) => {
      await boot(page);
      await startGame(page, /Trivia Challenge/);
      await shot(page, '15-trivia-handover');
      await startTurn(page);
      await page.waitForTimeout(300);
      await shot(page, '16-trivia-question');
      await page.waitForTimeout(950);
      await page.getByRole('button', { name: /^B: / }).click();
      await page.waitForTimeout(200);
      await shot(page, '17-trivia-selected');
      await btn(page, /^Lock in /).click();
      await page.waitForTimeout(400);
      await shot(page, '18-trivia-reveal');
      await tap(page, 'Next question');
      // Let one question time out (20 s).
      await expect(page.getByText(/Time’s up!/).first()).toBeVisible({ timeout: 30_000 });
      await page.waitForTimeout(300);
      await shot(page, '19-trivia-timeout');
    });

    test('forbidden words + resume', async ({ page }) => {
      await boot(page);
      await startGame(page, /Forbidden Words/);
      await startTurn(page);
      await page.waitForTimeout(300);
      await shot(page, '20-forbidden-play');
      await btn(page, 'Correct, got it').click();
      await btn(page, /^Buzz/).click();
      await page.waitForTimeout(150);
      await shot(page, '21-forbidden-buzzed');
      await endTurnViaPause(page);
      await page.waitForTimeout(400);
      await shot(page, '22-forbidden-results');
      await tap(page, 'Game menu');
      await btn(page, /^Home/).click();
      await page.waitForTimeout(400);
      await shot(page, '23-home-resume');
    });
  });
}

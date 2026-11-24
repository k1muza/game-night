import { expect, Page } from '@playwright/test';

export const btn = (page: Page, name: string | RegExp) => page.getByRole('button', { name }).first();

/** Fresh app: no saved session, rules already seen unless [showRules]. */
export async function boot(page: Page, opts: { keepStorage?: boolean; showRules?: boolean } = {}) {
  await page.goto('/');
  if (!opts.keepStorage) {
    await page.evaluate((showRules) => {
      localStorage.clear();
      if (!showRules) {
        for (const g of ['sprint', 'charades', 'trivia', 'forbidden']) localStorage.setItem(`flutter.flag.rules.${g}`, 'true');
      }
    }, !!opts.showRules);
    await page.reload();
  }
  await expect(btn(page, /30-Second Sprint/)).toBeVisible({ timeout: 30_000 });
}

export async function startGame(page: Page, game: RegExp) {
  await btn(page, game).click();
  await btn(page, 'Start game').click();
}

/** Handover → countdown → playing. */
export async function startTurn(page: Page) {
  await tap(page, /Start the (clock|questions)/);
  await expect(btn(page, 'Pause')).toBeVisible({ timeout: 10_000 });
}

export async function endTurnViaPause(page: Page) {
  await btn(page, 'Pause').click();
  await btn(page, 'End this turn now').click();
  await btn(page, 'End turn').click();
  await page.waitForTimeout(950);
}

export async function roles(page: Page) {
  return page.evaluate(() =>
    Array.from(document.querySelectorAll('flt-semantics [role]'))
      .map((e) => `${e.getAttribute('role')}:${e.getAttribute('aria-label') ?? ''}${e.getAttribute('aria-checked') ? ' checked=' + e.getAttribute('aria-checked') : ''}${e.getAttribute('aria-pressed') ? ' pressed=' + e.getAttribute('aria-pressed') : ''}`)
      .join('\n'));
}

/** Click after the screen's brief tap guard (InputGuard, ≤900 ms) has lapsed. */
export async function tap(page: Page, name: string | RegExp) {
  await page.waitForTimeout(950);
  await btn(page, name).click();
}

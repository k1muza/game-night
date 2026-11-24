// End-to-end single-device journeys in a real browser against the release build.
import { expect, Page, test } from '@playwright/test';
import { boot, btn, tap, endTurnViaPause, startGame, startTurn } from './helpers';

test.use({ viewport: { width: 390, height: 844 } });

/** Seconds shown by the turn timer (from its accessible label). */
async function secondsLeft(page: Page): Promise<number> {
  const label = await page.getByText(/^\d+ seconds left$/).first().textContent();
  return Number(label!.split(' ')[0]);
}

const standing = (page: Page, team: string, points: number) =>
  page.getByText(new RegExp(`^Rank =?\\d, ${team}, ${points} points`)).first();

async function oneRound(page: Page) {
  for (let i = 0; i < 4; i++) await btn(page, 'Fewer turns').click();
}

test('30-Second Sprint: mark, correct, two teams, final results', async ({ page }) => {
  await boot(page);
  await btn(page, /30-Second Sprint/).click();
  await oneRound(page);
  await btn(page, 'Start game').click();

  // Handover: the card is not on screen.
  await expect(page.getByRole('switch')).toHaveCount(0);
  await startTurn(page);
  const terms = page.getByRole('switch');
  await expect(terms).toHaveCount(5);
  await terms.nth(0).click();
  await terms.nth(1).click();
  await terms.nth(1).click(); // correction
  await expect(terms.nth(0)).toBeChecked();
  await expect(terms.nth(1)).not.toBeChecked();
  await expect(page.getByText('1 of 5 guessed')).toBeVisible();
  await endTurnViaPause(page);
  await expect(standing(page, 'Team A', 1)).toBeVisible();
  await tap(page, 'Next team');

  await startTurn(page);
  for (let i = 0; i < 5; i++) await page.getByRole('switch').nth(i).click();
  await expect(page.getByText('All five!').first()).toBeVisible();
  await tap(page, 'See the scores');
  await expect(standing(page, 'Team B', 5)).toBeVisible();
  await tap(page, 'See final results');
  await expect(page.getByText('Team B win!').first()).toBeVisible();
  await expect(page.getByText(/^Rank 1, Team B, 5 points/)).toBeVisible();
});

test('Charades: correct, pass, undo; scores and counts', async ({ page }) => {
  await boot(page);
  await btn(page, /Charades/).click();
  await oneRound(page);
  await btn(page, 'Start game').click();
  await expect(page.getByText(/^Act out:/)).toHaveCount(0);
  await startTurn(page);
  const card = page.getByText(/^Act out:/).first();
  const first = await card.textContent();
  await btn(page, 'Correct, got it').click();
  await expect(card).not.toHaveText(first!);
  await btn(page, 'Pass').click();
  await btn(page, 'Undo').click(); // undo the pass
  await btn(page, 'Correct, got it').click();
  await endTurnViaPause(page);
  await expect(standing(page, 'Team A', 2)).toBeVisible();
  await expect(page.getByText('2 got')).toBeVisible();
  await expect(page.getByText('0 passed')).toBeVisible();
  await tap(page, 'Next team');
  await startTurn(page);
  await btn(page, 'Pass').click();
  await endTurnViaPause(page);
  await tap(page, 'See final results');
  await expect(page.getByText('Team A win!').first()).toBeVisible();
});

test('Forbidden Words: violation is −1 and scores can go negative', async ({ page }) => {
  await boot(page);
  await btn(page, /Forbidden Words/).click();
  await oneRound(page);
  await btn(page, 'Start game').click();
  await expect(page.getByText(/^Get them to say:/)).toHaveCount(0);
  await startTurn(page);
  await btn(page, /^Buzz/).click();
  await btn(page, /^Buzz/).click();
  await btn(page, 'Correct, got it').click();
  await endTurnViaPause(page);
  await expect(standing(page, 'Team A', -1)).toBeVisible();
  await expect(page.getByText('2 buzzed')).toBeVisible();
  await tap(page, 'Next team');
  await startTurn(page);
  await endTurnViaPause(page);
  await tap(page, 'See final results');
  await expect(page.getByText('Team B win!').first()).toBeVisible();
});

test('Trivia: select, lock, reveal, timeout, five questions per turn', async ({ page }) => {
  test.setTimeout(180_000);
  await boot(page);
  await btn(page, /Trivia Challenge/).click();
  await oneRound(page);
  await btn(page, 'Start game').click();
  await startTurn(page);
  // Answers hidden until lock-in: no tile is labelled as the correct answer.
  await expect(page.getByRole('button', { name: /correct answer$/ }).or(page.getByText(/correct answer$/))).toHaveCount(0);
  await page.getByRole('button', { name: /^C: / }).click();
  await btn(page, /^Lock in /).click();
  await expect(page.getByRole('button', { name: /correct answer$/ }).or(page.getByText(/correct answer$/))).toHaveCount(1);
  await expect(page.getByText(/You got it!|So close!/).first()).toBeVisible();
  await tap(page, 'Next question');
  // Question 2: let it time out (20 s, real time).
  await expect(page.getByText('Time’s up!').first()).toBeVisible({ timeout: 30_000 });
  await expect(page.getByRole('button', { name: /correct answer$/ }).or(page.getByText(/correct answer$/))).toHaveCount(1);
  for (let q = 3; q <= 5; q++) {
    await tap(page, 'Next question');
    await page.getByRole('button', { name: /^A: / }).click();
    await btn(page, /^Lock in /).click();
  }
  await tap(page, 'See turn results');
  await expect(page.getByText('Round 1 of 1')).toBeVisible();
  await expect(page.getByText('1 timed out')).toBeVisible();
});

test('refresh during an active turn keeps the clock running (no extra time)', async ({ page }) => {
  await boot(page);
  await startGame(page, /Charades/);
  await startTurn(page);
  await btn(page, 'Correct, got it').click();
  await page.waitForTimeout(3000);
  const before = await secondsLeft(page);
  await page.reload();
  await expect(btn(page, 'Pause')).toBeVisible({ timeout: 30_000 });
  const after = await secondsLeft(page);
  expect(after).toBeLessThanOrEqual(before);
  expect(after).toBeGreaterThan(before - 15);
  await expect(page.getByText('1 got')).toBeVisible();
});

test('refresh between turns: Resume restores teams, scores and turn', async ({ page }) => {
  await boot(page);
  await btn(page, /Forbidden Words/).click();
  await btn(page, 'Add a team').click();
  await page.getByRole('textbox').first().fill('Sadza Squad');
  await btn(page, 'Start game').click();
  await startTurn(page);
  await btn(page, 'Correct, got it').click();
  await endTurnViaPause(page);
  await tap(page, 'Next team');
  await expect(page.getByText('TEAM B’S TURN')).toBeVisible();
  await page.reload();
  await expect(page.getByText('Your game is still on')).toBeVisible({ timeout: 30_000 });
  await btn(page, 'Resume').click();
  await expect(page.getByText('TEAM B’S TURN')).toBeVisible();
  await expect(page.getByText('Sadza Squad: 1 points')).toBeVisible();
  await expect(page.getByText(/^Team C: 0 points/)).toBeVisible();
});

test('discarding an unfinished game needs confirmation', async ({ page }) => {
  await boot(page);
  await startGame(page, /Charades/);
  await tap(page, 'Game menu');
  await btn(page, /^Home/).click();
  await btn(page, 'Discard').click();
  await btn(page, 'Cancel').click();
  await expect(page.getByText('Your game is still on')).toBeVisible();
  await btn(page, 'Discard').click();
  await btn(page, 'Discard game').click();
  await expect(page.getByText('Your game is still on')).toHaveCount(0);
  await expect(btn(page, /30-Second Sprint/)).toBeVisible();
});

test('works offline after the first load', async ({ page, context }) => {
  await boot(page);
  // Wait until the service worker controls the page and has cached the engine.
  await page.evaluate(async () => { await navigator.serviceWorker.ready; });
  await page.reload();
  await expect(btn(page, /30-Second Sprint/)).toBeVisible({ timeout: 30_000 });
  await page.evaluate(() => new Promise((r) => setTimeout(r, 5000)));
  await context.setOffline(true);
  await page.reload();
  await expect(btn(page, /30-Second Sprint/)).toBeVisible({ timeout: 30_000 });
  await startGame(page, /30-Second Sprint/);
  await startTurn(page);
  await page.getByRole('switch').nth(0).click();
  await endTurnViaPause(page);
  await expect(standing(page, 'Team A', 1)).toBeVisible();
  await context.setOffline(false);
});

test('small phone (360×640): every game renders without overflow errors', async ({ page }) => {
  await page.setViewportSize({ width: 360, height: 640 });
  const errors: string[] = [];
  page.on('console', (m) => { if (/overflow|RenderFlex|Exception/i.test(m.text())) errors.push(m.text()); });
  await boot(page);
  for (const g of [/30-Second Sprint/, /Charades/, /Trivia Challenge/, /Forbidden Words/]) {
    await startGame(page, g);
    if (g.source !== '30-Second Sprint') await btn(page, 'Start new').click();
    await startTurn(page);
    await page.waitForTimeout(300);
    await btn(page, 'Pause').click();
    await btn(page, /^Home/).click();
  }
  expect(errors).toEqual([]);
});

// Tests for hobbies.html
const { test, expect } = require('@playwright/test');

test.describe('hobbies.html', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto('/hobbies.html');
  });

  // ── Page load ──────────────────────────────────────────────

  test('page loads successfully (HTTP 200)', async ({ page }) => {
    const response = await page.goto('/hobbies.html');
    expect(response.status()).toBe(200);
  });

  test('page title contains "hobbies"', async ({ page }) => {
    await expect(page).toHaveTitle(/hobbies/i);
  });

  // ── Tab state ───────────────────────────────────────────────

  test('hobbies tab has active class', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="hobbies.html"]')).toHaveClass(/terminal__tab--active/);
  });

  test('all other tabs are NOT active', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="about.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="education.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="experience.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  // ── Content ─────────────────────────────────────────────────

  test('content shows hobbies list', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Cycling');
    await expect(page.locator('.terminal__content')).toContainText('Home Lab');
    await expect(page.locator('.terminal__content')).toContainText('Chess');
  });

  test('content shows open source and reading', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Open Source');
    await expect(page.locator('.terminal__content')).toContainText('Reading');
  });

  test('content shows AI engineering hobby', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('AI Engineering');
  });

  // ── Colors ──────────────────────────────────────────────────

  test('body background is black', async ({ page }) => {
    const bg = await page.evaluate(() =>
      window.getComputedStyle(document.body).backgroundColor
    );
    expect(bg).toBe('rgb(0, 0, 0)');
  });

  test('YAML keys are red', async ({ page }) => {
    const color = await page.locator('.yaml-key').first().evaluate(el =>
      window.getComputedStyle(el).color
    );
    expect(color).toBe('rgb(255, 59, 48)');
  });

  test('YAML values are yellow', async ({ page }) => {
    const color = await page.locator('.yaml-val').first().evaluate(el =>
      window.getComputedStyle(el).color
    );
    expect(color).toBe('rgb(255, 204, 0)');
  });

  // ── Navigation ──────────────────────────────────────────────

  test('clicking about tab navigates to about.html', async ({ page }) => {
    await page.locator('.terminal__tab[href="about.html"]').click();
    await expect(page).toHaveURL(/about\.html/);
  });

  test('clicking experience tab navigates to experience.html', async ({ page }) => {
    await page.locator('.terminal__tab[href="experience.html"]').click();
    await expect(page).toHaveURL(/experience\.html/);
  });

});

// Tests for experience.html
const { test, expect } = require('@playwright/test');

test.describe('experience.html', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto('/experience.html');
  });

  // ── Page load ──────────────────────────────────────────────

  test('page loads successfully (HTTP 200)', async ({ page }) => {
    const response = await page.goto('/experience.html');
    expect(response.status()).toBe(200);
  });

  test('page title contains "experience"', async ({ page }) => {
    await expect(page).toHaveTitle(/experience/i);
  });

  // ── Tab state ───────────────────────────────────────────────

  test('experience tab has active class', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="experience.html"]')).toHaveClass(/terminal__tab--active/);
  });

  test('about and education tabs are NOT active', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="about.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="education.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  test('hobbies tab is NOT active', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="hobbies.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  // ── Content ─────────────────────────────────────────────────

  test('content shows DevOps/cloud keywords', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Kubernetes');
    await expect(page.locator('.terminal__content')).toContainText('Terraform');
    await expect(page.locator('.terminal__content')).toContainText('AWS');
  });

  test('content shows role titles', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('DevOps Engineer');
    await expect(page.locator('.terminal__content')).toContainText('MLOps');
  });

  test('content shows multiple companies', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('AxiomQ');
    await expect(page.locator('.terminal__content')).toContainText('Jaggaer');
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

  test('clicking hobbies tab navigates to hobbies.html', async ({ page }) => {
    await page.locator('.terminal__tab[href="hobbies.html"]').click();
    await expect(page).toHaveURL(/hobbies\.html/);
  });

});

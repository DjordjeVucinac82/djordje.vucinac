// Tests for education.html
const { test, expect } = require('@playwright/test');

test.describe('education.html', () => {

  test.beforeEach(async ({ page }) => {
    await page.goto('/education.html');
  });

  // ── Page load ──────────────────────────────────────────────

  test('page loads successfully (HTTP 200)', async ({ page }) => {
    const response = await page.goto('/education.html');
    expect(response.status()).toBe(200);
  });

  test('page title contains "education"', async ({ page }) => {
    await expect(page).toHaveTitle(/education/i);
  });

  // ── Tab state ───────────────────────────────────────────────

  test('education tab has active class', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="education.html"]')).toHaveClass(/terminal__tab--active/);
  });

  test('about tab is NOT active', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="about.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  test('experience and hobbies tabs are NOT active', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="experience.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="hobbies.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  // ── Content ─────────────────────────────────────────────────

  test('content shows degree information', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Bachelor');
    await expect(page.locator('.terminal__content')).toContainText('Belgrade');
  });

  test('content shows certifications', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('AWS Certified');
    await expect(page.locator('.terminal__content')).toContainText('Kubernetes');
    await expect(page.locator('.terminal__content')).toContainText('Terraform');
    await expect(page.locator('.terminal__content')).toContainText('CCNA');
  });

  // ── Colors ──────────────────────────────────────────────────

  test('body background is black', async ({ page }) => {
    const bg = await page.evaluate(() =>
      window.getComputedStyle(document.body).backgroundColor
    );
    expect(bg).toBe('rgb(0, 0, 0)');
  });

  test('YAML section key "education" is red', async ({ page }) => {
    const color = await page.locator('.yaml-section').first().evaluate(el =>
      window.getComputedStyle(el).color
    );
    expect(color).toBe('rgb(255, 59, 48)');
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

  test('clicking hobbies tab navigates to hobbies.html', async ({ page }) => {
    await page.locator('.terminal__tab[href="hobbies.html"]').click();
    await expect(page).toHaveURL(/hobbies\.html/);
  });

});

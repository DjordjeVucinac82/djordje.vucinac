// Tests for aboutme.html — the landing page
const { test, expect } = require('@playwright/test');

test.describe('aboutme.html', () => {

  // Navigate to the about page before each test
  test.beforeEach(async ({ page }) => {
    await page.goto('/aboutme.html');
  });

  // ── Page load ──────────────────────────────────────────────

  test('page loads successfully (HTTP 200)', async ({ page }) => {
    const response = await page.goto('/aboutme.html');
    expect(response.status()).toBe(200);
  });

  test('page title contains "about"', async ({ page }) => {
    await expect(page).toHaveTitle(/about/i);
  });

  // ── Terminal chrome ─────────────────────────────────────────

  test('terminal window, titlebar, tabbar and content are visible', async ({ page }) => {
    await expect(page.locator('.terminal')).toBeVisible();
    await expect(page.locator('.terminal__titlebar')).toBeVisible();
    await expect(page.locator('.terminal__tabbar')).toBeVisible();
    await expect(page.locator('.terminal__content')).toBeVisible();
  });

  test('macOS traffic light dots are rendered', async ({ page }) => {
    await expect(page.locator('.terminal__dot--close')).toBeVisible();
    await expect(page.locator('.terminal__dot--min')).toBeVisible();
    await expect(page.locator('.terminal__dot--max')).toBeVisible();
  });

  test('title bar shows correct window title', async ({ page }) => {
    await expect(page.locator('.terminal__titlebar-title')).toContainText('djordje.vucinac.com');
  });

  // ── Tab state ───────────────────────────────────────────────

  test('about tab has active class', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="aboutme.html"]')).toHaveClass(/terminal__tab--active/);
  });

  test('other tabs do NOT have active class', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="education.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="experience.html"]')).not.toHaveClass(/terminal__tab--active/);
    await expect(page.locator('.terminal__tab[href="hobbies.html"]')).not.toHaveClass(/terminal__tab--active/);
  });

  test('all four navigation tabs are present', async ({ page }) => {
    await expect(page.locator('.terminal__tab[href="aboutme.html"]')).toBeVisible();
    await expect(page.locator('.terminal__tab[href="education.html"]')).toBeVisible();
    await expect(page.locator('.terminal__tab[href="experience.html"]')).toBeVisible();
    await expect(page.locator('.terminal__tab[href="hobbies.html"]')).toBeVisible();
  });

  // ── Content ─────────────────────────────────────────────────

  test('content shows name "Djordje Vucinac"', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Djordje Vucinac');
  });

  test('content shows role and location', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('DevOps');
    await expect(page.locator('.terminal__content')).toContainText('Belgrade');
  });

  test('linkedin link points to correct URL and opens in new tab', async ({ page }) => {
    const link = page.locator('a.yaml-link[href*="linkedin.com"]');
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute('href', 'https://www.linkedin.com/in/djordje-vucinac-b80761b9/');
    await expect(link).toHaveAttribute('target', '_blank');
  });

  test('github link points to correct URL and opens in new tab', async ({ page }) => {
    const link = page.locator('a.yaml-link[href*="github.com"]');
    await expect(link).toBeVisible();
    await expect(link).toHaveAttribute('href', 'https://github.com/DjordjeVucinac82');
    await expect(link).toHaveAttribute('target', '_blank');
  });

  test('content shows key skills', async ({ page }) => {
    await expect(page.locator('.terminal__content')).toContainText('Kubernetes');
    await expect(page.locator('.terminal__content')).toContainText('Terraform');
    await expect(page.locator('.terminal__content')).toContainText('AWS');
  });

  test('YAML comment line is visible', async ({ page }) => {
    await expect(page.locator('.yaml-comment')).toBeVisible();
    await expect(page.locator('.yaml-comment')).toContainText('#');
  });

  // ── Colors ──────────────────────────────────────────────────

  test('body background is black (#000000 = rgb(0, 0, 0))', async ({ page }) => {
    const bg = await page.evaluate(() =>
      window.getComputedStyle(document.body).backgroundColor
    );
    expect(bg).toBe('rgb(0, 0, 0)');
  });

  test('YAML keys are red (#ff3b30 = rgb(255, 59, 48))', async ({ page }) => {
    const color = await page.locator('.yaml-key').first().evaluate(el =>
      window.getComputedStyle(el).color
    );
    expect(color).toBe('rgb(255, 59, 48)');
  });

  test('YAML values are yellow (#ffcc00 = rgb(255, 204, 0))', async ({ page }) => {
    const color = await page.locator('.yaml-val').first().evaluate(el =>
      window.getComputedStyle(el).color
    );
    expect(color).toBe('rgb(255, 204, 0)');
  });

  // ── Navigation ──────────────────────────────────────────────

  test('clicking education tab navigates to education.html', async ({ page }) => {
    await page.locator('.terminal__tab[href="education.html"]').click();
    await expect(page).toHaveURL(/education\.html/);
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

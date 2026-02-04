// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Shop System', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/shop');
    await page.waitForTimeout(1000);
  });

  test('should display 5 shop categories', async ({ page }) => {
    // 5개 카테고리 확인
    await expect(page.getByText(/의류|clothes/i)).toBeVisible();
    await expect(page.getByText(/잡화|accessories/i)).toBeVisible();
    await expect(page.getByText(/가구|furniture/i)).toBeVisible();
    await expect(page.getByText(/배경|background/i)).toBeVisible();
    await expect(page.getByText(/시즌|season/i)).toBeVisible();
  });

  test('should navigate to clothes category', async ({ page }) => {
    await page.click('text=/의류|clothes/i');
    
    await expect(page).toHaveURL(/shop-category\/clothes/);
    
    // 아이템 그리드 표시 확인
    const items = page.locator('[data-testid="shop-item"]');
    await expect(items.first()).toBeVisible();
  });

  test('should display item details on click', async ({ page }) => {
    await page.goto('/shop-category/clothes');
    await page.waitForTimeout(1000);
    
    // 첫 번째 아이템 클릭
    await page.locator('[data-testid="shop-item"]').first().click();
    
    // 구매 다이얼로그 표시 확인
    await expect(page.getByText(/구매|purchase/i)).toBeVisible();
  });

  test('should show locked items with D-day', async ({ page }) => {
    await page.goto('/shop-category/clothes');
    await page.waitForTimeout(1000);
    
    // 잠긴 아이템 확인
    const lockedItems = page.locator('text=/D-[0-9]+/');
    const count = await lockedItems.count();
    
    expect(count).toBeGreaterThan(0);
  });

  test('should purchase item with sprouts', async ({ page }) => {
    await page.goto('/shop-category/clothes');
    await page.waitForTimeout(1000);
    
    // 잠기지 않은 첫 번째 아이템 클릭
    const unlockedItem = page.locator('[data-testid="shop-item"]').first();
    await unlockedItem.click();
    
    // 구매 버튼 클릭
    await page.click('text=/구매|purchase/i');
    
    // 성공 메시지 확인
    await expect(page.getByText(/구매.*성공|purchased/i)).toBeVisible({ timeout: 5000 });
  });
});

test.describe('Credit System', () => {
  test('should display credit balance', async ({ page }) => {
    await page.goto('/credit-balance');
    await page.waitForTimeout(1000);
    
    // 크레딧 잔액 표시 확인
    await expect(page.getByText(/250|credits/i)).toBeVisible();
  });

  test('should show credit charge options', async ({ page }) => {
    await page.goto('/credit-info-1');
    await page.waitForTimeout(1000);
    
    // 보너스 티어 표시 확인
    await expect(page.getByText(/6%/)).toBeVisible();
    await expect(page.getByText(/10%/)).toBeVisible();
    await expect(page.getByText(/20%/)).toBeVisible();
  });

  test('should display usage info', async ({ page }) => {
    await page.goto('/credit-info-2');
    await page.waitForTimeout(1000);
    
    // 4가지 사용처 확인
    const usageCards = page.locator('[data-testid="usage-card"]');
    await expect(usageCards).toHaveCount(4);
  });
});

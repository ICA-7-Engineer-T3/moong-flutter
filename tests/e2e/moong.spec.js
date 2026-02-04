// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Moong Management', () => {
  test.beforeEach(async ({ page }) => {
    // 로그인된 상태로 시작 (fixture 사용 권장)
    await page.goto('/');
    await page.waitForTimeout(2000);
    
    // 자동 로그인 (또는 세션 설정)
    await page.goto('/moong-select');
  });

  test('should display moong types', async ({ page }) => {
    await page.waitForSelector('text=Pet', { timeout: 10000 });
    
    // 3가지 타입 확인
    await expect(page.getByText('Pet')).toBeVisible();
    await expect(page.getByText('Mate')).toBeVisible();
    await expect(page.getByText('Guide')).toBeVisible();
  });

  test('should create new moong', async ({ page }) => {
    await page.waitForSelector('text=Pet', { timeout: 10000 });
    
    // Pet 타입 선택
    await page.click('text=Pet');
    
    // 이름 입력 (Flutter 텍스트 필드)
    await page.fill('input', '테스트뭉');
    
    // 생성 버튼 클릭
    await page.click('text=/create|생성/i');
    
    // 정원 화면으로 이동 확인
    await expect(page).toHaveURL(/garden/, { timeout: 10000 });
  });

  test('should display moong in garden', async ({ page }) => {
    await page.goto('/garden');
    await page.waitForSelector('text=/뭉/i', { timeout: 10000 });
    
    // 뭉 캐릭터 표시 확인
    await expect(page.locator('[data-testid="moong-character"]')).toBeVisible();
  });

  test('should navigate to main moong screen', async ({ page }) => {
    await page.goto('/garden');
    await page.waitForTimeout(1000);
    
    // 메인 화면으로 이동
    await page.goto('/main');
    
    // 애니메이션 확인 (호흡 애니메이션은 CSS로 확인)
    const moongElement = page.locator('[data-testid="moong-character"]');
    await expect(moongElement).toBeVisible();
  });
});

test.describe('Moong Interaction', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/main');
    await page.waitForTimeout(1000);
  });

  test('should open chat screen', async ({ page }) => {
    // 채팅 아이콘 클릭
    await page.click('[aria-label="chat"]');
    
    await expect(page).toHaveURL(/chat/);
  });

  test('should show quest screen', async ({ page }) => {
    await page.goto('/quest');
    await page.waitForTimeout(1000);
    
    // 3개의 퀘스트 확인
    const quests = page.locator('[data-testid="quest-card"]');
    await expect(quests).toHaveCount(3);
  });

  test('should display food selection', async ({ page }) => {
    await page.goto('/food');
    await page.waitForTimeout(1000);
    
    // 5개의 음식 아이템 확인
    const foodItems = page.locator('[data-testid="food-item"]');
    await expect(foodItems).toHaveCount(5);
  });
});

// @ts-check
const { test, expect } = require('@playwright/test');

/**
 * Flutter Web Visual Regression Tests
 * 
 * 이 테스트는 Flutter Web의 Canvas 렌더링으로 인해 
 * UI 상호작용 테스트가 어려운 점을 고려하여
 * 스크린샷 기반 시각적 회귀 테스트를 수행합니다.
 * 
 * 첫 실행 시 기준 스크린샷이 생성되고,
 * 이후 실행 시 기준 이미지와 비교합니다.
 */

test.describe('Visual Regression Tests - Core Screens', () => {
  test('Splash screen', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(2000); // 애니메이션 완료 대기
    await expect(page).toHaveScreenshot('01-splash-screen.png');
  });

  test('Login screen', async ({ page }) => {
    await page.goto('/login');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('02-login-screen.png');
  });

  test('Signup screen', async ({ page }) => {
    await page.goto('/signup');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('03-signup-screen.png');
  });

  test('Moong select screen', async ({ page }) => {
    await page.goto('/moong-select');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('04-moong-select.png');
  });

  test('Main moong screen', async ({ page }) => {
    await page.goto('/main');
    await page.waitForTimeout(1000); // 호흡 애니메이션 대기
    await expect(page).toHaveScreenshot('05-main-moong.png');
  });
});

test.describe('Visual Regression Tests - Navigation Screens', () => {
  test('Garden screen', async ({ page }) => {
    await page.goto('/garden');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('06-garden.png');
  });

  test('Quest screen', async ({ page }) => {
    await page.goto('/quest');
    await page.waitForTimeout(2000); // networkidle 대신 고정 대기
    await expect(page).toHaveScreenshot('07-quest.png');
  });

  test('Food screen', async ({ page }) => {
    await page.goto('/food');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('08-food.png');
  });

  test('Settings screen', async ({ page }) => {
    await page.goto('/settings');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('09-settings.png');
  });

  test('Chat screen', async ({ page }) => {
    await page.goto('/chat');
    await page.waitForTimeout(2000); // networkidle 대신 고정 대기
    await expect(page).toHaveScreenshot('10-chat.png');
  });
});

test.describe('Visual Regression Tests - Shop System', () => {
  test('Shop main screen', async ({ page }) => {
    await page.goto('/shop');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('11-shop-main.png');
  });

  test('Shop category - Clothes', async ({ page }) => {
    await page.goto('/shop-category/clothes');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('12-shop-clothes.png');
  });

  test('Shop category - Accessories', async ({ page }) => {
    await page.goto('/shop-category/accessories');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('13-shop-accessories.png');
  });

  test('Shop category - Furniture', async ({ page }) => {
    await page.goto('/shop-category/furniture');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('14-shop-furniture.png');
  });

  test('Shop category - Background', async ({ page }) => {
    await page.goto('/shop-category/background');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('15-shop-background.png');
  });

  test('Shop category - Season', async ({ page }) => {
    await page.goto('/shop-category/season');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('16-shop-season.png');
  });
});

test.describe('Visual Regression Tests - Credit & Archive', () => {
  test('Credit Info 1 screen', async ({ page }) => {
    await page.goto('/credit-info-1');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('17-credit-info-1.png');
  });

  test('Credit Info 2 screen', async ({ page }) => {
    await page.goto('/credit-info-2');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('18-credit-info-2.png');
  });

  test('Credit Balance screen', async ({ page }) => {
    await page.goto('/credit-balance');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('19-credit-balance.png');
  });

  test('Archive main screen', async ({ page }) => {
    await page.goto('/archive-main');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('20-archive-main.png');
  });

  test('Archive screen', async ({ page }) => {
    await page.goto('/archive');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('21-archive.png');
  });
});

test.describe('Visual Regression Tests - Special Screens', () => {
  test('Quest completed screen', async ({ page }) => {
    await page.goto('/quest-completed');
    await page.waitForTimeout(1500); // Confetti 애니메이션
    await expect(page).toHaveScreenshot('22-quest-completed.png');
  });

  test('Intimacy up screen', async ({ page }) => {
    await page.goto('/intimacy-up');
    await page.waitForTimeout(1500); // Hearts 애니메이션
    await expect(page).toHaveScreenshot('23-intimacy-up.png');
  });

  test('Emotion analysis screen', async ({ page }) => {
    await page.goto('/emotion-analysis');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('24-emotion-analysis.png');
  });

  test('Music generation screen', async ({ page }) => {
    await page.goto('/music-generation');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('25-music-generation.png');
  });

  test('Exercise suggestion screen', async ({ page }) => {
    await page.goto('/exercise-suggestion');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('26-exercise-suggestion.png');
  });

  test('Food suggestion screen', async ({ page }) => {
    await page.goto('/food-suggestion');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('27-food-suggestion.png');
  });
});

test.describe('Visual Regression Tests - Moong States', () => {
  test('Sad moong screen', async ({ page }) => {
    await page.goto('/sad-moong');
    await page.waitForTimeout(1000); // Rain 애니메이션
    await expect(page).toHaveScreenshot('28-sad-moong.png');
  });

  test('Cute moong screen', async ({ page }) => {
    await page.goto('/cute-moong');
    await page.waitForTimeout(1000); // Bouncing 애니메이션
    await expect(page).toHaveScreenshot('29-cute-moong.png');
  });

  test('Garden view screen', async ({ page }) => {
    await page.goto('/garden-view');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('30-garden-view.png');
  });
});

test.describe('Visual Regression Tests - Background Collection', () => {
  test('Forest background', async ({ page }) => {
    await page.goto('/background-forest');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('31-bg-forest.png');
  });

  test('Beach background', async ({ page }) => {
    await page.goto('/background-beach');
    await page.waitForTimeout(500); // Wave 애니메이션
    await expect(page).toHaveScreenshot('32-bg-beach.png');
  });

  test('Space background', async ({ page }) => {
    await page.goto('/background-space');
    await page.waitForTimeout(500); // Star 애니메이션
    await expect(page).toHaveScreenshot('33-bg-space.png');
  });

  test('Sakura background', async ({ page }) => {
    await page.goto('/background-sakura');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('34-bg-sakura.png');
  });
});

test.describe('Visual Regression Tests - Additional Screens', () => {
  test('Moong choice screen', async ({ page }) => {
    await page.goto('/moong-choice');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('35-moong-choice.png');
  });

  test('Profile edit screen', async ({ page }) => {
    await page.goto('/profile-edit');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('36-profile-edit.png');
  });

  test('Background screen', async ({ page }) => {
    await page.goto('/background');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('37-background.png');
  });

  test('Statistics screen', async ({ page }) => {
    await page.goto('/statistics');
    await page.waitForTimeout(2000); // networkidle 대신 고정 대기
    await expect(page).toHaveScreenshot('38-statistics.png');
  });

  test('Chat detail screen', async ({ page }) => {
    await page.goto('/chat-detail');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('39-chat-detail.png');
  });

  test('Chat input screen', async ({ page }) => {
    await page.goto('/chat-input');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('40-chat-input.png');
  });

  test('Credit refund screen', async ({ page }) => {
    await page.goto('/credit-refund');
    await page.waitForLoadState('networkidle');
    await expect(page).toHaveScreenshot('41-credit-refund.png');
  });
});

test.describe('Performance Tests', () => {
  test('Page load time check', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    const loadTime = Date.now() - startTime;

    console.log(`Page load time: ${loadTime}ms`);
    // 10초 이내 로딩 (Canvas 렌더링 고려)
    expect(loadTime).toBeLessThan(10000);
  });
});

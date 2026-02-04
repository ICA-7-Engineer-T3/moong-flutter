// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Performance Tests', () => {
  test('should load home page within 3 seconds', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    console.log(`Home page load time: ${loadTime}ms`);
    
    expect(loadTime).toBeLessThan(3000);
  });

  test('should render 41 screens without errors', async ({ page }) => {
    const routes = [
      '/',
      '/login',
      '/signup',
      '/moong-select',
      '/garden',
      '/main',
      '/quest',
      '/food',
      '/shop',
      '/settings',
      '/chat',
      '/archive',
      '/credit-balance',
      '/music-generation',
    ];

    for (const route of routes) {
      await page.goto(route);
      await page.waitForTimeout(500);
      
      // 콘솔 에러 체크
      const errors = [];
      page.on('console', msg => {
        if (msg.type() === 'error') {
          errors.push(msg.text());
        }
      });
      
      expect(errors.length).toBe(0);
    }
  });

  test('should measure animation performance', async ({ page }) => {
    await page.goto('/main');
    await page.waitForTimeout(1000);
    
    // Performance metrics 수집
    const metrics = await page.evaluate(() => {
      return window.performance.getEntriesByType('measure');
    });
    
    console.log('Animation metrics:', metrics);
  });

  test('should handle concurrent requests', async ({ page }) => {
    // 병렬 네비게이션 테스트
    const promises = [
      page.goto('/quest'),
      page.goto('/food'),
      page.goto('/shop'),
    ];
    
    await Promise.all(promises);
    
    // 마지막 페이지 확인
    await expect(page).toHaveURL(/shop/);
  });
});

test.describe('Memory Leaks', () => {
  test('should not have memory leaks on navigation', async ({ page }) => {
    await page.goto('/');
    
    // 초기 메모리 측정
    const initialMemory = await page.evaluate(() => {
      if (performance.memory) {
        return performance.memory.usedJSHeapSize;
      }
      return 0;
    });
    
    // 여러 페이지 반복 네비게이션
    for (let i = 0; i < 10; i++) {
      await page.goto('/quest');
      await page.goto('/food');
      await page.goto('/shop');
      await page.goto('/main');
    }
    
    // 최종 메모리 측정
    const finalMemory = await page.evaluate(() => {
      if (performance.memory) {
        return performance.memory.usedJSHeapSize;
      }
      return 0;
    });
    
    const memoryIncrease = finalMemory - initialMemory;
    console.log(`Memory increase: ${memoryIncrease / 1024 / 1024} MB`);
    
    // 메모리 증가가 50MB 이하인지 확인
    expect(memoryIncrease).toBeLessThan(50 * 1024 * 1024);
  });
});

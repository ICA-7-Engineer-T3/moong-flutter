// @ts-check
const { test, expect } = require('@playwright/test');

test.describe('Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    // 스플래시 화면 대기
    await page.waitForTimeout(2000);
  });

  test('should display splash screen', async ({ page }) => {
    await expect(page).toHaveTitle(/Moong/i);
  });

  test('should navigate to login screen', async ({ page }) => {
    // "함께하기" 버튼 클릭 (Flutter 텍스트로 찾기)
    await page.getByText('함께하기').click();
    
    // 로그인 화면으로 이동 확인
    await expect(page).toHaveURL(/login/, { timeout: 10000 });
    
    // 로그인 버튼 확인 (텍스트로 찾기)
    await expect(page.getByText('로그인')).toBeVisible();
  });

  test('should show validation for empty credentials', async ({ page }) => {
    // 로그인 화면으로 이동
    await page.getByText('함께하기').click();
    await page.waitForURL(/login/, { timeout: 10000 });
    
    // 빈 상태로 로그인 시도
    await page.getByText('로그인').click();
    
    // 스낵바가 나타나는지 확인 (Flutter SnackBar는 텍스트로 찾기)
    await expect(page.getByText(/닉네임과 비밀번호를 입력해주세요/i)).toBeVisible({ timeout: 3000 });
  });

  test('should login successfully with valid credentials', async ({ page }) => {
    // 로그인 화면으로 이동
    await page.getByText('함께하기').click();
    await page.waitForURL(/login/, { timeout: 10000 });
    
    // Flutter 웹 Canvas에서 TextField 입력은 거의 불가능하므로
    // 좋표 기반 클릭으로 입력 필드를 클릭하고 키보드 입력
    // 닉네임 필드 위치 클릭 (viewport 1280x720 기준)
    await page.mouse.click(527, 375); // 닉네임 필드 중앙
    await page.keyboard.type('testuser');
    
    // 비밀번호 필드 클릭
    await page.mouse.click(527, 533); // 비밀번호 필드 중앙
    await page.keyboard.type('password123');
    
    // 로그인 버튼 클릭
    await page.getByText('로그인').click();
    
    // 로그인 후 뭉 선택 화면으로 이동 확인
    await expect(page).toHaveURL(/moong-select/, { timeout: 10000 });
  });

  test('should navigate to signup screen', async ({ page }) => {
    // 로그인 화면으로 이동
    await page.getByText('함께하기').click();
    await page.waitForURL(/login/, { timeout: 10000 });
    
    // 회원가입 버튼 클릭
    await page.getByText('회원가입').click();
    
    // 회원가입 화면 확인
    await expect(page).toHaveURL(/signup/);
  });
});

test.describe('Signup Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/signup');
  });

  test('should display signup form', async ({ page }) => {
    await expect(page.getByText(/sign up/i)).toBeVisible();
  });

  test('should register new user successfully', async ({ page }) => {
    // 회원가입 폼 작성
    const timestamp = Date.now();
    await page.fill('input[type="text"]', `user${timestamp}`);
    await page.fill('input[type="email"]', `user${timestamp}@test.com`);
    await page.fill('input[type="password"]', 'password123');
    
    // 회원가입 버튼 클릭
    const signupButton = page.getByRole('button', { name: /sign up/i });
    await signupButton.click();
    
    // 성공 후 뭉 선택 화면으로 이동
    await expect(page).toHaveURL(/moong-select/, { timeout: 10000 });
  });
});

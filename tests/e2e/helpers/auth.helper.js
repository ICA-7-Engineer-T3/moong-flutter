// @ts-check

/**
 * Authentication Helper Functions
 */

/**
 * 테스트용 사용자로 로그인
 * @param {import('@playwright/test').Page} page
 * @param {string} username
 * @param {string} password
 */
async function login(page, username = 'testuser', password = 'password123') {
  await page.goto('/login');
  await page.waitForTimeout(1000);
  
  // 로그인 폼 작성
  await page.fill('input[type="text"]', username);
  await page.fill('input[type="password"]', password);
  
  // 로그인 버튼 클릭
  await page.click('button:has-text("Login")');
  
  // 로그인 완료 대기
  await page.waitForURL(/garden/, { timeout: 10000 });
}

/**
 * 새 사용자 생성 및 로그인
 * @param {import('@playwright/test').Page} page
 */
async function createUserAndLogin(page) {
  const timestamp = Date.now();
  const username = `user${timestamp}`;
  const email = `user${timestamp}@test.com`;
  const password = 'password123';
  
  await page.goto('/signup');
  await page.waitForTimeout(1000);
  
  // 회원가입 폼 작성
  await page.fill('input[type="text"]', username);
  await page.fill('input[type="email"]', email);
  await page.fill('input[type="password"]', password);
  
  // 회원가입 버튼 클릭
  await page.click('button:has-text("Sign Up")');
  
  // 뭉 선택 화면으로 이동 대기
  await page.waitForURL(/moong-select/, { timeout: 10000 });
  
  return { username, email, password };
}

/**
 * 로그아웃
 * @param {import('@playwright/test').Page} page
 */
async function logout(page) {
  await page.goto('/settings');
  await page.waitForTimeout(1000);
  
  // 로그아웃 버튼 클릭
  await page.click('text=/logout|로그아웃/i');
  
  // 확인 다이얼로그
  await page.click('button:has-text("로그아웃")');
  
  // 로그인 화면으로 이동 대기
  await page.waitForURL(/login/, { timeout: 5000 });
}

module.exports = {
  login,
  createUserAndLogin,
  logout,
};

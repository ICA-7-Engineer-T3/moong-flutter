// @ts-check
const { test as base } = require('@playwright/test');
const { login, createUserAndLogin } = require('../helpers/auth.helper');

/**
 * Custom fixtures for authenticated tests
 */
const test = base.extend({
  /**
   * Authenticated user fixture
   * 모든 테스트가 로그인된 상태로 시작
   */
  authenticatedPage: async ({ page }, use) => {
    await login(page);
    await use(page);
  },

  /**
   * New user fixture
   * 새로운 사용자를 생성하고 로그인
   */
  newUserPage: async ({ page }, use) => {
    const user = await createUserAndLogin(page);
    await use({ page, user });
  },
});

module.exports = { test };

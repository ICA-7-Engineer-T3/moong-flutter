# 🧪 Moong App E2E Tests

Playwright를 사용한 Flutter 웹 앱 End-to-End 테스트

## 📋 목차

- [설치](#설치)
- [테스트 실행](#테스트-실행)
- [병렬 테스트](#병렬-테스트)
- [테스트 작성](#테스트-작성)
- [CI/CD 통합](#cicd-통합)

## 설치

```bash
cd tests

# 의존성 설치
npm install

# 브라우저 설치
npm run install:browsers
```

## 테스트 실행

### 기본 실행

```bash
# 모든 테스트 실행 (Headless)
npm test

# UI 모드로 실행
npm run test:ui

# Headed 모드 (브라우저 보이기)
npm run test:headed

# 디버그 모드
npm run test:debug
```

### 특정 브라우저

```bash
# Chromium만
npm run test:chromium

# Firefox만
npm run test:firefox

# WebKit만
npm run test:webkit

# 모바일 브라우저만
npm run test:mobile
```

### 특정 테스트 파일

```bash
# 인증 테스트만
npx playwright test auth.spec.js

# 상점 테스트만
npx playwright test shop.spec.js

# 특정 테스트만
npx playwright test -g "should login successfully"
```

## 병렬 테스트

### 자동 병렬 실행

Playwright는 기본적으로 병렬 실행을 지원합니다:

```bash
# 8개 워커로 병렬 실행
npm run test:parallel

# 또는 직접 워커 수 지정
npx playwright test --workers=10
```

### 병렬 실행 전략

```javascript
// playwright.config.js
module.exports = defineConfig({
  // 모든 테스트를 병렬로 실행
  fullyParallel: true,
  
  // 워커 수 설정
  workers: process.env.CI ? 2 : 4,
  
  // 프로젝트별 병렬 실행 (브라우저별)
  projects: [
    { name: 'chromium' },
    { name: 'firefox' },
    { name: 'webkit' },
    { name: 'mobile-chrome' },
    { name: 'mobile-safari' },
  ],
});
```

### 쉘 스크립트로 실행

```bash
# 병렬 테스트 + Flutter 서버 자동 시작/종료
./run-parallel-tests.sh

# 테스트 후 리포트 자동 열기
./run-parallel-tests.sh --open-report
```

## 테스트 구조

```
tests/
├── playwright.config.js      # Playwright 설정
├── package.json               # 의존성
├── run-parallel-tests.sh      # 병렬 실행 스크립트
├── e2e/                       # E2E 테스트
│   ├── auth.spec.js          # 인증 테스트
│   ├── moong.spec.js         # 뭉 관리 테스트
│   ├── shop.spec.js          # 상점 테스트
│   ├── performance.spec.js   # 성능 테스트
│   ├── helpers/              # 헬퍼 함수
│   │   └── auth.helper.js
│   └── fixtures/             # 테스트 픽스처
│       └── auth.fixture.js
└── test-results/             # 테스트 결과
    ├── html/                 # HTML 리포트
    ├── results.json          # JSON 결과
    └── junit.xml             # JUnit XML
```

## 테스트 작성 가이드

### 기본 테스트

```javascript
const { test, expect } = require('@playwright/test');

test('my test', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/Moong/);
});
```

### 인증된 상태로 테스트

```javascript
const { test } = require('./fixtures/auth.fixture');

test('authenticated test', async ({ authenticatedPage }) => {
  await authenticatedPage.goto('/garden');
  // 이미 로그인된 상태
});
```

### 병렬 실행 최적화

```javascript
test.describe.configure({ mode: 'parallel' });

test.describe('Parallel Tests', () => {
  test('test 1', async ({ page }) => { /* ... */ });
  test('test 2', async ({ page }) => { /* ... */ });
  test('test 3', async ({ page }) => { /* ... */ });
});
```

### 데이터 주도 테스트

```javascript
const categories = ['clothes', 'accessories', 'furniture'];

for (const category of categories) {
  test(`should display ${category} items`, async ({ page }) => {
    await page.goto(`/shop-category/${category}`);
    await expect(page.getByText(category)).toBeVisible();
  });
}
```

## Flutter 웹 특수 사항

### Canvas 요소 처리

Flutter 웹은 Canvas를 사용하므로 일반 DOM 접근이 어렵습니다:

```javascript
// ❌ 작동 안 함 (Canvas 내부 요소)
await page.click('text=Login');

// ✅ 좌표 기반 클릭
await page.click('canvas', { position: { x: 640, y: 360 } });

// ✅ data-testid 속성 추가 권장
// Flutter: Semantics(testID: 'login-button')
await page.click('[data-testid="login-button"]');
```

### 스크린샷 비교

```javascript
test('visual regression', async ({ page }) => {
  await page.goto('/main');
  await page.waitForTimeout(1000);
  
  // 스크린샷 촬영 및 비교
  await expect(page).toHaveScreenshot('main-screen.png');
});
```

## 성능 테스트

```javascript
test('load time', async ({ page }) => {
  const startTime = Date.now();
  await page.goto('/');
  await page.waitForLoadState('networkidle');
  const loadTime = Date.now() - startTime;
  
  expect(loadTime).toBeLessThan(3000);
});
```

## CI/CD 통합

### GitHub Actions

```yaml
name: E2E Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        working-directory: tests
        run: npm install
      
      - name: Run tests
        working-directory: tests
        run: npx playwright test --workers=2
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: tests/test-results/
```

### GitLab CI

```yaml
e2e-tests:
  image: mcr.microsoft.com/playwright:v1.40.0
  stage: test
  script:
    - cd tests
    - npm install
    - npx playwright test --workers=2
  artifacts:
    when: always
    paths:
      - tests/test-results/
```

## 리포트 확인

```bash
# HTML 리포트 열기
npm run report

# 또는 직접
npx playwright show-report test-results/html
```

## 트러블슈팅

### Flutter 서버가 시작 안 됨

```bash
# 수동으로 서버 시작
cd ..
flutter run -d web-server --web-port 8080

# 다른 터미널에서 테스트 실행
cd tests
npx playwright test
```

### 타임아웃 에러

```javascript
// 타임아웃 증가
test('slow test', async ({ page }) => {
  test.setTimeout(60000); // 60초
  await page.goto('/');
});
```

### 브라우저 설치 문제

```bash
# 브라우저 재설치
npx playwright install --force --with-deps
```

## 모범 사례

1. **테스트 격리**: 각 테스트는 독립적으로 실행 가능해야 함
2. **명시적 대기**: `waitForSelector` 사용
3. **의미있는 이름**: 테스트 이름으로 무엇을 테스트하는지 명확히
4. **헬퍼 함수**: 반복되는 코드는 헬퍼로 추출
5. **Fixture 활용**: 공통 설정은 fixture로
6. **병렬 실행**: 독립적인 테스트는 병렬로

## 성능 팁

```javascript
// ✅ 병렬 실행
test.describe.configure({ mode: 'parallel' });

// ✅ 불필요한 대기 제거
await page.waitForLoadState('domcontentloaded'); // networkidle 대신

// ✅ 선택자 최적화
page.locator('[data-testid="button"]'); // XPath 대신 CSS
```

---

**Happy Testing! 🎉**

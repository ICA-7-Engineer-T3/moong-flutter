// @ts-check
const { defineConfig, devices } = require('@playwright/test');

/**
 * Moong App E2E Test Configuration
 * Playwright를 사용한 Flutter Web 앱 병렬 테스트
 */
module.exports = defineConfig({
  testDir: './e2e',
  
  // 테스트 결과 아티팩트 저장 경로 (HTML 리포터와 분리)
  outputDir: 'test-results/artifacts',
  
  // 병렬 실행 설정
  fullyParallel: true,
  workers: process.env.CI ? 2 : 4, // CI: 2 workers, Local: 4 workers
  
  // 재시도 설정
  retries: process.env.CI ? 2 : 0,
  
  // 타임아웃
  timeout: 30 * 1000, // 30초
  expect: {
    timeout: 5000, // assertion 타임아웃 5초
  },
  
  // 리포터
  reporter: [
    ['html', { outputFolder: 'test-results/html' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }],
    ['list'], // 콘솔 출력
  ],
  
  // 공통 설정
  use: {
    // Base URL
    baseURL: 'http://localhost:8080',
    
    // 스크린샷
    screenshot: 'only-on-failure',
    
    // 비디오 녹화
    video: 'retain-on-failure',
    
    // Trace
    trace: 'on-first-retry',
    
    // 타임아웃
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },

  // 테스트 프로젝트 (브라우저별 병렬 실행)
  projects: [
    {
      name: 'chromium',
      use: { 
        ...devices['Desktop Chrome'],
        viewport: { width: 1280, height: 720 },
      },
    },
    {
      name: 'firefox',
      use: { 
        ...devices['Desktop Firefox'],
        viewport: { width: 1280, height: 720 },
      },
    },
    {
      name: 'webkit',
      use: { 
        ...devices['Desktop Safari'],
        viewport: { width: 1280, height: 720 },
      },
    },
    // 모바일 테스트
    {
      name: 'mobile-chrome',
      use: { 
        ...devices['Pixel 5'],
      },
    },
    {
      name: 'mobile-safari',
      use: { 
        ...devices['iPhone 12'],
      },
    },
  ],

  // 로컬 개발 서버 자동 실행
  webServer: {
    command: 'flutter run -d web-server --web-port 8080 --web-hostname localhost',
    url: 'http://localhost:8080',
    reuseExistingServer: !process.env.CI,
    timeout: 120 * 1000, // Flutter 빌드에 2분
    stdout: 'pipe',
    stderr: 'pipe',
  },
});

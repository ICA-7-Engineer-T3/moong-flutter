# Testing Guide - Moong App

본 문서는 Moong 앱의 테스트 전략과 실행 방법을 설명합니다.

## 📊 테스트 전략 개요

Moong 앱은 **Hybrid Testing Strategy**를 사용합니다:

1. **Flutter Integration Tests** (준비 단계)
   - UI 상호작용, 네비게이션, 상태 검증
   - 현재 Flutter Web 지원 제한으로 인해 스켈레톤 코드만 작성됨
   - 향후 Native 앱 개발 시 또는 Flutter Web Integration Test 완전 지원 시 활용

2. **Playwright Visual Regression Tests** (메인)
   - 41개 화면 스크린샷 비교
   - 크로스 브라우저 시각적 검증
   - 성능 측정 (페이지 로드 시간)

---

## 🎯 왜 Hybrid Approach인가?

### Flutter Web의 Canvas 렌더링 문제

Flutter Web은 **CanvasKit** 렌더러를 사용하여 모든 UI를 Canvas에 그립니다:

- ❌ 일반적인 DOM 요소가 없음
- ❌ Playwright의 `getByText()`, `getByRole()` 등이 작동하지 않음
- ❌ TextField 입력이 거의 불가능
- ❌ 좌표 기반 클릭은 가능하지만 화면 크기에 의존하여 불안정

### Context7 공식 문서 리서치 결과

**Flutter 공식 권장사항:**
- `integration_test` 패키지 사용
- `flutter drive`로 실행
- ⚠️ **하지만** Flutter Web은 아직 완전히 지원되지 않음

**Playwright 공식 권장사항:**
- Canvas 기반 앱은 **Visual Regression Testing** (스크린샷 비교)
- `toHaveScreenshot()` 사용
- UI 상호작용보다는 **시각적 검증**에 최적화

---

## 🚀 테스트 실행 방법

### 1. Playwright Visual Regression Tests (추천)

**첫 실행 (기준 스크린샷 생성):**
```bash
cd tests
./run_visual_tests.sh
```

**이후 실행 (스크린샷 비교):**
```bash
cd tests
./run_visual_tests.sh
```

**수동 실행:**
```bash
cd tests
npx playwright test e2e/visual_regression.spec.js --project=chromium
```

**기준 스크린샷 업데이트:**
```bash
cd tests
npx playwright test e2e/visual_regression.spec.js --update-snapshots
```

**HTML 리포트 보기:**
```bash
cd tests
npx playwright show-report test-results/html
```

### 2. Flutter Integration Tests (미래를 위한 준비)

**⚠️ 현재 상태:**
- Flutter Web에서 Integration Tests가 완전히 지원되지 않음
- 코드는 작성되어 있지만 실행 불가
- Native 앱 개발 시 또는 향후 Flutter Web 지원 완성 시 사용 가능

**파일 위치:**
```
integration_test/
├── auth_test.dart       # 인증 플로우
├── moong_test.dart      # 뭉 관리 및 상호작용
└── shop_test.dart       # 상점 시스템
```

**이론적 실행 방법 (현재 작동 안 함):**
```bash
# ChromeDriver 필요 (port 4444)
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/auth_test.dart \
  -d chrome
```

---

## 📁 테스트 구조

```
hello_flutter/
├── integration_test/               # Flutter Integration Tests (준비됨)
│   ├── auth_test.dart
│   ├── moong_test.dart
│   └── shop_test.dart
├── test_driver/
│   └── integration_test.dart       # Integration test 드라이버
├── tests/                          # Playwright Tests (메인)
│   ├── e2e/
│   │   ├── visual_regression.spec.js   # 41개 화면 테스트 ✅
│   │   ├── auth.spec.js            # (사용 안 함)
│   │   ├── moong.spec.js           # (사용 안 함)
│   │   └── shop.spec.js            # (사용 안 함)
│   ├── playwright.config.js
│   ├── package.json
│   └── run_visual_tests.sh         # 실행 스크립트 ✅
└── run_integration_tests.sh        # (미래용)
```

---

## 🧪 Visual Regression Tests 상세

### 테스트 커버리지 (41개 화면)

#### Core Screens (5)
- Splash, Login, Signup, Moong Select, Main Moong

#### Navigation Screens (5)
- Garden, Quest, Food, Settings, Chat

#### Shop System (6)
- Shop Main, Clothes, Accessories, Furniture, Background, Season

#### Credit & Archive (5)
- Credit Info 1, Credit Info 2, Credit Balance, Archive Main, Archive

#### Special Screens (6)
- Quest Completed, Intimacy Up, Emotion Analysis, Music Generation,
  Exercise Suggestion, Food Suggestion

#### Moong States (3)
- Sad Moong, Cute Moong, Garden View

#### Background Collection (4)
- Forest, Beach, Space, Sakura

#### Additional Screens (7)
- Moong Choice, Profile Edit, Background, Statistics, Chat Detail,
  Chat Input, Credit Refund

### 스크린샷 비교 원리

1. **첫 실행**: 각 화면의 기준 이미지 저장
2. **이후 실행**: 현재 화면과 기준 이미지 pixel-by-pixel 비교
3. **차이 감지**: 픽셀 차이가 threshold (기본 0.2%) 초과 시 실패
4. **Diff 이미지**: 차이가 있는 부분을 빨간색으로 표시

---

## 🔧 CI/CD 통합 (향후)

### GitHub Actions Example

```yaml
name: Visual Regression Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.3'
      
      - name: Install dependencies
        run: |
          flutter pub get
          cd tests && npm install
      
      - name: Run Flutter Web Server
        run: flutter run -d web-server --web-port 8080 &
      
      - name: Run Visual Tests
        run: cd tests && npx playwright test --project=chromium
      
      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: playwright-report
          path: tests/test-results/
```

---

## 📊 테스트 결과 분석

### HTML Report

Playwright는 상세한 HTML 리포트를 자동 생성합니다:

```bash
cd tests
npx playwright show-report test-results/html
```

**포함 내용:**
- ✅ 통과/실패 테스트 목록
- 🖼️ 스크린샷 비교 (Before/After/Diff)
- ⏱️ 실행 시간
- 📹 실패 시 비디오 녹화

### JSON/JUnit Reports

```
tests/test-results/
├── html/                    # HTML 리포트
├── results.json             # JSON 형식
└── junit.xml                # JUnit XML (Jenkins 등)
```

---

## 🐛 문제 해결

### 1. 테스트가 timeout으로 실패
```bash
# Flutter 웹 서버가 시작되지 않은 경우
# playwright.config.js의 webServer 설정 확인
```

### 2. 스크린샷이 매번 다름
```bash
# 애니메이션이 진행 중일 수 있음
# visual_regression.spec.js에서 waitForTimeout 증가
await page.waitForTimeout(2000); // 2초 대기
```

### 3. Firefox/WebKit에서 실패
```bash
# 브라우저별로 기준 스크린샷이 다름
# Chromium만 사용하거나, 각 브라우저별로 baseline 생성
npx playwright test --update-snapshots --project=firefox
```

### 4. "Web devices are not supported for integration tests yet"
```
# 현재 Flutter Web Integration Tests는 지원되지 않음
# Playwright Visual Tests를 사용하세요
```

---

## 📚 참고 자료

- **Flutter Integration Tests**: https://docs.flutter.dev/testing/integration-tests
- **Playwright Visual Testing**: https://playwright.dev/docs/test-snapshots
- **Flutter Web Renderers**: https://docs.flutter.dev/platform-integration/web/renderers
- **Context7 Research**: 본 프로젝트의 테스트 전략은 Context7 MCP를 통한 공식 문서 리서치를 기반으로 수립됨

---

## 🎯 향후 계획

1. **Native App Development**
   - Android/iOS 앱 개발 시 Integration Tests 완전 활용
   - Widget-level 테스트 추가

2. **E2E Test Expansion**
   - API Mocking 추가
   - State Management 테스트 강화
   - Performance Profiling

3. **CI/CD Pipeline**
   - GitHub Actions 워크플로우 추가
   - 자동화된 스크린샷 리뷰

---

## 💡 팀 협업 가이드

### PR 시 테스트 실행

```bash
# PR 전에 반드시 실행
cd tests
./run_visual_tests.sh
```

### 스크린샷 차이 발생 시

1. **의도된 변경**: `--update-snapshots`로 기준 업데이트
2. **의도하지 않은 변경**: 코드 수정 후 재테스트
3. **애니메이션 차이**: `waitForTimeout` 조정

### Git에 커밋할 파일

**커밋해야 할 것:**
- ✅ `e2e/visual_regression.spec.js-snapshots/` (기준 스크린샷)
- ✅ 모든 `.spec.js` 파일

**커밋하지 말 것:**
- ❌ `test-results/` (test report)
- ❌ `playwright-report/`
- ❌ `.gitignore`에 이미 추가됨

---

**마지막 업데이트:** 2026-02-03  
**문의:** Moong Team

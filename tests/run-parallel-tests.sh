#!/bin/bash

###############################################################################
# Moong App - Playwright 병렬 테스트 실행 스크립트
###############################################################################

set -e

echo "🚀 Starting Moong App E2E Tests..."
echo ""

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 테스트 디렉토리로 이동
cd "$(dirname "$0")"

# 1. 의존성 확인
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# 2. Flutter 웹 서버 시작 (백그라운드)
echo "🌐 Starting Flutter web server..."
cd ..
flutter run -d web-server --web-port 8080 --web-hostname localhost > /dev/null 2>&1 &
FLUTTER_PID=$!
cd tests

# Flutter 서버 준비 대기
echo "⏳ Waiting for Flutter server to be ready..."
sleep 10

# 3. 브라우저 확인 및 설치
echo "🌐 Checking browsers..."
npx playwright install --with-deps

# 4. 병렬 테스트 실행
echo ""
echo "🧪 Running E2E tests in parallel..."
echo "=================================================="

# 모든 브라우저에서 병렬 실행
npx playwright test \
  --workers=8 \
  --reporter=html,json,list

TEST_EXIT_CODE=$?

# 5. Flutter 서버 종료
echo ""
echo "🛑 Stopping Flutter server..."
kill $FLUTTER_PID 2>/dev/null || true

# 6. 결과 출력
echo ""
echo "=================================================="
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed!${NC}"
fi

echo ""
echo "📊 Test report: test-results/html/index.html"
echo ""

# 7. HTML 리포트 자동 열기 (옵션)
if [ "$1" == "--open-report" ]; then
    echo "📈 Opening test report..."
    npx playwright show-report test-results/html
fi

exit $TEST_EXIT_CODE

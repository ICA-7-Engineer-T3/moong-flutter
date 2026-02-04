#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "======================================"
echo " Playwright Visual Regression Tests  "
echo "======================================"

# 첫 실행인 경우: 기준 스크린샷 생성
if [ ! -d "e2e/visual_regression.spec.js-snapshots" ]; then
  echo "[INFO] First run detected. Generating baseline screenshots..."
  npx playwright test e2e/visual_regression.spec.js --update-snapshots --project=chromium
  echo "[SUCCESS] Baseline screenshots generated!"
else
  # 이후 실행: 스크린샷 비교
  echo "[INFO] Running visual regression tests (comparing against baseline)..."
  npx playwright test e2e/visual_regression.spec.js --project=chromium
fi

echo ""
echo "View HTML report: npx playwright show-report test-results/html"

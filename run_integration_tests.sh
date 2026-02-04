#!/bin/bash
set -euo pipefail

echo "[Integration] Running Flutter Integration Tests on Chrome..."
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/auth_test.dart \
  -d chrome

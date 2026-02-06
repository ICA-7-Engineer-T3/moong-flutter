const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  const errors = [];
  const warnings = [];
  const allMessages = [];

  // Capture ALL console messages
  page.on('console', msg => {
    const text = msg.text();
    const type = msg.type();
    allMessages.push(`[${type}] ${text}`);

    if (type === 'error') {
      errors.push(text);
      console.log(`\n❌ ERROR: ${text}`);
    } else if (type === 'warning') {
      warnings.push(text);
      console.log(`\n⚠️  WARNING: ${text}`);
    }
  });

  // Capture page errors
  page.on('pageerror', error => {
    errors.push(error.message);
    console.log(`\n💥 PAGE ERROR: ${error.message}\n${error.stack}`);
  });

  // Capture failed requests
  page.on('requestfailed', request => {
    console.log(`\n🔴 FAILED REQUEST: ${request.url()} - ${request.failure().errorText}`);
  });

  console.log('Opening Flutter app...\n');
  await page.goto('http://localhost:63082', { waitUntil: 'networkidle', timeout: 30000 });

  // Wait for potential async errors
  await page.waitForTimeout(8000);

  // Check DOM state
  const html = await page.content();
  const bodyText = await page.locator('body').innerText();

  console.log('\n========== SUMMARY ==========');
  console.log(`Total errors: ${errors.length}`);
  console.log(`Total warnings: ${warnings.length}`);
  console.log(`Total console messages: ${allMessages.length}`);
  console.log(`Body text length: ${bodyText.length}`);
  console.log(`Canvas elements: ${await page.locator('canvas').count()}`);
  console.log(`Flutter views: ${await page.locator('flt-glass-pane').count()}`);

  if (errors.length > 0) {
    console.log('\n========== ERRORS ==========');
    errors.forEach((e, i) => console.log(`${i+1}. ${e}`));
  }

  if (warnings.length > 0) {
    console.log('\n========== WARNINGS ==========');
    warnings.forEach((w, i) => console.log(`${i+1}. ${w}`));
  }

  // Save all messages
  require('fs').writeFileSync('all-console-messages.txt', allMessages.join('\n'));
  console.log('\nAll messages saved to: all-console-messages.txt');

  // Check if Flutter is even loaded
  const flutterLoaded = await page.evaluate(() => {
    return typeof window.flutterConfiguration !== 'undefined';
  });
  console.log(`Flutter configuration loaded: ${flutterLoaded}`);

  console.log('\nKeeping browser open for 15 seconds...');
  await page.waitForTimeout(15000);

  await browser.close();
})();

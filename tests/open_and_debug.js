const { chromium } = require('playwright');

(async () => {
  console.log('Opening Chrome with Flutter app...\n');

  const browser = await chromium.launch({
    headless: false,
    args: ['--start-maximized']
  });

  const context = await browser.newContext({
    viewport: null // Use full screen
  });

  const page = await context.newPage();

  const errors = [];
  page.on('console', msg => {
    const type = msg.type();
    const text = msg.text();
    console.log(`[${type.toUpperCase()}] ${text}`);
    if (type === 'error') {
      errors.push(text);
    }
  });

  page.on('pageerror', error => {
    console.log(`[ERROR] ${error.message}`);
    errors.push(error.message);
  });

  console.log('Navigating to http://localhost:63082...');
  await page.goto('http://localhost:63082', { waitUntil: 'domcontentloaded' });

  console.log('Waiting 10 seconds for app to render...\n');
  await page.waitForTimeout(10000);

  const canvasCount = await page.locator('canvas').count();
  const title = await page.title();

  console.log('========== STATUS ==========');
  console.log(`Page Title: ${title}`);
  console.log(`Canvas Elements: ${canvasCount}`);
  console.log(`Errors Found: ${errors.length}`);

  if (errors.length > 0) {
    console.log('\n========== ERRORS ==========');
    errors.forEach((e, i) => console.log(`${i+1}. ${e}`));
  }

  await page.screenshot({ path: 'app-debug.png', fullPage: true });
  console.log('\nScreenshot saved: app-debug.png');

  console.log('\n✅ Browser window is now open.');
  console.log('👀 Please check the Chrome window that just opened.');
  console.log('🔍 Do you see the Moong app or a white screen?');
  console.log('\nPress Ctrl+C to close when done inspecting...');

  // Keep open indefinitely
  await page.waitForTimeout(300000); // 5 minutes

  await browser.close();
})();

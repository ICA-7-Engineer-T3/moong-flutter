const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext({ viewport: { width: 1280, height: 800 } });
  const page = await context.newPage();

  console.log('Opening Flutter app...');
  await page.goto('http://localhost:63082', { waitUntil: 'networkidle', timeout: 30000 });

  console.log('Waiting for Flutter to fully render (15 seconds)...');
  await page.waitForTimeout(15000);

  await page.screenshot({ path: 'final-screenshot.png', fullPage: true });
  console.log('Screenshot saved: final-screenshot.png');

  const canvasCount = await page.locator('canvas').count();
  const title = await page.title();

  console.log(`\nCanvas elements: ${canvasCount}`);
  console.log(`Page title: ${title}`);
  console.log(`\nIf you can see the Moong app in the browser window, the app is working!`);
  console.log('Check final-screenshot.png to see what was captured.');

  console.log('\nBrowser will stay open for 30 seconds for manual inspection...');
  await page.waitForTimeout(30000);

  await browser.close();
})();

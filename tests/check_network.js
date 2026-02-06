const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  const resources = [];
  const failed = [];
  const errors = [];

  page.on('console', msg => {
    if (msg.type() === 'error') {
      errors.push(msg.text());
      console.log(`❌ ${msg.text()}`);
    }
  });

  page.on('pageerror', error => {
    errors.push(error.message);
    console.log(`💥 ${error.message}`);
  });

  page.on('response', response => {
    const url = response.url();
    const status = response.status();
    resources.push({ url, status });

    if (status >= 400) {
      console.log(`🔴 ${status} - ${url}`);
      failed.push({ url, status });
    } else if (url.includes('.js') || url.includes('main') || url.includes('flutter')) {
      console.log(`✅ ${status} - ${url}`);
    }
  });

  console.log('Loading Flutter app...\n');
  try {
    await page.goto('http://localhost:60654', { waitUntil: 'networkidle', timeout: 30000 });
  } catch (e) {
    console.log(`\n⚠️  Navigation timeout: ${e.message}`);
  }

  await page.waitForTimeout(5000);

  console.log('\n========== SUMMARY ==========');
  console.log(`Total resources loaded: ${resources.length}`);
  console.log(`Failed resources: ${failed.length}`);
  console.log(`Console errors: ${errors.length}`);

  // Check specific files
  const jsFiles = resources.filter(r => r.url.includes('.js'));
  console.log(`\n========== JavaScript Files (${jsFiles.length}) ==========`);
  jsFiles.forEach(f => console.log(`${f.status} - ${f.url.split('/').pop()}`));

  if (failed.length > 0) {
    console.log('\n========== FAILED RESOURCES ==========');
    failed.forEach(f => console.log(`${f.status} - ${f.url}`));
  }

  if (errors.length > 0) {
    console.log('\n========== ERRORS ==========');
    errors.forEach((e, i) => console.log(`${i+1}. ${e}`));
  }

  // Check if main.dart.js loaded
  const mainJs = jsFiles.find(f => f.url.includes('main.dart.js'));
  console.log(`\nmain.dart.js loaded: ${mainJs ? 'YES ('+mainJs.status+')' : 'NO'}`);

  console.log('\nKeeping browser open for 10 seconds...');
  await page.waitForTimeout(10000);

  await browser.close();
})();

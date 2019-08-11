const puppeteer = require('puppeteer');

let urls = [];

function parseArguments() {
  if (process.argv.length > 2) {
    for (let i = 2; i < process.argv.length; i++) {
      urls.push(process.argv[i]);
    }
  } else {
    console.log("Please provide urls -> yarn --silent follow https://facebook.com https://cupon.es");
  }
}

parseArguments();


if (urls.length) {

  const iphone = puppeteer.devices['iPhone 6'];

  let checkResult = {};

  (async () => {

    const browser = await puppeteer.launch();

    await Promise.all(urls.map(async (url) => {

      const page = await browser.newPage();

      await page.emulate(iphone);

      const response = await page.goto(url, {timeout: 5000});

      //const chain = response.request().redirectChain();

      checkResult[url] = response.status();

      await page.close();
    }));

    await browser.close();

    console.log(JSON.stringify(checkResult));
  })();
}

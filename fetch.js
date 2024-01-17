const puppeteer = require('puppeteer');

(async () => {
    const username = process.env.user_name;
    const password = process.env.user_pass

    const browser = await puppeteer.launch({ headless: "new" });
    const page = await browser.newPage();

    const client = await page.target().createCDPSession()
    await client.send('Page.setDownloadBehavior', {
        behavior: 'allow',
        downloadPath: '/Users/gallochris/fbslogs/fbs-logs/data',
    })

    // Set up basic authentication
    const credentials = 'username:password';
    const encodedCredentials = Buffer.from(credentials).toString('base64');
    await page.setExtraHTTPHeaders({
        'Authorization': `Basic ${encodedCredentials}`
    });

    await page.goto('https://coachesbythenumbers.com/login-2/');  // URL for logging in
    await page.type('#user_login', 'cgallo');
    await page.type('#user_pass', 'USERPASS');
    await page.click('#btn-login');
    try {
     await page.waitForNavigation(9000); 
    }
    catch (error) {
        console.error('Navigation error:', error);
    }  // Wait for successful login

    // Now that you're authenticated, navigate to the download page
    await page.goto('https://coachesbythenumbers.com/data-downloads/', { timeout: 6000 });
     

    // Click the download link using page.click()
    const downloadLink = await page.waitForSelector('a[href*="/wp-content/custom-php/datadownloads.php?download=2023"]',
        { timeout: 6000});
    await downloadLink.click();

    // Wait for the download to start (adjust as needed)
    await page.waitForTimeout(6000);

    await browser.close();
})();
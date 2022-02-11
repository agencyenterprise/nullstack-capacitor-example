const { google } = require('googleapis');
const androidpublisher = google.androidpublisher('v3');

const ANDROID_PUBLISHER_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const CREDENTIALS_FILE_NAME = 'src/server/private_key.json';
const CREDENTIALS_FILE_PATH = 'private_key.json';

const configureGoogleClient = async () => {
  const auth = new google.auth.GoogleAuth({
    scopes: [ANDROID_PUBLISHER_SCOPE],
    keyFilename: CREDENTIALS_FILE_NAME,
    keyFile: CREDENTIALS_FILE_PATH,
  });

  const authClient = await auth.getClient();
  google.options({auth: authClient, retry: true });
}

const acknowledgePurchase = async ({ packageName, subscriptionId, token }) => {
  await configureGoogleClient();
  return await androidpublisher.purchases.subscriptions.acknowledge({
    packageName,
    subscriptionId,
    token,
  });
}

module.exports = {
  acknowledgePurchase,
}
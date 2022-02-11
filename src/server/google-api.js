const { google } = require('googleapis');
const androidpublisher = google.androidpublisher('v3');

const ANDROID_PUBLISHER_SCOPE = 'https://www.googleapis.com/auth/androidpublisher';
const CREDENTIALS_FILE_NAME = 'src/server/private_key.json';

const configureGoogleClient = async () => {
  const auth = new google.auth.GoogleAuth({
    scopes: [ANDROID_PUBLISHER_SCOPE],
    keyFilename: CREDENTIALS_FILE_NAME,
  });

  const authClient = await auth.getClient();
  google.options({auth: authClient, retry: true });
}

const acknowledgePurchase = async ({ packageName, productId: subscriptionId, purchaseToken: token }) => {
  await configureGoogleClient();
  return await androidpublisher.purchases.subscriptions.acknowledge({
    packageName,
    subscriptionId,
    token,
  });
}

const fetchSubscriptions = async ({ packageName }) => {
  await configureGoogleClient();
  return await androidpublisher.inappproducts.list({ packageName });
}

module.exports = {
  acknowledgePurchase,
  fetchSubscriptions,
}
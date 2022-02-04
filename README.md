# Nullstack Capacitor Example

<img src='https://raw.githubusercontent.com/nullstack/nullstack/master/nullstack.png' height='60' alt='Nullstack' />

## How to run this Project

Install the dependencies:

`npm install`

Copy the environment sample to a .env file

```sh
NULLSTACK_PROJECT_NAME="[dev] Nullstack Capacitor Example"
NULLSTACK_PROJECT_DOMAIN="localhost"
NULLSTACK_PROJECT_COLOR="#D22365"
NULLSTACK_SERVER_PORT="5000"
```

Run the app in development mode:

`npm start`

Open [http://localhost:5000](http://localhost:5000) to view it in the browser.

## Learn more about Nullstack

[Read the documentation](https://nullstack.app/documentation)


## Android Plugin samples

 - HelloPlugin.kt
 - EchoPlugin.kt

Always remember to register the plugins on the activity


## iOS Plugin samples
 - HelloPlugin.m (link the plugin to capacitor)
 - HelloPlugin.swift (native code to do your stuff)
 ---------------------------------------------------
 - EchoPlugin.m (link the plugin to capacitor)
 - EchoPlugin.swift (native code to do your stuff)

Always remember to add the .m files to register the plugins

## Android environment setup

- Open google play console : https://play.google.com/console/
- Add the testers account to License Testing under Setting menu
- Create an app
- Publish a base version to internal testing
- Add all testers accounts to the tester list
- Make sure everyone accepts the testing invite, you can generate an invite url on the testing menu
- Go to Products and create the in app products and subscriptions, and activate them

## Regarding Android purchases

- Every new purchase has its own unique ID, subscription status updates information on that ID
- At the time this does not support PENDING purchases neither one time products.
- Only PURCHASE state should be considered for activating the product.
- All information needed regarding the purchase should be inside the Purchase object received in the PurchasesUpdatedListene
- Server side we receive the Purchase object to create webhooks and update information regarding those purchases.

## Android Reference

- [Setting up the Environment](https://developer.android.com/google/play/billing/getting-ready)
- [Integrating the billing library](https://developer.android.com/google/play/billing/integrate)
- [Subscription Statuses](https://developer.android.com/google/play/billing/subscriptions)
- [Security practices](https://developer.android.com/google/play/billing/security)
- [Testing Subscriptions](https://qonversion.io/blog/the-ultimate-guide-to-subscription-testing-on-android/)
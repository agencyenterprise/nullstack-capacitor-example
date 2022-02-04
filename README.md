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

## iOS In-App Purchases

The plugin asynchronously fetches a product when it is loaded. You can change the `productId` variable to fetch different products.
A product must be registered to be able to be fetched. To register a product in the local enviroment, add it in the `Configuration.storekit` file. Check [here](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode) for more information about the configuration file. For information about testing enviroments and how to add products to it, check the [the documentation](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_at_all_stages_of_development_with_xcode_and_sandbox).

Please take in consideration that this plugin uses the older StoreKit API, which has backwards compability with iOS versions lower than iOS 15. Check the API documentation [here](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase) and check the difference between the APIs [here](https://developer.apple.com/documentation/storekit/choosing_a_storekit_api_for_in-app_purchase).

The used StoreKit API is not able to verify the transactions by itself, so it must be done on the server (or locally, but that is not recommended). To achieve that, you must use the transaction receipt for validation. The validated receipt has all the information regarding the purchases, including the subscription status and expiry date. Look [here](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/choosing_a_receipt_validation_technique) and [here](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/validating_receipts_with_the_app_store) for informations about how to validate the receipt, and [here](https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/subscriptions_and_offers/handling_subscriptions_billing) for information on how to use the validated receipt to check the subscription state.

Also, you can [check this repo](https://github.com/russell-archer/IAPHelper) for lots of useful (but not official) information.
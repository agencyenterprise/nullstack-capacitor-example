//
//  AppSubscriptionPlugin.swift
//  App
//
//  Created by Gustavo Gava on 02/02/2022.
//

import Capacitor
import StoreKit

@objc(AppSubscriptionPlugin)
public class AppSubscriptionPlugin: CAPPlugin {
    var subscriptionProduct: SKProduct?

    enum Products: String, CaseIterable {
        case subscription = "com.app.subscription"
    }

    @objc func subscribe(_ call: CAPPluginCall) {
        fetchSubscriptionProduct()
    }
    
    @objc func isUserSubscribed(_ call: CAPPluginCall) {
        //TODO:
    }
    
    private func subscribe() {
        guard let subscriptionProduct = subscriptionProduct else {
            return
        }
        let payment = SKPayment(product: subscriptionProduct)
        SKPaymentQueue.default().add(payment)
    }
    
    private func fetchSubscriptionProduct() {
        //TODO: Make products fetching general
        let request = SKProductsRequest(productIdentifiers: Set([Products.subscription.rawValue]))
        request.delegate = self
        request.start()
    }
}

extension AppSubscriptionPlugin: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            print("No products")
            return
        }
        //TODO: Make products fetching general
        self.subscriptionProduct = response.products.first

        self.subscribe()
    }
}

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
        SKPaymentQueue.default().add(self)
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
            return
        }
        //TODO: Make products fetching general
        self.subscriptionProduct = response.products.first

        self.subscribe()
    }
}

extension AppSubscriptionPlugin: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing:
                print("purchasing")
            case .purchased:
                SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
            case .restored:
                print("restored")
            case .deferred:
                print("deferred")
            @unknown default:
                print("default")
            }
        })
    }
    
    
}

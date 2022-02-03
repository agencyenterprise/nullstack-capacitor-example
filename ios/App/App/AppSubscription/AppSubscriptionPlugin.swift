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
    var product: SKProduct?
    
    override public func load() {
        fetchProduct(with: "com.app.subscription")
        SKPaymentQueue.default().add(self)
    }

    @objc func subscribe(_ call: CAPPluginCall) {
        guard let subscriptionProduct = product else {
            call.reject("Product is null")
            return
        }
        let payment = SKPayment(product: subscriptionProduct)
        SKPaymentQueue.default().add(payment)
        call.resolve()
    }

    @objc func isUserSubscribed(_ call: CAPPluginCall) {
        //TODO: Check the receipt, should it be done server side?
    }
    
    private func fetchProduct(with id: String) {
        //TODO: Make products fetching general
        let request = SKProductsRequest(productIdentifiers: Set([id]))
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
        self.product = response.products.first
    }
}

extension AppSubscriptionPlugin: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchasing, .deferred:
                break
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction($0)
                let receiptUrlString = Bundle.main.appStoreReceiptURL?.absoluteString
                self.notifyListeners("subscriptionPurchased", data: ["receiptUrl": receiptUrlString!])
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
            @unknown default:
                break
            }
        })
    }
}

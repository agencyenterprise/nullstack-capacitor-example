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
    let productIds: Set<String> = ["com.app.subscription.yearly", "com.app.subscription.monthly"]
    var products: [SKProduct]?
    
    override public func load() {
        fetchProduct(with: productIds)
        SKPaymentQueue.default().add(self)
    }

    @objc func subscribe(_ call: CAPPluginCall) {
        guard
            let productId = call.options["productId"] as? String,
            let subscriptionProduct = products?.first(where: { product in
                return product.productIdentifier == productId
            })
        else {
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
    
    private func fetchProduct(with ids: Set<String>) {
        let request = SKProductsRequest(productIdentifiers: ids)
        request.delegate = self
        request.start()
    }
}

extension AppSubscriptionPlugin: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            return
        }
        
        self.products = response.products
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
                self.notifyListeners("onSubscriptionPurchased", data: ["receiptUrl": receiptUrlString!])
            case .failed:
                SKPaymentQueue.default().finishTransaction($0)
            @unknown default:
                break
            }
        })
    }
}

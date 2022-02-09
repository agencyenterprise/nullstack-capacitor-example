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
    private let productIds: Set<String> = ["com.app.subscription.yearly", "com.app.subscription.monthly"]
    private var productsRequest: SKProductsRequest?
    private var products: [SKProduct]?
    
    override public func load() {
        fetchProducts(with: productIds)
        SKPaymentQueue.default().add(self)
    }

    private func fetchProducts(with ids: Set<String>) {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    @objc func subscribe(_ call: CAPPluginCall) {
        guard SKPaymentQueue.canMakePayments() else {
            print("Can not make payments")
            return
        }
        
        guard
            let productId = call.getString("productId"),
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
    
    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension AppSubscriptionPlugin: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard response.products.count > 0 else {
            return
        }
        
        self.products = response.products
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
    }
}

extension AppSubscriptionPlugin: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach({
            switch $0.transactionState {
            case .purchased, .restored:
                SKPaymentQueue.default().finishTransaction($0)
                let receiptUrlString = Bundle.main.appStoreReceiptURL?.absoluteString
                self.notifyListeners("onSubscriptionPurchased", data: ["receiptUrl": receiptUrlString!])
            case .failed:
                print("fail...")
                if let transactionError = $0.error as NSError?,
                   let localizedDescription = $0.error?.localizedDescription,
                   transactionError.code != SKError.paymentCancelled.rawValue {
                    print("Transaction Error: \(localizedDescription)")
                }
                
                SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
        })
    }
}

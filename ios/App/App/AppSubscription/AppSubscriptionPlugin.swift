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
    private let productIds: Set<String> = ["instill.yearly", "instill.monthly"]
    private var productsRequest: SKProductsRequest?
    private var products: [SKProduct]?
    private var subscriptionCallId: String?
    
    override public func load() {
        StoreObserver.shared.delegate = self
        fetchProducts(with: productIds)
    }

    private func fetchProducts(with ids: Set<String>) {
        productsRequest?.cancel()
        productsRequest = SKProductsRequest(productIdentifiers: ids)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    @objc func subscribe(_ call: CAPPluginCall) {
        guard SKPaymentQueue.canMakePayments() else {
            call.reject(Messages.cannotMakePayments)
            return
        }
        
        guard
            let productId = call.getString("productId"),
            let subscriptionProduct = products?.first(where: { product in
                return product.productIdentifier == productId
            })
        else {
            call.reject(Messages.productsUnavailable)
            return
        }
        
        //Save plugin call to release it later
        bridge?.saveCall(call)
        subscriptionCallId = call.callbackId
        
        let payment = SKPayment(product: subscriptionProduct)
        SKPaymentQueue.default().add(payment)
    }
}

// MARK: - SKProductsRequestDelegate

extension AppSubscriptionPlugin: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
}

// MARK: - SKRequestDelegate
//
extension AppSubscriptionPlugin: SKRequestDelegate {
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        releaseCall { call in
            call.reject(error.localizedDescription)
        }
    }
}

// MARK: - StoreObserverDelegate

extension AppSubscriptionPlugin: StoreObserverDelegate {
    func storeObserverSubscribeDidSucceed(_ receiptString: String) {
        releaseCall()
        
        self.notifyListeners("onSubscriptionPurchased", data: ["receiptString": receiptString])
    }
    
    func storeObserverDidReceiveMessage(_ message: String) {
        releaseCall { call in
            call.reject(message)
        }
    }
    
    func storeObserverDidCancel() {
        releaseCall()
    }
    
    typealias CAPReleaseCall = (CAPPluginCall) -> Void
    
    private func releaseCall(beforeReleaseHandler: CAPReleaseCall? = nil) {
        if let callId = subscriptionCallId, let call = bridge?.savedCall(withID: callId) {
            
            if let beforeReleaseHandler = beforeReleaseHandler {
                beforeReleaseHandler(call)
            }
            
            bridge?.releaseCall(call)
        }
    }
}

// MARK: - Messages

struct Messages {
    static let status = "Status"
    static let cannotMakePayments = "In-App Purchases may be restricted on your device. You are not authorized to make payments."
    static let productRequestStatus = "Product Request Status"
    static let purchaseOf = "Purchase of"
    static let failed = "failed."
    static let error = "Error: "
    static let purchaseStatus = "Purchase Status"
    static let productsUnavailable = "No products available"
}

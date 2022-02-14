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
    private var subscriptionCallId: String?
    private let iap = IAPHelper.shared
    
    override public func load() {
        iap.fetchProductsFromAppStore { [weak self] notification in
            if case let .requestProductsFailure(errorDescription) = notification {
                self?.releaseCall { call in
                    call.reject(errorDescription)
                }
            }
        }
    }
    
    @objc func subscribe(_ call: CAPPluginCall) {
        guard iap.canMakePayments else {
            call.reject("In-App Purchases may be restricted on your device. You are not authorized to make payments.")
            return
        }
        
        guard
            let productId = call.getString("productId"),
            let subscriptionProduct = iap.products?.first(where: { product in
                return product.productIdentifier == productId
            })
        else {
            call.reject("No products available")
            return
        }
        
        //Save plugin call to release it later
        bridge?.saveCall(call)
        subscriptionCallId = call.callbackId
        
        iap.buyProduct(subscriptionProduct) { [weak self] notification in
            guard let self = self else { return }
            
            switch notification {
            case .purchaseAbortPurchaseInProgress:
                self.releaseCall { call in
                    call.reject("Purchase aborted because another purchase is being processed")
                }
            case .purchaseCancelled(message: let message):
                self.releaseCall { call in
                    call.reject(message)
                }
            case .purchaseFailure(message: let message):
                self.releaseCall { call in
                    call.reject(message)
                }
            case .purchaseSuccess(productId: _):
                guard let receiptString = self.iap.getReceiptBase64EncodedString() else {
                    self.releaseCall { call in
                        call.reject("Receipt parsing failed")
                    }
                    return
                }
                
                self.releaseCall()
                self.notifyListeners("onSubscriptionPurchased", data: [
                    "receipt": receiptString,
                    "purchase": productId,
                    "platform": "ios"
                ])
            default:
                break
            }
        }
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

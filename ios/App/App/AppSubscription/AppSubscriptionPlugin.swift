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

    enum Products: String, CaseIterable {
        case subscription = "com.app.subscription"
    }

    @objc func subscribe(_ call: CAPPluginCall) {
        fetchSubscriptionProduct()
    }
    
    @objc func isUserSubscribed(_ call: CAPPluginCall) {
        //TODO:
    }
    
    private func fetchSubscriptionProduct() {
        let request = SKProductsRequest(productIdentifiers: Set([Products.subscription.rawValue]))
        request.delegate = self
        request.start()
    }
}

extension AppSubscriptionPlugin: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products.count)
    }
}

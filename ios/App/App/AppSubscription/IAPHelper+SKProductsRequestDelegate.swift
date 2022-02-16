//
//  IAPHelper+SKProductsRequestDelegate.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import StoreKit

extension IAPHelper: SKProductsRequestDelegate {
    
    /// Receives a list of localized product info from the App Store.
    /// - Parameters:
    ///   - request:    The request object.
    ///   - response:   The response from the App Store.
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else {
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsNoProducts)
            }
            return
        }

        guard response.invalidProductIdentifiers.isEmpty else {
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsInvalidProducts)
            }
            return
        }
        
        // Update our [SKProduct] set of all available products
        products = response.products
        DispatchQueue.main.async {
            self.requestProductsCompletion?(.requestProductsSuccess)
        }
        
        // When this method returns StoreKit will immediately call the SKRequestDelegate method
        // requestDidFinish(_:) where we will destroy the productsRequest object
    }
}

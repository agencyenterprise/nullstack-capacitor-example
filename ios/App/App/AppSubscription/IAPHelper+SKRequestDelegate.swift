//
//  IAPHelper+SKRequestDelegate.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import StoreKit

extension IAPHelper: SKRequestDelegate {

    /// This method is called for both SKProductsRequest (request product info) and
    /// SKRequest (request receipt refresh).
    /// - Parameters:
    ///   - request:    The request object.
    public func requestDidFinish(_ request: SKRequest) {
        
        if productsRequest != nil {
            productsRequest = nil  // Destroy the product info request object
            
            // Call the completion handler. The request for product info completed. See also productsRequest(_:didReceive:)
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsDidFinish)
            }
            return
        }
        
        if receiptRequest != nil { //
            receiptRequest = nil  // Destory the receipt request object
            DispatchQueue.main.async {
                self.requestReceiptCompletion?(.requestReceiptRefreshSuccess)
            }
        }
    }
    
    /// Called by the App Store if a request fails.
    /// This method is called for both SKProductsRequest (request product info) and
    /// SKRequest (request receipt refresh).
    /// - Parameters:
    ///   - request:    The request object.
    ///   - error:      The error returned by the App Store.
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        
        if productsRequest != nil {
            productsRequest = nil  // Destroy the request object
        
            // Call the completion handler. The request for product info failed
            DispatchQueue.main.async {
                self.requestProductsCompletion?(.requestProductsFailure(errorDescription: error.localizedDescription))
            }
            return
        }
        
        if receiptRequest != nil {
            receiptRequest = nil  // Destory the receipt request object
            DispatchQueue.main.async {
                self.requestReceiptCompletion?(.requestReceiptRefreshFailure)
            }
        }
    }
}

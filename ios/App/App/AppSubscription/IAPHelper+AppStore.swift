//
//  IAPHelper+AppStore.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import Foundation
import StoreKit

extension IAPHelper {
    
    /// Request from the App Store the collection of products that we've configured for sale in App Store Connect.
    /// Note that requesting product info will cause the App Store to provide a refreshed receipt. This will automatically
    /// cause the receipt to be validated.
    /// - Parameter completion:     A closure that will be called when the results are returned from the App Store.
    /// - Parameter notification:   An IAPNotification with a value of .configurationNoProductIds,
    ///                             .requestProductsCompleted or .requestProductsFailed
    public func fetchProductsFromAppStore(_ completion: ((IAPNotification) -> ())? = nil) {
        requestProductsCompletion = completion  // Save the completion handler so it can be used in productsRequest(_:didReceive:)
        
        guard haveConfiguredProductIdentifiers else {
            DispatchQueue.main.async {
                completion?(.configurationNoProductIds)
            }
            return
        }
        
        if products != nil {
            products!.removeAll()
        }
               
        // Request a list of products from the App Store. We use this request to present localized
        // prices and other information to the user. The results are returned asynchronously
        // to the SKProductsRequestDelegate methods productsRequest(_:didReceive:) or
        // request(_:didFailWithError:).
        productsRequest?.cancel()  // Cancel any existing pending requests
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest?.delegate = self  // Will notify through productsRequest(_:didReceive:)
        productsRequest?.start()
    }
    
    /// Start the process to purchase a product. When we add the payment to the default payment queue
    /// StoreKit will present the required UI to the user and start processing the payment. When that
    /// transaction is complete or if a failure occurs, the payment queue sends the SKPaymentTransaction
    /// object that encapsulates the request to all transaction observers. See the
    /// paymentQueue(_:updatedTransactions) for how these events get handled.
    /// - Parameter product:        An SKProduct object that describes the product to purchase.
    /// - Parameter completion:     Completion block that will be called when the purchase has completed, failed or been cancelled.
    /// - Parameter notification:   An IAPNotification with a value of .purchaseCompleted, .purchaseCancelled or .purchaseFailed
    public func buyProduct(_ product: SKProduct, completion: @escaping (_ notification: IAPNotification?) -> Void) {
        guard !isPurchasing else {
            // Don't allow another purchase to start until the current one completes
            completion(.purchaseAbortPurchaseInProgress)
            return
        }

        purchaseCompletion = completion  // Save the completion block for later use
        isPurchasing = true
        
        let payment = SKPayment(product: product)  // Wrap the SKProduct in an SKPayment object
        SKPaymentQueue.default().add(payment)
    }
    
    /// The Apple ID of some users (e.g. children) may not have permission to make purchases from the app store.
    /// - Returns: Returns true if the user is allowed to authorize payment, false if they do not have permission.
    public var canMakePayments: Bool {
        SKPaymentQueue.canMakePayments()
    }
    
    /// Should be used only when the receipt is not present at the appStoreReceiptURL or when
    /// it cannot be successfully validated. The app store is requested to provide a new receipt,
    /// which will result in the user being asked to provide their App Store credentials.
    /// - Parameter completion:     Closure that will be called when the receipt has been refreshed.
    /// - Parameter notification:   An IAPNotification with a value of .receiptRefreshCompleted or .receiptRefreshFailed.
    public func refreshReceipt(completion: @escaping (_ notification: IAPNotification?) -> Void) {
        requestReceiptCompletion = completion
        
        receiptRequest?.cancel()  // Cancel any existing pending requests
        receiptRequest = SKReceiptRefreshRequest()
        receiptRequest!.delegate = self
        receiptRequest!.start()  // Will notify through SKRequestDelegate requestDidFinish(_:)
    }
}

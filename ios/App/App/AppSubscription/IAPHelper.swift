//
//  IAPHelper.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import Foundation
import StoreKit

/// IAPHelper coordinates in-app purchases. Make sure to initiate IAPHelper early in the app's lifecycle so that
/// notifications from the App Store are not missed. For example, reference `IAPHelper.shared` in
/// `application(_:didFinishLaunchingWithOptions:)` in AppDelegate.
public class IAPHelper: NSObject  {

    // MARK:- Public Properties

    /// Singleton access. Use IAPHelper.shared to access all IAPHelper properties and methods.
    public static let shared: IAPHelper = IAPHelper()
    
    /// True if a purchase is in progress (excluding a deferred).
    public var isPurchasing = false
    
    /// List of products retrieved from the App Store and available for purchase.
    public var products: [SKProduct]?
    
    // MARK:- Internal Properties
    
    internal var productIds: Set<String> = ["instill.yearly", "instill.monthly"]
    
    internal var productsRequest: SKProductsRequest?  // Used to request product info async from the App Store
    internal var receiptRequest: SKRequest?  // Used to request a receipt refresh async from the App Store

    internal var requestProductsCompletion:     ((IAPNotification) -> Void)? = nil  // Completion handler when requesting products from the app store
    internal var requestReceiptCompletion:      ((IAPNotification) -> Void)? = nil  // Completion handler when requesting a receipt refresh from the App Store
    internal var purchaseCompletion:            ((IAPNotification?) -> Void)? = nil // Completion handler when purchasing a product from the App Store
    internal var notificationCompletion:        ((IAPNotification?) -> Void)? = nil // Completion handler for general notifications
    
    internal var haveConfiguredProductIdentifiers: Bool {
        return productIds.count > 0
    }
    
    // MARK:- Initialization of IAPHelper

    // Private initializer prevents more than a single instance of this class being created.
    // See the public static 'shared' property.
    private override init() {
        retryIntervalInSeconds = initialRetryIntervalInSeconds
        super.init()

        // Add ourselves as an observer of the StoreKit payments queue. This allows us to receive
        // notifications when payments are successful, fail, are restored, etc.
        // See the SKPaymentQueue notification handler paymentQueue(_:updatedTransactions:)
        // Add ourselves to the payment queue so we get App Store notifications
        SKPaymentQueue.default().add(self)

    }
    
    /// Call this method to remove IAPHelper as an observer of the StoreKit payment queue.
    /// This should be done from the AppDelgate applicationWillTerminate(_:) method.
    public func removeFromPaymentQueue() {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK:- Receipt
    
    private var retryIntervalInSeconds: TimeInterval
    private let initialRetryIntervalInSeconds: TimeInterval = 1
    private let maxRetryIntervalInSeconds: TimeInterval = 30
    private let limitRetryIntervalInSeconds: TimeInterval = 61
    private let retryDecayRate = 2.0

    public func getReceiptBase64EncodedString() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            
            retryIntervalInSeconds = initialRetryIntervalInSeconds
            
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)

                let receiptString = receiptData.base64EncodedString(options: [])

                return receiptString
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
            }
        } else {
            self.retryIntervalInSeconds = min(retryIntervalInSeconds * retryDecayRate, maxRetryIntervalInSeconds)
            
            if retryIntervalInSeconds < limitRetryIntervalInSeconds {
                DispatchQueue.main.asyncAfter(deadline: .now() + retryIntervalInSeconds) {
                    self.refreshReceipt { [weak self] notification in
                        if notification == .requestReceiptRefreshSuccess {
                            self?.purchaseCompletion?(.purchaseSuccess(productId: ""))
                        }
                    }
                }
            } else {
                return nil
            }
        }
        
        return nil
    }
}

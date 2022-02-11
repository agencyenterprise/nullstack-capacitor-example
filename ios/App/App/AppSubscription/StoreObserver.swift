//
//  StoreObserver.swift
//  App
//
//  Created by Fred Murakawa on 10/02/22.
//

import Foundation
import StoreKit

protocol StoreObserverDelegate: AnyObject {
    func storeObserverSubscribeDidSucceed(_ receiptString: String)
    func storeObserverDidReceiveMessage(_ message: String)
    func storeObserverDidCancel()
}

final class StoreObserver: NSObject {
    
    static let shared = StoreObserver()
    
    weak var delegate: StoreObserverDelegate?
    
    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)

                let receiptString = receiptData.base64EncodedString(options: [])

                self.delegate?.storeObserverSubscribeDidSucceed(receiptString)
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        } else {
            // TODO: Try to refresh receipt?            
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleFailed(_ transaction: SKPaymentTransaction) {
        var message = "\(Messages.purchaseOf) \(transaction.payment.productIdentifier) \(Messages.failed)"

        if let error = transaction.error {
            message += "\n\(Messages.error) \(error.localizedDescription)"
        }
        
        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            self.delegate?.storeObserverDidReceiveMessage(message)
        } else {
            self.delegate?.storeObserverDidCancel()
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func handleRestored(_ transaction: SKPaymentTransaction) {
        //TODO: Do we need this?
        
//        hasRestorablePurchases = true
//        restored.append(transaction)
//        print("\(Messages.restoreContent) \(transaction.payment.productIdentifier).")
        
//        DispatchQueue.main.async {
//            self.delegate?.storeObserverRestoreDidSucceed()
//        }
        // Finishes the restored transaction.
//        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // TODO: REFRESH RECEIPT???
}

// MARK: - SKPaymentTransactionObserver

extension StoreObserver: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { transaction in
            switch transaction.transactionState {
            case .purchased:
                handlePurchased(transaction)
            case .restored:
                handleRestored(transaction)
            case .failed:
                handleFailed(transaction)
            case .purchasing:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}

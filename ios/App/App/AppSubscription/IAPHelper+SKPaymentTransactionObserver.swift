//
//  IAPHelper+SKPaymentTransactionObserver.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import StoreKit

extension IAPHelper: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                purchaseCompleted(transaction: transaction)
            case .failed:
                purchaseFailed(transaction: transaction)
            case .deferred:
                purchaseDeferred(transaction: transaction)
            case .purchasing:
                purchaseInProgress(transaction: transaction)
            case .restored:
                break
            default:
                break
            }
        }
    }
    
    private func purchaseCompleted(transaction: SKPaymentTransaction) {
        // The purchase (or restore) was successful. Allow the user access to the product

        defer {
            // The use of the defer block guarantees that no matter when or how the method exits,
            // the code inside the defer block will be executed when the method goes out of scope.
            // It's important we remove the completed transaction from the queue. If this isn't done
            // then when the app restarts the payment queue will attempt to process the same transaction
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        isPurchasing = false
        let identifier = transaction.payment.productIdentifier

        // Tell the request originator about the purchase
        DispatchQueue.main.async {
            self.purchaseCompletion?(.purchaseSuccess(productId: identifier))
        }
    }

    private func purchaseFailed(transaction: SKPaymentTransaction) {
        // The purchase failed. Don't allow the user access to the product

        defer {
            // The use of the defer block guarantees that no matter when or how the method exits,
            // the code inside the defer block will be executed when the method goes out of scope
            // Always call SKPaymentQueue.default().finishTransaction() for a failure
            SKPaymentQueue.default().finishTransaction(transaction)
        }

        isPurchasing = false
        let identifier = transaction.payment.productIdentifier
        
        var message = ""

        if let e = transaction.error as NSError? {
            
            if e.code == SKError.paymentCancelled.rawValue {
                message = "\(Messages.purchaseCancelled) \(identifier)"
                DispatchQueue.main.async {
                    self.purchaseCompletion?(.purchaseCancelled(message: message))
                }
            } else {
                message = "\(Messages.purchaseFailure) \(identifier)"
                message += "\n\(Messages.error) \(e.localizedDescription)"
                DispatchQueue.main.async {
                    self.purchaseCompletion?(.purchaseFailure(message: message))
                }
            }
        } else {
            message = "\(Messages.purchaseCancelled) \(identifier)"
            DispatchQueue.main.async {
                self.purchaseCompletion?(.purchaseCancelled(message: message))
            }
        }
    }

    private func purchaseDeferred(transaction: SKPaymentTransaction) {
        // The purchase is in the deferred state. This happens when a device has parental restrictions enabled such
        // that in-app purchases require authorization from a parent. Do not allow access to the product at this point
        // Apple recommeds that there be no spinners or blocking while in this state as it could be hours or days
        // before the purchase is approved or declined.
        //
        // Starting December 31, 2020, legislation from the European Union introduces Strong Customer Authentication
        // (SCA) requirements for users in the European Economic Area (EEA) that may impact how they complete online
        // purchases. While the App Store and Apple Pay will support Strong Customer Authentication, you’ll need to verify
        // your app’s implementation of StoreKit and Apple Pay to ensure purchases are handled correctly.
        //
        // For in-app purchases that require SCA, the user is prompted to authenticate their credit or debit card.
        // They’re taken out of the purchase flow to the bank or payment service provider’s website or app for authentication,
        // then redirected to the App Store where they’ll see a message letting them know that their purchase is complete.
        // Handling this interrupted transaction is similar to Ask to Buy purchases that need approval from a family approver
        // or when users need to agree to updated App Store terms and conditions before completing a purchase.
        //
        // Make sure your app can properly handle interrupted transactions by initializing a transaction observer to respond
        // to new transactions and synchronize pending transactions with Apple. This observer helps your app handle SCA
        // transactions, which can update your payment queue with a state of “failed” or “deferred” as the user exits the app.
        // When the user is redirected to the App Store after authentication, a new transaction with a state of “purchased”
        // is immediately delivered to the observer and may include a new value for the transactionIdentifier property.
        //
        // Ref: https://developer.apple.com/support/psd2/

        isPurchasing = false
        DispatchQueue.main.async {
            self.purchaseCompletion?(.purchaseDeferred(productId: transaction.payment.productIdentifier))
        }

        // Do NOT call SKPaymentQueue.default().finishTransaction() for .deferred status
    }

    private func purchaseInProgress(transaction: SKPaymentTransaction) {
        // The product purchase transaction has started. Do not allow access to the product yet
        DispatchQueue.main.async {
            self.purchaseCompletion?(.purchaseInProgress(productId: transaction.payment.productIdentifier))
        }
        
        // Do NOT call SKPaymentQueue.default().finishTransaction() for .purchasing status
    }
}

// MARK: - Messages

struct Messages {
    static let error = "Error: "
    static let purchaseFailure = "Purchase failure for product"
    static let purchaseCancelled = "Purchase cancelled for product"
}

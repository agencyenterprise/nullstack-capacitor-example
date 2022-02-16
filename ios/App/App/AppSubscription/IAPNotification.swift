//
//  IAPNotification.swift
//  App
//
//  Created by Fred Murakawa on 14/02/22.
//

import Foundation


/// Informational logging notifications issued by IAPHelper
public enum IAPNotification: Error, Equatable {
    case configurationNoProductIds
    case requestProductsNoProducts
    case requestProductsInvalidProducts
    case requestProductsSuccess
    case requestProductsDidFinish
    case requestReceiptRefreshSuccess
    case requestProductsFailure(errorDescription: String)
    case requestReceiptRefreshFailure
    case purchaseAbortPurchaseInProgress
    case purchaseProductUnavailable(productId: String)
    case purchaseInProgress(productId: String)
    case purchaseCancelled(message: String)
    case purchaseDeferred(productId: String)
    case purchaseSuccess(productId: String)
    case purchaseFailure(message: String)
}

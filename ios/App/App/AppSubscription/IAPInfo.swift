//
//  IAPInfo.swift
//  App
//
//  Created by Gabriel Ribeiro on 14/02/22.
//

import Foundation

struct IAPInfo {
    var purchase: String
    
    var asDictionary: [String: Any] {
        return [
            "purchase": purchase,
            "platform": "ios"
        ]
    }
}

//
//  AppExtensions.swift
//  App
//
//  Created by Fred Murakawa on 10/02/22.
//

import UIKit

extension UIViewController {
    static func alert(_ title: String, message: String) {
        guard let controller = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                   style: .default, handler: nil)
        alertController.addAction(action)
        
        controller.present(alertController, animated: true)
    }
}

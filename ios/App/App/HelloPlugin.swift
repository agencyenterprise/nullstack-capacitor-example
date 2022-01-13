//
//  MortaroPlugin.swift
//  App
//
//  Created by Felipe Valadares on 1/13/22.
//

import Capacitor

@objc(HelloPlugin)
public class HelloPlugin: CAPPlugin {
    
    @objc func sayHello(_ call: CAPPluginCall) {
        let alert = UIAlertController(title: nil, message: "Hello :)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        
        DispatchQueue.main.async {
            self.bridge?.viewController?.present(alert, animated: true, completion: nil)
        }

        call.resolve()
    }
}

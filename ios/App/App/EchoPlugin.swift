//
//  EchoPlugin.swift
//  App
//
//  Created by Felipe Valadares on 1/13/22.
//

import Capacitor

@objc(EchoPlugin)
public class EchoPlugin: CAPPlugin {
    @objc func echo(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve(["value": value])
    }
}

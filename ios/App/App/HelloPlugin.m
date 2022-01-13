//
//  MortaroPlugin.m
//  App
//
//  Created by Felipe Valadares on 1/13/22.
//

#import <Capacitor/Capacitor.h>

CAP_PLUGIN(HelloPlugin, "Hello",
    CAP_PLUGIN_METHOD(sayHello, CAPPluginReturnPromise);
)

//
//  EchoPlugin.m
//  App
//
//  Created by Felipe Valadares on 1/13/22.
//

#import <Capacitor/Capacitor.h>

CAP_PLUGIN(EchoPlugin, "Echo",
    CAP_PLUGIN_METHOD(echo, CAPPluginReturnPromise);
)

//
//  AppSubscriptionPlugin.m
//  App
//
//  Created by Gustavo Gava on 02/02/2022.
//

#import <Capacitor/Capacitor.h>

CAP_PLUGIN(AppSubscriptionPlugin, "AppSubscriptionPlugin",
           CAP_PLUGIN_METHOD(subscribe, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removeAllListeners, CAPPluginReturnPromise);
)


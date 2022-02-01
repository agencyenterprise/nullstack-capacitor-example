package com.example.app.plugins.subscriptions

import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin
class AppSubscriptionPlugin : Plugin() {

    @PluginMethod
    fun subscribe(call: PluginCall) {
    }

    @PluginMethod
    fun isUserSubscribed(call: PluginCall) {
    }
}
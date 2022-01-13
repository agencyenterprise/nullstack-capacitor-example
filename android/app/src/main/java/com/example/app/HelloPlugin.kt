package com.example.app

import android.widget.Toast
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.PurchasesUpdatedListener
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "Hello")
class HelloPlugin : Plugin() {

    @PluginMethod
    fun sayHello(call: PluginCall) {
        Toast.makeText(context, "Hello :)", Toast.LENGTH_LONG).show()

        call.resolve()
    }
}
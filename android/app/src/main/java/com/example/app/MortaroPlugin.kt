package com.example.app

import android.widget.Toast
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.PurchasesUpdatedListener
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "Mortaro")
class MortaroPlugin : Plugin() {

    @PluginMethod
    fun sayHello(call: PluginCall) {
        Toast.makeText(context, "Hello Mortaro", Toast.LENGTH_LONG).show()

        call.resolve()
    }
}
package com.example.app.plugins.subscriptions

import android.util.Log
import com.android.billingclient.api.*
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@CapacitorPlugin
class AppSubscriptionPlugin : Plugin() {

    companion object {
        private const val TAG = "AppSubscriptionPlugin"
    }

    private val purchasesUpdatedListener =
        PurchasesUpdatedListener { billingResult, purchases ->
            Log.e(TAG, billingResult.debugMessage)
            purchases?.forEach { e -> Log.e(TAG, e.toString()) }
        }

    private lateinit var billingClient: BillingClient

    override fun handleOnStart() {
        super.handleOnStart()
        billingClient = BillingClient.newBuilder(context)
            .setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()
    }

    private fun connectToGooglePlay(action: () -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    CoroutineScope(Dispatchers.Main).launch {
                        action()
                    }
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.e(TAG, "Error while trying to connect with google play stablished")
                // Try to restart the connection on the next request to
                // Google Play by calling the startConnection() method.
            }
        })
    }

    suspend fun querySkuDetails() {
        val skuList = ArrayList<String>()
        skuList.add("gas")
//        skuList.add("premium_upgrade")


        // leverage querySkuDetails Kotlin extension function
        val params = SkuDetailsParams
            .newBuilder()
            .setSkusList(skuList)
            .setType(BillingClient.SkuType.SUBS)
            .build()
        val skuDetailsResult = withContext(Dispatchers.IO) {
            billingClient.querySkuDetails(params)
        }

        val flowParams = BillingFlowParams.newBuilder()
        skuDetailsResult.skuDetailsList?.forEach { e ->
            flowParams
                .setSkuDetails(e)
        }

        Log.e(TAG, skuDetailsResult.toString())

        val response = billingClient.launchBillingFlow(activity, flowParams.build())
        Log.e(TAG, "The result code is : ${response.debugMessage}")
    }

    suspend fun checkIfUserIsSubscribed() {
        val productId = "gas"

        val purchaseResult = withContext(Dispatchers.IO) {
            billingClient.queryPurchasesAsync(BillingClient.SkuType.SUBS)
        }

        val result = purchaseResult.purchasesList.find { e -> e.skus.contains(productId)  } != null
        Log.e(TAG, "User is subscribed : $result")
    }

    @PluginMethod
    fun subscribe(call: PluginCall) {

        connectToGooglePlay {
            CoroutineScope(Dispatchers.Main).launch {
                querySkuDetails()
            }
        }
    }

    @PluginMethod
    fun isUserSubscribed(call: PluginCall) {
        connectToGooglePlay {
            CoroutineScope(Dispatchers.Main).launch {
                checkIfUserIsSubscribed()
            }
        }

    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        billingClient.endConnection()
    }
}
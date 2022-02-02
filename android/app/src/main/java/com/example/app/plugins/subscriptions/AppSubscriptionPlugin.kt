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
        private const val DEFAULT_SUBSCRIPTION_TYPE = BillingClient.SkuType.SUBS
        private const val SUBSCRIPTION_PRODUCT_ID_KEY = "productId"
    }

    private lateinit var billingClient: BillingClient

    private val purchasesUpdatedListener =
        PurchasesUpdatedListener { billingResult, purchases ->
            Log.e(TAG, billingResult.debugMessage)
            purchases?.forEach { e -> Log.e(TAG, e.toString()) }
        }

    override fun handleOnStart() {
        super.handleOnStart()
        billingClient = BillingClient.newBuilder(context)
            .setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()
    }

    @PluginMethod
    fun subscribe(call: PluginCall) {
        val productId = call.getString(SUBSCRIPTION_PRODUCT_ID_KEY)
        val skus = buildSkuDetails(productId)

        connectToGooglePlay {
            displaySubscriptionDialog(skus)
        }
    }

    @PluginMethod
    fun isUserSubscribed(call: PluginCall) {
        val productId = call.getString(SUBSCRIPTION_PRODUCT_ID_KEY) ?: ""
        connectToGooglePlay {
            checkIfUserIsSubscribed(productId)
        }
    }

    private fun connectToGooglePlay(action: () -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
                    action()
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.e(TAG, "Error while trying to connect with google play stablished")
            }
        })
    }

    private fun buildSkuDetailsParams(skuList: List<String>, skuType: String) =
        SkuDetailsParams
            .newBuilder()
            .setSkusList(skuList)
            .setType(skuType)
            .build()

    private fun buildBillingFlowParams(skuDetails: List<SkuDetails>?): BillingFlowParams {
        val params = BillingFlowParams.newBuilder()
        skuDetails?.forEach { detail -> params.setSkuDetails(detail) }

        return params.build()
    }

    private fun buildSkuDetails(productId: String?): ArrayList<String> {
        if (productId.isNullOrBlank()) {
            return arrayListOf()
        }

        val skus = ArrayList<String>()
        skus.add(productId)

        return skus
    }

    private suspend fun loadSkuDetails(params: SkuDetailsParams) = withContext(Dispatchers.IO) {
        billingClient.querySkuDetails(params)
    }

    private suspend fun loadPurchases(skuType: String) = withContext(Dispatchers.IO) {
        billingClient.queryPurchasesAsync(skuType)
    }

    private fun findUserSubscription(productId: String, purchases: List<Purchase>) =
        purchases.find { e -> e.skus.contains(productId) } != null

    private fun displaySubscriptionDialog(skuList: ArrayList<String>) {
        CoroutineScope(Dispatchers.Main).launch {
            if (skuList.isEmpty()) {
                Log.e(TAG, "[displaySubscriptionDialog] : skuList is empty")
            }

            val skuDetailsParams = buildSkuDetailsParams(skuList, DEFAULT_SUBSCRIPTION_TYPE)
            val skuDetailsResult = loadSkuDetails(skuDetailsParams)

            val billingParams = buildBillingFlowParams(skuDetailsResult.skuDetailsList)

            val result = billingClient.launchBillingFlow(activity, billingParams)
            if (result.responseCode != BillingClient.BillingResponseCode.OK) {
                Log.e(TAG, result.debugMessage)
            }
        }
    }

    private fun checkIfUserIsSubscribed(productId: String) {
        CoroutineScope(Dispatchers.Main).launch {
            if (productId.isBlank()) {
                Log.e(TAG, "[checkIfUserIsSubscribed] : product id is empty")
            }

            val purchaseResult = loadPurchases(DEFAULT_SUBSCRIPTION_TYPE)
            val result = findUserSubscription(productId, purchaseResult.purchasesList)
            Log.e(TAG, "Subscribed? $result")
        }
    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        billingClient.endConnection()
    }
}
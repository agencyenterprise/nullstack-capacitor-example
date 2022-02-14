package com.example.app.plugins.subscriptions

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.android.billingclient.api.*
import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin
import com.google.gson.Gson
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.math.min

data class Info(val purchase: Purchase, val platform: String)

@CapacitorPlugin
class AppSubscriptionPlugin : Plugin() {

    companion object {
        private const val TAG = "AppSubscriptionPlugin"
        private const val SUBSCRIPTION_PRODUCT_ID_KEY = "productId"
        private const val PRODUCT_ID_NULL_OR_EMPTY_MESSAGE = "Product must not be null or empty"
        private const val PLATFORM_NAME = "android"

        private const val DEFAULT_SUBSCRIPTION_TYPE = BillingClient.SkuType.SUBS
        private const val PURCHASED_STATE = Purchase.PurchaseState.PURCHASED
        private const val STATUS_CODE_OK = BillingClient.BillingResponseCode.OK

        private const val RECONNECT_TIMER_START_MILLISECONDS = 1L * 1000L
        private const val RECONNECT_TIMER_MAX_TIME_MILLISECONDS = 1000L * 60L * 15L // 15 minutes

        private const val SUBSCRIPTION_NOTIFICATION_KEY = "onSubscriptionPurchased"
    }

    private lateinit var billingClient: BillingClient

    private val handler = Handler(Looper.getMainLooper())

    private var reconnectMilliseconds = RECONNECT_TIMER_START_MILLISECONDS

    private val billingClientStateListener = object : BillingClientStateListener {
        override fun onBillingSetupFinished(billingResult: BillingResult) {
            if (billingResult.responseCode == STATUS_CODE_OK) {
                reconnectMilliseconds = RECONNECT_TIMER_START_MILLISECONDS
                CoroutineScope(Dispatchers.Main).launch {
                    refreshPurchases()
                }
            }
        }

        override fun onBillingServiceDisconnected() {
            retryBillingServiceConnectionWithExponentialBackoff();
        }
    }

    private val purchasesUpdatedListener =
        PurchasesUpdatedListener { billingResult, purchases ->
            if (billingResult.responseCode == STATUS_CODE_OK) {
                handlePurchasesList(purchases)
            }
        }

    override fun handleOnStart() {
        super.handleOnStart()
        billingClient = BillingClient.newBuilder(context)
            .setListener(purchasesUpdatedListener)
            .enablePendingPurchases()
            .build()

        connectToGooglePlay()
    }

    override fun handleOnResume() {
        super.handleOnResume()
        if (billingClient.isReady) {
            CoroutineScope(Dispatchers.Main).launch {
                refreshPurchases()
            }
        }
    }

    @PluginMethod
    fun subscribe(call: PluginCall) {
        val productId = call.getString(SUBSCRIPTION_PRODUCT_ID_KEY)
        if (productId.isNullOrBlank()) {
            Log.d(TAG, "[subscribe]: $PRODUCT_ID_NULL_OR_EMPTY_MESSAGE")
            call.reject(PRODUCT_ID_NULL_OR_EMPTY_MESSAGE)
            return
        }

        CoroutineScope(Dispatchers.Main).launch {
            val skus = buildSkuDetails(productId)
            displaySubscriptionDialog(skus)
            call.resolve()
        }
    }

    private fun retryBillingServiceConnectionWithExponentialBackoff() {
        handler.postDelayed(
            { connectToGooglePlay() },
            reconnectMilliseconds
        )
        reconnectMilliseconds = min(
            reconnectMilliseconds * 2,
            RECONNECT_TIMER_MAX_TIME_MILLISECONDS
        )
    }

    private fun shouldAcknowledgePurchase(purchase: Purchase) =
        !purchase.isAcknowledged && purchase.purchaseState == PURCHASED_STATE

    private fun isValidPurchase(purchase: Purchase) =
        Security.verifyPurchase(purchase.originalJson, purchase.signature)

    private fun handlePurchasesList(purchases: List<Purchase>?) {
        purchases?.forEach { purchase ->
            val info = Info(purchase, PLATFORM_NAME)
            val jsonString = Gson().toJson(info)
            val payload = JSObject(jsonString)
            if (isValidPurchase(purchase) && shouldAcknowledgePurchase(purchase)) {
                notifyListeners(SUBSCRIPTION_NOTIFICATION_KEY, payload)
            }
        }
    }

    private fun connectToGooglePlay() = billingClient.startConnection(billingClientStateListener)

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

    private suspend fun refreshPurchases() {
        Log.d(TAG, "Refreshing purchases.")
        val purchasesResult = loadPurchases(DEFAULT_SUBSCRIPTION_TYPE)
        val billingResult = purchasesResult.billingResult
        if (billingResult.responseCode != STATUS_CODE_OK) {
            Log.e(TAG, "Problem getting subscriptions: " + billingResult.debugMessage)
        } else {
            handlePurchasesList(purchasesResult.purchasesList)
        }
        Log.d(TAG, "Refreshing purchases finished.")
    }

    private suspend fun loadSkuDetails(params: SkuDetailsParams) = withContext(Dispatchers.IO) {
        billingClient.querySkuDetails(params)
    }

    private suspend fun loadPurchases(skuType: String) = withContext(Dispatchers.IO) {
        billingClient.queryPurchasesAsync(skuType)
    }

    private suspend fun displaySubscriptionDialog(skuList: ArrayList<String>) {
        val skuDetailsParams = buildSkuDetailsParams(skuList, DEFAULT_SUBSCRIPTION_TYPE)
        val skuDetailsResult = loadSkuDetails(skuDetailsParams)

        val billingParams = buildBillingFlowParams(skuDetailsResult.skuDetailsList)

        val result = billingClient.launchBillingFlow(activity, billingParams)
        if (result.responseCode != STATUS_CODE_OK) {
            Log.e(TAG, result.debugMessage)
        }
    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        billingClient.endConnection()
    }
}
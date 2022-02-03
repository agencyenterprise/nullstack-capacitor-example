package com.example.app.plugins.subscriptions

import android.util.Log
import com.android.billingclient.api.*
import com.getcapacitor.JSObject
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
        private const val USER_SUBSCRIBED_KEY = "subscribed"
        private const val PRODUCT_ID_NULL_OR_EMPTY_MESSAGE = "Product must not be null or empty"
        private const val PURCHASED_STATE = Purchase.PurchaseState.PURCHASED
        private const val STATUS_CODE_OK = BillingClient.BillingResponseCode.OK
    }

    private lateinit var billingClient: BillingClient

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
            .build()
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

        val skus = buildSkuDetails(productId)
        connectToGooglePlay {
            CoroutineScope(Dispatchers.Main).launch {
                displaySubscriptionDialog(skus)
                call.resolve()
            }
        }
    }

    @PluginMethod
    fun isUserSubscribed(call: PluginCall) {
        val productId = call.getString(SUBSCRIPTION_PRODUCT_ID_KEY)

        if (productId.isNullOrBlank()) {
            Log.d(TAG, "[isUserSubscribed]: $PRODUCT_ID_NULL_OR_EMPTY_MESSAGE")
            call.reject(PRODUCT_ID_NULL_OR_EMPTY_MESSAGE)
            return
        }

        connectToGooglePlay {
            CoroutineScope(Dispatchers.Main).launch {
                val result = checkIfUserIsSubscribed(productId)
                call.resolve(buildUserSubscribedResponse(productId, result))
            }
        }
    }

    private fun shouldAcknowledgePurchase(purchase: Purchase) =
        !purchase.isAcknowledged && purchase.purchaseState == PURCHASED_STATE

    private fun isValidPurchase(purchase: Purchase) =
        Security.verifyPurchase(purchase.originalJson, purchase.signature)

    private suspend fun processPurchase(purchase: Purchase) {
        val acknowledgePurchaseParams = buildAcknowledgePurchaseParams(purchase)
        val ackPurchaseResult = acknowledgePurchase(acknowledgePurchaseParams)

        if (ackPurchaseResult.responseCode != STATUS_CODE_OK) {
            Log.e(TAG, ackPurchaseResult.debugMessage)
        }
    }

    private fun handlePurchasesList(purchases: List<Purchase>?) {
        purchases?.forEach { purchase ->
            if (isValidPurchase(purchase) && shouldAcknowledgePurchase(purchase)) {
                CoroutineScope(Dispatchers.Main).launch {
                    processPurchase(purchase)
                }
            }
        }
    }

    private fun buildUserSubscribedResponse(productId: String, subscribed: Boolean): JSObject {
        val jsonObject = JSObject()
        jsonObject.put(SUBSCRIPTION_PRODUCT_ID_KEY, productId)
        jsonObject.put(USER_SUBSCRIBED_KEY, subscribed)

        return jsonObject
    }

    private fun connectToGooglePlay(action: () -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == STATUS_CODE_OK) {
                    action()
                }
            }

            override fun onBillingServiceDisconnected() {
                Log.d(TAG, "Billing service disconnected")
            }
        })
    }

    private fun buildSkuDetailsParams(skuList: List<String>, skuType: String) =
        SkuDetailsParams
            .newBuilder()
            .setSkusList(skuList)
            .setType(skuType)
            .build()

    private fun buildAcknowledgePurchaseParams(purchase: Purchase) =
        AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchase.purchaseToken).build()

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

    private suspend fun acknowledgePurchase(params: AcknowledgePurchaseParams) =
        withContext(Dispatchers.IO) {
            billingClient.acknowledgePurchase(params)
        }

    private fun findUserSubscription(productId: String, purchases: List<Purchase>) =
        purchases.find { purchase ->
            purchase.skus.contains(productId) && purchase.purchaseState == PURCHASED_STATE
        } != null

    private suspend fun displaySubscriptionDialog(skuList: ArrayList<String>) {
        val skuDetailsParams = buildSkuDetailsParams(skuList, DEFAULT_SUBSCRIPTION_TYPE)
        val skuDetailsResult = loadSkuDetails(skuDetailsParams)

        val billingParams = buildBillingFlowParams(skuDetailsResult.skuDetailsList)

        val result = billingClient.launchBillingFlow(activity, billingParams)
        if (result.responseCode != STATUS_CODE_OK) {
            Log.e(TAG, result.debugMessage)
        }
    }

    private suspend fun checkIfUserIsSubscribed(productId: String): Boolean {
        val purchaseResult = loadPurchases(DEFAULT_SUBSCRIPTION_TYPE)
        return findUserSubscription(productId, purchaseResult.purchasesList)
    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        billingClient.endConnection()
    }
}
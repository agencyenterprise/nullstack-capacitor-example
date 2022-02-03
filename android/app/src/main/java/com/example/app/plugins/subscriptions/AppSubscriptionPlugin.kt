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
class AppSubscriptionPlugin : Plugin(), PurchasesUpdatedListener {

    companion object {
        private const val TAG = "AppSubscriptionPlugin"
        private const val DEFAULT_SUBSCRIPTION_TYPE = BillingClient.SkuType.SUBS
        private const val SUBSCRIPTION_PRODUCT_ID_KEY = "productId"
        private const val USER_SUBSCRIBED_KEY = "subscribed"
        private const val PRODUCT_ID_NULL_OR_EMPTY_MESSAGE = "Product must not be null or empty"
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

    private fun buildUserSubscribedResponse(productId: String, subscribed: Boolean): JSObject {
        val jsonObject = JSObject()
        jsonObject.put(SUBSCRIPTION_PRODUCT_ID_KEY, productId)
        jsonObject.put(USER_SUBSCRIBED_KEY, subscribed)

        return jsonObject
    }

    private fun connectToGooglePlay(action: () -> Unit) {
        billingClient.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(billingResult: BillingResult) {
                if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
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
        purchases.find { purchase ->
            purchase.skus.contains(productId) && purchase.purchaseState == Purchase.PurchaseState.PURCHASED
        } != null

    private suspend fun displaySubscriptionDialog(skuList: ArrayList<String>) {
        val skuDetailsParams = buildSkuDetailsParams(skuList, DEFAULT_SUBSCRIPTION_TYPE)
        val skuDetailsResult = loadSkuDetails(skuDetailsParams)

        val billingParams = buildBillingFlowParams(skuDetailsResult.skuDetailsList)

        val result = billingClient.launchBillingFlow(activity, billingParams)
        if (result.responseCode != BillingClient.BillingResponseCode.OK) {
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

    override fun onPurchasesUpdated(
        billingResult: BillingResult,
        list: MutableList<Purchase>?
    ) {
        if (billingResult.responseCode == BillingClient.BillingResponseCode.OK) {
            handlePurchaseList(list)
        }
    }

    private fun handlePurchaseList(purchases: List<Purchase>?){
        if (null != purchases) {
            for (purchase in purchases) {
                if (purchase.purchaseState == Purchase.PurchaseState.PURCHASED) {
                    if (!Security.verifyPurchase(purchase.originalJson, purchase.signature))
                        Log.e(TAG, "Invalid Signature")
                }
            }
        }
    }

}
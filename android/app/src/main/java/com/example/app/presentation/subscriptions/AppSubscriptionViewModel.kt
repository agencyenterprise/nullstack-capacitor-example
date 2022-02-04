package com.example.app.presentation.subscriptions

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.example.app.base.BaseViewModel
import com.example.app.data.repository.model.purchases.PurchaseDetailRequest
import com.example.app.data.repository.remote.purchases.IPurchasesRepository
import com.example.app.helper.Event
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

class AppSubscriptionViewModel(private val repository: IPurchasesRepository) : BaseViewModel() {

    companion object {
        private const val SUCCESS = "success"
        private const val FAIL = "failure"
    }

    private val _onPurchaseDetailRequestFinished = MutableLiveData<Event<String>>()
    val onPurchaseDetailRequestFinished: LiveData<Event<String>> = _onPurchaseDetailRequestFinished

    fun sendPurchaseDetails(purchaseDetail: PurchaseDetailRequest) {
        launch {
            repository
                .sendPurchaseDetails(purchaseDetail)
                .catch { _onPurchaseDetailRequestFinished.value = Event(FAIL) }
                .collect { succeed ->
                    _onPurchaseDetailRequestFinished.value = Event(if (succeed) SUCCESS else FAIL)
                }
        }
    }
}
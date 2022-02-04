package com.example.app.data.repository.remote.purchases

import com.example.app.base.BaseRepository
import com.example.app.data.repository.model.purchases.PurchaseDetailRequest
import com.example.app.data.repository.remote.api.purchases.PurchaseApi
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.withContext

class PurchasesRepository(private val api: PurchaseApi) : BaseRepository(), IPurchasesRepository {

    override suspend fun sendPurchaseDetails(request: PurchaseDetailRequest) =
        withContext(coroutineContext) {
            val result = api.sendPurchaseDetails(request)
            flow {
                emit(result.isSuccessful)
            }
        }
}
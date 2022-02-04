package com.example.app.data.repository.remote.purchases

import com.example.app.data.repository.model.purchases.PurchaseDetailRequest
import kotlinx.coroutines.flow.Flow

interface IPurchasesRepository {

    suspend fun sendPurchaseDetails(request: PurchaseDetailRequest): Flow<Boolean>
}
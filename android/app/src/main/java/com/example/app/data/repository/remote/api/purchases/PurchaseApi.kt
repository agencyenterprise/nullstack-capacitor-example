package com.example.app.data.repository.remote.api.purchases

import com.example.app.data.repository.model.purchases.PurchaseDetailRequest
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST

interface PurchaseApi {

    @POST("webhook/android")
    suspend fun sendPurchaseDetails(@Body request: PurchaseDetailRequest): Response<Void>
}
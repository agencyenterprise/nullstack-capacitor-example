package com.example.app.data.di

import com.appsandbox.test.BuildConfig
import com.example.app.data.repository.remote.api.purchases.PurchaseApi
import com.example.app.data.repository.remote.purchases.IPurchasesRepository
import com.example.app.data.repository.remote.purchases.PurchasesRepository
import org.koin.dsl.module
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

private val apiModule = module {
    single { get<Retrofit>().create(PurchaseApi::class.java) }
}

private val repository = module {
    single<IPurchasesRepository> { PurchasesRepository(get()) }
}

private val networkModule = module {
    single {
        Retrofit.Builder()
            .baseUrl(BuildConfig.BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
    }
}

val dataModule = networkModule + apiModule + repository
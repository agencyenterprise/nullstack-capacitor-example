package com.example.app

import android.app.Application
import com.example.app.data.di.dataModule
import com.example.app.presentation.di.presentationModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class Application : Application() {
    override fun onCreate() {
        super.onCreate()

        startKoin {
            androidContext(this@Application)
            modules(presentationModule + dataModule)
        }
    }
}
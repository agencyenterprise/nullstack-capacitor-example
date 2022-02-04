package com.example.app.presentation.di

import com.example.app.presentation.subscriptions.AppSubscriptionViewModel
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

private val module = module {
    viewModel { AppSubscriptionViewModel(get()) }
}

val presentationModule = module
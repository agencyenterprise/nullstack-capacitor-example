package com.example.app;

import android.os.Bundle;

import com.example.app.plugins.subscriptions.AppSubscriptionPlugin;
import com.getcapacitor.BridgeActivity;

public class MainActivity extends BridgeActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        registerPlugin(EchoPlugin.class);
        registerPlugin(HelloPlugin.class);
        registerPlugin(AppSubscriptionPlugin.class);
    }
}

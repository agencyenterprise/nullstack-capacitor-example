package com.example.app.helper

import android.util.Base64
import android.util.Log

import com.appsandbox.test.BuildConfig
import java.lang.IllegalArgumentException
import java.security.*
import java.security.spec.X509EncodedKeySpec

object Security {
    private const val TAG = "Payment/Security"
    private const val KEY_FACTORY_ALGORITHM = "RSA"
    private const val SIGNATURE_ALGORITHM = "SHA1withRSA"
    private const val PUBLIC_KEY = BuildConfig.SUBSCRIPTION_LICENSE_KEY

    fun verifyPurchase(data: String, signature: String): Boolean {
        if (signature.isBlank() || data.isBlank() || PUBLIC_KEY.isBlank()) {
            Log.w(TAG, "Purchase verification failed: missing data.")
            return false
        }
        return try {
            val key = generatePublicKey(PUBLIC_KEY)
            verify(key, data, signature)
        } catch (e: InvalidKeyException) {
            Log.e(TAG, "")
            false
        }
    }

    private fun generatePublicKey(publicKey: String): PublicKey {
        val decodedKey = Base64.decode(publicKey, Base64.DEFAULT)
        val keyFactory = KeyFactory.getInstance(KEY_FACTORY_ALGORITHM)
        return keyFactory.generatePublic(X509EncodedKeySpec(decodedKey))
    }

    private fun verify(publicKey: PublicKey, data: String, signature: String): Boolean {
        val signatureBytes = try {
            Base64.decode(signature, Base64.DEFAULT)
        } catch (e: IllegalArgumentException) {
            Log.w(TAG, "Decoding Failed")
            return false
        }
        try {
            Signature.getInstance(SIGNATURE_ALGORITHM)
                .run {
                    initVerify(publicKey)
                    update(data.toByteArray())
                    if (verify(signatureBytes)) {
                        return true
                    }
                }
            Log.w(TAG, "Signature verification failed")
            return false
        } catch (e: InvalidKeyException) {
            Log.e(TAG, "Invalid Key")
        } catch (e: SignatureException) {
            Log.e(TAG, "Signature Exception")
        }
        return false
    }
}
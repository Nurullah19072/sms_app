package com.example.sms_app  // <-- kendi paket adınla aynı olmalı

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Base64
import android.util.Log
import androidx.preference.PreferenceManager
import okhttp3.*
import org.bouncycastle.jce.provider.BouncyCastleProvider
import org.json.JSONObject
import java.io.IOException
import java.security.SecureRandom
import java.security.Security
import javax.crypto.Cipher
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody
import okhttp3.Response
import okhttp3.Callback


class SmsReceiver : BroadcastReceiver() {

    private val client = OkHttpClient()
    private val huggingfaceUrl = "https://08cf78f0-e670-4887-9101-d672c026b47a-00-2hxds00um0q5r.pike.replit.dev/predict" // 🔥 HuggingFace API URL'in

    companion object {
        private const val AES_KEY = "ThisIsASecretKey" // 🔥 Flutter tarafında kullandığın 16 karakterlik KEY ile aynı olmalı
    }

    override fun onReceive(context: Context, intent: Intent) {
        // SMS geldiğinde ForegroundService başlat
        val serviceIntent = Intent(context, ForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }


        val bundle: Bundle? = intent.extras
        if (bundle != null) {
            try {
                val pdus = bundle.get("pdus") as Array<*>
                val format = bundle.getString("format")

                for (pdu in pdus) {
                    val smsMessage: SmsMessage = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        SmsMessage.createFromPdu(pdu as ByteArray, format)
                    } else {
                        SmsMessage.createFromPdu(pdu as ByteArray)
                    }

                    val sender = smsMessage.originatingAddress ?: "Bilinmeyen"
                    val body = smsMessage.messageBody ?: ""

                    Log.d("SmsReceiver", "📩 Gelen SMS: $sender - $body")

                    // 📦 Önce gelen mesajı kaydet
                    saveMessage(context, sender, body)

                    // 🚀 HuggingFace API'ye gönderip sınıflandıralım
                    classifyAndSave(context, body)
                }
            } catch (e: Exception) {
                Log.e("SmsReceiver", "Hata oluştu: ${e.message}")
            }
        }


    }

    private fun saveMessage(context: Context, sender: String, body: String) {
        val prefs = PreferenceManager.getDefaultSharedPreferences(context)
        val editor = prefs.edit()
        editor.putString("last_sms_sender", sender)
        editor.putString("last_sms_body", body)
        editor.apply()
    }

    private fun classifyAndSave(context: Context, body: String) {
        try {
            val encryptedBody = encryptAES(body) // 🔐 Şifrele ve gönder

            val json = JSONObject()
            json.put("sms", encryptedBody)

            val mediaType = "application/json; charset=utf-8".toMediaTypeOrNull()
            val requestBody = RequestBody.create(mediaType, json.toString())


            val request = Request.Builder()
                .url(huggingfaceUrl)
                .post(requestBody)
                .build()

            client.newCall(request).enqueue(object : Callback {
                override fun onFailure(call: Call, e: IOException) {
                    Log.e("SmsReceiver", "❌ HuggingFace API Hatası: ${e.message}")
                }

                override fun onResponse(call: Call, response: Response) {
                    val responseData = response.body?.string()
                    Log.d("SmsReceiver", "✅ HuggingFace API cevabı: $responseData")

                    if (response.isSuccessful && responseData != null) {
                        val jsonResponse = JSONObject(responseData)
                        val result = jsonResponse.optString("result", "")

                        val isSpam = result.contains("LABEL_1")

                        val prefs = PreferenceManager.getDefaultSharedPreferences(context)
                        val editor = prefs.edit()
                        editor.putBoolean("last_sms_is_spam", isSpam)
                        editor.apply()
                    }
                }
            })
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Sınıflandırma Hatası: ${e.message}")
        }
    }

    private fun encryptAES(plainText: String): String {
        Security.addProvider(BouncyCastleProvider())

        val keySpec = SecretKeySpec(AES_KEY.toByteArray(Charsets.UTF_8), "AES")
        val iv = ByteArray(16)
        SecureRandom().nextBytes(iv)

        val cipher = Cipher.getInstance("AES/CBC/PKCS7Padding", "BC")
        cipher.init(Cipher.ENCRYPT_MODE, keySpec, IvParameterSpec(iv))

        val encryptedBytes = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        val combined = iv + encryptedBytes

        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }
}

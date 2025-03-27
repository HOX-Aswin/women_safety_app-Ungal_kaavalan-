package com.example.ungal_kaavalan

import android.telephony.SmsManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.util.Log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phone")?.trim()
                val sosMessage = call.argument<String>("sosMessage")?.trim()
                val locationMessage = call.argument<String>("locationMessage")?.trim()

                Log.d("SMS_DEBUG", "Received Phone: $phoneNumber")
                Log.d("SMS_DEBUG", "Received SOS Message: $sosMessage")
                Log.d("SMS_DEBUG", "Received Location Message: $locationMessage")

                if (phoneNumber.isNullOrEmpty() || sosMessage.isNullOrEmpty() || locationMessage.isNullOrEmpty()) {
                    result.error("INVALID_ARGUMENTS", "Phone number or message is missing", null)
                    return@setMethodCallHandler
                }

                try {
                    val smsManager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        applicationContext.getSystemService(SmsManager::class.java)
                    } else {
                        SmsManager.getDefault()
                    }

                    // Send both SMS messages
                    smsManager.sendTextMessage(phoneNumber, null, sosMessage, null, null)
                    smsManager.sendTextMessage(phoneNumber, null, locationMessage, null, null)

                    Log.d("SMS_DEBUG", "SMS Sent Successfully to $phoneNumber")

                    result.success("SMS sent successfully")
                } catch (e: Exception) {
                    Log.e("SMS_DEBUG", "SMS Sending Failed: ${e.message}")
                    result.error("SMS_ERROR", "Failed to send SMS: ${e.message}", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}

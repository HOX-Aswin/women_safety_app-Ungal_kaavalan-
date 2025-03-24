package com.example.ungal_kaavalan


import android.telephony.SmsManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phone")
                val message = call.argument<String>("message")

                if (phoneNumber != null && message != null) {
                    try {
                        val smsManager = SmsManager.getDefault()
                        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
                        result.success("SMS sent successfully")
                    } catch (e: Exception) {
                        result.error("SMS_ERROR", "Failed to send SMS: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone number or message missing", null)
                }
            }
        }
    }
}
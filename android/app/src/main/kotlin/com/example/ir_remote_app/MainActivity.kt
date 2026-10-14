package com.example.ir_remote_app

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val ir = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ir")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasEmitter" -> result.success(ir?.hasIrEmitter() == true)
                    "transmit" -> {
                        try {
                            val freq = call.argument<Int>("freq")!!
                            val pattern = call.argument<List<Int>>("pattern")!!.toIntArray()
                            ir?.transmit(freq, pattern)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("IR_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}

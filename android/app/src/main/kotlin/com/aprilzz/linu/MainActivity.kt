package com.aprilzz.linu

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val RINGTONE_CHANNEL = "com.aprilzz.linu/ringtone"
    private lateinit var audioManager: AudioManager
    private lateinit var methodChannelHandler: AudioMethodChannelHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        audioManager = AudioManager(applicationContext)
        methodChannelHandler = AudioMethodChannelHandler(applicationContext, audioManager)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, RINGTONE_CHANNEL)
            .setMethodCallHandler(methodChannelHandler)
    }
}

package com.aprilzz.linu

import android.content.Context
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class AudioMethodChannelHandler(
    private val context: Context,
    private val audioManager: AudioManager
) : MethodChannel.MethodCallHandler {
    
    private val executor = Executors.newCachedThreadPool()
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startRinging" -> handleStartRinging(call, result)
            "stopRinging" -> handleStopRinging(result)
            "isRinging" -> handleIsRinging(result)
            "getCustomAudios" -> handleGetCustomAudios(result)
            "trimAudio" -> handleTrimAudio(call, result)
            "getAudioDuration" -> handleGetAudioDuration(call, result)
            "getSoundContentUri" -> handleGetSoundContentUri(call, result)
            else -> result.notImplemented()
        }
    }
    
    private fun handleStartRinging(call: MethodCall, result: MethodChannel.Result) {
        val title = call.argument<String>("title") ?: "紧急消息"
        val body = call.argument<String>("body") ?: ""
        val sound = call.argument<String>("sound")
        
        RingingForegroundService.start(context, title, body, sound)
        result.success(true)
    }
    
    private fun handleStopRinging(result: MethodChannel.Result) {
        RingingForegroundService.stop(context)
        result.success(true)
    }
    
    private fun handleIsRinging(result: MethodChannel.Result) {
        result.success(RingingForegroundService.isRunning())
    }
    
    private fun handleGetCustomAudios(result: MethodChannel.Result) {
        executor.execute {
            try {
                val audios = audioManager.getCustomAudios()
                result.success(audios)
            } catch (e: Exception) {
                result.error("GET_CUSTOM_AUDIOS_FAILED", e.message, null)
            }
        }
    }
    
    private fun handleTrimAudio(call: MethodCall, result: MethodChannel.Result) {
        val sourcePath = call.argument<String>("sourcePath")
        val startTime = call.argument<Double>("startTime")
        val endTime = call.argument<Double>("endTime")
        val outputPath = call.argument<String>("outputPath")
        
        if (sourcePath == null || startTime == null || endTime == null || outputPath == null) {
            result.error("INVALID_ARGS", "Missing required arguments", null)
            return
        }
        
        executor.execute {
            try {
                val outputFile = audioManager.trimAudio(sourcePath, startTime, endTime, outputPath)
                result.success(outputFile)
            } catch (e: Exception) {
                result.error("TRIM_AUDIO_FAILED", e.message ?: "Unknown error", null)
            }
        }
    }
    
    private fun handleGetAudioDuration(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")
        if (filePath == null) {
            result.error("INVALID_ARGS", "Missing filePath", null)
            return
        }
        
        try {
            val duration = audioManager.getAudioDuration(filePath)
            result.success(duration)
        } catch (e: Exception) {
            result.error("GET_DURATION_FAILED", e.message, null)
        }
    }
    
    /** 将铃音文件路径转为 content URI，供 Android 8+ 通知 channel 使用 */
    private fun handleGetSoundContentUri(call: MethodCall, result: MethodChannel.Result) {
        val filePath = call.argument<String>("path")
        if (filePath == null) {
            result.error("INVALID_ARGS", "Missing path argument", null)
            return
        }
        try {
            val file = File(filePath)
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "Sound file not found: $filePath", null)
                return
            }
            val uri = FileProvider.getUriForFile(
                context,
                "${context.packageName}.fileprovider",
                file
            )
            result.success(uri.toString())
        } catch (e: Exception) {
            result.error("GET_CONTENT_URI_FAILED", e.message, null)
        }
    }
}

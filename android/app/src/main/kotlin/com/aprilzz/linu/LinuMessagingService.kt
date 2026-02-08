package com.aprilzz.linu

import android.content.Context
import android.content.SharedPreferences
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import org.json.JSONObject

/**
 * FCM 消息服务
 *
 * 接收消息后转发给 Flutter 处理，轮询等待处理完成后检查是否需要启动响铃服务
 */
class LinuMessagingService : FirebaseMessagingService() {

    companion object {
        private const val TAG = "LinuMessagingService"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_PENDING_RINGING = "flutter.pending_ringing"
        private const val KEY_MESSAGE_PROCESSED = "flutter.message_processed"
        private const val POLL_INTERVAL_MS = 100L
        private const val POLL_TIMEOUT_MS = 5000L
    }

    private val handler = Handler(Looper.getMainLooper())
    private var pollStartTime = 0L
    private var isPolling = false
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        Log.d(TAG, "Message received from: ${remoteMessage.from}")
        super.onMessageReceived(remoteMessage)
        startPolling()
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "New FCM token: $token")
        super.onNewToken(token)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopPolling()
        releaseWakeLock()
    }

    private fun startPolling() {
        if (isPolling) return

        isPolling = true
        pollStartTime = System.currentTimeMillis()
        acquireWakeLock()
        poll()
    }

    private fun poll() {
        val elapsed = System.currentTimeMillis() - pollStartTime
        if (elapsed > POLL_TIMEOUT_MS) {
            Log.w(TAG, "Polling timeout after ${elapsed}ms")
            stopPolling()
            return
        }

        try {
            val prefs = getPreferences()
            val marker = prefs.getString(KEY_MESSAGE_PROCESSED, null)

            if (marker != null) {
                Log.d(TAG, "Message processed after ${elapsed}ms")
                prefs.edit().remove(KEY_MESSAGE_PROCESSED).apply()
                checkAndStartRinging(prefs)
                stopPolling()
                return
            }

            handler.postDelayed({ poll() }, POLL_INTERVAL_MS)
        } catch (e: Exception) {
            Log.e(TAG, "Polling error", e)
            stopPolling()
        }
    }

    private fun stopPolling() {
        isPolling = false
        handler.removeCallbacksAndMessages(null)
        releaseWakeLock()
    }

    private fun checkAndStartRinging(prefs: SharedPreferences) {
        try {
            val json = prefs.getString(KEY_PENDING_RINGING, null) ?: return

            val obj = JSONObject(json)
            val title = obj.optString("title")
            val body = obj.optString("body")
            val sound = obj.optString("sound", "")

            Log.i(TAG, "Starting ringing: $title")
            RingingForegroundService.start(this, title, body, sound)

            prefs.edit().remove(KEY_PENDING_RINGING).apply()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start ringing", e)
        }
    }

    private fun acquireWakeLock() {
        try {
            if (wakeLock == null) {
                val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                wakeLock = pm.newWakeLock(
                    PowerManager.PARTIAL_WAKE_LOCK,
                    "LinuMessaging::Polling"
                ).apply {
                    setReferenceCounted(false)
                }
            }
            wakeLock?.acquire(POLL_TIMEOUT_MS + 1000)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to acquire WakeLock", e)
        }
    }

    private fun releaseWakeLock() {
        try {
            wakeLock?.let {
                if (it.isHeld) it.release()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to release WakeLock", e)
        }
    }

    private fun getPreferences() = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}

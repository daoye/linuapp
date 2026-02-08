package com.aprilzz.linu

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import androidx.core.app.NotificationCompat
import java.io.File

/**
 * 响铃前台服务
 *
 * 用于 Ringing 优先级消息的持续响铃，作为前台服务运行，
 * 负责播放铃声、振动和显示来电式通知
 */
class RingingForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "ringing_channel"
        const val NOTIFICATION_ID = 999999

        const val ACTION_START = "com.aprilzz.linu.RINGTONE_START"
        const val ACTION_STOP = "com.aprilzz.linu.RINGTONE_STOP"

        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_SOUND = "sound"

        private const val RINGING_DURATION_MS = 30_000L

        private var instance: RingingForegroundService? = null

        fun isRunning(): Boolean = instance != null

        fun start(context: Context, title: String, body: String, sound: String?) {
            // 如果服务已在运行，先停止旧的
            if (isRunning()) {
                stop(context)
            }

            val intent = Intent(context, RingingForegroundService::class.java).apply {
                action = ACTION_START
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
                putExtra(EXTRA_SOUND, sound)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, RingingForegroundService::class.java))
        }
    }

    private var mediaPlayer: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val handler = Handler(Looper.getMainLooper())
    private var stopAfterDelayRunnable: Runnable? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopRinging()
        instance = null
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> {
                // 从 Intent extras 或 arguments 中获取参数
                val extras = intent.extras
                val title = extras?.getString("title")
                    ?: intent.getStringExtra(EXTRA_TITLE)
                    ?: "紧急消息"
                val body = extras?.getString("body")
                    ?: intent.getStringExtra(EXTRA_BODY)
                    ?: ""
                val sound = extras?.getString("sound")
                    ?: intent.getStringExtra(EXTRA_SOUND)
                startRinging(title, body, sound)
            }
            ACTION_STOP -> {
                stopSelf()
            }
        }
        return START_NOT_STICKY
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = getString(R.string.ringing_channel_name)
            val channelDescription = getString(R.string.ringing_channel_description)

            val channel = NotificationChannel(
                CHANNEL_ID,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = channelDescription
                setBypassDnd(true)
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000, 500, 1000)
            }

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun startRinging(title: String, body: String, soundName: String?) {
        val stopIntent = Intent(this, RingingForegroundService::class.java).apply {
            action = ACTION_STOP
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val openIntent = packageManager.getLaunchIntentForPackage(packageName)?.apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = if (openIntent != null) {
            PendingIntent.getActivity(
                this, 1, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else null

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setOngoing(true)
            .setAutoCancel(false)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "停止", stopPendingIntent)
            .setFullScreenIntent(openPendingIntent, true)
            .build()

        startForeground(NOTIFICATION_ID, notification)

        playSound(soundName)
        startVibration()

        // 确保30秒后自动停止
        stopAfterDelayRunnable?.let { handler.removeCallbacks(it) }
        stopAfterDelayRunnable = Runnable {
            stopSelf()  // 30秒后自动停止服务
        }
        handler.postDelayed(stopAfterDelayRunnable!!, RINGING_DURATION_MS)
    }

    private fun playSound(soundName: String?) {
        try {
            mediaPlayer?.release()

            val soundUri = if (!soundName.isNullOrEmpty()) {
                val soundsDir = File(filesDir, "sounds")
                var soundFile: File? = null

                val extensions = listOf("mp3", "wav", "ogg", "m4a", "aac")
                for (ext in extensions) {
                    val file = File(soundsDir, "$soundName.$ext")
                    if (file.exists()) {
                        soundFile = file
                        break
                    }
                }

                if (soundFile != null) {
                    Uri.fromFile(soundFile)
                } else {
                    val manager = RingtoneManager(applicationContext)
                    manager.setType(RingtoneManager.TYPE_RINGTONE)
                    val cursor = manager.cursor
                    var systemUri: Uri? = null

                    while (cursor.moveToNext()) {
                        val title = cursor.getString(RingtoneManager.TITLE_COLUMN_INDEX)
                        if (title == soundName) {
                            systemUri = manager.getRingtoneUri(cursor.position)
                            break
                        }
                    }
                    cursor.close()

                    systemUri
                }
            } else {
                null
            }

            if (soundUri != null) {
                mediaPlayer = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    setDataSource(applicationContext, soundUri)
                    isLooping = true
                    prepare()
                    start()
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            try {
                val defaultUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                mediaPlayer = MediaPlayer().apply {
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    setDataSource(applicationContext, defaultUri)
                    isLooping = true
                    prepare()
                    start()
                }
            } catch (e2: Exception) {
                e2.printStackTrace()
            }
        }
    }

    private fun startVibration() {
        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        val pattern = longArrayOf(0, 1000, 500, 1000, 500, 1000, 500)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator?.vibrate(VibrationEffect.createWaveform(pattern, 0))
        } else {
            @Suppress("DEPRECATION")
            vibrator?.vibrate(pattern, 0)
        }
    }

    private fun stopRinging() {
        stopAfterDelayRunnable?.let { handler.removeCallbacks(it) }
        stopAfterDelayRunnable = null

        mediaPlayer?.apply {
            if (isPlaying) {
                stop()
            }
            release()
        }
        mediaPlayer = null

        vibrator?.cancel()
        vibrator = null

        stopForeground(STOP_FOREGROUND_REMOVE)
    }
}

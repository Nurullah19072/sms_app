package com.example.sms_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class ForegroundService : Service() {

    private val CHANNEL_ID = "ForegroundServiceChannel"

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        startForeground(1, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Servis burada arka planda çalışıyor
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Foreground Service Channel",
                NotificationManager.IMPORTANCE_MIN // 🔥 En düşük seviye
            ).apply {
                setShowBadge(false) // Bildirimde sayı rozetleri gösterilmesin
                lockscreenVisibility = Notification.VISIBILITY_SECRET // Kilit ekranında gösterme
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }


    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("") // Başlığı boş bırak
            .setContentText("") // İçeriği boş bırak
            .setSmallIcon(android.R.drawable.stat_notify_sync) // Küçük sade bir ikon
            .setPriority(NotificationCompat.PRIORITY_MIN) // 🔥 Çok düşük öncelikli bildirim
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

}

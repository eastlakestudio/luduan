package com.eastlakestudio.luduan.widget

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.glance.appwidget.updateAll
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withTimeoutOrNull

/**
 * 透明 Trampoline Activity：前台执行换词 + 刷新 widget 后立即 finish。
 * 解决 ColorOS 进程冻结导致 actionRunCallback 偶发不生效的问题。
 */
class NextWordTrampolineActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overridePendingTransition(0, 0)
        lifecycleScope.launch(Dispatchers.Main) {
            try {
                kotlinx.coroutines.withContext(Dispatchers.IO) {
                    WordStore.next(applicationContext)
                }
                withTimeoutOrNull(2000) {
                    IdiomWidget().updateAll(applicationContext)
                }
            } catch (_: Exception) {}
            // 立即刷新可能被 launcher 节流丢弃；再排一个 300ms 后的兜底刷新
            scheduleFallbackRefresh(applicationContext, delayMillis = 300)
            finish()
            overridePendingTransition(0, 0)
        }
    }

    companion object {
        private const val ACTION_FALLBACK = "com.eastlakestudio.luduan.WIDGET_FALLBACK_REFRESH"

        internal fun scheduleFallbackRefresh(context: Context, delayMillis: Long) {
            val am = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pi = PendingIntent.getBroadcast(
                context,
                0x77,
                Intent(context, WidgetFallbackRefreshReceiver::class.java).setAction(ACTION_FALLBACK),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            am.setExactAndAllowWhileIdle(AlarmManager.ELAPSED_REALTIME, android.os.SystemClock.elapsedRealtime() + delayMillis, pi)
        }
    }
}

/** 兜底刷新 receiver：错开 launcher 节流窗口后再刷一次 */
class WidgetFallbackRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
            try {
                withTimeoutOrNull(3000) {
                    IdiomWidget().updateAll(context.applicationContext)
                }
            } catch (_: Exception) {}
            // 保险起见再排一次更长延迟的第二兜底（仅当还有一次未消费）
            pending.finish()
        }
    }
}

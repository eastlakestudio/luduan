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
 * 透明 Trampoline Activity：前台执行换词 + 单次刷新。
 * 解决 ColorOS 进程冻结导致 actionRunCallback 偶发不生效的问题。
 *
 * 刷新策略（简化版，避免闪烁）：
 * - 只做一次 updateAll（Glance session 提交即视为成功）
 * - 仅当 updateAll 超时/异常时，排一个 alarm 兜底重试
 * - 正常路径无第二次刷新，消除视觉跳动
 */
class NextWordTrampolineActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overridePendingTransition(0, 0)
        lifecycleScope.launch(Dispatchers.Main) {
            var refreshOk = false
            try {
                kotlinx.coroutines.withContext(Dispatchers.IO) {
                    WordStore.next(applicationContext)
                }
                // 单次刷新；成功提交即完成
                refreshOk = withTimeoutOrNull(2500) {
                    IdiomWidget().updateAll(applicationContext)
                    true
                } ?: false
            } catch (_: Exception) {
                refreshOk = false
            }
            // 仅失败时兜底重试一次（正常路径不触发，避免闪烁）
            if (!refreshOk) {
                scheduleFallbackRefresh(applicationContext, delayMillis = 400)
            }
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

/** 兜底刷新 receiver：仅在主刷新失败时由 alarm 触发一次 */
class WidgetFallbackRefreshReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val pending = goAsync()
        kotlinx.coroutines.CoroutineScope(kotlinx.coroutines.Dispatchers.Main).launch {
            try {
                withTimeoutOrNull(3000) {
                    IdiomWidget().updateAll(context.applicationContext)
                }
            } catch (_: Exception) {}
            pending.finish()
        }
    }
}

package com.eastlakestudio.luduan.widget

import android.os.Bundle
import androidx.activity.ComponentActivity
import com.eastlakestudio.luduan.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import androidx.glance.appwidget.updateAll

/**
 * 透明 Trampoline Activity：前台执行换词 + 刷新 widget 后立即 finish。
 * 解决 ColorOS 进程冻结导致 actionRunCallback 偶发不生效的问题。
 */
class NextWordTrampolineActivity : ComponentActivity() {

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        overridePendingTransition(0, 0) // 无动画
        scope.launch {
            try {
                WordStore.next(applicationContext)
                IdiomWidget().updateAll(applicationContext)
            } catch (_: Exception) {}
            finish()
            overridePendingTransition(0, 0)
        }
    }
}

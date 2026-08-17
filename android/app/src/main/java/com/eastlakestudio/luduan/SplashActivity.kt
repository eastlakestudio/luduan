package com.eastlakestudio.luduan

import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.ui.theme.*

class SplashActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 沉浸式全屏：内容延伸到状态栏/导航栏之下
        WindowCompat.setDecorFitsSystemWindows(window, false)
        val insets = WindowCompat.getInsetsController(window, window.decorView)
        // 隐藏状态栏和导航栏，并设置为深色
        insets.hide(WindowInsetsCompat.Type.systemBars())
        insets.systemBarsBehavior = WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        // 强制状态栏颜色为深色（配合 themes.xml 的窗口背景）
        window.statusBarColor = android.graphics.Color.parseColor("#000000")
        val repo = (application as LuDuanApp).repository
        setContent {
            MaterialTheme(colorScheme = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()) {
                SplashScreen(repo) {
                    startActivity(Intent(this, MainActivity::class.java))
                    finish()
                }
            }
        }
    }
}

@Composable
fun SplashScreen(repo: com.eastlakestudio.luduan.data.GameRepository, onStart: () -> Unit) {
    val phrases by repo.learnedPhrases.collectAsState()
    val count = phrases.size
    val ctx = LocalContext.current
    val isDark = isSystemInDarkTheme()

    val bgName = if (isDark) "text/launch_bg_dark.png" else "text/launch_bg_light.png"
    val bgBmp = remember(ctx, isDark) {
        try { BitmapFactory.decodeStream(ctx.assets.open(bgName)) } catch (e: Exception) { null }
    }

    Box(Modifier.fillMaxSize()) {
        if (bgBmp != null) {
            Image(bgBmp.asImageBitmap(), "launch", Modifier.fillMaxSize(), contentScale = ContentScale.Fit)
        }

        // 已学词数 + 启动按钮（整体下移到屏幕底部，避开品牌文案）
        Column(
            Modifier.align(Alignment.BottomCenter).padding(bottom = 90.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "\u5df2\u5b66 $count \u8bcd",
                color = if (isDark) CinnabarRedDark else CinnabarRed,
                fontSize = 26.sp,
                fontFamily = FontFamily.Serif
            )
            Spacer(Modifier.height(14.dp))
            // 启动按钮（金框 + 文字图片）
            val btnBmp = remember { try { BitmapFactory.decodeStream(ctx.assets.open("text/btn_text.png")) } catch (e: Exception) { null } }
            Box(
                modifier = Modifier
                    .clip(RoundedCornerShape(24.dp))
                    .border(2.dp, if (isDark) CloudGoldDark else CloudGold, RoundedCornerShape(24.dp))
                    .clickable { onStart() }
                    .padding(horizontal = 12.dp, vertical = 8.dp)
            ) {
                if (btnBmp != null) {
                    Image(btnBmp.asImageBitmap(), "start", contentScale = ContentScale.Fit)
                } else {
                    Text(text = "\u5f00\u542f\u7aef\u5b57\u6e38\u4e4b\u65c5 >", color = if (isDark) CloudGoldDark else CloudGold, fontSize = 18.sp, fontFamily = FontFamily.Serif)
                }
            }
        }
    }
}
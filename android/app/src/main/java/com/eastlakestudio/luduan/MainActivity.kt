package com.eastlakestudio.luduan

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.togetherWith
import androidx.compose.ui.Modifier
import androidx.core.view.WindowCompat
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.ui.screens.*
import com.eastlakestudio.luduan.ui.theme.*

// 首页 Activity（SplashActivity 启动后跳转到这里）
class MainActivity : ComponentActivity() {
    sealed class Screen {
        object Dashboard : Screen()
        object BadgeGallery : Screen()
        data class Puzzle(val level: LevelModel) : Screen()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val repo = (application as LuDuanApp).repository
        setContent {
            val dark = isSystemInDarkTheme()
            SideEffect {
                WindowCompat.getInsetsController(window, window.decorView).apply {
                    isAppearanceLightStatusBars = !dark
                    isAppearanceLightNavigationBars = !dark
                }
            }
            MaterialTheme(colorScheme = if (dark) darkColorScheme() else lightColorScheme()) {
                var screen by remember { mutableStateOf<Screen>(Screen.Dashboard) }
                var dashboardTab by remember { mutableStateOf(0) }
                var scrollToIndex by remember { mutableStateOf(-1) }
                Surface(Modifier.fillMaxSize(), color = adaptivePaper()) {
                    when (val current = screen) {
                        is Screen.Dashboard -> DashboardScreen(
                            repo = repo,
                            onLevelClick = { l, cardIdx ->
                                scrollToIndex = cardIdx
                                screen = Screen.Puzzle(l)
                            },
                            onBadgeGalleryClick = { screen = Screen.BadgeGallery },
                            initialTab = dashboardTab,
                            onTabChange = { dashboardTab = it },
                            scrollToIndex = scrollToIndex,
                            onScrolled = { scrollToIndex = -1 }
                        )
                        is Screen.BadgeGallery -> BadgeGalleryScreen(repo = repo, onBack = { screen = Screen.Dashboard })
                        is Screen.Puzzle -> PuzzleGameScreen(
                            level = current.level,
                            repo = repo,
                            onBack = { screen = Screen.Dashboard },
                            onNextLevel = { n -> screen = Screen.Puzzle(n) }
                        )
                    }
                }
            }
        }
    }
}
package com.eastlakestudio.luduan

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
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
            MaterialTheme(colorScheme = if (isSystemInDarkTheme()) darkColorScheme() else lightColorScheme()) {
                var screen by remember { mutableStateOf<Screen>(Screen.Dashboard) }
                var dashboardTab by remember { mutableStateOf(0) }
                Surface(Modifier.fillMaxSize(), color = adaptivePaper()) {
                    val current = screen
                    when (current) {
                        is Screen.Dashboard -> DashboardScreen(repo, { l -> screen = Screen.Puzzle(l) }, { screen = Screen.BadgeGallery }, dashboardTab, { dashboardTab = it })
                        is Screen.BadgeGallery -> BadgeGalleryScreen(repo) { screen = Screen.Dashboard }
                        is Screen.Puzzle -> PuzzleGameScreen(current.level, repo, { screen = Screen.Dashboard }, { n -> screen = Screen.Puzzle(n) })
                    }
                }
            }
        }
    }
}
package com.eastlakestudio.luduan

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.ui.screens.*
import com.eastlakestudio.luduan.ui.theme.*

class MainActivity : ComponentActivity() {

    sealed class Screen {
        object Launch : Screen()
        object Dashboard : Screen()
        object BadgeGallery : Screen()
        data class Puzzle(val level: LevelModel) : Screen()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val repo = (application as LuDuanApp).repository

        setContent {
            val isDark = androidx.compose.foundation.isSystemInDarkTheme()
            MaterialTheme(
                colorScheme = if (isDark) darkColorScheme() else lightColorScheme()
            ) {
                var screen by remember { mutableStateOf<Screen>(Screen.Launch) }

                Surface(modifier = Modifier.fillMaxSize(), color = adaptivePaper()) {
                    AnimatedContent(
                        targetState = screen,
                        transitionSpec = { fadeIn() togetherWith fadeOut() },
                        label = "nav"
                    ) { current ->
                        when (current) {
                            is Screen.Launch -> LaunchScreen(repo) {
                                screen = Screen.Dashboard
                            }
                            is Screen.Dashboard -> DashboardScreen(
                                repo = repo,
                                onLevelClick = { level -> screen = Screen.Puzzle(level) },
                                onBadgeGalleryClick = { screen = Screen.BadgeGallery }
                            )
                            is Screen.BadgeGallery -> BadgeGalleryScreen(
                                repo = repo,
                                onBack = { screen = Screen.Dashboard }
                            )
                            is Screen.Puzzle -> PuzzleGameScreen(
                                level = current.level,
                                repo = repo,
                                onBack = { screen = Screen.Dashboard },
                                onNextLevel = { next -> screen = Screen.Puzzle(next) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun LaunchScreen(repo: GameRepository, onStart: () -> Unit) {
    val learnedCount by repo.learnedPhrases.collectAsState()
    Column(
        modifier = Modifier.fillMaxSize().padding(40.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("lù  duān  zì  yóu", color = adaptiveGold(), fontSize = 16.sp, letterSpacing = 6.sp)
        Spacer(Modifier.height(8.dp))
        Text("《甪端字游》", color = adaptiveCinnabar(), fontSize = 42.sp, fontFamily = FontFamily.Serif)
        Spacer(Modifier.height(4.dp))
        Text("神兽甪端伴学 · 万关典籍古风手游", color = adaptiveXuan(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
        Spacer(Modifier.height(40.dp))
        Text("已学 $learnedCount 词", color = adaptiveCinnabar(), fontSize = 24.sp, fontFamily = FontFamily.Serif)
        Spacer(Modifier.height(32.dp))
        Button(
            onClick = onStart,
            colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())
        ) {
            Text("开启甪端字游之旅 >", color = PaperWhite, fontSize = 18.sp)
        }
    }
}

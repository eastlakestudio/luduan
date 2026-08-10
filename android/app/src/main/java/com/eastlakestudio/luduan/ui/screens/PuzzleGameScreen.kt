package com.eastlakestudio.luduan.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.engine.PuzzleEngine
import com.eastlakestudio.luduan.ui.theme.*
import kotlinx.coroutines.launch

@Composable
fun PuzzleGameScreen(
    level: LevelModel,
    repo: GameRepository,
    onBack: () -> Unit,
    onNextLevel: (LevelModel) -> Unit
) {
    val engine = remember(level) { PuzzleEngine(level) }
    val scope = rememberCoroutineScope()
    val isMultiRow = level.targetPhrase.length > 4

    // 通关状态
    var showStory by remember { mutableStateOf(false) }
    var showMilestone by remember { mutableStateOf(false) }
    var shake by remember { mutableStateOf(false) }

    // 通关监听
    LaunchedEffect(engine.isCompleted) {
        if (engine.isCompleted) {
            repo.completeLevel(level)
            val count = repo.learnedPhrases.value.size
            kotlinx.coroutines.delay(300)
            if (count > 0 && count % 10 == 0) {
                showMilestone = true
            } else {
                showStory = true
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(adaptivePaper())
    ) {
        // 顶栏
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            TextButton(onClick = onBack) {
                Text("← 返回", color = adaptiveXuan(), fontSize = 16.sp)
            }
            Spacer(Modifier.weight(1f))
            Text(
                "${level.title} · ${level.targetPhrase.length} 字",
                color = adaptiveXuan(),
                fontSize = 16.sp,
                fontFamily = FontFamily.Serif
            )
        }

        // 线索卡片
        Card(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = adaptiveCard())
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("线索", color = adaptiveGold(), fontSize = 14.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(4.dp))
                Text(level.annotation, color = adaptiveXuan(), fontSize = 18.sp, fontFamily = FontFamily.Serif, maxLines = 2)
            }
        }

        Spacer(Modifier.weight(1f))

        // 答题槽
        val targetCount = level.targetPhrase.length
        val colCount = if (targetCount == 8) 4 else minOf(targetCount, 5)
        val slotHeight = if (isMultiRow) 58.dp else 72.dp

        LazyVerticalGrid(
            columns = GridCells.Fixed(colCount),
            modifier = Modifier.padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(if (isMultiRow) 6.dp else 8.dp),
            verticalArrangement = Arrangement.spacedBy(if (isMultiRow) 6.dp else 10.dp),
            userScrollEnabled = false
        ) {
            items(targetCount) { idx ->
                val borderColor = if (idx < engine.selectedIndices.size) adaptiveCinnabar() else adaptiveBorder()
                val char = if (idx < engine.selectedIndices.size) engine.tiles[engine.selectedIndices[idx]] else null

                Box(
                    modifier = Modifier
                        .height(slotHeight)
                        .clip(RoundedCornerShape(12.dp))
                        .background(adaptiveCard())
                        .border(2.dp, borderColor, RoundedCornerShape(12.dp))
                        .clickable {
                            if (idx < engine.selectedIndices.size) {
                                engine.unselectTile(at = idx)
                            }
                        },
                    contentAlignment = Alignment.Center
                ) {
                    if (char != null) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text(char, color = adaptiveCinnabar(), fontSize = 28.sp, fontFamily = FontFamily.Serif)
                        }
                    } else {
                        Box(
                            modifier = Modifier
                                .width(28.dp)
                                .height(3.dp)
                                .background(Color.Gray.copy(alpha = 0.25f))
                                .clip(RoundedCornerShape(1.5.dp))
                        )
                    }
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // 字块矩阵 (4列)
        LazyVerticalGrid(
            columns = GridCells.Fixed(4),
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            userScrollEnabled = false
        ) {
            items(engine.tiles.size) { tileIndex ->
                val isSelected = tileIndex in engine.selectedIndices
                val tileHeight = if (isMultiRow) 44.dp else 56.dp

                Box(
                    modifier = Modifier
                        .height(tileHeight)
                        .clip(RoundedCornerShape(12.dp))
                        .background(if (isSelected) adaptiveCinnabar().copy(alpha = 0.1f) else adaptiveCard())
                        .border(
                            width = if (isSelected) 2.dp else 1.dp,
                            color = if (isSelected) adaptiveCinnabar() else adaptiveBorder(),
                            shape = RoundedCornerShape(12.dp)
                        )
                        .clickable {
                            engine.selectTile(at = tileIndex)
                        },
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        engine.tiles[tileIndex],
                        color = if (isSelected) adaptiveCinnabar() else adaptiveXuan(),
                        fontSize = 24.sp,
                        fontFamily = FontFamily.Serif
                    )
                }
            }
        }

        Spacer(Modifier.height(12.dp))

        // 底部操作栏
        Row(
            modifier = Modifier.fillMaxWidth().padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // 重置
            OutlinedButton(
                onClick = { engine.clearInput() },
                modifier = Modifier.weight(1f)
            ) {
                Text("重置", color = Color.Gray, fontSize = 14.sp)
            }
            // 完成
            Button(
                onClick = { engine.checkAnswer() },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())
            ) {
                Text("完成拼字", color = PaperWhite, fontSize = 14.sp)
            }
        }

        // 错误抖动
        if (engine.lastCheckState == PuzzleEngine.CheckState.INCORRECT) {
            LaunchedEffect(Unit) {
                shake = true
                kotlinx.coroutines.delay(400)
                shake = false
            }
        }
    }

    // 通关故事卡
    if (showStory) {
        StoryDialog(
            level = level,
            onDismiss = { showStory = false },
            onNextLevel = {
                showStory = false
                repo.nextLevel(after = level)?.let { onNextLevel(it) }
            }
        )
    }

    // 里程碑庆祝 (每10关)
    if (showMilestone) {
        MilestoneDialog(
            learnedCount = repo.learnedPhrases.value.size,
            lastLevel = level,
            onDismiss = { showMilestone = false },
            onNextLevel = {
                showMilestone = false
                repo.nextLevel(after = level)?.let { onNextLevel(it) }
            }
        )
    }
}

@Composable
private fun StoryDialog(
    level: LevelModel,
    onDismiss: () -> Unit,
    onNextLevel: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("「${level.targetPhrase}」出自《${level.source}》", color = adaptiveCinnabar(), fontFamily = FontFamily.Serif) },
        text = {
            Column {
                Text(level.annotation, color = adaptiveXuan(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(12.dp))
                Text(level.story, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(8.dp))
                Text("—— 出处：${level.source}", color = Color.Gray, fontSize = 13.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
            }
        },
        confirmButton = {
            TextButton(onClick = onNextLevel) {
                Text("进入下一关 >", color = adaptiveCinnabar(), fontSize = 16.sp)
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("关闭", color = Color.Gray)
            }
        },
        containerColor = adaptivePaper()
    )
}

@Composable
private fun MilestoneDialog(
    learnedCount: Int,
    lastLevel: LevelModel,
    onDismiss: () -> Unit,
    onNextLevel: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text("《甪端字游》", color = adaptiveCinnabar(), fontSize = 22.sp, fontFamily = FontFamily.Serif)
        },
        text = {
            Column {
                Text("神兽甪端伴学 · 万关典籍古风手游", color = Color.Gray, fontSize = 12.sp)
                Spacer(Modifier.height(4.dp))
                Text(""通解百家语言，专守千古书案"", color = adaptiveGold(), fontSize = 11.sp)
                Spacer(Modifier.height(12.dp))
                if (lastLevel.story.isNotEmpty()) {
                    Text(""${lastLevel.story}"", color = adaptiveXuan(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
                    Spacer(Modifier.height(6.dp))
                    Text("—— 出处：${lastLevel.source}", color = adaptiveCinnabar(), fontSize = 12.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
                }
            }
        },
        confirmButton = {
            TextButton(onClick = onNextLevel) {
                Text("继续勇闯下一关 >", color = adaptiveCinnabar())
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("关闭", color = Color.Gray)
            }
        },
        containerColor = adaptivePaper()
    )
}

package com.eastlakestudio.luduan.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import com.eastlakestudio.luduan.ui.components.LuText
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.engine.PuzzleEngine
import com.eastlakestudio.luduan.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun PuzzleGameScreen(level: LevelModel, repo: GameRepository, onBack: () -> Unit, onNextLevel: (LevelModel) -> Unit) {
    val engine = remember(level) { PuzzleEngine(level) }
    val scope = rememberCoroutineScope()
    val multi = level.targetPhrase.length > 4
    var showStory by remember { mutableStateOf(false) }
    var showMs by remember { mutableStateOf(false) }
    var showHint by remember { mutableStateOf(false) }
    var shake by remember { mutableFloatStateOf(0f) }

    LaunchedEffect(engine.isCompleted) {
        if (engine.isCompleted) {
            repo.completeLevel(level); val c = repo.learnedPhrases.value.size; delay(400)
            if (c > 0 && c % 10 == 0) showMs = true else showStory = true
        }
    }
    LaunchedEffect(engine.lastCheckState) {
        if (engine.lastCheckState == PuzzleEngine.CheckState.INCORRECT) {
            scope.launch { for (i in 0..3) { shake = if (i % 2 == 0) -10f else 10f; delay(50) }; shake = 0f }
        }
    }

    Column(Modifier.fillMaxSize().background(adaptivePaper())) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onBack) { Text("\u2190", color = adaptiveXuan(), fontSize = 20.sp) }
            Spacer(Modifier.width(8.dp))
            Text(level.categoryName.ifEmpty { level.title }, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif, modifier = Modifier.weight(1f))
            TextButton({ showHint = true }) { Text("\u2728", fontSize = 16.sp) }
        }
        Card(Modifier.fillMaxWidth().padding(horizontal = 16.dp), shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(adaptiveCard())) {
            Column(Modifier.padding(16.dp)) {
                Text("\u7ebf\u7d22", color = adaptiveGold(), fontSize = 14.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(4.dp))
                Text(level.annotation, color = adaptiveXuan(), fontSize = 18.sp, fontFamily = FontFamily.Serif, maxLines = 2)
            }
        }
        Spacer(Modifier.weight(1f))
        if (engine.hintStage > 0) {
            LuText("甪\u7aef\u6307\u5f15\uff1a\u5df2\u9501\u5b9a ${engine.hintStage} \u4e2a\u6b63\u786e\u5b57\uff01", color = adaptiveXuan(), fontSize = 13.sp, modifier = Modifier.padding(horizontal = 16.dp))
            Spacer(Modifier.height(4.dp))
        }
        val tc = level.targetPhrase.length; val cc = if (tc == 8) 4 else minOf(tc, 5); val sh = if (multi) 58.dp else 72.dp
        LazyVerticalGrid(GridCells.Fixed(cc), Modifier.padding(horizontal = 16.dp).offset(x = shake.dp), horizontalArrangement = Arrangement.spacedBy(if (multi) 6.dp else 8.dp), verticalArrangement = Arrangement.spacedBy(if (multi) 6.dp else 10.dp), userScrollEnabled = false) {
            items(tc) { idx ->
                val sel = idx < engine.selectedIndices.size; val ch = if (sel) engine.tiles[engine.selectedIndices[idx]] else null
                Box(Modifier.height(sh).clip(RoundedCornerShape(12.dp)).background(adaptiveCard()).border(2.dp, if (sel) adaptiveCinnabar() else adaptiveBorder(), RoundedCornerShape(12.dp)).clickable { if (sel) engine.unselectTile(idx) }, Alignment.Center) {
                    if (ch != null) Text(text = ch, color = adaptiveCinnabar(), fontSize = 28.sp, fontFamily = FontFamily.Serif)
                    else Box(Modifier.width(28.dp).height(3.dp).background(Color.Gray.copy(alpha = 0.25f)).clip(RoundedCornerShape(1.5.dp)))
                }
            }
        }
        Spacer(Modifier.height(16.dp))
        LazyVerticalGrid(GridCells.Fixed(4), Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(12.dp), verticalArrangement = Arrangement.spacedBy(12.dp), userScrollEnabled = false) {
            items(engine.tiles.size) { ti ->
                val sel = ti in engine.selectedIndices; val hl = engine.highlightedTileIndex == ti; val th = if (multi) 44.dp else 56.dp
                val bc = when { sel -> adaptiveCinnabar(); hl -> adaptiveGold(); else -> adaptiveBorder() }
                Box(Modifier.height(th).clip(RoundedCornerShape(12.dp)).background(if (sel) adaptiveCinnabar().copy(alpha = 0.1f) else adaptiveCard()).border(if (hl) 3.dp else if (sel) 2.dp else 1.dp, bc, RoundedCornerShape(12.dp)).clickable(enabled = !sel) { engine.selectTile(ti) }, Alignment.Center) {
                    Text(text = engine.tiles[ti], color = if (sel) adaptiveCinnabar() else adaptiveXuan(), fontSize = 24.sp, fontFamily = FontFamily.Serif)
                }
            }
        }
        Spacer(Modifier.height(12.dp))
        Row(Modifier.fillMaxWidth().padding(16.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton({ engine.clearInput() }, Modifier.weight(1f)) { Text(text = "\u91cd\u7f6e", color = Color.Gray, fontSize = 14.sp) }
            Button({ engine.checkAnswer() }, Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())) { Text(text = "\u5b8c\u6210\u62fc\u5b57", color = PaperWhite, fontSize = 14.sp) }
        }
    }

    if (showStory) AlertDialog({ showStory = false }, title = { Text("\u300c${level.targetPhrase}\u300d\u51fa\u81ea\u300a${level.source}\u300b", color = adaptiveCinnabar(), fontFamily = FontFamily.Serif) },
        text = { Column(Modifier.verticalScroll(rememberScrollState())) {
            Text("\u5df2\u901a\u8fc7 ${repo.learnedPhrases.value.size} \u8bcd", color = adaptiveCinnabar(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
            Spacer(Modifier.height(8.dp))
            Text(level.annotation, color = adaptiveXuan(), fontSize = 16.sp, fontFamily = FontFamily.Serif); Spacer(Modifier.height(12.dp)); Text(level.story, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif) } },
        confirmButton = { TextButton({ showStory = false; repo.nextLevel(level)?.let(onNextLevel) }) { Text("\u8fdb\u5165\u4e0b\u4e00\u5173 >", color = adaptiveCinnabar()) } },
        dismissButton = { TextButton({ showStory = false }) { Text(text = "\u5173\u95ed", color = Color.Gray) } }, containerColor = adaptivePaper())

    if (showMs) AlertDialog({ showMs = false }, title = { LuText("甪\u7aef\u5b57\u6e38", color = adaptiveCinnabar(), fontSize = 22.sp, fontFamily = FontFamily.Serif) },
        text = { Column { LuText("\u795e\u517d甪\u7aef\u4f34\u5b66 \u00b7 \u4e07\u5173\u5178\u7c4d\u53e4\u98ce\u624b\u6e38", color = Color.Gray, fontSize = 12.sp); if (level.story.isNotEmpty()) { Spacer(Modifier.height(12.dp)); Text("\u201c${level.story}\u201d", color = adaptiveXuan(), fontSize = 16.sp, fontFamily = FontFamily.Serif) } } },
        confirmButton = { TextButton({ showMs = false; repo.nextLevel(level)?.let(onNextLevel) }) { Text("\u7ee7\u7eed\u52c7\u95ef\u4e0b\u4e00\u5173 >", color = adaptiveCinnabar()) } },
        dismissButton = { TextButton({ showMs = false }) { Text(text = "\u5173\u95ed", color = Color.Gray) } }, containerColor = adaptivePaper())

    if (showHint) {
        val bt = when (engine.hintStage) { 0 -> "\u63d0\u793a 1 \u4e2a\u6b63\u786e\u5b57\u5757"; 1 -> "\u63d0\u793a 2 \u4e2a\u6b63\u786e\u5b57\u5757"; else -> "\u89e3\u9501\u5168\u90e8\u6b63\u786e\u5b57\u901a\u5173" }
        AlertDialog({ showHint = false }, title = { LuText("甪\u7aef\u7075\u611f", color = adaptiveCinnabar(), fontFamily = FontFamily.Serif) },
            text = { Column(Modifier.verticalScroll(rememberScrollState())) { Text("\u5178\u7c4d\u51fa\u5904\uff1a${level.source}", color = adaptiveGold(), fontSize = 15.sp, fontFamily = FontFamily.Serif); Spacer(Modifier.height(12.dp)); Text(level.story, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif) } },
            confirmButton = { if (engine.hintStage < 3) TextButton({ engine.provideHintProgressive() }) { Text(bt, color = adaptiveCinnabar()) } else TextButton({ showHint = false }) { Text("\u5b8c\u6210", color = adaptiveCinnabar()) } },
            dismissButton = { TextButton({ showHint = false }) { Text(text = "\u5173\u95ed", color = Color.Gray) } }, containerColor = adaptivePaper())
    }
}

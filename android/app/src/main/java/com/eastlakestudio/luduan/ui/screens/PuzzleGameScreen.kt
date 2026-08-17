package com.eastlakestudio.luduan.ui.screens

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.BitmapFactory
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.BadgeModel
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.components.LuText
import com.eastlakestudio.luduan.ui.components.ShareHelper
import com.eastlakestudio.luduan.ui.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun PuzzleGameScreen(level: com.eastlakestudio.luduan.data.models.LevelModel, repo: GameRepository, onBack: () -> Unit, onNextLevel: (com.eastlakestudio.luduan.data.models.LevelModel) -> Unit) {
    var currentLevel by remember { mutableStateOf(level) }
    val engine = remember(currentLevel) { com.eastlakestudio.luduan.engine.PuzzleEngine(currentLevel) }
    val scope = rememberCoroutineScope()
    val ctx = LocalContext.current
    val multi = currentLevel.targetPhrase.length > 4
    var showStory by remember { mutableStateOf(false) }
    var showMs by remember { mutableStateOf(false) }
    var showHint by remember { mutableStateOf(false) }
    var newlyUnlockedBadge by remember { mutableStateOf<BadgeModel?>(null) }
    var showVictoryShare by remember { mutableStateOf(false) }
    var shake by remember { mutableFloatStateOf(0f) }
    val phrases by repo.learnedPhrases.collectAsState()
    val learnedCount = phrases.size

    LaunchedEffect(engine.isCompleted) {
        if (engine.isCompleted) {
            val unlockedBid = repo.completeLevel(currentLevel)
            val c = repo.learnedPhrases.value.size
            delay(400)
            if (unlockedBid != null) {
                newlyUnlockedBadge = repo.badges.firstOrNull { it.id == unlockedBid }
            }
            if (c > 0 && c % 10 == 0) showVictoryShare = true
            else showStory = true
        }
    }
    LaunchedEffect(engine.lastCheckState) {
        if (engine.lastCheckState == com.eastlakestudio.luduan.engine.PuzzleEngine.CheckState.INCORRECT) {
            scope.launch { for (i in 0..3) { shake = if (i % 2 == 0) -10f else 10f; delay(50) }; shake = 0f }
        }
    }

    Column(Modifier.fillMaxSize().background(adaptivePaper())) {
        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onBack) { Text("\u2190", color = adaptiveXuan(), fontSize = 20.sp) }
            Spacer(Modifier.width(8.dp))
            Text(currentLevel.categoryName.ifEmpty { currentLevel.title }, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif, modifier = Modifier.weight(1f))
            Text("\u5df2\u5b66 $learnedCount \u8bcd", color = adaptiveCinnabar(), fontSize = 13.sp, fontFamily = FontFamily.Serif)
            Spacer(Modifier.width(8.dp))
            TextButton({ showHint = true }) { Text("\u2728", fontSize = 16.sp) }
        }
        Card(Modifier.fillMaxWidth().padding(horizontal = 16.dp), shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(adaptiveCard())) {
            Column(Modifier.padding(16.dp)) {
                Text("\u91ca\u4e49", color = adaptiveGold(), fontSize = 14.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(4.dp))
                Text(currentLevel.annotation, color = adaptiveXuan(), fontSize = 18.sp, fontFamily = FontFamily.Serif, maxLines = 2)
            }
        }
        Spacer(Modifier.weight(1f))
        if (engine.hintStage > 0) {
            LuText("\u752a\u7aef\u6307\u5f15\uff1a\u5df2\u9501\u5b9a ${engine.hintStage} \u4e2a\u6b63\u786e\u5b57\uff01", color = adaptiveXuan(), fontSize = 13.sp, modifier = Modifier.padding(horizontal = 16.dp))
            Spacer(Modifier.height(4.dp))
        }
        val tc = currentLevel.targetPhrase.length; val cc = if (tc == 8) 4 else minOf(tc, 5); val sh = if (multi) 58.dp else 72.dp
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

    // 通关弹窗
    if (showStory) FullScreenStory(currentLevel, learnedCount, { showStory = false; repo.nextLevel(currentLevel)?.let { currentLevel = it } }, { showStory = false; repo.nextLevel(currentLevel)?.let { currentLevel = it } })

    // 每10词里程碑 → 直接弹出分享页

    // 勋章解锁 → 直接弹出勋章分享页（徽章图 + 随机原文 + 二维码）
    if (newlyUnlockedBadge != null) {
        val badge = newlyUnlockedBadge!!
        // 从该勋章词池随机选一条已完成词的原文
        val randomWord = remember(badge.id) {
            val range = repo.badgeRanges[badge.id]
            val words = repo.allWordsPublic().filter { it.phrase in (range?.uniquePhrases ?: emptySet()) }
            val learned = words.filter { it.phrase in repo.learnedPhrases.value }
            (if (learned.isNotEmpty()) learned else words).randomOrNull()
        }
        BadgeShareDialog(
            badgeName = badge.name,
            badgeImageName = badge.imageName,
            badgeSealText = badge.sealText,
            badgeDescription = badge.description,
            phrase = randomWord?.phrase ?: "",
            source = randomWord?.source ?: currentLevel.source,
            story = randomWord?.story ?: "",
            onDismiss = { newlyUnlockedBadge = null }
        )
    }

    if (showHint) {
        val bt = when (engine.hintStage) { 0 -> "\u63d0\u793a 1 \u4e2a\u6b63\u786e\u5b57\u5757"; 1 -> "\u63d0\u793a 2 \u4e2a\u6b63\u786e\u5b57\u5757"; else -> "\u89e3\u9501\u5168\u90e8\u6b63\u786e\u5b57\u901a\u5173" }
        AlertDialog({ showHint = false }, title = { LuText("\u752a\u7aef\u7075\u611f", color = adaptiveCinnabar(), fontFamily = FontFamily.Serif) },
            text = { Column(Modifier.verticalScroll(rememberScrollState())) { Text("\u5178\u7c4d\u51fa\u5904\uff1a${currentLevel.source}", color = adaptiveGold(), fontSize = 15.sp, fontFamily = FontFamily.Serif); Spacer(Modifier.height(12.dp)); Text(currentLevel.story, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif) } },
            confirmButton = { if (engine.hintStage < 3) TextButton({ engine.provideHintProgressive(); if (engine.hintStage >= 3) showHint = false }) { Text(bt, color = adaptiveCinnabar()) } else TextButton({ showHint = false }) { Text("\u5b8c\u6210", color = adaptiveCinnabar()) } },
            dismissButton = { TextButton({ showHint = false }) { Text(text = "\u5173\u95ed", color = Color.Gray) } }, containerColor = adaptivePaper())
    }

    if (showVictoryShare) {
        VictoryShareDialog(
            learnedCount = learnedCount,
            source = currentLevel.source,
            story = currentLevel.story,
            onDismiss = {
                showVictoryShare = false
                repo.nextLevel(currentLevel)?.let { currentLevel = it }
            }
        )
    }
}

@Composable
private fun FullScreenStory(level: com.eastlakestudio.luduan.data.models.LevelModel, learnedCount: Int, onDismiss: () -> Unit, onNext: () -> Unit) {
    Dialog(onDismissRequest = onDismiss) {
        Surface(Modifier.fillMaxSize(), color = adaptivePaper()) {
            Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(24.dp)) {
                Text(level.source, color = adaptiveCinnabar(), fontSize = 22.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(8.dp)); Text("\u5df2\u901a\u8fc7 $learnedCount \u8bcd", color = adaptiveGold(), fontSize = 14.sp)
                Spacer(Modifier.height(20.dp)); Divider(color = adaptiveBorder()); Spacer(Modifier.height(20.dp))
                Text("\u3010\u53e4\u6587\u539f\u6587\u3011", color = adaptiveGold(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(8.dp)); Text(level.story, color = adaptiveXuan(), fontSize = 18.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(8.dp)); Text("\u2014\u2014 \u51fa\u5904\uff1a${level.source}", color = Color.Gray, fontSize = 13.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
                Spacer(Modifier.height(20.dp)); Divider(color = adaptiveBorder()); Spacer(Modifier.height(20.dp))
                Text("\u3010\u5b57\u8bcd\u91ca\u4e49\u3011", color = adaptiveBamboo(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.height(8.dp)); Text(level.annotation, color = adaptiveXuan(), fontSize = 17.sp, fontFamily = FontFamily.Serif)
                Spacer(Modifier.weight(1f))
                Row(Modifier.fillMaxWidth().padding(top = 24.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    TextButton(onDismiss, Modifier.weight(1f)) { Text("\u5173\u95ed", color = Color.Gray, fontSize = 16.sp) }
                    Button(onNext, Modifier.weight(1f), colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())) { Text("\u4e0b\u4e00\u5173 >", color = PaperWhite, fontSize = 16.sp) }
                }
            }
        }
    }
}

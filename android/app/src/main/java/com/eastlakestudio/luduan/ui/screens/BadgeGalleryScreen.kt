package com.eastlakestudio.luduan.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.BadgeCategory
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BadgeGalleryScreen(repo: GameRepository, onBack: () -> Unit) {
    val uc = repo.unlockedBadges.value.size; val tc = repo.badges.size
    var sel by remember { mutableStateOf(BadgeCategory.ACADEMIC) }
    var selectedBadge by remember { mutableStateOf<com.eastlakestudio.luduan.data.models.BadgeModel?>(null) }
    val filtered = remember(sel) { sel?.let { c -> repo.badges.filter { BadgeCategory.from(it.category) == c } } ?: repo.badges }
    Column(Modifier.fillMaxSize().background(adaptivePaper())) {
        Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onBack) { Text("\u2190 \u8fd4\u56de", color = adaptiveXuan(), fontSize = 16.sp) }
            Spacer(Modifier.weight(1f))
            Text("\u52cb\u7ae0\u9986", color = adaptiveCinnabar(), fontSize = 20.sp, fontFamily = FontFamily.Serif)
            Spacer(Modifier.weight(1f))
            Text("$uc / $tc", color = adaptiveCinnabar(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
        }
        // 去掉"全部"与"处世修养"，只保留 学阶功名 / 典籍名篇 / 人物名将
        val cats = listOf(BadgeCategory.ACADEMIC, BadgeCategory.CLASSICS, BadgeCategory.CHARACTER)
        LazyRow(Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            items(cats.size) { i -> FilterChip(sel == cats[i], { sel = cats[i] }, { Text(cats[i].rawValue) }) }
        }
        Spacer(Modifier.height(12.dp))
        LazyVerticalGrid(GridCells.Adaptive(100.dp), Modifier.fillMaxSize().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp), contentPadding = PaddingValues(bottom = 24.dp)) {
            items(filtered.size) { i ->
                val b = filtered[i]; val un = repo.isBadgeUnlocked(b.id)
                val (completed, total) = repo.badgeProgress(b.id)
                Column(Modifier.padding(4.dp).clickable { selectedBadge = b }, horizontalAlignment = Alignment.CenterHorizontally) {
                    BadgeImageView(LocalContext.current, b.imageName, b.sealText, un, 72)
                    Spacer(Modifier.height(4.dp))
                    Text(text = b.name, color = if (un) adaptiveXuan() else Color.Gray, fontSize = 11.sp, fontFamily = FontFamily.Serif, maxLines = 1, overflow = TextOverflow.Ellipsis, textAlign = TextAlign.Center)
                    if (total > 0) {
                        Text(text = "$completed/$total", color = if (un) adaptiveGold() else Color.Gray.copy(alpha = 0.5f), fontSize = 10.sp)
                    }
                }
            }
        }
    }

    // 4: 勋章详情弹窗（代表原文 + 进度）
    if (selectedBadge != null) {
        val b = selectedBadge!!
        val un = repo.isBadgeUnlocked(b.id)
        val (completed, total) = repo.badgeProgress(b.id)
        Dialog({ selectedBadge = null }) {
            Surface(Modifier.fillMaxWidth().fillMaxHeight(0.7f), color = adaptivePaper(), shape = RoundedCornerShape(16.dp)) {
                Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        BadgeImageView(LocalContext.current, b.imageName, b.sealText, un, 64)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(b.name, color = adaptiveCinnabar(), fontSize = 18.sp, fontFamily = FontFamily.Serif)
                            Text(if (un) "\u5df2\u89e3\u9501" else "\u672a\u89e3\u9501", color = if (un) adaptiveGold() else Color.Gray, fontSize = 13.sp)
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    Text("\u8fdb\u5ea6\uff1a$completed / $total \u8bcd", color = adaptiveCinnabar(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                    Spacer(Modifier.height(8.dp))
                    Text(b.description, color = adaptiveXuan(), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                    Spacer(Modifier.height(16.dp))
                    Text("\u3010\u89e3\u9501\u65b9\u5f0f\u3011", color = adaptiveGold(), fontSize = 13.sp, fontFamily = FontFamily.Serif)
                    Text(b.requirementDescription, color = adaptiveXuan(), fontSize = 14.sp)
                    Spacer(Modifier.height(16.dp))
                    Text("\u3010\u4ee3\u8868\u8bcd\u53e5\u3011", color = adaptiveGold(), fontSize = 13.sp, fontFamily = FontFamily.Serif)
                    // 代表词句 + 原文（词池中已学的优先，否则第一条）
                    val repWord = remember(b.id) {
                        val range = repo.badgeRanges[b.id]
                        val pool = repo.allWordsPublic().filter { it.phrase in (range?.uniquePhrases ?: emptySet()) }
                        val learned = pool.filter { it.phrase in repo.learnedPhrases.value }
                        (learned.ifEmpty { pool }).firstOrNull()
                    }
                    if (repWord != null) {
                        Text("\u3010${repWord.phrase}\u3011", color = Color(0xFF333333), fontSize = 15.sp, fontFamily = FontFamily.Serif)
                        Spacer(Modifier.height(4.dp))
                        Text(repWord.story.take(80) + if (repWord.story.length > 80) "\u2026" else "", color = adaptiveXuan(), fontSize = 13.sp, fontFamily = FontFamily.Serif, lineHeight = 21.sp)
                        Spacer(Modifier.height(4.dp))
                        Text(repWord.source, color = Color.Gray, fontSize = 11.sp, textAlign = TextAlign.End, modifier = Modifier.fillMaxWidth())
                    }
                    Spacer(Modifier.height(16.dp))
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                        TextButton({ selectedBadge = null }) { Text("\u5173\u95ed", color = Color.Gray) }
                    }
                }
            }
        }
    }
}

package com.eastlakestudio.luduan.ui.screens

import android.graphics.BitmapFactory
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.BadgeCategory
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.engine.LevelEngine
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(
    repo: GameRepository,
    onLevelClick: (LevelModel, Int) -> Unit,
    onBadgeGalleryClick: () -> Unit,
    initialTab: Int = 0,
    onTabChange: (Int) -> Unit = {},
    scrollToIndex: Int = -1,
    onScrolled: () -> Unit = {}
) {
    val phrases by repo.learnedPhrases.collectAsState()
    val learnedCount = phrases.size
    var sel by remember { mutableStateOf(initialTab) }
    val tabs = listOf("\u5b66\u9636\u529f\u540d", "\u5178\u7c4d\u540d\u7bc7", "\u5904\u4e16\u4fee\u517b")
    val cats = listOf(BadgeCategory.ACADEMIC, BadgeCategory.CLASSICS, BadgeCategory.PRACTICAL)

    Column(Modifier.fillMaxSize().background(adaptivePaper())) {
        Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                val dashCtx = LocalContext.current
                val titleBmp = remember(dashCtx) { try { BitmapFactory.decodeStream(dashCtx.assets.open("text/title_header.png")) } catch (e: Exception) { null } }
                if (titleBmp != null) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(titleBmp.asImageBitmap(), "title", Modifier.widthIn(max = 130.dp), contentScale = ContentScale.Fit)
                        Spacer(Modifier.width(6.dp))
                        Text("\u6587\u7EC9\u7EC9-", color = adaptiveBamboo(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
                    }
                }
                Text("\u5df2\u5b66 $learnedCount \u8bcd", color = adaptiveXuan(), fontSize = 14.sp)
            }
            TextButton(onBadgeGalleryClick) { Text("\u52cb\u7ae0\u9986", color = adaptiveCinnabar(), fontSize = 14.sp) }
        }
        Row(Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            tabs.forEachIndexed { i, t -> FilterChip(sel == i, { sel = i; onTabChange(i) }, { Text(t, fontSize = 13.sp) }) }
        }
        Spacer(Modifier.height(8.dp))
        val cb = remember(sel) { repo.badges.filter { BadgeCategory.from(it.category) == cats[sel] } }
        val per = maxOf(1, LevelEngine.TOTAL_LEVELS / maxOf(1, cb.size))
        val listState = rememberLazyListState()
        LaunchedEffect(scrollToIndex) {
            if (scrollToIndex >= 0 && scrollToIndex < cb.size) { listState.scrollToItem(scrollToIndex); onScrolled() }
        }
        LazyColumn(state = listState, modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(12.dp), contentPadding = PaddingValues(bottom = 24.dp)) {
            items(cb.size) { idx ->
                val b = cb[idx]; val st = idx * per
                val (completed, total) = repo.badgeProgress(b.id)
                val isDone = completed >= total && total > 0
                Card(Modifier.fillMaxWidth().clickable {
                    val lvl = repo.levelForBadge(b.id)
                    if (lvl != null) onLevelClick(lvl, idx)
                }, shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(
                        // 5: 全部完成用金色底色
                        containerColor = if (isDone) adaptiveGold().copy(alpha = 0.2f) else adaptiveCard()
                    ),
                    border = androidx.compose.foundation.BorderStroke(
                        if (isDone) 2.dp else 1.dp,
                        if (isDone) adaptiveGold() else adaptiveBorder()
                    )
                ) {
                    Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        BadgeImageView(LocalContext.current, b.imageName, b.sealText, true, 56)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(b.name, color = adaptiveCinnabar(), fontSize = 16.sp, fontFamily = FontFamily.Serif, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Spacer(Modifier.height(4.dp))
                            // 5: 显示已完成/总数
                            val pct = if (total > 0) "${completed}/${total} \u8bcd" else ""
                            val statusText = if (isDone) "\u2713 $pct \u5b8c\u6210" else pct
                            Text(statusText, color = if (isDone) adaptiveGold() else adaptiveXuan(), fontSize = 13.sp, fontFamily = FontFamily.Serif)
                            if (total > 0 && !isDone) {
                                Spacer(Modifier.height(6.dp))
                                LinearProgressIndicator(
                                    progress = completed.toFloat() / total,
                                    modifier = Modifier.fillMaxWidth(),
                                    color = adaptiveCinnabar()
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

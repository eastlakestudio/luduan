package com.eastlakestudio.luduan.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.BadgeCategory
import com.eastlakestudio.luduan.data.models.BadgeModel
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.engine.LevelEngine
import com.eastlakestudio.luduan.ui.theme.*

@Composable
fun DashboardScreen(
    repo: GameRepository,
    onLevelClick: (LevelModel) -> Unit,
    onBadgeGalleryClick: () -> Unit
) {
    val learnedCount by repo.learnedPhrases.collectAsState()
    var selectedCategory by remember { mutableStateOf(0) }
    val tabs = listOf("学阶功名", "典籍名篇", "处世修养")
    val cats = listOf(BadgeCategory.ACADEMIC, BadgeCategory.CLASSICS, BadgeCategory.PRACTICAL)

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
            Column(modifier = Modifier.weight(1f)) {
                Text("《甪端字游》", color = adaptiveCinnabar(), fontSize = 20.sp, fontFamily = FontFamily.Serif)
                Text("已学 $learnedCount 词", color = adaptiveXuan(), fontSize = 14.sp)
            }
            TextButton(onClick = onBadgeGalleryClick) {
                Text("勋章馆", color = adaptiveCinnabar(), fontSize = 14.sp)
            }
        }

        // 分类 Tab
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            tabs.forEachIndexed { i, title ->
                FilterChip(
                    selected = selectedCategory == i,
                    onClick = { selectedCategory = i },
                    label = { Text(title, fontSize = 13.sp) },
                    colors = FilterChipDefaults.filterChipColors(
                        selectedContainerColor = adaptiveCinnabar(),
                        selectedLabelColor = PaperWhite
                    )
                )
            }
        }

        Spacer(Modifier.height(8.dp))

        // 卡片列表（从 badges.json 取）
        val catBadges = remember(selectedCategory) {
            val cat = cats[selectedCategory]
            repo.badges.filter { BadgeCategory.from(it.category) == cat }
        }
        val perBadge = maxOf(1, LevelEngine.TOTAL_LEVELS / maxOf(1, catBadges.size))

        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(catBadges) { badge ->
                val idx = catBadges.indexOf(badge)
                val start = idx * perBadge
                val count = if (idx == catBadges.size - 1) LevelEngine.TOTAL_LEVELS - start else perBadge
                val completed = (start until start + count).count { repo.isLevelCompleted("level_${it + 1}") }
                BadgeSectionCard(
                    badge = badge,
                    completed = completed,
                    total = count,
                    onClick = {
                        val nextIdx = (start until start + count).firstOrNull { !repo.isLevelCompleted("level_${it + 1}") } ?: start
                        onLevelClick(repo.level(at = nextIdx, categoryName = badge.name))
                    }
                )
            }
        }
    }
}

@Composable
private fun BadgeSectionCard(
    badge: BadgeModel,
    completed: Int,
    total: Int,
    onClick: () -> Unit
) {
    val ratio = if (total > 0) completed.toFloat() / total else 0f
    val isDone = ratio >= 1f

    Card(
        modifier = Modifier.fillMaxWidth().clickable { onClick() },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = adaptiveCard()),
        border = BorderStroke(1.dp, if (isDone) adaptiveGold() else adaptiveBorder())
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // 印章圆
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .clip(RoundedCornerShape(8.dp))
                    .background(if (isDone) adaptiveGold().copy(alpha = 0.2f) else adaptiveBorder().copy(alpha = 0.2f)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    badge.sealText.replace("\n", ""),
                    color = adaptiveCinnabar(),
                    fontSize = 12.sp,
                    fontFamily = FontFamily.Serif,
                    maxLines = 2
                )
            }
            Spacer(Modifier.width(12.dp))
            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        badge.name,
                        color = adaptiveCinnabar(),
                        fontSize = 16.sp,
                        fontFamily = FontFamily.Serif,
                        modifier = Modifier.weight(1f),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Text(
                        "$completed / $total 关",
                        color = Color.Gray,
                        fontSize = 13.sp
                    )
                }
                Spacer(Modifier.height(6.dp))
                LinearProgressIndicator(
                    progress = { ratio },
                    modifier = Modifier.fillMaxWidth(),
                    color = if (isDone) adaptiveGold() else adaptiveCinnabar(),
                    trackColor = adaptiveBorder().copy(alpha = 0.3f)
                )
            }
        }
    }
}

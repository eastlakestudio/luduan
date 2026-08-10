package com.eastlakestudio.luduan.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.lazy.LazyColumn
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
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.theme.*
import androidx.compose.ui.platform.LocalContext

@Composable
fun BadgeGalleryScreen(
    repo: GameRepository,
    onBack: () -> Unit
) {
    val unlockedCount = repo.unlockedBadges.value.size
    val totalCount = repo.badges.size
    var selectedCategory by remember { mutableStateOf<BadgeCategory?>(null) }

    val filtered = remember(selectedCategory) {
        selectedCategory?.let { cat -> repo.badges.filter { BadgeCategory.from(it.category) == cat } }
            ?: repo.badges
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
            Text("勋章馆", color = adaptiveCinnabar(), fontSize = 20.sp, fontFamily = FontFamily.Serif)
            Spacer(Modifier.weight(1f))
            Text("$unlockedCount / $totalCount", color = adaptiveCinnabar(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
        }

        // 分类筛选
        LazyRow(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            item {
                FilterChip(
                    selected = selectedCategory == null,
                    onClick = { selectedCategory = null },
                    label = { Text("全部", fontSize = 13.sp) }
                )
            }
            items(BadgeCategory.entries) { cat ->
                FilterChip(
                    selected = selectedCategory == cat,
                    onClick = { selectedCategory = cat },
                    label = { Text(cat.rawValue, fontSize = 13.sp) }
                )
            }
        }

        Spacer(Modifier.height(12.dp))

        // 勋章网格
        LazyVerticalGrid(
            columns = GridCells.Adaptive(minSize = 100.dp),
            modifier = Modifier.fillMaxSize().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
            contentPadding = PaddingValues(bottom = 24.dp)
        ) {
            items(filtered) { badge ->
                val isUnlocked = repo.isBadgeUnlocked(badge.id)
                BadgeGridItem(badge, isUnlocked)
            }
        }
    }
}

@Composable
private fun BadgeGridItem(badge: com.eastlakestudio.luduan.data.models.BadgeModel, isUnlocked: Boolean) {
    val context = LocalContext.current
    Column(
        modifier = Modifier.padding(4.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        BadgeImageView(
            context = context,
            imageName = badge.imageName,
            sealText = badge.sealText,
            isUnlocked = isUnlocked,
            size = 72
        )
        Spacer(Modifier.height(4.dp))
        Text(
            badge.name,
            color = if (isUnlocked) adaptiveXuan() else Color.Gray,
            fontSize = 11.sp,
            fontFamily = FontFamily.Serif,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center
        )
    }
}

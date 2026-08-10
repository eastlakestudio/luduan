package com.eastlakestudio.luduan.ui.screens

import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.BadgeCategory
import com.eastlakestudio.luduan.ui.components.BadgeImageView
import com.eastlakestudio.luduan.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BadgeGalleryScreen(repo: GameRepository, onBack: () -> Unit) {
    val uc = repo.unlockedBadges.value.size; val tc = repo.badges.size
    var sel by remember { mutableStateOf<BadgeCategory?>(null) }
    val filtered = remember(sel) { sel?.let { c -> repo.badges.filter { BadgeCategory.from(it.category) == c } } ?: repo.badges }
    Column(Modifier.fillMaxSize().background(adaptivePaper())) {
        Row(Modifier.fillMaxWidth().padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            TextButton(onBack) { Text("\u2190 \u8fd4\u56de", color = adaptiveXuan(), fontSize = 16.sp) }
            Spacer(Modifier.weight(1f))
            Text("\u52cb\u7ae0\u9986", color = adaptiveCinnabar(), fontSize = 20.sp, fontFamily = FontFamily.Serif)
            Spacer(Modifier.weight(1f))
            Text("$uc / $tc", color = adaptiveCinnabar(), fontSize = 16.sp, fontFamily = FontFamily.Serif)
        }
        val cats = BadgeCategory.entries.toList()
        LazyRow(Modifier.fillMaxWidth().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            item { FilterChip(sel == null, { sel = null }, { Text("\u5168\u90e8") }) }
            items(cats.size) { i -> FilterChip(sel == cats[i], { sel = cats[i] }, { Text(cats[i].rawValue) }) }
        }
        Spacer(Modifier.height(12.dp))
        LazyVerticalGrid(GridCells.Adaptive(100.dp), Modifier.fillMaxSize().padding(horizontal = 16.dp), horizontalArrangement = Arrangement.spacedBy(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp), contentPadding = PaddingValues(bottom = 24.dp)) {
            items(filtered.size) { i ->
                val b = filtered[i]; val un = repo.isBadgeUnlocked(b.id)
                Column(Modifier.padding(4.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                    BadgeImageView(LocalContext.current, b.imageName, b.sealText, un, 72)
                    Spacer(Modifier.height(4.dp))
                    Text(text = b.name, color = if (un) adaptiveXuan() else Color.Gray, fontSize = 11.sp, fontFamily = FontFamily.Serif, maxLines = 1, overflow = TextOverflow.Ellipsis, textAlign = TextAlign.Center)
                }
            }
        }
    }
}

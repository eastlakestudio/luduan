package com.eastlakestudio.luduan.ui.screens

import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.graphics.asAndroidBitmap
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ImageBitmap
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.layer.GraphicsLayer
import androidx.compose.ui.graphics.rememberGraphicsLayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.eastlakestudio.luduan.data.GameRepository
import com.eastlakestudio.luduan.data.models.LevelModel
import com.eastlakestudio.luduan.ui.components.ShareHelper
import com.eastlakestudio.luduan.ui.theme.*

@Composable
fun MilestoneShareCard(
    learnedCount: Int,
    lastLevel: LevelModel,
    onShare: () -> Unit,
    onContinue: () -> Unit
) {
    val context = LocalContext.current
    val graphicsLayer = rememberGraphicsLayer()

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // 金框卡片（可截图）
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .padding(4.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(adaptivePaper())
                .border(2.dp, adaptiveGold(), RoundedCornerShape(16.dp))
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(16.dp)
                    .verticalScroll(rememberScrollState())
                    .drawWithContent {
                        graphicsLayer.record { this@drawWithContent.drawContent() }
                        drawContent()
                    },
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // 顶部品牌
                Text("《甪端字游》", color = adaptiveCinnabar(), fontSize = 22.sp, fontFamily = FontFamily.Serif)
                Text("神兽甪端伴学 · 万关典籍古风手游", color = Color.Gray, fontSize = 11.sp)
                Text(""通解百家语言，专守千古书案"", color = adaptiveGold(), fontSize = 10.sp)

                HorizontalDivider(color = adaptiveBorder())

                // 古文原文
                if (lastLevel.story.isNotEmpty()) {
                    Text(""${lastLevel.story}"", color = adaptiveXuan(), fontSize = 17.sp, fontFamily = FontFamily.Serif, lineHeight = 24.sp)
                    Text(
                        "—— 出处：${lastLevel.source}",
                        color = adaptiveCinnabar(),
                        fontSize = 12.sp,
                        textAlign = TextAlign.End,
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                HorizontalDivider(color = adaptiveBorder())

                // 下载信息
                Text("《甪端字游》App Store下载", color = adaptiveCinnabar(), fontSize = 13.sp, fontFamily = FontFamily.Serif)
                Text("扫码体验神兽伴学 · 畅游万关国学典籍", color = adaptiveXuan(), fontSize = 11.sp)
            }
        }

        // 按钮组
        Row(
            modifier = Modifier.fillMaxWidth().padding(top = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick = {
                    val bitmap = graphicsLayer.toImageBitmap().asAndroidBitmap()
                    val shareText = "【甪端字游】我已累计通关 $learnedCount 词古风字游！神兽甪端伴学，万关典籍名篇。快来一起体验《甪端字游》！"
                    ShareHelper.shareImageAndText(context, bitmap, shareText)
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = adaptiveCinnabar())
            ) {
                Text("分享捷报", color = PaperWhite, fontSize = 14.sp)
            }
            OutlinedButton(
                onClick = onContinue,
                modifier = Modifier.weight(1f)
            ) {
                Text("继续闯关 >", color = adaptiveCinnabar(), fontSize = 14.sp)
            }
        }
    }
}
